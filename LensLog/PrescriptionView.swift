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
	let CYLValues = Array(stride(from: -5.00, through: 5.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let AXISValues = (1...180).map { String($0) }
	let ADDValues = Array(stride(from: 0.0, through: 3.00, by: 0.25)).map { String(format: "%+.2f", $0) }
	let BCValues = Array(stride(from: 8.0, through: 10.0, by: 0.1)).map { String(format: "%.1f", $0) }
	let DIAValues = Array(stride(from: 13.0, through: 15.0, by: 0.1)).map { String(format: "%.1f", $0) }
	let contactBrands = loadContactBrands(from: "ContactBrands")

	@State private var expirationDate: Date? = UserDefaults.standard.object(forKey: "expirationDate") as? Date
	@State private var showImagePicker = false
	@State private var prescriptionImage: UIImage? {
		didSet {
			save()
		}
	}
	private func imageSelected(_ image: UIImage?) {
		self.prescriptionImage = image
		self.save()
		print("Image selected and saved")
	}

	
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
							Text("Upload Image")
								.foregroundColor(.black)
								.padding(9)
								.frame(maxWidth: .infinity)
								.background(Color(.systemGray6)) // Choose a color that contrasts well
								.cornerRadius(10)
						}
						.sheet(isPresented: $showImagePicker) {
							ImagePicker(image: self.$prescriptionImage, onImagePicked: imageSelected)
						}

						if let image = prescriptionImage {
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
						}
					}
				}
				.accentColor(.white)
				.navigationBarTitle("Contact Lens Prescription", displayMode: .inline)
				.scrollContentBackground(.hidden)
			}
			
			
		}
		.onAppear(perform: loadPrescriptionData)
	}

	private func prescriptionSection(title: String, eyeSide: EyeSide) -> some View {
		Section(header: Text(title).foregroundColor(.white)) {
			// Power (SPH) Picker
			Picker("Power (SPH)", selection: binding(for: eyeSide == .left ? $leftEyeSPHIndex : $rightEyeSPHIndex)) {
				Text("Select SPH").tag(Int?.none) // Option for no selection
				ForEach(0..<SPHValues.count, id: \.self) {
					Text(self.SPHValues[$0]).tag(Int?.some($0))
				}
			}

			// Cylinder (CYL) Picker
			Picker("Cylinder (CYL)", selection: binding(for: eyeSide == .left ? $leftEyeCYLIndex : $rightEyeCYLIndex)) {
				Text("Select CYL").tag(Int?.none)
				ForEach(0..<CYLValues.count, id: \.self) {
					Text(self.CYLValues[$0]).tag(Int?.some($0))
				}
			}

			// Axis Picker
			Picker("Axis", selection: binding(for: eyeSide == .left ? $leftEyeAXISIndex : $rightEyeAXISIndex)) {
				Text("Select Axis").tag(Int?.none)
				ForEach(0..<AXISValues.count, id: \.self) {
					Text(self.AXISValues[$0]).tag(Int?.some($0))
				}
			}

			// Add Power Picker
			Picker("Add Power", selection: binding(for: eyeSide == .left ? $leftEyeADDIndex : $rightEyeADDIndex)) {
				Text("Select Add Power").tag(Int?.none)
				ForEach(0..<ADDValues.count, id: \.self) {
					Text(self.ADDValues[$0]).tag(Int?.some($0))
				}
			}

			// Base Curve (BC) Picker
			Picker("Base Curve (BC)", selection: binding(for: eyeSide == .left ? $leftEyeBCIndex : $rightEyeBCIndex)) {
				Text("Select BC").tag(Int?.none)
				ForEach(0..<BCValues.count, id: \.self) {
					Text(self.BCValues[$0]).tag(Int?.some($0))
				}
			}

			// Diameter (DIA) Picker
			Picker("Diameter (DIA)", selection: binding(for: eyeSide == .left ? $leftEyeDIAIndex : $rightEyeDIAIndex)) {
				Text("Select DIA").tag(Int?.none)
				ForEach(0..<DIAValues.count, id: \.self) {
					Text(self.DIAValues[$0]).tag(Int?.some($0))
				}
			}

			// Brand Picker
			Picker("Brand", selection: binding(for: eyeSide == .left ? $leftEyeBrandIndex : $rightEyeBrandIndex)) {
				Text("Select Brand").tag(Int?.none)
				ForEach(0..<contactBrands.count, id: \.self) {
					Text(self.contactBrands[$0]).tag(Int?.some($0))
				}
			}
		}
	}

	private func binding<T>(for state: Binding<T>) -> Binding<T> {
		Binding(
			get: { state.wrappedValue },
			set: { newValue in
				state.wrappedValue = newValue
				save()
			}
		)
	}
	

	private func loadPrescriptionData() {
		let defaults = UserDefaults.standard
		
		print("Loading prescription data")
		
		// Load 'samePrescriptionForBothEyes'
		samePrescriptionForBothEyes = defaults.bool(forKey: "samePrescriptionForBothEyes")

		// Load 'SPH' values
		leftEyeSPHIndex = defaults.object(forKey: "leftEyeSPHIndex") as? Int
		rightEyeSPHIndex = defaults.object(forKey: "rightEyeSPHIndex") as? Int

		// Load 'CYL' values
		leftEyeCYLIndex = defaults.object(forKey: "leftEyeCYLIndex") as? Int
		rightEyeCYLIndex = defaults.object(forKey: "rightEyeCYLIndex") as? Int

		// Load 'AXIS' values
		leftEyeAXISIndex = defaults.object(forKey: "leftEyeAXISIndex") as? Int
		rightEyeAXISIndex = defaults.object(forKey: "rightEyeAXISIndex") as? Int

		// Load 'ADD' values
		leftEyeADDIndex = defaults.object(forKey: "leftEyeADDIndex") as? Int
		rightEyeADDIndex = defaults.object(forKey: "rightEyeADDIndex") as? Int

		// Load 'BC' values
		leftEyeBCIndex = defaults.object(forKey: "leftEyeBCIndex") as? Int
		rightEyeBCIndex = defaults.object(forKey: "rightEyeBCIndex") as? Int

		// Load 'DIA' values
		leftEyeDIAIndex = defaults.object(forKey: "leftEyeDIAIndex") as? Int
		rightEyeDIAIndex = defaults.object(forKey: "rightEyeDIAIndex") as? Int

		// Load 'Brand' values
		leftEyeBrandIndex = defaults.object(forKey: "leftEyeBrandIndex") as? Int
		rightEyeBrandIndex = defaults.object(forKey: "rightEyeBrandIndex") as? Int

		// Load 'expirationDate'
		expirationDate = defaults.object(forKey: "expirationDate") as? Date
		
		prescriptionImage = loadImageFromFile()
		if prescriptionImage != nil {
			print("Prescription image set from file")
		} else {
			print("No prescription image found in file")
		}
	}
	


	
	func save() {
		let defaults = UserDefaults.standard
		print("Saving prescription data")
		// Helper function to either save a value or remove the key if the value is nil
		func saveOrRemove<T>(_ key: String, value: T?) {
			if let value = value {
				defaults.set(value, forKey: key)
			} else {
				defaults.removeObject(forKey: key)
			}
		}


		// Save 'samePrescriptionForBothEyes'
		saveOrRemove("samePrescriptionForBothEyes", value: samePrescriptionForBothEyes)

		// Save 'SPH' values
		saveOrRemove("leftEyeSPHIndex", value: leftEyeSPHIndex)
		saveOrRemove("rightEyeSPHIndex", value: rightEyeSPHIndex)

		// Save 'CYL' values
		saveOrRemove("leftEyeCYLIndex", value: leftEyeCYLIndex)
		saveOrRemove("rightEyeCYLIndex", value: rightEyeCYLIndex)

		// Save 'AXIS' values
		saveOrRemove("leftEyeAXISIndex", value: leftEyeAXISIndex)
		saveOrRemove("rightEyeAXISIndex", value: rightEyeAXISIndex)

		// Save 'ADD' values
		saveOrRemove("leftEyeADDIndex", value: leftEyeADDIndex)
		saveOrRemove("rightEyeADDIndex", value: rightEyeADDIndex)

		// Save 'BC' values
		saveOrRemove("leftEyeBCIndex", value: leftEyeBCIndex)
		saveOrRemove("rightEyeBCIndex", value: rightEyeBCIndex)

		// Save 'DIA' values
		saveOrRemove("leftEyeDIAIndex", value: leftEyeDIAIndex)
		saveOrRemove("rightEyeDIAIndex", value: rightEyeDIAIndex)

		// Save 'Brand' values
		saveOrRemove("leftEyeBrandIndex", value: leftEyeBrandIndex)
		saveOrRemove("rightEyeBrandIndex", value: rightEyeBrandIndex)

		// Save 'expirationDate'
		if let expirationDate = expirationDate {
			defaults.set(expirationDate, forKey: "expirationDate")
		} else {
			defaults.removeObject(forKey: "expirationDate")
		}
		
		if let image = prescriptionImage {
			saveImageToFile(image)
		} else {
			deleteImageFile()
		}
		
		print("Finished saving prescription data")
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
	
	var onImagePicked: (UIImage?) -> Void
	
	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		let parent: ImagePicker

		init(_ parent: ImagePicker) {
			self.parent = parent
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let uiImage = info[.originalImage] as? UIImage {
				parent.onImagePicked(uiImage)
			}
			parent.presentationMode.wrappedValue.dismiss()
		}
	}


	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
		// This function can be empty if no update needed.
	}
}


func getDocumentsDirectory() -> URL {
	print("get doc")
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}

func saveImageToFile(_ image: UIImage) {
	print("Saving Image to File")
	if let data = image.jpegData(compressionQuality: 1) ?? image.pngData() {
		let filename = getDocumentsDirectory().appendingPathComponent("prescriptionImage.jpg")
		do {
			try data.write(to: filename)
			UserDefaults.standard.set(filename.path, forKey: "prescriptionImagePath")
			print("Image successfully saved at \(filename.path)")
		} catch {
			print("Error saving image: \(error)")
		}
	} else {
		print("Error: Could not convert image to data")
	}
}


func loadImageFromFile() -> UIImage? {
	print("Load Image from File")
	if let imagePath = UserDefaults.standard.string(forKey: "prescriptionImagePath"),
	   let image = UIImage(contentsOfFile: imagePath) {
		print("Image loaded from path: \(imagePath)")
		return image
	} else {
		print("Failed to load image from path")
	}
	return nil
}

func deleteImageFile() {
	if let imagePath = UserDefaults.standard.string(forKey: "prescriptionImagePath") {
		let fileManager = FileManager.default
		let url = URL(fileURLWithPath: imagePath)
		try? fileManager.removeItem(at: url)
		UserDefaults.standard.removeObject(forKey: "prescriptionImagePath")
	}
}



struct PrescriptionView_Previews: PreviewProvider {
	static var previews: some View {
		PrescriptionView()
	}
}
