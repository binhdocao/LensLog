//
//  HomePageView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI

struct HomePageView: View {
	@State private var samePrescriptionForBothEyes = false
	@State private var leftEyePrescription = ""
	@State private var rightEyePrescription = ""
	@State private var leftEyeCylinder = ""
	@State private var rightEyeCylinder = ""
	@State private var leftEyeAxis = ""
	@State private var rightEyeAxis = ""
	@State private var addPower = ""
	@State private var dominantEye = "Right"
	@State private var brand = ""
	@State private var baseCurve = ""
	@State private var diameter = ""
	@State private var expirationDate = Date()

	var dominantEyeOptions = ["Right", "Left"]
	var contactBrands = ["Brand A", "Brand B", "Brand C", "Brand D"] // Example brands

	var body: some View {
		NavigationView {
			Form {
				Toggle(isOn: $samePrescriptionForBothEyes) {
					Text("Same Prescription for Both Eyes")
				}

				Section(header: Text("Left Eye")) {
					TextField("Power (SPH)", text: $leftEyePrescription)
					TextField("Cylinder (CYL)", text: $leftEyeCylinder)
					TextField("Axis", text: $leftEyeAxis)
				}

				if !samePrescriptionForBothEyes {
					Section(header: Text("Right Eye")) {
						TextField("Power (SPH)", text: $rightEyePrescription)
						TextField("Cylinder (CYL)", text: $rightEyeCylinder)
						TextField("Axis", text: $rightEyeAxis)
					}
				}

				Section(header: Text("Additional Details")) {
					TextField("Add Power (for Presbyopia)", text: $addPower)
					Picker("Dominant Eye", selection: $dominantEye) {
						ForEach(dominantEyeOptions, id: \.self) {
							Text($0)
						}
					}
					TextField("Base Curve (BC)", text: $baseCurve)
					TextField("Diameter (DIA)", text: $diameter)
					Picker("Brand", selection: $brand) {
						ForEach(contactBrands, id: \.self) {
							Text($0)
						}
					}
					DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
				}
			}
			.navigationBarTitle("Contact Lens Prescription", displayMode: .inline)
		}
	}
}

struct HomePageView_Previews: PreviewProvider {
	static var previews: some View {
		HomePageView()
	}
}
