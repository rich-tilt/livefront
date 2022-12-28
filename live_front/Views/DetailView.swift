//
//  DetailView.swift
//  live_front
//
//  Created by Richard Tilt on 12/26/22.
//

import SwiftUI

struct DetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        
        main
            .padding()
    }
    
    private var main: some View {
        
        VStack(alignment: .leading) {
            
            /// Name of city
            heading
            
            /// Minimal data for this city
            conditions
            
            ScrollView {
                
                ForEach(viewModel.weather?.forecasts ?? [forecast(day: "", date: Date(), high: 0, low: 0, text: "")], id: \.self) { forecast in
                    
                    detail(forecast: forecast)
                }
            }
            
            dismiss
        }
        .font(.system(size: 24, weight: .bold, design: .default))
        .foregroundColor(.black)
    }
    
    private var heading: some View {
        
        Text(viewModel.locationName())
            .font(.system(size: 42, weight: .bold, design: .default))
    }
    
    private var conditions: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                Text("Conditions: ")
                
                Text(viewModel.weather?.current_observation.condition.text ?? "")
            }
        
            HStack {
                    
                Text("Temp: ")
                
                Text(String(viewModel.weather?.current_observation.condition.temperature ?? 0) + "º")
            }
        }
    }
    
    private func detail(forecast: forecast) -> some View {
        
        Group {
            HStack {

                Text(forecast.day)

                Text(viewModel.formatDate(date: forecast.date))
            }
        
            HStack {

                Text("High: ")

                Text(String(forecast.high) + "º")

                Text("Low: ")

                Text(String(forecast.low) + "º")
            }
            
            HStack {

                Text("Forecast: ")

                Text(String(forecast.text))
            }

            Divider()
        }
        .font(.system(size: 18, weight: .bold, design: .default))
    }
    
    private var dismiss: some View {
        
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {

            Text("Dismiss")
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                   .stroke(Color.black, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        /// Used for UI Testing
        .accessibilityIdentifier("DismissButton")
        /// Used to add a label to the view that describes its contents.
        .accessibilityLabel("Return to main view")
        /// Used to Communicate to the user what happens after performing the view’s action.
        .accessibilityHint("The main view will be shown")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
            .environmentObject(ViewModel())
    }
}
