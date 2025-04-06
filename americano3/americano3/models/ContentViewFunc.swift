//
//  ContentViewFunc.swift
//  americano3
//
//  Created by Francesco Romeo on 10/02/25.
//
import SwiftUI
import AVFoundation

// ViewModel class handling translation logic and app state
class ContentViewFunc: ObservableObject {

    @Published var textInput = "" // Stores user input text
    @Published var brailleOutput = "" // Stores translated Braille output
    @Published var isTextToBraille = true // Determines translation direction
    @Published var flashcardManager = FlashcardManager() // Manages flashcards
    @Published var isCameraPresented = false // Tracks camera view presentation
    @Published var showingFavorites = false // Tracks favorites view state
    @Published var selectedImage: UIImage? // Holds selected image for OCR
    @Published var flashcardToDelete: Flashcard? // Stores flashcard to be deleted
    @Published var showingDeleteConfirmation = false // Controls delete confirmation dialog
    @Published var isBraille = false // Tracks if input is Braille

    @Published var selectedText: String? {
        didSet {
            if let text = selectedText {
                DispatchQueue.main.async {
                    self.selectedText = nil  // Temporarily resets selection
                    self.textInput = text
                    self.updateTranslation()
                }
            }
        }
    }

    @Published var translatedBraille: String? // Holds translated Braille

    // Updates translation based on user input
    func updateTranslation() {
        DispatchQueue.main.async {
            if self.isTextToBraille {
                let newBraille = Translate.translateToBraille(text: self.textInput)
                self.giveHapticFeedbackForEachLetter(oldText: self.brailleOutput, newText: newBraille)
                self.brailleOutput = newBraille
            } else {
                let newText = Translate.translateToText(braille: self.textInput)
                self.giveHapticFeedbackForEachLetter(oldText: self.brailleOutput, newText: newText)
                self.brailleOutput = newText
            }
        }
    }

    // Swaps translation mode and updates output accordingly
    func swapTranslation() {
        isTextToBraille.toggle()
        let temp = textInput
        textInput = brailleOutput
        brailleOutput = temp
        updateTranslation()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // Adds a new flashcard
    func addFlashcard() {
        if !textInput.isEmpty {
            flashcardManager.addFlashcard(textInput: textInput, brailleOutput: brailleOutput)
            textInput = ""
            brailleOutput = ""
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // Updates an existing flashcard
    func updateFlashcard(_ updatedFlashcard: Flashcard) {
        if let index = flashcardManager.flashcards.firstIndex(where: { $0.id == updatedFlashcard.id }) {
            flashcardManager.flashcards[index] = updatedFlashcard
        }
    }

    // Deletes a selected flashcard
    func deleteFlashcard() {
        if let flashcard = flashcardToDelete {
            flashcardManager.flashcards.removeAll { $0.id == flashcard.id }
            flashcardToDelete = nil
        }
    }

    // Provides haptic feedback for each new character added
    func giveHapticFeedbackForEachLetter(oldText: String, newText: String) {
        guard oldText != newText else { return }

        let diff = newText.count - oldText.count
        if diff > 0 {
            for _ in 0..<diff {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    // Checks if the provided text is in Braille Unicode range
    func isBraille(text: String) -> Bool {
        let brailleCharacterRange = "\u{2800}"..."\u{28FF}"
        return text.allSatisfy { brailleCharacterRange.contains(String($0)) }
    }

    // Processes an image and extracts text using OCR
    func processImage(_ image: UIImage?) {
        guard let validImage = image else {
            print("❌ Error: Nil image in processImage")
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
                    self.selectedText = "No text recognized"
                    self.translatedBraille = " "
                }
            }
        }
    }

    // Returns appropriate placeholder text based on translation mode
    func placeholderText() -> String {
        return isTextToBraille ? "Enter text" : "⠑⠝⠞⠑⠗ ⠃⠗⠁⠊⠇⠇⠑"
    }

    // Hides keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Handles file import and extracts text content
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
                    print("❌ Error: Unable to decode file.")
                    UIAccessibility.post(notification: .announcement, argument: "Error reading file.")
                    return
                }
                
                DispatchQueue.main.async {
                    print("✅ Imported file content: \(content)") // Debug
                    
                    if self.isBraille(text: content) {
                        self.selectedText = Translate.translateToText(braille: content)
                        self.translatedBraille = content
                    } else {
                        self.selectedText = content
                        self.translatedBraille = Translate.translateToBraille(text: content)
                    }
                    
                    UIAccessibility.post(notification: .announcement, argument: "File imported successfully.")
                }
            } catch {
                print("❌ Error reading file: \(error.localizedDescription)")
                UIAccessibility.post(notification: .announcement, argument: "Error importing file.")
            }
        case .failure(let error):
            print("❌ Error importing: \(error.localizedDescription)")
            UIAccessibility.post(notification: .announcement, argument: "Error importing file.")
        }
    }
    
    @Published var isBrailleKeyboardActive = false
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let supportedLanguages = ["en", "it", "fr", "es", "de"]
    
    func activateBrailleKeyboard() {
        isBrailleKeyboardActive = true
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        // Check if Braille keyboard is available
        if let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String],
           keyboards.contains("com.apple.BrailleIM") {
            UIAccessibility.post(notification: .announcement, argument: NSLocalizedString("braille_keyboard_ready", comment: ""))
        } else {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
        
        func speakTranslation(with synthesizer: AVSpeechSynthesizer, in language: String) {
            let textToSpeak = isTextToBraille ? textInput : brailleOutput
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            
            feedbackGenerator.impactOccurred()
            
            // Get device language (first 2 characters)
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            
            // Supported languages with fallback
            let supportedLanguages = ["en", "it", "es", "fr", "de"]
            let languageToUse = supportedLanguages.contains(deviceLanguage) ? deviceLanguage : "en"
            
            guard let voice = AVSpeechSynthesisVoice(language: languageToUse) else {
                // Fallback to English if voice not available
                if let defaultVoice = AVSpeechSynthesisVoice(language: "en") {
                    let utterance = AVSpeechUtterance(string: textToSpeak)
                    utterance.rate = 0.5
                    utterance.pitchMultiplier = 1.0
                    utterance.volume = 1.0
                    utterance.voice = defaultVoice
                    synthesizer.speak(utterance)
                }
                return
            }
            
            let utterance = AVSpeechUtterance(string: textToSpeak)
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            utterance.voice = voice
            
            synthesizer.speak(utterance)
        }
        // ... rest of existing functions ...
    }

