//
//  YelpReview
//
//  DetailView.swift
//

import SwiftUI
import MapKit

struct MyAnnotations: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

struct DetailView: View {
    @State var business_search_data: [Business]
    @State var business_details_data: [BusinessDetail] = [BusinessDetail]()
    @State var business_reviews_data: [Review] = [Review]()
    
    // set to -1 to indicate initial empty view
    @State var details_status: Int = -1
    
    @State var detail_categories: String = ""
    
    @Binding var saved_bookings: [Booking]

    var body: some View {
        // 0 is initial index, as only passing a single element array
        let element = business_search_data[0]
        
        TabView {
            BusinessDetailView(business_details_data: business_details_data, details_status: $details_status, detail_categories: $detail_categories, saved_bookings: $saved_bookings)
                .tabItem {
                    Label("Business Detail", systemImage: "text.bubble.fill")
                }
            MapDetailView(business_search_data: business_search_data,
                          region_lat: business_search_data[0].coordinates.latitude,
                          region_lng: business_search_data[0].coordinates.longitude)
                .tabItem {
                    Label("Map Location", systemImage: "location.fill")
                }
            ReviewDetailView(element_id: element.id)
                .tabItem {
                    Label("Reviews", systemImage: "message.fill")
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            //print(element.id)
            Task {
                do {
                    // Call Details API
                    details_status = 0
                    business_details_data = try await business_details_request(business_id: element.id)
                    
                    if (business_details_data.isEmpty) {
                        details_status = 2
                    }
                    else {
                        var titles = [String]()
                        for category in element.categories {
                            titles.append(category.title)
                        }
                        detail_categories = titles.joined(separator: " | ")
                        
                        details_status = 1
                    }
                    
                    //print("Details: Status: \(details_status)")
                    //dump(business_details_data)
                } catch {
                    print("Error: ", error)
                }
            }
        }
    }
}

struct BusinessDetailView: View {
    let business_details_data: [BusinessDetail]
    
    @Binding var details_status: Int
    @Binding var detail_categories: String
    @Binding var saved_bookings: [Booking]
    
    @State private var showing_sheet = false
    @State private var show_toast: Bool = false

    var body: some View {
        if (details_status == 1)
        {
            // 0 is initial index, as only passing a single element array
            let element = business_details_data[0]
            let photos = business_details_data[0].photos
            
            let facebook_url = "https://www.facebook.com/sharer/sharer.php?u=\(element.url)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let twitter_url = "https://twitter.com/intent/tweet?text=\(element.name) on Yelp: &url=\(element.url)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let detail_address = element.location.displayAddress.joined(separator: ", ")
            
            VStack {
                VStack {
                    Text("\(element.name)")
                        .font(.title)
                        .bold()
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("Address") // TODO
                                .bold()
                            Text("\(detail_address)")
                                .foregroundColor(.gray)
                        }.frame(maxWidth: 180, alignment: .topLeading)

                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Category") // TODO
                                .bold()
                            Text("\(detail_categories)")
                                .foregroundColor(.gray)
                        }.frame(maxWidth: 170, alignment: .topTrailing)
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Phone")
                                .bold()
                            Text("\(element.displayPhone)")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Price Range")
                                .bold()
                            Text("\(element.price ?? "Default")")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Status")
                                .bold()
                            Text(element.isClosed ? "Closed" : "Open Now")
                                .foregroundColor(element.isClosed ? .red : .green)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Visit Yelp for more")
                                .bold()
                            Link("Business Link",
                                 destination: URL(string: element.url) ?? URL(string: "https://www.yelp.com/")!)
                        }
                    }
                    .padding(.top, 5)
                    
                    ZStack {
                        if (saved_bookings.contains(where: { $0.r_id == element.id })) {
                            Button {
                                //print("Cancel Reservation")
                                saved_bookings.removeAll(where: { $0.r_id == element.id })
                                //print("Show Toast")
                                withAnimation {
                                    self.show_toast.toggle()
                                }
                            } label: {
                                Text("Cancel Reservation")
                                    .foregroundColor(Color.white)
                            }
                            .frame(width: 175, height: 50)
                            .background(Color.blue)
                            .cornerRadius(13)
                            .padding()
                        }
                        else {
                            Button {
                                //print("Reserve Now")
                                showing_sheet.toggle()
                            } label: {
                                Text("Reserve Now")
                                    .foregroundColor(Color.white)
                            }
                            .frame(width: 125, height: 50)
                            .background(Color.red)
                            .cornerRadius(13)
                            .padding()
                        }
                    }
                    .sheet(isPresented: $showing_sheet) {
                        ReservationView(business_details_data: business_details_data, saved_bookings: $saved_bookings)
                    }
                    
                    HStack {
                        Text("Share On:")
                        
                        Link(destination: URL(string: facebook_url)!, label: {
                            Image("logo_facebook")
                                .resizable()
                        })
                        .frame(width: 48, height: 48)
                        .scaledToFit()
                        
                        Link(destination: URL(string: twitter_url)!, label: {
                            Image("logo_twitter")
                                .resizable()
                        })
                        .frame(width: 48, height: 48)
                        .scaledToFit()
                    }
                    .padding(.bottom)
                    
                    TabView {
                        ForEach(photos, id: \.self) { photo in
                            AsyncImage(url: URL(string: photo)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 290, height: 200, alignment: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                        .clipped()
                                case .failure(let error):
                                    let _ = print(error)
                                    Text("error: \(error.localizedDescription)")
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                @unknown default:
                                    fatalError()
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(width: 290, height: 200)
                }
                .padding()
                
                Spacer()
            }
            // Cancel Reservation Toast
            .toast(isPresented: self.$show_toast) {
                HStack {
                    Text("Your reservation is cancelled.")
                }
            }
        }
        else {
            ResultLoadingView().id(UUID())
        }
    }
}

struct MapDetailView: View {
    let business_search_data: [Business]
    
    let region_lat: Double
    let region_lng: Double
    let region_zoom: Double = 0.05
    
    var body: some View {
        // 0 is initial index, as only passing a single element array
        let element = business_search_data[0]
        
        // Array for single annotation
        let map_annotations = [
            MyAnnotations(
                name: element.name,
                latitude: element.coordinates.latitude,
                longitude: element.coordinates.longitude
            )
        ]
       
        VStack {
            Map(
                coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: region_lat,
                            longitude: region_lng
                        ),
                        span: MKCoordinateSpan(
                            latitudeDelta: region_zoom,
                            longitudeDelta: region_zoom
                        )
                    )
                ),
                interactionModes: MapInteractionModes.all,
                annotationItems: map_annotations,
                annotationContent: { location in
                    MapMarker(
                        coordinate: location.coordinate,
                        tint: .red
                    )
                }
            )
        }
    }
}

struct ReviewDetailView: View {
    @State var element_id: String
    
    @State var business_reviews_data: [Review] = [Review]()
    
    // set to -1 to indicate initial empty view
    @State var reviews_status: Int = -1
    
    var body: some View {
        ZStack {
            if (reviews_status == 1) {
                List {
                    ForEach(Array(business_reviews_data.enumerated()), id: \.element.id) { (index, element) in
                        
                        VStack(alignment: .leading) {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("\(element.user.name)")
                                        .bold()
                                }
                                Spacer()
                                VStack (alignment: .trailing) {
                                    Text("\(element.rating)/5")
                                        .bold()
                                }
                            }
                            .padding(.bottom, 5)
                            
                            VStack (alignment: .leading) {
                                Text("\(element.text)")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Spacer()
                                Text(element.timeCreated.split(separator: " ", maxSplits: 1)[0])
                                Spacer()
                            }
                            .padding(.top, 5)
                        }
                        .padding(.all, 10)
                    }
                }
            }
            else {
                ResultLoadingView().id(UUID())
            }
        }
        .onAppear() {
            Task {
                do {
                    // Call Reviews API
                    reviews_status = 0
                    business_reviews_data = try await business_reviews_request(business_id: element_id)
                    
                    if (business_reviews_data.isEmpty) {
                        reviews_status = 2
                    }
                    else {
                        reviews_status = 1
                    }
                    
                    //print("Reviews: Status: \(reviews_status)")
                    //dump(business_reviews_data)
                } catch {
                    print("Error: ", error)
                }
            }
        }
    }
}

// -------------------------------------------------------------------------
// https://developer.apple.com/forums/thread/118589
// SwiftUI View that acts as a preview container to display the example data
struct DetailView_PreviewContainer: View {
    //@AppStorage("bookings") var saved_bookings: [Booking] = []

    // Example Data for Preview
    let business_search_data: [Business] = [Business(
        alias: "Business Alias",
        categories: [Category(
            alias: "Business Category Alias",
            title: "Business Category Title"
        )],
        coordinates: Center(
            latitude: 34.0224,
            longitude: -118.2851
        ),
        displayPhone: "(555) 555-5555",
        distance: 10.0,
        id: "AUbKbVQAUNI6Vr6LYtOZzA",
        imageUrl: "Business Image URL",
        isClosed: false,
        location: Location(
            address1: "Business Address 1",
            address2: "Business Address 2",
            address3: "Business Address 3",
            city: "Business City",
            country: "Business Country",
            displayAddress: ["Business Address"],
            state: "Business State",
            zipCode: "Postal"),
        name: "Business Name",
        phone: "+1 (555) 555-5555",
        price: "$$$",
        rating: 4.5,
        reviewCount: 20,
        transactions: ["Business Transactions"],
        url: "https://www.yelp.com/"
    )]
    
    var body: some View {
        //DetailView(business_search_data: business_search_data, saved_bookings: $saved_bookings)
        SplashView()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView_PreviewContainer()
    }
}



