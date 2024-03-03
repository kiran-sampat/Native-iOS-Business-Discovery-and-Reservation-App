//
//  YelpReview
//
//  ObjectManager.swift
//

import Foundation

// -------- BusinessSearch Decodable Models --------
// Model type is Decodable, since it is used to convert JSON to instances on this type
// Decodable is often used when data is only received from the server
// MARK: - BusinessSearch
struct BusinessSearch: Decodable {
    let businesses: [Business]
    let region: Region
    let total: Int
}

// MARK: - Business
struct Business: Identifiable, Decodable {
    let alias: String
    let categories: [Category]
    let coordinates: Center
    let displayPhone: String
    let distance: Double
    let id: String
    let imageUrl: String
    let isClosed: Bool
    let location: Location
    let name: String
    let phone, price: String?
    let rating: Double
    let reviewCount: Int
    let transactions: [String?]
    let url: String
}

// MARK: - Category
struct Category: Decodable {
    let alias, title: String
}

// MARK: - Center
struct Center: Decodable {
    let latitude, longitude: Double
}

// MARK: - Location
struct Location: Decodable {
    let address1: String?
    let address2, address3: String?
    let city, country: String
    let displayAddress: [String]
    let state, zipCode: String
}

// MARK: - Region
struct Region: Decodable {
    let center: Center
}

// -------- Autocomplete Decodable Models --------
// MARK: - Autocomplete
struct Autocomplete: Decodable {
    let businesses: [String?]
    let categories: [AutoCategory]
    let terms: [AutoTerm]
}

// MARK: - Category
struct AutoCategory: Decodable {
    let alias, title: String
}

// MARK: - Term
struct AutoTerm: Decodable {
    let text: String
}

// -------- BusinessDetail Decodable Models --------
// MARK: - BusinessDetail
struct BusinessDetail: Identifiable, Decodable {
    let alias: String
    let categories: [CategoryDetail]
    let coordinates: CoordinatesDetail
    let displayPhone: String
    let hours: [HourDetail]
    let id: String
    let imageUrl: String
    let isClaimed, isClosed: Bool
    let location: LocationDetail
    let name, phone: String
    let photos: [String]
    let price: String?
    let rating: Double
    let reviewCount: Int
    let transactions: [String]
    let url: String
}

// MARK: - CategoryDetail
struct CategoryDetail: Decodable {
    let alias, title: String
}

// MARK: - CoordinatesDetail
struct CoordinatesDetail: Decodable {
    let latitude, longitude: Double
}

// MARK: - HourDetail
struct HourDetail: Decodable {
    let hoursType: String
    let isOpenNow: Bool
    let open: [OpenDetail]
}

// MARK: - OpenDetail
struct OpenDetail: Decodable {
    let day: Int
    let end: String
    let isOvernight: Bool
    let start: String
}

// MARK: - LocationDetail
struct LocationDetail: Decodable {
    let address1: String?
    let address2, address3: String?
    let city: String
    let country, crossStreets: String
    let displayAddress: [String]
    let state, zipCode: String
}

// -------- BusinessReview Decodable Models --------
// MARK: - BusinessReview
struct BusinessReview: Decodable {
    let possibleLanguages: [String]
    let reviews: [Review]
    let total: Int
}

// MARK: - Review
struct Review: Identifiable, Decodable {
    let id: String
    let rating: Int
    let text, timeCreated: String
    let url: String
    let user: User
}

// MARK: - User
struct User: Decodable {
    let id: String
    let imageUrl: String
    let name: String
    let profileUrl: String
}

// -------- IPInfo and Geo Data Decodable Model --------
// MARK: - LocationCoordinates
struct LocationCoordinates: Decodable {
    let lat, lng: Float
}

// -------- Booking Codable Model --------
// Object for saving reservation and booking data
// Object is Codable, meaning both Encodable and Decodable
// MARK: - Booking
struct Booking: Encodable, Decodable {
    let r_id: String
    let r_business: String
    let r_email: String
    let r_date: String
    let r_time: String
}
