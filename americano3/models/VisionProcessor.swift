//
//  VisionProcessor.swift
//  americano3
//
//  Created by Francesco Romeo on 31/12/24.
//

import Vision
import UIKit

/// A singleton class responsible for processing images using Apple's Vision framework.
class VisionProcessor {
    /// Shared instance to allow easy access across the app.
    static let shared = VisionProcessor()
    
    /// Recognizes text from a given UIImage using Vision's OCR capabilities.
    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        // Ensure the image has a valid Core Graphics (CG) representation
        guard let cgImage = image.cgImage else {
            completion("Error: Unable to process image.") // Error: Invalid image format
            return
        }
        
        // Create a request handler for the image
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Create a text recognition request
        let textDetectionRequest = VNRecognizeTextRequest { request, error in
            // Ensure there is no error and extract text observations
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")") // Error during text recognition
                return
            }
            
            // Extract the best recognized text from each observation and join them into a single string
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            // Return the recognized text via the completion handler
            completion(recognizedText)
        }
        
        // Set the recognition level to high accuracy for better results
        textDetectionRequest.recognitionLevel = .accurate
        
        // Perform the request on a background thread to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([textDetectionRequest])
            } catch {
                completion("Error: \(error.localizedDescription)") // Error while performing OCR request
            }
        }
    }
}
