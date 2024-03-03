//
//  YelpReview
//
//  HomeView.swift
//

import SwiftUI

// -------- HomeView --------
struct HomeView: View {
    @AppStorage("bookings") var saved_bookings: [Booking] = []
    
    // https://developer.apple.com/forums/thread/682448
    @FocusState var field_is_focused: Bool
    
    // https://www.hackingwithswift.com/read/7/3/parsing-json-using-the-codable-protocol
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-fix-cannot-assign-to-property-self-is-immutable
    @State var business_search_data: [Business] = [Business]()

    // set to -1 to indicate initial empty view
    @State var results_status: Int = -1

    var body: some View {
        NavigationView {
            List {
                // Search Section
                Section {
                    BusinessSearchView(field_is_focused: _field_is_focused, results_status: $results_status, business_search_data: $business_search_data)
                }
                
                // Results Section
                Section {
                    ResultView(results_status: $results_status, business_search_data: $business_search_data, saved_bookings: $saved_bookings)
                }
            }
            .navigationTitle("Business Search")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: BookingView(saved_bookings: $saved_bookings)) {
                        Image(systemName: "calendar.badge.clock")
                            .accentColor(.blue)
                    }.simultaneousGesture(TapGesture().onEnded{
                        //print("Bookings View")
                        field_is_focused = false
                    })
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        //print("Hide Keyboard")
                        field_is_focused = false
                    } label: {
                        Text("Done")
                    }
                }
            }  // ~Toolbars~
        }  // ~Navigation View~
    }
}

// -------- BusinessSearchView --------
struct BusinessSearchView: View {
    @FocusState var field_is_focused: Bool
    
    @Binding var results_status: Int
    @Binding var business_search_data: [Business]
    
    @State private var s_keyword: String = ""
    @State private var s_distance: Double = 10.0
    @State private var s_category: String = "All"
    @State private var s_location: String = ""
    @State private var s_auto_detect: Bool = false
    
    @State private var s_latitude: Float = 0
    @State private var s_longitude: Float = 0
    
    @State private var show_autocomplete = false
    @State private var autocomplete_status: Bool = false
    @State private var suggestions = [String]()
    
    let yelp_categories: [String: String] = [
        "All": "Default",
        "arts": "Arts & Entertainment",
        "health": "Health & Medical",
        "hotelstravel": "Hotels & Travel",
        "food": "Food",
        "professional": "Professional Services",
    ]

    var submit_is_disabled: Bool {
        if !s_keyword.isEmpty && (!s_location.isEmpty || s_auto_detect) {
            return false
        }

        return true
    }

    var body: some View {
        // KEYWORD
        HStack {
            Text("Keyword:")
            TextField("Keyword", text: $s_keyword, prompt: Text("Required"))
                .disableAutocorrection(true)
                .onSubmit {
                    if (s_keyword.isEmpty) {
                        show_autocomplete = false
                        //print("No Show Popover")
                    }
                    else {
                        show_autocomplete = true
                        //print("Show Popover")
                        
                        Task {
                            // Set status to loading
                            autocomplete_status = false
                            
                            suggestions.removeAll()
                            
                            // Call Autocomplete API
                            let suggestions_request = try await autocomplete_request(term: s_keyword)
                            
                            // Loop over data and append all suggested categories to array
                            for suggestion in suggestions_request[0].categories {
                                suggestions.append(suggestion.title)
                            }
                            
                            // Loop over data and append all suggested terms to array
                            for suggestion in suggestions_request[0].terms {
                                suggestions.append(suggestion.text)
                            }
                            
                            //dump(suggestions)
                            
                            // Set status to loaded
                            autocomplete_status = true
                        }
                    }
                }
        }
        .focused($field_is_focused, equals: true)
        .alwaysPopover(isPresented: $show_autocomplete) {
            if (!autocomplete_status) {
                ResultLoadingView()
            }
            else {
                VStack {
                    if (!suggestions.isEmpty) {
                        ForEach(suggestions, id: \.self){ suggestion in
                            Text("\(suggestion)")
                                .font(.subheadline)
                                .frame(minWidth: 150)
                                .onTapGesture {
                                    s_keyword = suggestion
                                    //print("\(suggestion)")
                                    show_autocomplete = false
                                }
                        }
                    }
                    else {
                        Text("No results found.")
                            .font(.subheadline)
                            .frame(minWidth: 150)
                            .foregroundColor(Color.red)
                    }
                }
                .padding()
            }
        }
        
        // DISTANCE
        HStack {
            Text("Distance:")
            TextField("Distance", value: $s_distance, format: .number)
                .keyboardType(.numberPad)
        }.focused($field_is_focused, equals: true)
        
        // CATEGORY
        HStack {
            Text("Category:")
            Menu {
                ForEach(yelp_categories.sorted(by: <), id: \.key) {
                    (key, value) in
                    
                    Button {
                        //print("Selected \(value)")
                        s_category = key
                    } label: {
                        HStack {
                            Text(value)

                            if s_category == key {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(yelp_categories[s_category] ?? "Undefined")
            }
        }.focused($field_is_focused, equals: true)
        
        // LOCATION
        if !s_auto_detect {
            HStack {
                Text("Location:")
                TextField("Location", text: $s_location, prompt: Text("Required"))
                    .disableAutocorrection(true)
            }.focused($field_is_focused, equals: true)
        }
        
        // AUTO DETECT
        Toggle("Auto-detect my location", isOn: $s_auto_detect)
            .toggleStyle(SwitchToggleStyle(tint: .green))
        
        // FORM BUTTONS
        HStack {
            Spacer()
            
            Button {
                //print("Submit Form")
                //print("-------- Values --------")
                //print("Keyword: \(s_keyword)")
                //print("Distance: \(s_distance)")
                //print("Category: \(s_category)")
                //print("Location: \(s_location)")
                //print("Auto-Detect: \(s_auto_detect)")
                
                field_is_focused = false
                
                Task {
                    do {
                        // Location APIs
                        if (s_auto_detect) {
                            // Call IP Info API
                            let location_data = try await auto_location_request()
                            
                            s_latitude = location_data["lat"] ?? 0
                            s_longitude = location_data["lng"] ?? 0
                        }
                        else {
                            // Call Geo Data API
                            let location_data = try await geo_location_request(location: s_location)
                            
                            s_latitude = location_data["lat"] ?? 0
                            s_longitude = location_data["lng"] ?? 0
                        }
                        
                        // Call Search API
                        results_status = 0
                        business_search_data = try await business_search_request(keyword: s_keyword, latitude: s_latitude, longitude: s_longitude, distance: s_distance, category: s_category)
                        
                        if (business_search_data.isEmpty) {
                            results_status = 2
                        } else {
                            results_status = 1
                        }
                        
                        //print("Results Status: \(results_status)")
                    } catch {
                        print("Error: ", error)
                    }
                }
            } label: {
                Text("Submit")
                    .foregroundColor(Color.white)
            }
            .frame(width: 110, height: 50)
            .background(submit_is_disabled ? .gray : .red)
            .cornerRadius(8)
            .padding()
            .disabled(submit_is_disabled)
            
            Button {
                s_keyword = ""
                s_distance = 10.0
                s_category = "All"
                s_location = ""
                s_auto_detect = false
                results_status = -1
                business_search_data = []
                
                //print("Clear Form")
                field_is_focused = false
            } label: {
                Text("Clear")
                    .foregroundColor(Color.white)
            }
            .frame(width: 110, height: 50)
            .background(Color.blue)
            .cornerRadius(8)
            .padding()
            
            Spacer()
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

// -------- ResultView --------
struct ResultView: View {
    @Binding var results_status: Int
    @Binding var business_search_data: [Business]
    @Binding var saved_bookings: [Booking]

    var body: some View {
        Text("Results")
            .font(.title).bold()
        
        // ZStack contatiner to prevent conditional ProgressView animation error
        //ZStack {
            switch results_status {
            case 0:
                ResultLoadingView().id(UUID())
            case 1:
                ResultTableView(business_search_data: business_search_data, saved_bookings: $saved_bookings)
            case 2:
                ResultNoView()
            default:
                EmptyView()
            }
        //}
    }
}

// -------- ResultNoView --------
struct ResultNoView: View {
    var body: some View {
        Text("No result available")
            .foregroundColor(.red)
    }
}

// -------- ResultLoadingView --------
struct ResultLoadingView: View {
    var body: some View {
        HStack {
            Spacer()

            ProgressView("Please wait...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()

            Spacer()
        }
    }
}

// -------- ResultTableView --------
struct ResultTableView: View {
    let business_search_data: [Business]
    @Binding var saved_bookings: [Booking]
    
    var body: some View {
        // https://stackoverflow.com/questions/73179886/asyncimage-not-rendering-all-images-in-a-list-and-producing-error-code-999-ca
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-horizontal-and-vertical-scrolling-using-scrollview
        // https://www.hackingwithswift.com/books/ios-swiftui/how-scrollview-lets-us-work-with-scrolling-data
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(business_search_data.enumerated()), id: \.element.id) { (index, element) in
                    NavigationLink(destination: DetailView(business_search_data: [element], saved_bookings: $saved_bookings)) {
                        HStack {
                            Text("\(index + 1)")
                                .foregroundColor(.black)
                                .frame(width: 25, height: 55)
                            
                            // async load a resizable image from a url with a placeholder
                            // set the frame, resize image to frame, clip image shape
                            AsyncImage(url: URL(string: "\(element.imageUrl)")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill() // Call before frame to maintain aspect ratio
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
                            .frame(width: 55, height: 55)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            Text("\(element.name)")
                                .foregroundColor(.gray)
                                .frame(minWidth: 110, minHeight: 65)
                            
                            Text("\(element.rating, specifier: "%.1f")")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .frame(width: 30, height: 55)
                            
                            Text("\(Int(element.distance / 1609))")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .frame(width: 25, height: 55)
                            
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.gray)
                                .frame(width: 25, height: 55)
                        }
                    }
                
                    Divider()
                }
            }
        }
    }
}

// -------- HomeView Preview --------
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
