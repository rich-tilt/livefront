//
//  live_frontTests.swift
//  live_frontTests
//
//  Created by Richard Tilt on 12/26/22.
//

import XCTest
@testable import live_front

class live_frontTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    @MainActor func testEndPointsDefined() throws {
        
        let viewModel = ViewModel()
        
        XCTAssertEqual(viewModel.endpoints.count, 10, "expected 10 endpoints")
        
    }
    
    @MainActor func testEndPointName() throws {
        
        let viewModel = ViewModel()
        
        viewModel.updateLocation(index: 0)
        
        let name = viewModel.locationName()
        
        XCTAssertEqual(name, "New York", "expected New York")
    }
    
    @MainActor func testService() async {
        
        let endpoint = WeatherEndpoint.newYork("New York", 2459115)
        
        let service = WeatherService()
        
        let result = await service.getWeather(endpoint: endpoint)
        
        do {
            let weather = try result.get()
            let city = weather.location.city
            XCTAssertEqual(city, "New York", "expected New York")
        } catch {
            XCTAssertNil(error)
        }
    }
}
