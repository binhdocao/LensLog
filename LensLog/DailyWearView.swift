//
//  DailyWearView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI
import EventKit

struct DailyWearTrackerView: View {
	@State private var contactsOn = false {
		didSet {
			UserDefaults.standard.set(contactsOn, forKey: "contactsOn")
			if !contactsOn {
				wearStartTime = nil // Resetting start time when contacts are off
			}
		}
	}
	@State private var wearStartTime: Date? {
		didSet {
			if let startTime = wearStartTime {
				UserDefaults.standard.set(startTime, forKey: "wearStartTime")
			} else {
				UserDefaults.standard.removeObject(forKey: "wearStartTime")
			}
		}
	}
	@State private var wearEndTime: Date?
	@State private var showingTimePicker = false
	@State private var showingStartOptions = false
	@State private var wearHistory: [Date: TimeInterval] = [:] {
		didSet {
			saveWearHistory()
		}
	}

	init() {
		if let savedContactsOn = UserDefaults.standard.object(forKey: "contactsOn") as? Bool {
			_contactsOn = State(initialValue: savedContactsOn)
		}
		if let savedStartTime = UserDefaults.standard.object(forKey: "wearStartTime") as? Date {
			_wearStartTime = State(initialValue: savedStartTime)
		}
		loadWearHistory()
	}
	private func saveWearHistory() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(wearHistory.mapKeys { $0.timeIntervalSince1970 }) {
			UserDefaults.standard.set(encoded, forKey: "wearHistory")
		}
	}

	private func loadWearHistory() {
		if let savedHistory = UserDefaults.standard.object(forKey: "wearHistory") as? Data {
			let decoder = JSONDecoder()
			if let loadedHistory = try? decoder.decode([TimeInterval: TimeInterval].self, from: savedHistory) {
				wearHistory = loadedHistory.mapKeys { Date(timeIntervalSince1970: $0) }
			}
		}
	}
	
	
	var body: some View {
		ZStack {
			Color(red: 75 / 255, green: 145 / 255, blue: 241 / 255)
				.edgesIgnoringSafeArea(.all)

			VStack {
				// Calendar view to display wear history
				CalendarView(wearHistory: wearHistory)
					.frame(height: 400)

				Spacer()

				if contactsOn {
					if let wearStartTime = wearStartTime {
						WearDurationView(startTime: wearStartTime)
							.frame(height: 300)
						Button("Contacts Off") {
							contactsOn = false
							wearEndTime = Date()
							if let wearEndTime = wearEndTime {
								let duration = wearEndTime.timeIntervalSince(wearStartTime)
								// Assuming we want to store the duration against the start date
								wearHistory[wearStartTime] = duration
							}
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

extension Dictionary {
	func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> Dictionary<T, Value> {
		Dictionary<T, Value>(uniqueKeysWithValues: try map { (key, value) in (try transform(key), value) })
	}
}

// New view to display wear duration
struct WearDurationView: View {
	let startTime: Date
	@State private var timeWorn: TimeInterval = 0
	let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

	var body: some View {
		VStack {
			Text("Time Contacts Worn For:")
				.font(.headline)
				.foregroundColor(.white)
			Text(timeString(from: timeWorn))
				.font(.system(size: 30, weight: .bold))
				.foregroundColor(.white)
		}
		.onReceive(timer) { _ in
			self.timeWorn = Date().timeIntervalSince(startTime)
		}
	}

	func timeString(from timeInterval: TimeInterval) -> String {
		let hours = Int(timeInterval) / 3600
		let minutes = Int(timeInterval) / 60 % 60
		return "\(hours) hours and \(minutes) minutes"
	}
}

// New view to display a calendar with wear history
struct CalendarView: View {
	var wearHistory: [Date: TimeInterval]

	var body: some View {
		// Implement a calendar view that shows the days and the wear duration for each day
		// You can use a third-party library or SwiftUI's capabilities to create a calendar view
		Text("Calendar View") // Placeholder for the actual calendar view
	}
}

// Rest of the existing views (ContactLensButtonStyle, TimePickerView, DailyWearTrackerView_Previews)




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



struct DailyWearTrackerView_Previews: PreviewProvider {
	static var previews: some View {
		DailyWearTrackerView()
	}
}
