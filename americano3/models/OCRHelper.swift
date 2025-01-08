//
//  OCRHelper.swift
//  americano3
//
//  Created by Francesco Romeo on 08/01/25.
//

import Vision
import UIKit

// Funzione OCR condivisa
func performOCR(on image: UIImage, completion: @escaping (String?) -> Void) {
    guard let cgImage = image.cgImage else {
        completion(nil)
        return
    }

    let request = VNRecognizeTextRequest { (request, error) in
        guard error == nil else {
            completion(nil)
            return
        }

        let recognizedStrings = request.results?.compactMap { result in
            (result as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
        }

        completion(recognizedStrings?.joined(separator: " "))
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
        } catch {
            completion(nil)
        }
    }
}

