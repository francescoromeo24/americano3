//
//  ContentView.swift
//  americano3
//
//  Created by Francesco Romeo on 10/12/24.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    
    // Customization of navigation title
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
    
    // Variables for translation and recording
    @State private var textInput = ""
    @State private var brailleOutput = ""
    @State private var isTextToBraille = true
    @State private var flashcards: [Flashcard] = []
    @State private var showingFavorites = false
    @State private var isRecording = false
    
    @StateObject private var speechRecognizer = SpeechRecognizerCoordinator()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Rectangle, text section, and buttons
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .frame(width: 370, height: 350)
                        
                        VStack {
                            // Text section and text label
                            HStack {
                                Text(isTextToBraille ? "Text" : "Braille")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.black)
                                Spacer()
                            }
                            
                            // Insert text
                            TextField("Enter \(isTextToBraille ? "text" : "braille")", text: isTextToBraille ? $textInput : $brailleOutput)
                                .frame(height: 80)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.gray)
                            
                                .onChange(of: textInput) {
                                    if isTextToBraille {
                                        brailleOutput = Translate.translateToBraille(text: textInput)
                                    } else {
                                        textInput = Translate.translateToText(braille: brailleOutput)
                                    }
                                }
                                .onSubmit {
                                    addFlashcard()
                                }
                            
                            Spacer()
                            
                            // Line in the middle of the rectangle, switch button
                            ZStack {
                                Divider()
                                    .frame(height: 2)
                                    .background(Color.blue)
                                
                                Button(action: {
                                    isTextToBraille.toggle()
                                    let temp = textInput
                                    textInput = brailleOutput
                                    brailleOutput = temp
                                }) {
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .foregroundStyle(Color("Background"))
                                            .font(.system(size: 40))
                                        Image(systemName: "arrow.trianglehead.swap")
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                            Spacer()
                            
                            // Braille section, output
                            VStack(alignment: .leading) {
                                Text(isTextToBraille ? "Braille" : "Text")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.black)
                                
                                ScrollView(.vertical, showsIndicators: true) {
                                    Text(brailleOutput)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.clear)
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 40)
                            }
                            
                            // Importer from files
                            HStack {
                                Importer()
                                
                                // Microphone button
                                Button(action: {
                                    if isRecording {
                                        speechRecognizer.stopRecording()
                                    } else {
                                        speechRecognizer.startRecording { result in
                                            textInput = result
                                            brailleOutput = Translate.translateToBraille(text: result)
                                            addFlashcard()

                                        }
                                    }
                                    isRecording.toggle()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(isRecording ? Color.red : Color.background)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "microphone")
                                            .foregroundColor(.blue)
                                            .font(.title)
                                    }
                                }
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                    }
                    .padding(.vertical, 10)
                    
                    // History section
                    HStack {
                        Text("History")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.blue)
                        Spacer()
                    }
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                  ForEach(flashcards) { flashcard in
                                      FlashcardView(flashcard: flashcard)
                                      { updatedFlashcard in
                                          // Update the flashcard with the updated one
                                          if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
                                              flashcards[index] = updatedFlashcard
                                          }
                                          toggleFlashcardStar(for: updatedFlashcard)
                                      }
                                      .frame(width: 146, height: 164) // Set the size of each flashcard
                                  }
                              }
                
                ForEach(flashcards) { flashcard in
                    FlashcardView(flashcard: flashcard)
                    { updatedFlashcard in
                        // Update the flashcard with the updated one
                        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
                            flashcards[index] = updatedFlashcard
                        }
                        toggleFlashcardStar(for: updatedFlashcard)
                    }
                }

                
                
                .foregroundStyle(.blue)
                .padding()
            }
            .navigationTitle("Braille Translator")
            .foregroundColor(.blue)
            .background(Color("Background"))
        }
    }
    
    private func addFlashcard() {
        // Avoid adding a flashcard if no translation exists
        guard !textInput.isEmpty else { return }
        
        // Create a new flashcard
        let newFlashcard = Flashcard(word: textInput, translation: brailleOutput)
        
        if !flashcards.contains(where: {$0.word == newFlashcard.word}){
            flashcards.append(newFlashcard) //add flashcard
        }
       
        textInput = ""
        brailleOutput = ""
    }
    
    private func toggleStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle() // Cambia lo stato di isStarred
        }
    }
    private func toggleFlashcardStar(for flashcard: Flashcard) {
        // Cerca l'indice della flashcard nell'array
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle() // Cambia lo stato di preferito
        }
    }

    
    
    
    
    // Speech Recognizer Coordinator Class
    final class SpeechRecognizerCoordinator: NSObject, ObservableObject {
        private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        private let audioEngine = AVAudioEngine()
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
        
        func startRecording(completion: @escaping (String) -> Void) {
            guard !audioEngine.isRunning else {
                print("Audio engine is already running.")
                return
            }
            
            // Request microphone and speech permissions
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    if authStatus == .authorized {
                        AVAudioApplication.requestRecordPermission { granted in
                            if granted {
                                do {
                                    try self.startAudioEngine(completion: completion)
                                } catch {
                                    print("Error starting audio engine: \(error.localizedDescription)")
                                }
                            } else {
                                print("Microphone permission denied.")
                            }
                        }
                    } else {
                        print("Speech recognition permission denied.")
                    }
                }
            }
        }
        
        func stopRecording() {
            audioEngine.inputNode.removeTap(onBus: 0) // Remove the tap
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        private func startAudioEngine(completion: @escaping (String) -> Void) throws {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                throw SpeechError.requestInitializationFailed
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        completion(result.bestTranscription.formattedString)
                    }
                }
                if let error = error {
                    print("Speech recognition error: \(error.localizedDescription)")
                }
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.inputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        }
        
        enum SpeechError: Error {
            case requestInitializationFailed
        }
    }
}

#Preview {
    ContentView()
}
