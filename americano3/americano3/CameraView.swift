//
//  CameraView.swift
//  americano3
//
//  Created by Francesco Romeo on 31/12/24.
//
import SwiftUI
import UIKit
import CoreData

struct CameraView: UIViewControllerRepresentable {
    var isBraille: Bool
    var onTextRecognized: (String) -> Void

    let context = PersistenceController.shared.context

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.view.backgroundColor = .black
        picker.modalPresentationStyle = .fullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        // Called when an image is picked from the camera
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Perform OCR on the selected image
                performOCR(on: image) { text, success, isBrailleDetected in
                    DispatchQueue.main.async {
                        if success, let recognizedText = text {
                            // Translate Braille if detected or use the recognized text
                            let translatedText = self.parent.isBraille || isBrailleDetected
                                ? Translate.translateToText(braille: recognizedText)
                                : recognizedText
                            // Pass the final translated text back to the parent view
                            self.parent.onTextRecognized(translatedText)
                        } else {
                            // If OCR fails, pass an error message
                            self.parent.onTextRecognized("Recognition error")
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }

        // Called when the user cancels image picking
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
