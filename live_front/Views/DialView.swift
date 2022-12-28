//
//  DialView.swift
//  live_front
//
//  Created by Richard Tilt on 12/26/22.
//

import SwiftUI

struct DialView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    /// Used with geometry read and large dial image (size)
    let scaleFactor = 1.7

    let pointerWidth: CGFloat = 24.0

    /// Used with Drag Gesture
    @State private var dialAngle = Angle(degrees: 90)
    /// Used with Drag Gesture
    @State private var dialReleaseAngle = Angle(degrees: 90)
    
    /// Used to show Detail View
    @State var showDetailView = false

    var body: some View {
        
        main
            .disabled(viewModel.requestInProgress)
            .opacity(viewModel.requestInProgress ? 0.5 : 1.0)
            .onAppear {
                viewModel.updateLocation(index: 0)
                
                viewModel.fetchWeather()
            }
    }
    
    private var main: some View {
        
        ZStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                
                /// Name of city
                heading
                
                /// Minimal data for this city
                conditions
                    .padding(10)
                
                Spacer()
                
                /// Button shows Detail (extended data)
                extended
            }
            .font(.system(size: 24, weight: .bold, design: .default))
            .foregroundColor(.black)
            
            wheel
        }
    }
    
    private var heading: some View {
        
        Text(viewModel.locationName())
            .font(.system(size: 42, weight: .bold, design: .default))
    }
    
    private var conditions: some View {
        Group {
            HStack {
                
                Text("Conditions: ")
                
                Text(viewModel.weather?.current_observation.condition.text ?? "")
            }
            
            HStack {
                    
                Text("Temp: ")
                
                Text(String(viewModel.weather?.current_observation.condition.temperature ?? 0) + "º")
            }
            
            HStack {
                
                Text("Humidity:")
                
                Text(String(viewModel.weather?.current_observation.atmosphere.humidity ?? 0) + "%")
            }
            
            HStack {
                
                Text("Visibility:")
                
                Text(String(viewModel.weather?.current_observation.atmosphere.visibility ?? 0) + "m")
            }
        }
    }
    
    private var extended: some View {
        
        Button {
            showDetailView.toggle()
        } label: {
            
            Text("Extended Forecast")
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                   .stroke(Color.black, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        /// Used for UI Testing
        .accessibilityIdentifier("ExtendedButton")
        /// Used to add a label to the view that describes its contents.
        .accessibilityLabel("Show extended information for selected City")
        /// Used to Communicate to the user what happens after performing the view’s action.
        .accessibilityHint("A detail view will be shown for the selected City")
        .sheet(isPresented: $showDetailView) {
            DetailView()
                .environmentObject(viewModel)
        }
    }
    
    private var wheel: some View {
        
        GeometryReader { geometry in

            VStack(alignment: .leading) {

                Spacer()
                
                HStack(spacing: 0.0) {

                    Image("pointer")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: pointerWidth, height: 200)
                        .offset(x: pointerWidth / 2, y: 6.0)
                        .zIndex(1)
                    
                    Image("dial")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .frame(
                            width: geometry.size.width * scaleFactor,
                            height: geometry.size.width * scaleFactor,
                            alignment: .center
                        )
                        .rotationEffect(dialAngle)
                        .gesture(rotationDragGesture(geometry: geometry))
                }

                Spacer()
            }
            .offset(x: (geometry.size.width * 0.6), y: 0)
        }
    }
    
    private func updateIndex(for position: Double) {

        if position >= viewModel.minimumRotationAngle.degrees && position <= viewModel.maximumRotationAngle.degrees {

            var newIndex: Int = 0

            if position <= viewModel.initialPosition {
                newIndex = Int((viewModel.initialPosition - position) / viewModel.stepDegrees)
            } else {
                newIndex = Int((position - viewModel.initialPosition) / viewModel.stepDegrees)
            }

            if newIndex != viewModel.endpointIndex {

                // viewModel.endpointIndex = newIndex
                viewModel.updateLocation(index: newIndex)

                /// Trigger Haptics only when the index changes
                viewModel.playSoundAndHaptics()
            }
        }
    }

    private func dragDidEnd() {
        
        viewModel.fetchWeather()
    }

    private func rotationDragGesture(geometry: GeometryProxy) -> some Gesture {

        return DragGesture(minimumDistance: 0.0, coordinateSpace: .local)

            .onChanged { value in

                var dragAngle = computedDragAngle(from: value.startLocation.y, to: value.location.y)

                if dragAngle < viewModel.minimumRotationAngle {

                    dragAngle = viewModel.minimumRotationAngle - ((viewModel.minimumRotationAngle - dragAngle) / 4.0)
                }

                if dialAngle > viewModel.maximumRotationAngle {

                    dragAngle = viewModel.maximumRotationAngle + ((dragAngle - viewModel.maximumRotationAngle) / 4.0)
                }

                /// Restricted to min and max bounce angle
                let newAngle = min(viewModel.maximumBounceAngle, max(viewModel.minimumBounceAngle, dragAngle))

                withAnimation(.linear(duration: 0.1)) {
                    dialAngle = newAngle
                    updateIndex(for: newAngle.degrees)
                }
            }

            .onEnded { value in
                self.dialReleaseAngle = dialAngle
                bounce()
                dragDidEnd()
            }
    }

    private func bounce() {

        if self.dialReleaseAngle > viewModel.maximumRotationAngle {

            withAnimation(
                Animation.interpolatingSpring(mass: 0.1, stiffness: 30.0, damping: 1.0, initialVelocity: 0.8)
            ) {
                dialAngle = viewModel.maximumRotationAngle
                dialReleaseAngle = dialAngle
            }
        }
        if self.dialReleaseAngle < viewModel.minimumRotationAngle {

            withAnimation(
                Animation.interpolatingSpring(mass: 0.1, stiffness: 30.0, damping: 1.0, initialVelocity: 0.8)
            ) {
                dialAngle = viewModel.minimumRotationAngle
                dialReleaseAngle = dialAngle
            }
        }

    }

    private func computedDragAngle(from start: CGFloat, to current: CGFloat) -> Angle {

        /// distance from start to current drag position
        let drag_delta = start - current

        /// dividing by some value to move the dial at a reasonable speed, based on size of dial
        /// 3.0 , 6.0 increasing this number only changes the drag speed - higher number is slower
        let scaled_drag = Int(drag_delta / 3.0)

        /// Convert to Double in preparation for Angle Degrees
        let drag_degrees = Double(scaled_drag)

        /// Use last release angle and drag degrees to get new position
        let delta_degrees = self.dialReleaseAngle.degrees + drag_degrees

        /// return as an Angle
        return Angle(degrees: delta_degrees)
    }
}

struct DialView_Previews: PreviewProvider {
    static var previews: some View {
        DialView()
            .environmentObject(ViewModel())
            .padding()
    }
}
