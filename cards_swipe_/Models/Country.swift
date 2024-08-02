//
//  Country.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 26.07.2024.
//

import Foundation

struct Country: Identifiable, Equatable, Decodable  {
    let id = UUID()
    let name: Name
    let tld: [String]?
    let cca2: String
    let ccn3: String?
    let cca3: String
    let independent: Bool?
    let status: String
    let unMember: Bool
    let currencies: [String: Currency]?
    let idd: IDD
    let capital: [String]?
    let altSpellings: [String]
    let region: String
    let languages: [String: String]
    let translations: [String: Translation]
    let latlng: [Double]
    let landlocked: Bool
    let area: Double
    let demonyms: Demonyms?
    let flag: String
    let maps: Maps
    let population: Int
    let car: Car
    let timezones: [String]
    let continents: [String]
    let flags: Flags
    let coatOfArms: CoatOfArms?
    let startOfWeek: String
    let capitalInfo: CapitalInfo?

    struct Name: Decodable, Equatable {
        let common: String
        let official: String
        let nativeName: [String: NativeName]?
    }

    struct NativeName: Decodable, Equatable {
        let official: String
        let common: String
    }

    struct Currency: Decodable, Equatable {
        let name: String
        let symbol: String?
    }

    struct IDD: Decodable, Equatable {
        let root: String
        let suffixes: [String]
    }

    struct Translation: Decodable, Equatable {
        let official: String
        let common: String
    }

    struct Demonyms: Decodable, Equatable {
        let eng: Demonym
        struct Demonym: Codable, Equatable {
            let f: String
            let m: String
        }
    }

    struct Maps: Decodable, Equatable {
        let googleMaps: String
        let openStreetMaps: String
    }

    struct Car: Decodable, Equatable {
        let signs: [String]
        let side: String
    }

    struct Flags: Decodable, Equatable {
        let png: String
        let svg: String
    }

    struct CoatOfArms: Decodable, Equatable {
        // Add fields if necessary
    }

    struct CapitalInfo: Decodable, Equatable {
        let latlng: [Double]
    }
}
