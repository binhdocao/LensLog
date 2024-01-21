//
//  HomePageView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI

struct HomePageView: View {
	@State private var timeRemaining = ""
	let targetDate: Date

	init() {
		// Set the target date for countdown
		let calendar = Calendar.current
		var components = DateComponents()
		components.year = 2024
		components.month = 1
		components.day = 24
		components.hour = 0
		components.minute = 0
		components.second = 0
		self.targetDate = calendar.date(from: components) ?? Date()
		
		// Initialize the countdown
		updateTimeRemaining()
	}

	var body: some View {
		 ZStack {
			 Color(hex: "#4B91F1") // Set the background color
				 .edgesIgnoringSafeArea(.all)

			 // Your other home page content goes here
			 VStack {
				 Text(timeRemaining)
					 .font(.largeTitle)
					 .foregroundColor(.white) // Change text color for visibility
					 .onAppear(perform: startTimer)
					 .padding()
				 Spacer()
			 }
			 
			 SwipeUpMenuView() // Ensure this is at the end to be on top
		 }
	 }

	private func startTimer() {
		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
			updateTimeRemaining()
			
			// Check if the current date has reached the target date
			if Date() >= self.targetDate {
				timer.invalidate()
				timeRemaining = "Countdown finished!"
			}
		}
	}

	private func updateTimeRemaining() {
		let remaining = targetDate.timeIntervalSince(Date())
		let hours = Int(remaining) / 3600
		let minutes = Int(remaining) / 60 % 60
		let seconds = Int(remaining) % 60
		timeRemaining = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
	}

	// SwipeUpMenuView and other views/components go here
}

struct SwipeUpMenuView: View {
	@State private var isMenuOpen = false

	var body: some View {
		VStack {
			Spacer()

			VStack {
				Capsule()
					.frame(width: 40, height: 5)
					.foregroundColor(Color.gray)
					.padding()

				Button("Button 1") {
					// Button 1 action
				}
				.buttonStyle(ColoredButtonStyle())

				Button("Button 2") {
					// Button 2 action
				}
				.buttonStyle(ColoredButtonStyle())

				Button("Button 3") {
					// Button 3 action
				}
				.buttonStyle(ColoredButtonStyle())
			}
			.background(Color.white)
			.cornerRadius(15)
			.shadow(radius: 10)
			.frame(maxWidth: .infinity)
			.offset(y: isMenuOpen ? 0 : UIScreen.main.bounds.height)
			.gesture(
				DragGesture().onEnded { value in
					if value.translation.height > 0 {
						self.isMenuOpen = false
					} else {
						self.isMenuOpen = true
					}
				}
			)
		}
	}
}

struct ColoredButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundColor(Color.white)
			.padding()
			.background(Color(hex: "#4B91F1"))
			.cornerRadius(8)
	}
}

extension Color {
	init(hex: String) {
		let scanner = Scanner(string: hex)
		_ = scanner.scanString("#")

		var rgbValue: UInt64 = 0
		scanner.scanHexInt64(&rgbValue)

		let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
		let g = Double((rgbValue & 0xFF00) >> 8) / 255.0
		let b = Double(rgbValue & 0xFF) / 255.0

		self.init(red: r, green: g, blue: b)
	}
}


struct HomePageView_Previews: PreviewProvider {
	static var previews: some View {
		HomePageView()
	}
}
