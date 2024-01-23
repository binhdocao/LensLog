//
//  TrackerView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI
import UserNotifications

struct ContactLensTrackerView: View {
	@State private var numberOfPairs: Int = UserDefaults.standard.integer(forKey: "numberOfPairs")
	@State private var contactType: ContactType = .daily
	@State private var startDate: Date = UserDefaults.standard.object(forKey: "startDate") as? Date ?? Date()
	@State private var currentPairAdded: Bool = UserDefaults.standard.bool(forKey: "currentPairAdded")
	@State private var showingAddNewPairSheet = false
	@State private var showNotificationAlert = false
	@State private var shouldNavigateToOtherView1 = false
	@State private var shouldNavigateToOtherView2 = false
	
	@State private var showingBottomSheet = false

	@State private var showingResetConfirmation = false
	
	@State private var progress: Double = 0.0
	let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
	
	
	enum ContactType: String, CaseIterable, Identifiable {
		case daily = "Daily"
		case monthly = "Monthly"

		var id: String { self.rawValue }
		var durationInDays: Int {
			switch self {
			case .daily: return 1
			case .monthly: return 30
			}
		}
	}

	var body: some View {
		NavigationStack {
			ZStack {
				Color(red: 75 / 255, green: 145 / 255, blue: 241 / 255)
					.edgesIgnoringSafeArea(.all)
				
				VStack {
					HStack {
						SettingsButtonView { selectedOption in
							// Handle the selection from settings
							handleOptionSelected(selectedOption)
						}
						
						Spacer()
						// Other elements in the header
					}
					.padding(.leading)
					
					Spacer()
					Circle()
						.stroke(lineWidth: 20)
						 .foregroundColor(.white)
						 .frame(width: 300, height: 300)
						 .overlay(
							 VStack {
								 Text("\(daysRemaining())")
									 .font(.system(size: 80, weight: .bold))
									 .foregroundColor(.white)
								 Text("Days Remaining")
									 .font(.title)
									 .foregroundColor(.white)
							 }
						 )
					
					Text("You have \(numberOfPairs) unopened pairs left")
						.foregroundColor(.white)
						.padding()
					
					if !currentPairAdded {
						Button("ADD NEW PAIR") {
							showingAddNewPairSheet = true
						}
						.padding()
						.frame(maxWidth: .infinity)
						.background(Color.white)
						.foregroundColor(.blue)
						.cornerRadius(10)
						.padding(.horizontal)
					}
					
					// Display the start date
					Text("Start Date: \(startDate, formatter: dateFormatter)")
						.foregroundColor(.white)

					// Display the calculated end date
					Text("End Date: \(calculateEndDate(), formatter: dateFormatter)")
						.foregroundColor(.white)
					
					
					Spacer()
					
					
					Button(action: {
						withAnimation {
							showingBottomSheet.toggle()
						}
					}) {
						Image(systemName: "chevron.up")
							.rotationEffect(.degrees(showingBottomSheet ? 180 : 0))
							.padding()
							.background(Color.white)
							.clipShape(Circle())
							.foregroundColor(.blue)
					}
				}
				// Hidden Navigation Links
				NavigationLink("", isActive: $shouldNavigateToOtherView1) {
					DailyWearTrackerView() // Replace with actual view
				}.hidden()

				NavigationLink("", isActive: $shouldNavigateToOtherView2) {
					PrescriptionView() // Replace with actual view
				}.hidden()
			}
		}
		.accentColor(.white)
		.navigationBarTitle("Lens Usage Tracker", displayMode: .inline)
		.sheet(isPresented: $showingAddNewPairSheet) {
			AddNewPairSheet(isCurrentPairAdded: $currentPairAdded, numberOfPairs: $numberOfPairs, contactType: $contactType, startDate: $startDate)
		}
		.bottomSheet(isPresented: $showingBottomSheet) {
			// Content of your bottom sheet
			VStack(spacing: 20) {
				Text("Options").font(.headline)
				
				Button("Reset Duration of Current Pair") {
					showingResetConfirmation = true // Show confirmation alert
				}
				.alert(isPresented: $showingResetConfirmation) {
					Alert(
						title: Text("Reset Duration"),
						message: Text("Are you sure you want to reset the duration of the current pair?"),
						primaryButton: .destructive(Text("Reset")) {
							// Perform the reset
							currentPairAdded = true
							numberOfPairs -= 1
							startDate = Date() // Set start date to current date
							save() // Save the changes
						},
						secondaryButton: .cancel()
					)
				}
				
				Button("Reset Start Date") {
					// Perform reset
//					showingDatePicker = true
				}
				
				Button("Modify Contact Type") {
					// Show options to modify contact type
				}
			}
			.padding()
		}
		.onAppear(perform: load)
	}

	
	// Function to calculate the end date based on the start date and contact type duration
	func calculateEndDate() -> Date {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: contactType.durationInDays, to: startDate)!
	}

	// DateFormatter to format the displayed dates
	var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}
	
	func handleOptionSelected(_ option: Int) {
		// Navigation handling
		switch option {
		case 0:
			shouldNavigateToOtherView1 = true
		case 1:
			shouldNavigateToOtherView2 = true
		default:
			break
		}
	}
	

	func daysRemaining() -> Int {
		let calendar = Calendar.current
		let endDate = calendar.date(byAdding: .day, value: contactType.durationInDays, to: startDate)!
		return calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
	}

	func load() {
		let defaults = UserDefaults.standard
		self.numberOfPairs = defaults.integer(forKey: "numberOfPairs")
		self.contactType = ContactType(rawValue: defaults.string(forKey: "contactType") ?? "Daily") ?? .daily
		self.startDate = defaults.object(forKey: "startDate") as? Date ?? Date()
	}

	func save() {
		let defaults = UserDefaults.standard
		defaults.set(self.numberOfPairs, forKey: "numberOfPairs")
		defaults.set(self.contactType.rawValue, forKey: "contactType")
		defaults.set(self.startDate, forKey: "startDate")
		defaults.set(self.currentPairAdded, forKey: "currentPairAdded")
	}
}


struct AddNewPairSheet: View {
	@Binding var isCurrentPairAdded: Bool
	@Binding var numberOfPairs: Int
	@Binding var contactType: ContactLensTrackerView.ContactType
	@Binding var startDate: Date
	@Environment(\.presentationMode) var presentationMode

	var body: some View {
		NavigationView {
			Form {
				Picker("Type", selection: $contactType) {
					Text("Daily").tag(ContactLensTrackerView.ContactType.daily)
					Text("Monthly").tag(ContactLensTrackerView.ContactType.monthly)
				}
				.pickerStyle(SegmentedPickerStyle())

				Button("Save") {
					isCurrentPairAdded = true // Mark that the current pair has been added
					numberOfPairs += 1
					startDate = Date() // Reset the start date for the new pair
					saveData()
					scheduleNotification()
					presentationMode.wrappedValue.dismiss()
				}
			}
			.navigationBarTitle("Add New Pair", displayMode: .inline)
			.navigationBarItems(trailing: Button("Cancel") {
				presentationMode.wrappedValue.dismiss()
			})
		}
	}

	private func saveData() {
		let defaults = UserDefaults.standard
		defaults.set(numberOfPairs, forKey: "numberOfPairs")
		defaults.set(contactType.rawValue, forKey: "contactType")
		defaults.set(startDate, forKey: "startDate")
		defaults.set(isCurrentPairAdded, forKey: "currentPairAdded")
	}

	private func scheduleNotification() {
		let content = UNMutableNotificationContent()
		content.title = "Replace Contacts"
		content.body = "It's time to replace your contact lenses."
		content.sound = .default

		let triggerDate = Calendar.current.date(byAdding: .day, value: contactType.durationInDays, to: startDate)!
		let triggerDaily = Calendar.current.dateComponents([.year,.month,.day], from: triggerDate)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)

		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error {
				print("Error scheduling notification: \(error)")
			}
		}
	}
	
}

struct BottomSheetView<Content: View>: View {
	let content: Content
	@Binding var isPresented: Bool

	init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
		self._isPresented = isPresented
		self.content = content()
	}

	var body: some View {
		if isPresented {
			ZStack {
				// Dimmed background
				Color.black.opacity(0.4)
					.edgesIgnoringSafeArea(.all)
					.onTapGesture {
						withAnimation {
							isPresented = false
						}
					}
				
				// Actual bottom sheet content
				VStack {
					Spacer()
					VStack {
						content
					}
					.frame(maxWidth: .infinity)
					.background(Color.white)
					.cornerRadius(10)
				}
				.transition(.move(edge: .bottom))
			}
			.zIndex(2) // Ensure it's above other content
		}
	}
}

// Extend View to use the bottom sheet more easily
extension View {
	func bottomSheet<Content: View>(
		isPresented: Binding<Bool>,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		self
			.overlay(
				BottomSheetView(isPresented: isPresented, content: content)
			)
	}
}


struct ContactLensTrackerView_Previews: PreviewProvider {
	static var previews: some View {
		ContactLensTrackerView()
	}
}
