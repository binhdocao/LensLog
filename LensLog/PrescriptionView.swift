//
//  PrescriptionView.swift
//  LensLog
//
//  Created by Binh Do-Cao on 1/20/24.
//

import Foundation
import SwiftUI
import UIKit


func loadContactBrands(from fileName: String) -> [String] {
	guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
		print("CSV file not found")
		return []
	}

	do {
		let data = try String(contentsOfFile: filePath)
		var brands: [String] = []
		let rows = data.components(separatedBy: "\n")
		for row in rows {
			let brand = row.trimmingCharacters(in: .whitespacesAndNewlines)
			if !brand.isEmpty {
				brands.append(brand)
			}
		}
		return brands
	} catch {
		print("Error reading CSV file: \(error)")
		return []
	}
}


struct PrescriptionView: View {
	@State private var samePrescriptionForBothEyes = UserDefaults.standard.bool(forKey: "samePrescriptionForBothEyes")
	
	// SPH
	@State private var leftEyeSPHIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeSPHIndex") as? Int
	@State private var rightEyeSPHIndex: Int? = UserDefaults.standard.object(forKey: "rightEyeSPHIndex") as? Int

	// CYL
	@State private var leftEyeCYLIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeCYLIndex") as? Int
	@State private var rightEyeCYLIndex: Int? = UserDefaults.standard.object(forKey: "rightEyeCYLIndex") as? Int

	// AXIS
	@State private var leftEyeAXISIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeAXISIndex") as? Int
	@State private var rightEyeAXISIndex: Int? = UserDefaults.standard.object(forKey: "rightEyeAXISIndex") as? Int

	// ADD
	@State private var leftEyeADDIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeADDIndex") as? Int
	@State private var rightEyeADDIndex: Int? = UserDefaults.standard.object(forKey: "rightEyeADDIndex") as? Int

	// BC
	@State private var leftEyeBCIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeBCIndex") as? Int
	@State private var rightEyeBCIndex: Int? =  UserDefaults.standard.object(forKey: "rightEyeBCIndex") as? Int

	// DIA
	@State private var leftEyeDIAIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeDIAIndex") as? Int
	@State private var rightEyeDIAIndex: Int? = UserDefaults.standard.object(forKey: "rightEyeDIAIndex") as? Int

	// Brand
	@State private var leftEyeBrandIndex: Int? = UserDefaults.standard.object(forKey: "leftEyeBrandIndex") as? Int
	@State private var rightEyeBrandIndex: Int? = UserDefaults.standard.object(forKey: "rightEyeBrandIndex") as? Int

	let SPHValues = Array(stride(from: -10.00, through: 8.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let CYLValues = Array(stride(from: -4.00, through: 4.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let AXISValues = (0...180).map { String($0) }
	let ADDValues = Array(stride(from: 0.75, through: 3.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let BCValues = Array(stride(from: 8.0, through: 10.0, by: 0.1)).map { String(format: "%.1f", $0) }
	let DIAValues = Array(stride(from: 13.0, through: 15.0, by: 0.1)).map { String(format: "%.1f", $0) }
	let contactBrands = loadContactBrands(from: "ContactBrands")

	@State private var expirationDate: Date? = UserDefaults.standard.object(forKey: "expirationDate") as? Date
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

					Section(header: Text("Expiration Date").foregroundColor(.white)) {
						if let expirationDate = expirationDate {
							DatePicker("Expiration Date", selection: Binding($expirationDate)!, displayedComponents: .date)
						} else {
							Button("Set Expiration Date") {
								expirationDate = Date() // Or any default date you want to start with
							}
						}
					}
					.onChange(of: expirationDate) { newValue, _ in save() }
					

					Section(header: Text("Prescription").foregroundColor(.white)) {
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
		Section(header: Text(title).foregroundColor(.white)) {
			// Power (SPH) Picker
			Picker("Power (SPH)", selection: eyeSide == .left ? $leftEyeSPHIndex : $rightEyeSPHIndex) {
				Text("Select SPH").tag(Int?.none) // Option for no selection
				ForEach(0..<SPHValues.count, id: \.self) {
					Text(self.SPHValues[$0]).tag(Int?.some($0))
				}
			}

			// Cylinder (CYL) Picker
			Picker("Cylinder (CYL)", selection: eyeSide == .left ? $leftEyeCYLIndex : $rightEyeCYLIndex) {
				Text("Select CYL").tag(Int?.none)
				ForEach(0..<CYLValues.count, id: \.self) {
					Text(self.CYLValues[$0]).tag(Int?.some($0))
				}
			}

			// Axis Picker
			Picker("Axis", selection: eyeSide == .left ? $leftEyeAXISIndex : $rightEyeAXISIndex) {
				Text("Select Axis").tag(Int?.none)
				ForEach(0..<AXISValues.count, id: \.self) {
					Text(self.AXISValues[$0]).tag(Int?.some($0))
				}
			}

			// Add Power Picker
			Picker("Add Power", selection: eyeSide == .left ? $leftEyeADDIndex : $rightEyeADDIndex) {
				Text("Select Add Power").tag(Int?.none)
				ForEach(0..<ADDValues.count, id: \.self) {
					Text(self.ADDValues[$0]).tag(Int?.some($0))
				}
			}

			// Base Curve (BC) Picker
			Picker("Base Curve (BC)", selection: eyeSide == .left ? $leftEyeBCIndex : $rightEyeBCIndex) {
				Text("Select BC").tag(Int?.none)
				ForEach(0..<BCValues.count, id: \.self) {
					Text(self.BCValues[$0]).tag(Int?.some($0))
				}
			}

			// Diameter (DIA) Picker
			Picker("Diameter (DIA)", selection: eyeSide == .left ? $leftEyeDIAIndex : $rightEyeDIAIndex) {
				Text("Select DIA").tag(Int?.none)
				ForEach(0..<DIAValues.count, id: \.self) {
					Text(self.DIAValues[$0]).tag(Int?.some($0))
				}
			}

			// Brand Picker
			Picker("Brand", selection: eyeSide == .left ? $leftEyeBrandIndex : $rightEyeBrandIndex) {
				Text("Select Brand").tag(Int?.none)
				ForEach(0..<contactBrands.count, id: \.self) {
					Text(self.contactBrands[$0]).tag(Int?.some($0))
				}
			}
		}
	}

	func save() {
		UserDefaults.standard.set(samePrescriptionForBothEyes, forKey: "samePrescriptionForBothEyes")

		// Saving SPH values
		if let index = leftEyeSPHIndex {
			UserDefaults.standard.set(SPHValues[index], forKey: "leftEyeSPH")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeSPH")
		}

		if let index = rightEyeSPHIndex {
			UserDefaults.standard.set(SPHValues[index], forKey: "rightEyeSPH")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeSPH")
		}

		// Saving CYL values
		if let index = leftEyeCYLIndex {
			UserDefaults.standard.set(CYLValues[index], forKey: "leftEyeCYL")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeCYL")
		}

		if let index = rightEyeCYLIndex {
			UserDefaults.standard.set(CYLValues[index], forKey: "rightEyeCYL")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeCYL")
		}

		// Saving AXIS values
		if let index = leftEyeAXISIndex {
			UserDefaults.standard.set(AXISValues[index], forKey: "leftEyeAXIS")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeAXIS")
		}

		if let index = rightEyeAXISIndex {
			UserDefaults.standard.set(AXISValues[index], forKey: "rightEyeAXIS")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeAXIS")
		}

		// Saving ADD values
		if let index = leftEyeADDIndex {
			UserDefaults.standard.set(ADDValues[index], forKey: "leftEyeADD")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeADD")
		}

		if let index = rightEyeADDIndex {
			UserDefaults.standard.set(ADDValues[index], forKey: "rightEyeADD")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeADD")
		}

		// Saving BC values
		if let index = leftEyeBCIndex {
			UserDefaults.standard.set(BCValues[index], forKey: "leftEyeBC")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeBC")
		}

		if let index = rightEyeBCIndex {
			UserDefaults.standard.set(BCValues[index], forKey: "rightEyeBC")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeBC")
		}

		// Saving DIA values
		if let index = leftEyeDIAIndex {
			UserDefaults.standard.set(DIAValues[index], forKey: "leftEyeDIA")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeDIA")
		}

		if let index = rightEyeDIAIndex {
			UserDefaults.standard.set(DIAValues[index], forKey: "rightEyeDIA")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeDIA")
		}

		// Saving Brand
		if let index = leftEyeBrandIndex {
			UserDefaults.standard.set(contactBrands[index], forKey: "leftEyeBrand")
		} else {
			UserDefaults.standard.removeObject(forKey: "leftEyeBrand")
		}

		if let index = rightEyeBrandIndex {
			UserDefaults.standard.set(contactBrands[index], forKey: "rightEyeBrand")
		} else {
			UserDefaults.standard.removeObject(forKey: "rightEyeBrand")
		}

		// Saving the expiration date if it's not nil
		if let expirationDate = expirationDate {
			UserDefaults.standard.set(expirationDate, forKey: "expirationDate")
		} else {
			UserDefaults.standard.removeObject(forKey: "expirationDate")
		}
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
