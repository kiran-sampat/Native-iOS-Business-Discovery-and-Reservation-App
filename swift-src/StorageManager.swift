//
//  YelpReview
//
//  StorageManager.swift
//

import Foundation

// Function to help with Encoding and Decoding data for Reservation System
// https://stackoverflow.com/questions/66846106/using-appstoarge-with-a-custom-object-array-does-not-persist-data/
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }
        do {
            let result = try JSONDecoder().decode([Element].self, from: data)
            //print("Init from result: \(result)")
            self = result
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        //print("Returning \(result)")
        return result
    }
}
