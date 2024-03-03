//
//  YelpReview
//
//  BookingView.swift
//

import SwiftUI

struct BookingView: View {
    @Binding var saved_bookings: [Booking]
    
    var body: some View {
        ZStack {
            if (saved_bookings.isEmpty) {
                VStack {
                    Spacer()
                    Text("No bookings found.")
                        .foregroundColor(Color.red)
                    Spacer()
                }
            }
            else {
                List {
                    ForEach(saved_bookings, id: \.r_id) { booking in
                        HStack {
                            Text("\(booking.r_business)")
                                .font(.system(size: 12))
                                .frame(width: 80, alignment: .leading)
                                .padding(.leading, 5)
                            
                            Spacer()
                            
                            Text("\(booking.r_date)")
                                .font(.system(size: 12))
                                .frame(width: 65, alignment: .leading)
                            
                            Spacer()
                            
                            Text("\(booking.r_time)")
                                .font(.system(size: 12))
                                .frame(width: 35, alignment: .leading)
                            
                            Spacer()
                            
                            Text("\(booking.r_email)")
                                .font(.system(size: 12))
                                .frame(width: 110, alignment: .center)
                        }
                    }
                    .onDelete { index_set in
                        saved_bookings.remove(atOffsets: index_set)
                    }
                }
            }
        }
        .navigationTitle("Your Reservations")
    }
}

struct ReservationView: View {
    @Environment(\.dismiss) var dismiss
    let business_details_data: [BusinessDetail]
    
    @State private var showing_sheet = false
    @State private var show_toast: Bool = false
    
    @State private var r_email: String = ""
    @State private var r_long_date = Date()
    @State private var r_hours: String = "10"
    @State private var r_minutes: String = "00"
    
    let dateFormatter = DateFormatter()
    let pick_hours: [String] = ["10", "11", "12", "13", "14", "15", "16", "17"]
    let pick_minutes: [String] = ["00", "15", "30", "45"]
    
    @State var r_date: String = ""
    @State var r_time: String = ""
    
    @State private var email_is_valid: Bool = false
    
    @State var is_confirmation: Bool = false
    
    @Binding var saved_bookings: [Booking]

    var body: some View {
        let element = business_details_data[0]
        
        if (!is_confirmation)
        {
            List {
                Section {
                    HStack {
                        Spacer()
                        Text("Reservation Form")
                            .font(.title).bold()
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("\(element.name)")
                            .font(.title).bold()
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Text("Email:")
                        TextField("Email", text: $r_email, prompt: Text("Required"))
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Text("Date/Time:")
                        
                        DatePicker(
                            "",
                            selection: $r_long_date,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .datePickerStyle(.compact)
                        
                        HStack {
                            Menu {
                                ForEach(pick_hours, id: \.self) {
                                    value in
                                    
                                    Button {
                                        //print("Selected \(value)")
                                        r_hours = value
                                    } label: {
                                        HStack {
                                            Text(value)
                                            
                                            if r_hours == value {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("\(r_hours)")
                                    .foregroundColor(.black)
                            }
                            
                            Text(" : ")
                                .foregroundColor(.black)
                            
                            Menu {
                                ForEach(pick_minutes, id: \.self) {
                                    value in
                                    
                                    Button {
                                        //print("Selected \(value)")
                                        r_minutes = value
                                    } label: {
                                        HStack {
                                            Text(value)
                                            
                                            if r_minutes == value {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("\(r_minutes)")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.all, 6.5)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6.5))
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            //print("Submit Form")
                            //print("-------- Values --------")
                            //print("Email: \(r_email)")
                            //print("Business: \(element.id)")
                            //print("Business Name: \(element.name)")
                            //print("Reservation Long Date: \(r_long_date)")
                            //print("Reservation Hours: \(r_hours)")
                            //print("Reservation Minutes: \(r_minutes)")
                            
                            if (!validate_email(candidate: r_email)) {
                                //print("Show Toast")
                                withAnimation {
                                    self.show_toast.toggle()
                                }
                            }
                            else {
                                // Set Date Format
                                dateFormatter.dateFormat = "y-M-d"
                                // Convert Date to String
                                r_date = dateFormatter.string(from: r_long_date)
                                r_time = "\(r_hours):\(r_minutes)"
                                
                                //print("Reservation Date: \(r_date)")
                                //print("Reservation Time: \(r_time)")
                                
                                email_is_valid = true
                                
                                withAnimation {
                                    is_confirmation.toggle()
                                }
                                
                                Task {
                                    let new_booking = Booking(
                                        r_id: element.id,
                                        r_business: element.name,
                                        r_email: r_email,
                                        r_date: r_date,
                                        r_time: r_time
                                    )
                                    
                                    saved_bookings.append(new_booking)
                                }
                            }
                            
                            //print(email_is_valid)
                        } label: {
                            Text("Submit")
                                .foregroundColor(Color.white)
                        }
                        .frame(width: 110, height: 50)
                        .background(.blue)
                        .cornerRadius(8)
                        .padding()
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                    }
                }
            }.toast(isPresented: self.$show_toast) {
                HStack {
                    Text("Please enter a valid email.")
                }
            }
        }
        else
        {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Text("Congratulations")
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        Text("You have succesfully made a reservation at")
                            .foregroundColor(.white)
                        
                        Text("\(element.name)")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .foregroundColor(Color.green)
                        }
                        .frame(width: 175, height: 50)
                        .background(.white)
                        .cornerRadius(24)
                        .padding()
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                    }
                }
            }
            .transition(.move(edge: .bottom))
            .onAppear() {
                // give time to close the sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
