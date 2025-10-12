import SwiftUI
import CoreLocation

struct ReportingView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var service = ReportService()
    @State private var animalType: String = "Dog"
    @State private var descriptionText: String = ""
    @State private var pickedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSubmitting = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Animal")) {
                    Picker("Type", selection: $animalType) {
                        Text("Dog").tag("Dog")
                        Text("Cat").tag("Cat")
                        Text("Other").tag("Other")
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Details")) {
                    TextField("Description (color, size, name)", text: $descriptionText)
                }

                Section {
                    HStack {
                        Spacer()
                        if let img = pickedImage {
                            Image(uiImage: img).resizable().scaledToFit().frame(height: 160)
                        } else {
                            Button("Pick Photo") { showImagePicker = true }
                        }
                        Spacer()
                    }
                }

                Section {
                    Button(action: submit) {
                        HStack {
                            Spacer()
                            if isSubmitting { ProgressView() }
                            else { Text("Report Lost Pet") }
                            Spacer()
                        }
                    }
                    .disabled(isSubmitting || locationManager.location == nil)
                }
            }
            .navigationTitle("Report Lost Pet")
            .sheet(isPresented: $showImagePicker) { ImagePicker(image: $pickedImage) }
        }
    }

    private func submit() {
        guard let loc = locationManager.location else { return }
        isSubmitting = true
        let report = LostReport(reporterId: "anonymous", animalType: animalType, description: descriptionText, latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)

        var imageData: Data? = nil
        if let img = pickedImage { imageData = img.jpegData(compressionQuality: 0.7) }

        service.publish(report: report, imageData: imageData) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let err):
                    print("Publish error:", err.localizedDescription)
                }
            }
        }
    }
}
