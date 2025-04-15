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
                    Label(LocalizedStringKey("import_attach_files"), systemImage: "folder")
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .accessibilityLabel(LocalizedStringKey("import_attach_files"))
                .accessibilityHint(LocalizedStringKey("import_file_hint"))

                Button(action: { showImagePicker = true }) {
                    Label(LocalizedStringKey("import_attach_photos"), systemImage: "photo")
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .accessibilityLabel(LocalizedStringKey("import_attach_photos"))
                .accessibilityHint(LocalizedStringKey("import_photo_hint"))
            } label: {
                ZStack {
                    Image(systemName: "square.and.arrow.up")
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
        // Pre-process the image
        guard let processedImage = preprocessImage(image),
              let cgImage = processedImage.cgImage else { return }
    
        // Try Braille pattern detection first
        if let brailleText = detectBraillePattern(from: processedImage) {
            DispatchQueue.main.async {
                self.selectedText = Translate.translateToText(braille: brailleText)
                self.translatedBraille = brailleText
                return
            }
        }
    
        // Fallback to standard text recognition
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
                    // Check if the recognized text contains Braille characters
                    if isBrailleText(recognizedText) {
                        self.selectedText = Translate.translateToText(braille: recognizedText)
                        self.translatedBraille = recognizedText
                    } else {
                        self.selectedText = recognizedText
                        self.translatedBraille = Translate.translateToBraille(text: recognizedText)
                    }
                    print("Recognized text: \(recognizedText)") // Debug
                    UIAccessibility.post(notification: .announcement, argument: "Text recognized successfully")
                }
            }
        }
        
        // Enhanced configuration for better recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.05
        request.recognitionLanguages = ["en-US"]
    
        try? requestHandler.perform([request])
    }
    
    private func detectBraillePattern(from image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
    
        // Configura il rilevatore per i punti Braille
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, 
                                context: CIContext(), 
                                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                        CIDetectorMinFeatureSize: 0.1])
    
        let ciImage = CIImage(cgImage: cgImage)
        let features = detector?.features(in: ciImage) as? [CIRectangleFeature]
    
        // Ordina i rettangoli da sinistra a destra e dall'alto al basso
        let sortedFeatures = features?.sorted { (f1, f2) -> Bool in
            if abs(f1.bounds.minY - f2.bounds.minY) > f1.bounds.height {
                return f1.bounds.minY > f2.bounds.minY
            }
            return f1.bounds.minX < f2.bounds.minX
        }
        
        // Processa i rettangoli rilevati
        var braillePattern = ""
        var currentCell = [CGRect]()
    
        sortedFeatures?.forEach { feature in
            currentCell.append(feature.bounds)
            if currentCell.count == 6 {
                if let pattern = convertToUnicodeBraille(currentCell) {
                    braillePattern += pattern
                }
                currentCell.removeAll()
            }
        }
        
        return braillePattern.isEmpty ? nil : braillePattern
    }
    
    private func convertToUnicodeBraille(_ dots: [CGRect]) -> String? {
        var pattern = Array(repeating: false, count: 6)
    
        // Ordina i punti in base alla posizione standard Braille (2x3)
        let sortedDots = dots.sorted { (d1, d2) -> Bool in
            if abs(d1.midY - d2.midY) > d1.height {
                return d1.midY > d2.midY
            }
            return d1.midX < d2.midX
        }
        
        // Mappa i punti rilevati al pattern Braille
        for (index, _) in sortedDots.prefix(6).enumerated() {
            pattern[index] = true
        }
        
        // Converti in Unicode Braille
        let baseCode = 0x2800
        let dotValue = pattern.enumerated().reduce(0) { result, element in
            result | (element.1 ? (1 << element.0) : 0)
        }
        
        return String(UnicodeScalar(baseCode + dotValue)!)
    }
    
    private func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // Apply noise reduction
        guard let noiseReduction = CIFilter(name: "CINoiseReduction") else { return image }
        noiseReduction.setValue(ciImage, forKey: kCIInputImageKey)
        noiseReduction.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReduction.setValue(0.4, forKey: "inputSharpness")
        
        guard let noiseReduced = noiseReduction.outputImage else { return image }
        
        // Enhance contrast and brightness
        guard let colorControls = CIFilter(name: "CIColorControls") else { return image }
        colorControls.setValue(noiseReduced, forKey: kCIInputImageKey)
        colorControls.setValue(1.8, forKey: kCIInputContrastKey)
        colorControls.setValue(0.2, forKey: kCIInputBrightnessKey)
        colorControls.setValue(1.1, forKey: kCIInputSaturationKey)
        
        guard let output = colorControls.outputImage,
              let finalCGImage = context.createCGImage(output, from: output.extent) else { return image }
        
        return UIImage(cgImage: finalCGImage)
    }
    
    private func convertToUnicodeBraille(_ bounds: CGRect) -> String? {
        let cellWidth = bounds.width / 2
        let cellHeight = bounds.height / 3
        
        // Analyze the image in a 2x3 grid
        var pattern = Array(repeating: false, count: 6)
        
        // Grid positions for standard Braille
        let positions = [
            CGPoint(x: bounds.minX + cellWidth/2, y: bounds.minY + cellHeight/2),
            CGPoint(x: bounds.minX + cellWidth/2, y: bounds.minY + cellHeight*1.5),
            CGPoint(x: bounds.minX + cellWidth/2, y: bounds.minY + cellHeight*2.5),
            CGPoint(x: bounds.minX + cellWidth*1.5, y: bounds.minY + cellHeight/2),
            CGPoint(x: bounds.minX + cellWidth*1.5, y: bounds.minY + cellHeight*1.5),
            CGPoint(x: bounds.minX + cellWidth*1.5, y: bounds.minY + cellHeight*2.5)
        ]
        
        // Check each position for a dot
        for (index, position) in positions.enumerated() {
            if bounds.contains(position) {
                pattern[index] = true
            }
        }
        
        // Convert to Unicode Braille
        let baseCode = 0x2800
        let dots = pattern.enumerated().reduce(0) { result, element in
            result | (element.1 ? (1 << element.0) : 0)
        }
        
        return String(UnicodeScalar(baseCode + dots)!)
    }
    
    // Helper function to detect Braille text
    private func isBrailleText(_ text: String) -> Bool {
        let brailleRange = "\u{2800}"..."\u{28FF}"
        return text.contains { char in
            String(char).unicodeScalars.first.map { brailleRange.contains(String($0)) } ?? false
        }
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
