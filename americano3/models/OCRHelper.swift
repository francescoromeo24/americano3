//
//  OCRHelper.swift
//  americano3
//
//  Created by Francesco Romeo on 08/01/25.
//

import UIKit
import Vision

// Funzione OCR utilizzata per riconoscere il testo nell'immagine
func performOCR(on image: UIImage, completion: @escaping (String?, Bool) -> Void) {
    guard let cgImage = image.cgImage else {
        completion(nil, false) // Restituisce false se non c'è immagine valida
        return
    }

    let request = VNRecognizeTextRequest { (request, error) in
        guard error == nil else {
            completion(nil, false) // Se si verifica un errore, restituisce false
            return
        }

        let recognizedStrings = request.results?.compactMap { result in
            (result as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
        }

        if let text = recognizedStrings?.joined(separator: " "), !text.isEmpty {
            completion(text, true) // Restituisce true se il testo è stato riconosciuto con successo
        } else {
            completion(nil, false) // Se il testo non è stato trovato, restituisce false
        }
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
        } catch {
            completion(nil, false) // Restituisce false se c'è un errore nell'esecuzione
        }
    }
}
