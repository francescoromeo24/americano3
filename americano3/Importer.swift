//
//  Importer.swift
//  americano3
//
//  Created by Francesco Romeo on 13/12/24.
//

import SwiftUI
import Vision
import UniformTypeIdentifiers

struct Importer: View {
    @Binding var selectedText: String?
    @Binding var selectedImage: UIImage?
    @Binding var translatedBraille: String?

    @State private var showImporter = false
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            Menu {
                Button(action: { showImporter = true }) {
                    Label("Attach Files", systemImage: "folder")
                }
                .accessibilityLabel("Attach a file")
                .accessibilityHint("Opens the file picker")

                Button(action: { showImagePicker = true }) {
                    Label("Attach Photos", systemImage: "photo")
                }
                .accessibilityLabel("Attach a photo")
                .accessibilityHint("Opens the photo library")
            } label: {
                ZStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 25))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Circle().stroke(Color.blue, lineWidth: 2))
                        .accessibilityLabel("Import options")
                        .accessibilityHint("Tap to choose between attaching a file or a photo")
                }
            }
            .accessibilityElement(children: .combine)
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [UTType.plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, onImagePicked: handleImageImport)
        }
    }

    // Handles file import and reads text content
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                DispatchQueue.main.async {
                    self.selectedText = fileContent
                    print("File content imported: \(fileContent)") // Debug
                    UIAccessibility.post(notification: .announcement, argument: "File imported successfully")
                }
            } catch {
                print("Failed to read file: \(error.localizedDescription)")
                UIAccessibility.post(notification: .announcement, argument: "Failed to import file")
            }
        case .failure(let error):
            print("Error during file import: \(error.localizedDescription)")
            UIAccessibility.post(notification: .announcement, argument: "Error importing file")
        }
    }

    // Handles image selection and processes text recognition
    private func handleImageImport(image: UIImage?) {
        guard let image = image else { return }
        recognizeText(from: image)
        UIAccessibility.post(notification: .announcement, argument: "Photo imported successfully")
    }

    // Uses Vision framework to recognize text in an image
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error during text recognition: \(error.localizedDescription)")
                UIAccessibility.post(notification: .announcement, argument: "Text recognition failed")
                return
            }

            if let results = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                DispatchQueue.main.async {
                    self.selectedText = recognizedText
                    self.translatedBraille = Translate.translateToBraille(text: recognizedText)
                    print("Recognized text: \(recognizedText)") // Debug
                    UIAccessibility.post(notification: .announcement, argument: "Text recognized successfully")
                }
            }
        }

        try? requestHandler.perform([request])
    }
}

// ImagePicker View
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    self.parent.selectedImage = image
                    self.parent.onImagePicked(image)
                }
            }
            picker.dismiss(animated: true)
            UIAccessibility.post(notification: .announcement, argument: "Photo selected successfully")
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            UIAccessibility.post(notification: .announcement, argument: "Photo selection cancelled")
        }
    }
}

// Preview
struct Importer_Previews: PreviewProvider {
    static var previews: some View {
        Importer(
            selectedText: .constant(nil),
            selectedImage: .constant(nil),
            translatedBraille: .constant(nil)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
