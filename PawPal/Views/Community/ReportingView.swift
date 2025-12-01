import SwiftUI
import CoreLocation

struct ReportingView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var service = ReportService()
    @State private var petName: String = ""
    @State private var animalType: String = "Dog"
    @State private var breed: String = ""
    @State private var color: String = ""
    @State private var descriptionText: String = ""
    @State private var pickedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero header keeps this screen visually aligned with the rest of the app.
                    VStack(spacing: 8) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text("Report Lost Pet")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Help bring pets home safely")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    VStack(spacing: 24) {
                        // Photo Section
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Pet Photo", systemImage: "photo")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let img = pickedImage {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)
                                    
                                    Button(action: { pickedImage = nil }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                    }
                                    .padding(8)
                                }
                            } else {
                                Button(action: { showImagePicker = true }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.blue)
                                        Text("Add Photo")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        Text("Help others identify your pet")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 180)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Pet Information Section (name/species/breed/color)
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Pet Information", systemImage: "info.circle")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 16) {
                                CustomTextField(icon: "textformat", placeholder: "Pet's Name", text: $petName)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "pawprint")
                                            .foregroundColor(.secondary)
                                        Text("Animal Type")
                                            .foregroundColor(.secondary)
                                    }
                                    .font(.subheadline)
                                    
                                    Picker("Type", selection: $animalType) {
                                        Text("Dog").tag("Dog")
                                        Text("Cat").tag("Cat")
                                        Text("Bird").tag("Bird")
                                        Text("Other").tag("Other")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                CustomTextField(icon: "flame", placeholder: "Breed (optional)", text: $breed)
                                CustomTextField(icon: "paintpalette", placeholder: "Color/Markings", text: $color)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Additional Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Additional Details", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TextEditor(text: $descriptionText)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                
                                if descriptionText.isEmpty {
                                    Text("Describe unique features, behavior, last seen location...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Location Section shows whether CoreLocation is ready.
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Location", systemImage: "location.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: locationManager.location != nil ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(locationManager.location != nil ? .green : .orange)
                                
                                if let loc = locationManager.location {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Current Location")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("\(String(format: "%.4f", loc.coordinate.latitude)), \(String(format: "%.4f", loc.coordinate.longitude))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("Location services not available")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        
                        // Submit Button
                        Button(action: submit) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Submit Report")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSubmit ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!canSubmit || isSubmitting)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $pickedImage)
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Your lost pet report has been submitted. We'll notify nearby users.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canSubmit: Bool {
        !petName.isEmpty && !color.isEmpty && locationManager.location != nil
    }

    private func submit() {
        guard let loc = locationManager.location else {
            errorMessage = "Location is required to submit a report"
            showErrorAlert = true
            return
        }
        
        guard !petName.isEmpty else {
            errorMessage = "Please enter your pet's name"
            showErrorAlert = true
            return
        }
        
        isSubmitting = true
        
        // Bundle the structured fields into one rich description for Firestore.
        let fullDescription = """
        Name: \(petName)
        Breed: \(breed.isEmpty ? "Not specified" : breed)
        Color: \(color)
        \(descriptionText)
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let report = LostReport(
            reporterId: "anonymous",
            petName: petName,
            animalType: animalType,
            description: fullDescription,
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude
        )

        var imageData: Data? = nil
        if let img = pickedImage {
            imageData = img.jpegData(compressionQuality: 0.7)
        }

        service.publish(report: report, imageData: imageData) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    showSuccessAlert = true
                case .failure(let err):
                    errorMessage = err.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ReportingView()
}
