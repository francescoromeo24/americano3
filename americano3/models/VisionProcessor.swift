//
//  VisionProcessor.swift
//  americano3
//
//  Created by Francesco Romeo on 31/12/24.
//

import Vision
import UIKit

class VisionProcessor {
    static let shared = VisionProcessor()
    
    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("Error: Unable to process image.")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let textDetectionRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            completion(recognizedText)
        }
        
        textDetectionRequest.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([textDetectionRequest])
            } catch {
                completion("Error: \(error.localizedDescription)")
            }
        }
    }
}

