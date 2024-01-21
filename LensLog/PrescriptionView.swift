//
//  PrescriptionView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI
import UIKit

struct PrescriptionView: View {
	@State private var samePrescriptionForBothEyes = UserDefaults.standard.bool(forKey: "samePrescriptionForBothEyes")
	
	// SPH
	@State private var leftEyeSPHIndex = UserDefaults.standard.integer(forKey: "leftEyeSPHIndex")
	@State private var rightEyeSPHIndex = UserDefaults.standard.integer(forKey: "rightEyeSPHIndex")

	// CYL
	@State private var leftEyeCYLIndex = UserDefaults.standard.integer(forKey: "leftEyeCYLIndex")
	@State private var rightEyeCYLIndex = UserDefaults.standard.integer(forKey: "rightEyeCYLIndex")

	// AXIS
	@State private var leftEyeAXISIndex = UserDefaults.standard.integer(forKey: "leftEyeAXISIndex")
	@State private var rightEyeAXISIndex = UserDefaults.standard.integer(forKey: "rightEyeAXISIndex")

	// ADD
	@State private var leftEyeADDIndex = UserDefaults.standard.integer(forKey: "leftEyeADDIndex")
	@State private var rightEyeADDIndex = UserDefaults.standard.integer(forKey: "rightEyeADDIndex")

	// BC
	@State private var leftEyeBCIndex = UserDefaults.standard.integer(forKey: "leftEyeBCIndex")
	@State private var rightEyeBCIndex = UserDefaults.standard.integer(forKey: "rightEyeBCIndex")

	// DIA
	@State private var leftEyeDIAIndex = UserDefaults.standard.integer(forKey: "leftEyeDIAIndex")
	@State private var rightEyeDIAIndex = UserDefaults.standard.integer(forKey: "rightEyeDIAIndex")

	// Brand
	@State private var leftEyeBrandIndex = UserDefaults.standard.integer(forKey: "leftEyeBrandIndex")
	@State private var rightEyeBrandIndex = UserDefaults.standard.integer(forKey: "rightEyeBrandIndex")

	let SPHValues = Array(stride(from: -4.00, through: 4.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let CYLValues = Array(stride(from: -4.00, through: 4.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let AXISValues = (0...180).map { String($0) }
	let ADDValues = Array(stride(from: 0.75, through: 3.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let BCValues = Array(stride(from: 8.0, through: 10.0, by: 0.1)).map { String(format: "%.1f", $0) }
	let DIAValues = Array(stride(from: 13.0, through: 15.0, by: 0.1)).map { String(format: "%.1f", $0) }
	let contactBrands = ["Acuvue", "Air Optix", "Avaira", "Biofinity", "Dailies"]

	@State private var expirationDate = UserDefaults.standard.object(forKey: "expirationDate") as? Date ?? Date()
	@State private var showImagePicker = false
	@State private var prescriptionImage: UIImage?

	var body: some View {
		NavigationView {
			ZStack {
				Color(red: 75 / 255, green: 145 / 255, blue: 241 / 255)
					.edgesIgnoringSafeArea(.all)

				Form {
					Toggle(isOn: $samePrescriptionForBothEyes.onChange(save)) {
						Text("Same Prescription for Both Eyes")
					}

					if samePrescriptionForBothEyes {
						prescriptionSection(title: "Left/Right Eye", eyeSide: .both)
					} else {
						prescriptionSection(title: "Left Eye", eyeSide: .left)
						prescriptionSection(title: "Right Eye", eyeSide: .right)
					}

					Section(header: Text("Expiration Date")) {
						DatePicker("Expiration Date", selection: $expirationDate.onChange(save), displayedComponents: .date)
					}
					

					Section {
						Button(action: {
							self.showImagePicker = true
						}) {
							Text("Upload Prescription Image")
						}
						.sheet(isPresented: $showImagePicker) {
							ImagePicker(image: self.$prescriptionImage)
						}

						if let image = prescriptionImage {
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
						}
					}
				}
				.navigationBarTitle("Contact Lens Prescription", displayMode: .inline)
				.scrollContentBackground(.hidden)
			}
			
			
		}
	}

	private func prescriptionSection(title: String, eyeSide: EyeSide) -> some View {
		Section(header: Text(title)) {
			Picker("Power (SPH)", selection: eyeSide == .left ? $leftEyeSPHIndex : $rightEyeSPHIndex) {
				ForEach(0..<SPHValues.count) {
					Text(self.SPHValues[$0])
				}
			}
			Picker("Cylinder (CYL)", selection: eyeSide == .left ? $leftEyeCYLIndex : $rightEyeCYLIndex) {
				ForEach(0..<CYLValues.count) {
					Text(self.CYLValues[$0])
				}
			}
			Picker("Axis", selection: eyeSide == .left ? $leftEyeAXISIndex : $rightEyeAXISIndex) {
				ForEach(0..<AXISValues.count) {
					Text(self.AXISValues[$0])
				}
			}
			Picker("Add Power", selection: eyeSide == .left ? $leftEyeADDIndex : $rightEyeADDIndex) {
				ForEach(0..<ADDValues.count) {
					Text(self.ADDValues[$0])
				}
			}
			Picker("Base Curve (BC)", selection: eyeSide == .left ? $leftEyeBCIndex : $rightEyeBCIndex) {
				ForEach(0..<BCValues.count) {
					Text(self.BCValues[$0])
				}
			}
			Picker("Diameter (DIA)", selection: eyeSide == .left ? $leftEyeDIAIndex : $rightEyeDIAIndex) {
				ForEach(0..<DIAValues.count) {
					Text(self.DIAValues[$0])
				}
			}
			Picker("Brand", selection: eyeSide == .left ? $leftEyeBrandIndex : $rightEyeBrandIndex) {
				ForEach(0..<contactBrands.count) {
					Text(self.contactBrands[$0])
				}
			}
		}
	}

	func save() {
		UserDefaults.standard.set(samePrescriptionForBothEyes, forKey: "samePrescriptionForBothEyes")

		// Saving SPH values
		UserDefaults.standard.set(SPHValues[leftEyeSPHIndex], forKey: "leftEyeSPH")
		UserDefaults.standard.set(SPHValues[rightEyeSPHIndex], forKey: "rightEyeSPH")

		// Saving CYL values
		UserDefaults.standard.set(CYLValues[leftEyeCYLIndex], forKey: "leftEyeCYL")
		UserDefaults.standard.set(CYLValues[rightEyeCYLIndex], forKey: "rightEyeCYL")

		// Saving AXIS values
		UserDefaults.standard.set(AXISValues[leftEyeAXISIndex], forKey: "leftEyeAXIS")
		UserDefaults.standard.set(AXISValues[rightEyeAXISIndex], forKey: "rightEyeAXIS")

		// Saving ADD values
		UserDefaults.standard.set(ADDValues[leftEyeADDIndex], forKey: "leftEyeADD")
		UserDefaults.standard.set(ADDValues[rightEyeADDIndex], forKey: "rightEyeADD")

		// Saving BC values
		UserDefaults.standard.set(BCValues[leftEyeBCIndex], forKey: "leftEyeBC")
		UserDefaults.standard.set(BCValues[rightEyeBCIndex], forKey: "rightEyeBC")

		// Saving DIA values
		UserDefaults.standard.set(DIAValues[leftEyeDIAIndex], forKey: "leftEyeDIA")
		UserDefaults.standard.set(DIAValues[rightEyeDIAIndex], forKey: "rightEyeDIA")

		// Saving Brand
		UserDefaults.standard.set(contactBrands[leftEyeBrandIndex], forKey: "leftEyeBrand")
		UserDefaults.standard.set(contactBrands[rightEyeBrandIndex], forKey: "rightEyeBrand")

		// Saving the expiration date
		UserDefaults.standard.set(expirationDate, forKey: "expirationDate")
	}

}

extension Binding {
	func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
		Binding(
			get: { self.wrappedValue },
			set: { newValue in
				self.wrappedValue = newValue
				handler()
			}
		)
	}
}

enum EyeSide {
	case left, right, both
}

struct ImagePicker: UIViewControllerRepresentable {
	@Environment(\.presentationMode) var presentationMode
	@Binding var image: UIImage?

	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		let parent: ImagePicker

		init(_ parent: ImagePicker) {
			self.parent = parent
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let uiImage = info[.originalImage] as? UIImage {
				parent.image = uiImage
			}

			parent.presentationMode.wrappedValue.dismiss()
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

	}
}

struct PrescriptionView_Previews: PreviewProvider {
	static var previews: some View {
		PrescriptionView()
	}
}
