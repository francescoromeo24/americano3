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
    @Published var flashcardToDelete: Flashcard?
    @Published var showingDeleteConfirmation = false
    @Published var isBraille = false

    @Published var selectedText: String? {
        didSet {
            if let text = selectedText {
                DispatchQueue.main.async {
                    self.selectedText = nil  // Resetta temporaneamente
                    self.textInput = text
                    self.updateTranslation()
                }
            }
        }
    }


    @Published var translatedBraille: String?

    func updateTranslation() {
        DispatchQueue.main.async {  // Assicura che il codice venga eseguito sul main thread
            if self.isTextToBraille {
                let newBraille = Translate.translateToBraille(text: self.textInput)
                self.giveHapticFeedbackForEachLetter(oldText: self.brailleOutput, newText: newBraille)
                self.brailleOutput = newBraille
            } else {
                let newText = Translate.translateToText(braille: self.brailleOutput)
                self.giveHapticFeedbackForEachLetter(oldText: self.textInput, newText: newText)
                self.textInput = newText
            }
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

    func deleteFlashcard() {
        if let flashcard = flashcardToDelete {
            flashcardManager.flashcards.removeAll { $0.id == flashcard.id }
            flashcardToDelete = nil
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

    // Funzione che verifica se il testo è Braille (Unicode)
    func isBraille(text: String) -> Bool {
        // Range dei caratteri Braille Unicode
        let brailleCharacterRange = "\u{2800}"..."\u{28FF}"
        // Verifica se ogni carattere è nel range Braille
        return text.allSatisfy { brailleCharacterRange.contains(String($0)) }
    }

    func processImage(_ image: UIImage?) {
        guard let validImage = image else {
            print("❌ Errore: immagine nulla in processImage")
            return
        }

        performOCR(on: validImage) { (recognizedText, success, isBrailleDetected) in
            DispatchQueue.main.async {
                if let result = recognizedText {
                    if self.isBraille || isBrailleDetected {
                        self.selectedText = Translate.translateToText(braille: result)
                        self.translatedBraille = result
                    } else {
                        self.selectedText = result
                        self.translatedBraille = Translate.translateToBraille(text: result)
                    }
                } else {
                    self.selectedText = "Nessun testo riconosciuto"
                    self.translatedBraille = " "
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
    
    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let fileData = try Data(contentsOf: url)
                
                var fileContent: String? = String(data: fileData, encoding: .utf8)
                if fileContent == nil {
                    fileContent = String(data: fileData, encoding: .isoLatin1)
                }
                if fileContent == nil {
                    fileContent = String(data: fileData, encoding: .utf16)
                }
                
                guard let content = fileContent else {
                    print("❌ Errore: impossibile decodificare il file.")
                    UIAccessibility.post(notification: .announcement, argument: "Errore nella lettura del file.")
                    return
                }
                
                DispatchQueue.main.async {
                    print("✅ Contenuto file importato: \(content)") // Debug
                    
                    // Controlla se il contenuto del file è Braille o testo
                    if self.isBraille(text: content) {
                        self.selectedText = Translate.translateToText(braille: content)
                        self.translatedBraille = content
                        print("🔹 Braille rilevato, tradotto in testo: \(self.selectedText ?? "")") // Debug
                    } else {
                        self.selectedText = content
                        self.translatedBraille = Translate.translateToBraille(text: content)
                        print("🔹 Testo normale, tradotto in Braille: \(self.translatedBraille ?? "")") // Debug
                    }
                    
                    // ⚠️ Annuncia il risultato tramite accessibilità
                    UIAccessibility.post(notification: .announcement, argument: "File importato con successo.")
                }
            } catch {
                print("❌ Errore nella lettura del file: \(error.localizedDescription)")
                UIAccessibility.post(notification: .announcement, argument: "Errore nell'importazione del file.")
            }
            
        case .failure(let error):
            print("❌ Errore durante l'importazione: \(error.localizedDescription)")
            UIAccessibility.post(notification: .announcement, argument: "Errore nell'importazione del file.")
        }
    }
}
