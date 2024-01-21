//
//  SettingsView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//


import SwiftUI


struct SettingsButtonView: View {
	let onOptionSelected: (Int) -> Void

	var body: some View {
		Menu {
			Button("Daily Wear") { onOptionSelected(0) }
			Button("Prescription") { onOptionSelected(1) }
			Button("Settings") { onOptionSelected(2) }
		} label: {
			Image(systemName: "gear")
				.padding(5)
				.background(Color.white)
				.foregroundColor(Color.blue)
				.clipShape(Circle())
		}
	}
}

// Preview for SettingsButtonView
struct SettingsButtonView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsButtonView(onOptionSelected: { _ in })
			.previewLayout(.sizeThatFits)
			.padding()
			.background(Color(red: 75 / 255, green: 145 / 255, blue: 241 / 255))
	}
}
