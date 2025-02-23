//
//  OCRHelper.swift
//  americano3
//
//  Created by Francesco Romeo on 08/01/25.
//

import UIKit
import Vision

/// Performs Optical Character Recognition (OCR) on a given UIImage.
func performOCR(on image: UIImage, completion: @escaping (String?, Bool, Bool) -> Void) {
    // Ensure the image has a valid Core Graphics (CG) representation
    guard let cgImage = image.cgImage else {
        completion(nil, false, false) // Error: Unable to get CGImage from UIImage
        return
    }

    // Create a text recognition request
    let request = VNRecognizeTextRequest { (request, error) in
        guard error == nil else {
            print("OCR Error: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil, false, false) // Error during text recognition
            return
        }

        // Extract recognized text from Vision framework results
        let recognizedStrings = request.results?.compactMap { result in
            (result as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
        }

        // If text is found, check if it contains Braille patterns
        if let text = recognizedStrings?.joined(separator: " "), !text.isEmpty {
            print("OCR recognized text: \(text)")
            
            // Basic Braille detection: check for more patterns
            let brailleDetected = text.contains("⠁") || text.contains("⠃") || text.contains("⠉") ||
                                  text.contains("⠙") || text.contains("⠑") || text.contains("⠋")
            
            completion(text, true, brailleDetected)
        } else {
            print("No text recognized")
            completion(nil, false, false) // No recognizable text found
        }
    }

    // Create a request handler for the image
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

    // Perform the OCR request on a background thread
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
        } catch {
            print("OCR failed: \(error.localizedDescription)")
            completion(nil, false, false) // Error while performing the OCR request
        }
    }
}
