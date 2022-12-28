//
//  ViewModel.swift
//  live_front
//
//  Created by Richard Tilt on 12/26/22.
//

import Foundation
import AVFoundation
import SwiftUI

/// Automatic main thread dispatch behavior
@MainActor final class ViewModel: ObservableObject {
    
    let systemSoundUrl = URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/TimerWheelHoursDetent_Haptic.caf")

    let impactHaptics = UIImpactFeedbackGenerator(style: .rigid)
    
    let dateFormatter = DateFormatter()

    var endpointIndex: Int = 0

    let initialDegrees: Double =  90.0
    let initialPosition: Double = 90.0
    let stepDegrees: Double = 14.0

    let minimumBounceAngle: Angle = Angle(degrees: 30.0)
    let maximumBounceAngle: Angle = Angle(degrees: 280.0)

    let minimumRotationAngle: Angle = Angle(degrees: 90.0)
    let maximumRotationAngle: Angle = Angle(degrees: 220.0)
        
    let endpoints: [WeatherEndpoint] = [WeatherEndpoint.newYork("New York", 2459115),
                                        WeatherEndpoint.losAngeles("Los Angeles", 2442047),
                                        WeatherEndpoint.chicago("Chicago", 2379574),
                                        WeatherEndpoint.philadelphia("Philadelphia", 2471217),
                                        WeatherEndpoint.mexicoCity("Mexico City", 116545),
                                        WeatherEndpoint.tokyo("Tokyo", 1118370),
                                        WeatherEndpoint.saoPaulo("Sao Paulo", 455827),
                                        WeatherEndpoint.london("London", 44418),
                                        WeatherEndpoint.paris("Paris", 615702),
                                        WeatherEndpoint.venice("Venice", 725746)]
    
    
    @Published var currentLocation:WeatherEndpoint
    @Published var requestInProgress: Bool = false
    @Published var weather: Weather?
    @Published var error: Error?
    
    private let service = WeatherService()
    
    init() {
        self.currentLocation = endpoints[endpointIndex]
        dateFormatter.dateFormat = "MM/dd/yyyy"
    }
    
    public func locationName() -> String {
        
        switch currentLocation {
        case .newYork(let name, _):
            return (name)
        case .losAngeles(let name, _):
            return (name)
        case .chicago(let name, _):
            return (name)
        case .philadelphia(let name, _):
            return (name)
        case .mexicoCity(let name, _):
            return (name)
        case .tokyo(let name, _):
            return (name)
        case .saoPaulo(let name, _):
            return (name)
        case .london(let name, _):
            return (name)
        case .paris(let name, _):
            return (name)
        case .venice(let name, _):
            return (name)
        }
    }
    
    public func updateLocation(index: Int) {
        
        self.endpointIndex = index
        
        self.currentLocation = endpoints[index]
    }
    
    private func fetchData(for endpoint: WeatherEndpoint, completion: @escaping (Result<Weather, RequestError>) -> Void) {

        Task(priority: .background) {
            let result = await service.getWeather(endpoint: endpoint)
            completion(result)
        }
    }
    
    public func fetchWeather() {
        
        self.requestInProgress = true
        
        fetchData(for: self.currentLocation) { [weak self] result in
            
            guard let self = self else { return }
                    
            self.requestInProgress = false
            
            switch result {
                
                case .success(let response):
                
                    print("Response: \(response)")
                
                    self.weather = response
                
                case .failure(let error):
                    self.error = error
             }
        }
    }
    
    public func playSoundAndHaptics() {

        var systemSoundID: SystemSoundID = 0

        AudioServicesDisposeSystemSoundID(systemSoundID)

        AudioServicesCreateSystemSoundID(self.systemSoundUrl as CFURL, &systemSoundID)

        AudioServicesPlaySystemSound(systemSoundID)

        impactHaptics.impactOccurred()
    }
    
    public func formatDate(date: Date) -> String {
        
        return dateFormatter.string(from: date)
    }
}
