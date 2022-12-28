//
//  Model.swift
//  live_front
//
//  Created by Richard Tilt on 12/26/22.
//

import Foundation

struct Weather: Decodable {
    let location: location
    let current_observation: current_observation
    let forecasts: [forecast]
}

struct location: Decodable {

    let city: String
    let region: String
    let country: String
    let lat: Double
    let long: Double
}

struct current_observation: Decodable {

    let pubDate: Int64
    let wind: wind
    let atmosphere: atmosphere
    let astronomy: astronomy
    let condition: condition
}

struct wind: Decodable {

    var chill: Int
    var direction: String
    var speed: Int
}

struct atmosphere: Decodable {
    var humidity: Int
    var visibility: Double
    var pressure: Double
}

struct astronomy: Decodable {
    var sunrise: String
    var sunset: String
}

struct condition: Decodable {
    var temperature: Int
    var text: String
}

struct forecast: Decodable, Hashable {
    
    var day: String
    var date: Date
    var high: Int
    var low: Int
    var text: String
}
