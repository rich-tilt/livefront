//
//  WeatherService.swift
//  live_front
//
//  Created by Richard Tilt on 12/26/22.
//

import Foundation

protocol WeatherServiceable {
    func getWeather(endpoint: WeatherEndpoint) async -> Result<Weather, RequestError>
}

struct WeatherService: HTTPClient, WeatherServiceable {
    func getWeather(endpoint: WeatherEndpoint) async -> Result<Weather, RequestError> {
        return await sendRequest(endpoint: endpoint, responseModel: Weather.self)
    }
}
