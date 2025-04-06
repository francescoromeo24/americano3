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
    @StateObject private var viewModel = ContentViewFunc()
    @Environment(\.colorScheme) var colorScheme
    @State private var showSettings = false
   
    
    // Replace with this at the top of your ContentView struct:
    @State private var synthesizer = AVSpeechSynthesizer()
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @State private var isBrailleKeyboardActive = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
    
    private func speakTranslation() {
        do {
            let textToSpeak = viewModel.isTextToBraille ? viewModel.brailleOutput : viewModel.textInput
            guard !textToSpeak.isEmpty else { return }
            
            let utterance = AVSpeechUtterance(string: textToSpeak)
            if let voice = AVSpeechSynthesisVoice(language: selectedLanguage) {
                utterance.voice = voice
            }
            utterance.rate = 0.5
            synthesizer.speak(utterance)
        } catch {
            print("Speech synthesis error: \(error.localizedDescription)")
        }
    }
    
    private func activateBrailleKeyboard() {
        viewModel.activateBrailleKeyboard()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Text Input Section
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                           
                            Text(viewModel.isTextToBraille ? LocalizedStringKey("text_label") : LocalizedStringKey("braille_label"))

                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .font(.title)
                                .fontWeight(.semibold)
                                
                            
                            Spacer()
                            
                            // Add Braille Keyboard Button
                            if !viewModel.isTextToBraille {
                                Button(action: {
                                    activateBrailleKeyboard()
                                }) {
                                    Image(systemName: "keyboard")
                                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Circle().stroke(Color.blue, lineWidth: 2))
                                    
                                }
                                .accessibilityLabel("Activate Braille Keyboard")
                            }
                        }
                        
                        TextField(LocalizedStringKey(viewModel.placeholderText()), text: $viewModel.textInput, axis: .vertical)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            .padding()
                            .frame(minHeight: 80)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                            .foregroundColor(.gray)
                            .accessibilityHint(LocalizedStringKey("enter_text_hint"))
                            .onChange(of: viewModel.textInput) {
                                viewModel.updateTranslation()
                            }
                            .padding(5)
                    }
                    
                    // Button Row: Switch Translation Mode & Add Flashcard
                    HStack {
                        // Button to swap translation direction
                        Button(action: {
                            viewModel.swapTranslation()
                        }) {
                            Image(systemName: "arrow.trianglehead.swap")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .padding()
                                .background(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                        
                        Spacer()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60:20)
                        
                        // Button to add a flashcard
                        Button(action: {
                            viewModel.addFlashcard()
                        }) {
                            Image(systemName: "plus")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .padding()
                                .background(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                    }
                    .padding(.top, 5.0)
                    
                    // Braille Output Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.isTextToBraille ? LocalizedStringKey("braille_label") : LocalizedStringKey("text_label"))
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .padding([.top, .leading], 10.0)
                        
                        // Display the translated Braille output
                        ScrollView(.vertical, showsIndicators: true) {
                            
                            
                            // Nella sezione Braille Output, modifica il TextField così:
                            TextField(LocalizedStringKey("translation"), text: $viewModel.brailleOutput, axis: .vertical)
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .font(.custom("Courier", size: 20))
                                .padding()
                                .frame(minHeight: 80)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .disabled(true)
                                .accessibilityLabel(viewModel.textInput.map { String($0) }.joined(separator: ", "))
                                .accessibilityHint(LocalizedStringKey("swipe_to_hear"))
                                .onTapGesture {
                                    viewModel.speakTranslation(with: synthesizer, in: selectedLanguage)
                                }
                        }
                        .padding(5)
                        .frame(minHeight: 80)
                    }
                    
                    // Importer and Camera Buttons
                    HStack {
                        // Import text or image for translation
                        Importer(selectedText: $viewModel.selectedText, selectedImage: $viewModel.selectedImage, translatedBraille: $viewModel.translatedBraille)
                        
                        Spacer()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60:20)
                            
                        
                        // Open the camera to capture text
                        Button(action: {
                            viewModel.isCameraPresented = true
                        }) {
                            Image(systemName: "camera")
                                .font(.system(size: 25))
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                        
                        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
                            CameraView(isBraille: viewModel.isBraille) { recognizedText in
                                DispatchQueue.main.async {
                                    viewModel.textInput = recognizedText
                                    viewModel.updateTranslation()
                                    viewModel.isCameraPresented = false
                                }
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                        
                        Spacer()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60:20)
                        
                        // Speech recognition button
                        SpeechRecognizerView() { result in
                            viewModel.textInput = result
                            viewModel.updateTranslation()
                        }
                    }
                    .padding(.top, 5)
                    
                    // History Section
                    HStack {
                        Text(LocalizedStringKey("history"))
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            .foregroundColor(.blue)
                            .font(.title)
                            .fontWeight(.bold)
    
                        
                        Spacer()
                        
                        // Toggle to show favorite flashcards
                        Button(action: {
                            viewModel.showingFavorites.toggle()
                        }) {
                            Text(LocalizedStringKey("view_favorites"))
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .foregroundColor(.blue)
                               
                        }
                    }
                    .padding(.horizontal)
                    
                    // Flashcard Grid Display
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.flashcardManager.sortedFlashcards) { flashcard in
                            NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                                FlashcardView(flashcard: .constant(flashcard)) { updatedFlashcard in
                                    viewModel.updateFlashcard(updatedFlashcard)
                                }
                            }
                            .frame(
                                width: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 146,
                                height: UIDevice.current.userInterfaceIdiom == .pad ? 220 : 164
                            )
                            .onLongPressGesture {
                                viewModel.flashcardToDelete = flashcard
                                viewModel.showingDeleteConfirmation = true
                            }
                        }
                    }
                    
                    
                    .foregroundStyle(.blue)
                    .padding()
                }
            }
            .onTapGesture { viewModel.hideKeyboard() } // Hide keyboard when tapping outside
            .sheet(isPresented: $viewModel.showingFavorites) {
                FavoritesView(flashcards: $viewModel.flashcardManager.flashcards)
            }
            .alert(LocalizedStringKey("delete_flashcard_title"), isPresented: $viewModel.showingDeleteConfirmation) {
                Button(LocalizedStringKey("cancel"), role: .cancel) { viewModel.flashcardToDelete = nil }
                    
                Button(LocalizedStringKey("delete"), role: .destructive) {
                    viewModel.deleteFlashcard()
                        
                }
            } message: {
                Text(LocalizedStringKey("delete_flashcard_message"))
                  
            }
            .navigationTitle(LocalizedStringKey("translate"))
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 25))
                    }
                    .accessibilityLabel(LocalizedStringKey("settings_button"))
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .background(Color("Background"))
        }
    }
    
}


#Preview {
    ContentView()
}


