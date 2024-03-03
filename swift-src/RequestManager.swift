//
//  YelpReview
//
//  RequestManager.swift
//

import Foundation

// -------- BusinessSearch Request Function --------
// async keyword tells Swift this function might need sleep in order to complete the work
func business_search_request(keyword: String, latitude: Float, longitude: Float, distance: Double, category: String) async throws -> [Business] {
    let base_api_url = "http://127.0.0.1:8080/business_api/search"

    let keyword: String = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let latitude: Float = latitude
    let longitude: Float = longitude
    let distance: Int = miles_to_meters(miles: distance)
    let category: String = category

    let search_url = ("\(base_api_url)" + "?keyword=\(keyword)" + "&latitude=\(latitude)" + "&longitude=\(longitude)" + "&distance=\(distance)" + "&category=\(category)")

    //print(search_url)
    
    // create url type from string
    guard
        let url = URL(string: search_url)
    else {
        fatalError("Invalid URL.")
    }

    //print("URL: \(url)")

    // uses try keyword to indicate that an error might be thrown
    // stores the result using a deconstructed tuple made up of two parts
    // the data that was downloaded, and the response that was received
    let (data, response) = try await URLSession.shared.data(from: url)

    // check status of response
    guard
        let http_response = response as? HTTPURLResponse,
        http_response.statusCode == 200 /* OK */
    else {
        fatalError("Cannot fetch data.")
    }

    // create a JSONDecoder instance
    let decoder = JSONDecoder()

    // set the keyDecodingStrategy on the decoder to convertFromSnakeCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // decode the json data object into desired Swift type object (decodable models)
    // two parameters, first the data container models, second the json data
    let decoded_data = try decoder.decode(BusinessSearch.self, from: data)
    //dump(decoded_data)

    return decoded_data.businesses
}

func miles_to_meters(miles: Double) -> Int {
    let meters: Double = Double(miles) * 1609.344
    
    return Int(meters)
}

// -------- Autocomplete Request Function --------
func autocomplete_request(term: String) async throws -> [Autocomplete] {
    let base_api_url = "http://127.0.0.1:8080/business_api/autocomplete"

    let term: String = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

    let search_url = ("\(base_api_url)" + "?term=\(term)")

    // create url type from string
    guard
        let url = URL(string: search_url)
    else {
        fatalError("Invalid URL.")
    }

    //print("URL: \(url)")

    // uses try keyword to indicate that an error might be thrown
    // stores the result using a deconstructed tuple made up of two parts
    // the data that was downloaded, and the response that was received
    let (data, response) = try await URLSession.shared.data(from: url)

    // check status of response
    guard
        let http_response = response as? HTTPURLResponse,
        http_response.statusCode == 200 /* OK */
    else {
        fatalError("Cannot fetch data.")
    }

    // create a JSONDecoder instance
    let decoder = JSONDecoder()

    // set the keyDecodingStrategy on the decoder to convertFromSnakeCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // decode the json data object into desired Swift type object (decodable models)
    // two parameters, first the data container models, second the json data
    let decoded_data = try decoder.decode(Autocomplete.self, from: data)
    //dump(decoded_data)

    return [decoded_data]
}

// -------- BusinessDetail Request Function --------
func business_details_request(business_id: String) async throws -> [BusinessDetail] {
    let base_api_url = "http://127.0.0.1:8080/business_api/details"

    let business_id: String = business_id

    let search_url = ("\(base_api_url)" + "?id=\(business_id)")

    // create url type from string
    guard
        let url = URL(string: search_url)
    else {
        fatalError("Invalid URL.")
    }

    //print("URL: \(url)")

    // uses try keyword to indicate that an error might be thrown
    // stores the result using a deconstructed tuple made up of two parts
    // the data that was downloaded, and the response that was received
    let (data, response) = try await URLSession.shared.data(from: url)

    // check status of response
    guard
        let http_response = response as? HTTPURLResponse,
        http_response.statusCode == 200 /* OK */
    else {
        fatalError("Cannot fetch data.")
    }

    // create a JSONDecoder instance
    let decoder = JSONDecoder()

    // set the keyDecodingStrategy on the decoder to convertFromSnakeCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // decode the json data object into desired Swift type object (decodable models)
    // two parameters, first the data container models, second the json data
    let decoded_data = try decoder.decode(BusinessDetail.self, from: data)
    //dump(decoded_data)

    return [decoded_data]
}

// -------- BusinessReview Request Function --------
func business_reviews_request(business_id: String) async throws -> [Review] {
    let base_api_url = "http://127.0.0.1:8080/business_api/reviews"

    let business_id: String = business_id

    let search_url = ("\(base_api_url)" + "?id=\(business_id)")

    // create url type from string
    guard
        let url = URL(string: search_url)
    else {
        fatalError("Invalid URL.")
    }

    //print("URL: \(url)")

    // uses try keyword to indicate that an error might be thrown
    // stores the result using a deconstructed tuple made up of two parts
    // the data that was downloaded, and the response that was received
    let (data, response) = try await URLSession.shared.data(from: url)

    // check status of response
    guard
        let http_response = response as? HTTPURLResponse,
        http_response.statusCode == 200 /* OK */
    else {
        fatalError("Cannot fetch data.")
    }

    // create a JSONDecoder instance
    let decoder = JSONDecoder()

    // set the keyDecodingStrategy on the decoder to convertFromSnakeCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // decode the json data object into desired Swift type object (decodable models)
    // two parameters, first the data container models, second the json data
    let decoded_data = try decoder.decode(BusinessReview.self, from: data)
    //dump(decoded_data)

    return decoded_data.reviews
}

// -------- IPInfo API Request Function --------
func auto_location_request() async throws -> [String: Float] {
    let base_api_url = "http://127.0.0.1:8080/ipinfo_api"

    let search_url = ("\(base_api_url)")

    // create url type from string
    guard
        let url = URL(string: search_url)
    else {
        fatalError("Invalid URL.")
    }

    //print("URL: \(url)")

    // uses try keyword to indicate that an error might be thrown
    // stores the result using a deconstructed tuple made up of two parts
    // the data that was downloaded, and the response that was received
    let (data, response) = try await URLSession.shared.data(from: url)

    // check status of response
    guard
        let http_response = response as? HTTPURLResponse,
        http_response.statusCode == 200 /* OK */
    else {
        fatalError("Cannot fetch data.")
    }

    // create a JSONDecoder instance
    let decoder = JSONDecoder()

    // set the keyDecodingStrategy on the decoder to convertFromSnakeCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // decode the json data object into desired Swift type object (decodable models)
    // two parameters, first the data container models, second the json data
    let decoded_data = try decoder.decode(LocationCoordinates.self, from: data)
    dump(decoded_data)
    
    let location_data = [
        "lat": decoded_data.lat,
        "lng": decoded_data.lng
    ]

    return location_data
}

// -------- Geo Data API Request Function --------
func geo_location_request(location: String) async throws -> [String: Float]  {
    let base_api_url = "http://localhost:8080/geo_data_api"

    let location: String = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

    let search_url = ("\(base_api_url)" + "?location=" + "\(location)")

    // create url type from string
    guard
        let url = URL(string: search_url)
    else {
        fatalError("Invalid URL.")
    }

    //print("URL: \(url)")

    // uses try keyword to indicate that an error might be thrown
    // stores the result using a deconstructed tuple made up of two parts
    // the data that was downloaded, and the response that was received
    let (data, response) = try await URLSession.shared.data(from: url)

    // check status of response
    guard
        let http_response = response as? HTTPURLResponse,
        http_response.statusCode == 200 /* OK */
    else {
        fatalError("Cannot fetch data.")
    }

    // create a JSONDecoder instance
    let decoder = JSONDecoder()

    // set the keyDecodingStrategy on the decoder to convertFromSnakeCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // decode the json data object into desired Swift type object (decodable models)
    // two parameters, first the data container models, second the json data
    let decoded_data = try decoder.decode(LocationCoordinates.self, from: data)
    dump(decoded_data)
    
    let location_data = [
        "lat": decoded_data.lat,
        "lng": decoded_data.lng
    ]

    return location_data
}

// Function to validate email addresses
// https://emailregex.com/
func validate_email(candidate: String) -> Bool {
    let email_regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    return NSPredicate(format: "SELF MATCHES %@", email_regex).evaluate(with: candidate)
}
