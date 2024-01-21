//
//  DailyWearView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI

struct DailyWearTrackerView: View {
	@State private var contactsOn = false
	@State private var wearStartTime: Date?
	@State private var wearEndTime: Date?
	@State private var showingTimePicker = false
	@State private var showingStartOptions = false
	let maxWearDuration: TimeInterval = 16 * 60 * 60 // 16 hours in seconds

	var body: some View {
		ZStack {
			Color(red: 75 / 255, green: 145 / 255, blue: 241 / 255)
				.edgesIgnoringSafeArea(.all)

			VStack {
				Spacer()
				if contactsOn {
					if let wearStartTime = wearStartTime {
						CountdownView(endTime: wearStartTime.addingTimeInterval(maxWearDuration))
							.frame(height: 300)
						Button("Contacts Off") {
							contactsOn = false
							wearEndTime = Date()
						}
						.buttonStyle(ContactLensButtonStyle())
					}
				} else {
					Button("Contacts On") {
						showingStartOptions = true
					}
					.buttonStyle(ContactLensButtonStyle())
					.actionSheet(isPresented: $showingStartOptions) {
						ActionSheet(
							title: Text("Start Time"),
							message: Text("Choose start time for contact lens wear."),
							buttons: [
								.default(Text("Use Current Time")) {
									wearStartTime = Date()
									contactsOn = true
								},
								.default(Text("Enter Time Manually")) {
									showingTimePicker = true
								},
								.cancel()
							]
						)
					}
					.sheet(isPresented: $showingTimePicker, onDismiss: {
						if wearStartTime != nil {
							contactsOn = true
						}
					}) {
						TimePickerView(selectedTime: $wearStartTime)
					}
				}
				Spacer()
			}
		}
		.navigationBarTitle("Daily Wear Tracker", displayMode: .inline)
	}
}



struct ContactLensButtonStyle: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.white)
			.foregroundColor(.blue)
			.cornerRadius(10)
			.padding(.horizontal)
			.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
	}
}

struct TimePickerView: View {
	@Binding var selectedTime: Date
	@Environment(\.presentationMode) var presentationMode

	init(selectedTime: Binding<Date?>) {
		self._selectedTime = Binding<Date>(
			get: { selectedTime.wrappedValue ?? Date() },
			set: { selectedTime.wrappedValue = $0 }
		)
	}

	var body: some View {
		NavigationView {
			DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
				.datePickerStyle(WheelDatePickerStyle())
				.navigationTitle("Choose Time")
				.navigationBarItems(trailing: Button("Done") {
					presentationMode.wrappedValue.dismiss() // Dismiss the view
				})
		}
	}
}




struct CountdownView: View {
	let endTime: Date
	@State private var timeRemaining: TimeInterval
	let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

	init(endTime: Date) {
		self.endTime = endTime
		self._timeRemaining = State(initialValue: endTime.timeIntervalSinceNow)
	}

	var body: some View {
		VStack {
			Text("Time Contacts Worn For:")
				.font(.headline)
				.foregroundColor(.white)
			Text(timeString(from: timeRemaining))
				.font(.system(size: 30, weight: .bold))
				.foregroundColor(.white)
		}
		.onReceive(timer) { _ in
			let timeLeft = endTime.timeIntervalSinceNow
			if timeLeft <= 0 {
				self.timeRemaining = 0
				self.timer.upstream.connect().cancel()
			} else {
				self.timeRemaining = timeLeft
			}
		}
	}

	func timeString(from timeInterval: TimeInterval) -> String {
		let hours = Int(timeInterval) / 3600
		let minutes = Int(timeInterval) / 60 % 60
		return "\(hours) hours and \(minutes) minutes"
	}
}

struct DailyWearTrackerView_Previews: PreviewProvider {
	static var previews: some View {
		DailyWearTrackerView()
	}
}
