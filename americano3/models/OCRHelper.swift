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
            completion(nil, false, false) // Error during text recognition
            return
        }

        // Extract recognized text from Vision framework results
        let recognizedStrings = request.results?.compactMap { result in
            (result as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
        }

        // If text is found, check if it contains Braille patterns
        if let text = recognizedStrings?.joined(separator: " "), !text.isEmpty {
            let isBraille = text.contains("⠁") || text.contains("⠃") || text.contains("⠉") // Basic Braille detection
            completion(text, true, isBraille)
        } else {
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
            completion(nil, false, false) // Error while performing the OCR request
        }
    }
}

