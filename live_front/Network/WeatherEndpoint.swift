//
//  WeatherEndpoint.swift
//  live_front
//
//  Created by Richard Tilt on 12/26/22.
//

enum WeatherEndpoint {
    case newYork(String, Int)
    case losAngeles(String, Int)
    case chicago(String, Int)
    case philadelphia(String, Int)
    case mexicoCity(String, Int)
    case tokyo(String, Int)
    case saoPaulo(String, Int)
    case london(String, Int)
    case paris(String, Int)
    case venice(String, Int)
}

extension WeatherEndpoint: Endpoint {
       
    var path: String {
        return "/weather"
    }
    
    var query: String {
       
        switch self {
            
        case .newYork( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .losAngeles( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .chicago( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .philadelphia( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .mexicoCity( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .tokyo( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .saoPaulo( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .london( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .paris( _, let id):
            return "woeid=\(id)&format=json&u=f"
        case .venice( _, let id):
            return "woeid=\(id)&format=json&u=f"
        }
    }

    var method: RequestMethod {
        return .get
    }

    var header: [String: String]? {
        
        return  [
            "X-RapidAPI-Key": "3ffdec7ee3msh4fcc1131151df39p15026fjsn43dae8385b9e",
            "X-RapidAPI-Host": "yahoo-weather5.p.rapidapi.com"
        ]
    }
}
