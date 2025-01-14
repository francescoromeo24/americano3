//
//  Importer.swift
//  americano3
//
//  Created by Francesco Romeo on 13/12/24.
//

import SwiftUI
import Vision
import UIKit

struct Importer: View {
    @Binding var selectedText: String?
    @Binding var selectedImage: UIImage?
    @Binding var translatedBraille: String?
    
    @State private var showImporter = false
    @State private var showImagePicker = false
    
    var body: some View {
        VStack {
            Menu {
                Button("Import from File") {
                    showImporter = true
                }
                Button("Import from Gallery") {
                    showImagePicker = true
                }
            } label: {
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(Color("Background"))
                        .font(.system(size: 50))
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 25))
                        .foregroundColor(.blue)
                }
                .padding()
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, onImagePicked: handleImageImport)
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                self.selectedText = fileContent
            } catch {
                print("Failed to read file: \(error.localizedDescription)")
            }
        case .failure(let error):
            print("Error during file import: \(error.localizedDescription)")
        }
    }
    
    private func handleImageImport(image: UIImage?) {
        guard let image = image else { return }
        recognizeText(from: image)
    }
    
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error during text recognition: \(error.localizedDescription)")
                return
            }

            if let results = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                DispatchQueue.main.async {
                    selectedText = recognizedText
                    translatedBraille = Translate.translateToBraille(text: recognizedText)
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
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
