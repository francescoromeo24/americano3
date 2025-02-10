//
//  ContentViewFunc.swift
//  americano3
//
//  Created by Francesco Romeo on 10/02/25.
//
import SwiftUI
import AVFoundation

class ContentViewFunc: ObservableObject {
    
    @Published var textInput = ""
    @Published var brailleOutput = ""
    @Published var isTextToBraille = true
    @Published var flashcardManager = FlashcardManager()
    @Published var isCameraPresented = false
    @Published var showingFavorites = false
    @Published var selectedImage: UIImage?
    @Published var selectedText: String?{
        didSet{
            if let text = selectedText {
                textInput = text
                updateTranslation()
            }
        }
    }
    @Published var translatedBraille: String?

    func updateTranslation() {
        if isTextToBraille {
            let newBraille = Translate.translateToBraille(text: textInput)
            giveHapticFeedbackForEachLetter(oldText: brailleOutput, newText: newBraille)
            brailleOutput = newBraille
        } else {
            let newText = Translate.translateToText(braille: brailleOutput)
            giveHapticFeedbackForEachLetter(oldText: textInput, newText: newText)
            textInput = newText
        }
    }
    
    func swapTranslation() {
        isTextToBraille.toggle()
        let temp = textInput
        textInput = brailleOutput
        brailleOutput = temp
        updateTranslation()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    
    func addFlashcard() {
        if !textInput.isEmpty {
            flashcardManager.addFlashcard(textInput: textInput, brailleOutput: brailleOutput)
            textInput = ""
            brailleOutput = ""
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    func updateFlashcard(_ updatedFlashcard: Flashcard) {
        if let index = flashcardManager.flashcards.firstIndex(where: { $0.id == updatedFlashcard.id }) {
            flashcardManager.flashcards[index] = updatedFlashcard
        }
    }

    func giveHapticFeedbackForEachLetter(oldText: String, newText: String) {
        guard oldText != newText else { return }
        
        let diff = newText.count - oldText.count
        if diff > 0 {
            for _ in 0..<diff {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    func processImage(_ image: UIImage) {
        VisionProcessor.shared.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                if result.isEmpty {
                    self.textInput = "Nessun testo riconosciuto"
                    self.brailleOutput = " "
                } else {
                    if self.isTextToBraille {
                        self.textInput = result
                        self.brailleOutput = Translate.translateToBraille(text: result)
                    } else {
                        self.textInput = Translate.translateToText(braille: result)
                        self.brailleOutput = result
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
    }
    func placeholderText() -> String {
            return isTextToBraille ? "Enter text" : "⠑⠝⠞⠑⠗ ⠃⠗⠁⠊⠇⠇⠑"
        }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
