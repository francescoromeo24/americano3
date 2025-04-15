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
    let synthesizer = AVSpeechSynthesizer()
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Text Input Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.isTextToBraille ? "Text" : "Braille")
                            .font(.title)
                            .fontWeight(.semibold)
                            .dynamicTypeSize(..<DynamicTypeSize.large)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .padding([.top, .leading], 10.0)
                        
                        
                        
                        TextField(LocalizedStringKey(viewModel.placeholderText()), text: $viewModel.textInput, axis: .vertical)
                            .padding()
                            .frame(minHeight: 80)
                            .dynamicTypeSize(..<DynamicTypeSize.large)
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
                                .font(.system(size: 20))
                                .dynamicTypeSize(..<DynamicTypeSize.large)
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
                                .font(.system(size: 20))
                                .dynamicTypeSize(..<DynamicTypeSize.large)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                    }
                    .padding(.top, 5.0)
                    
                    // Braille Output Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.isTextToBraille ? "Braille" : "Text")
                            .font(.title)
                            .fontWeight(.semibold)
                            .dynamicTypeSize(..<DynamicTypeSize.large)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .padding([.top, .leading], 10.0)
                        
                        // Display the translated Braille output
                        ScrollView(.vertical, showsIndicators: true) {
    
                            
                            // Nella sezione Braille Output, modifica il TextField così:
                            TextField(LocalizedStringKey("translation"), text: $viewModel.brailleOutput, axis: .vertical)
                                .font(.custom("Courier", size: 20))
                                .padding()
                                .frame(minHeight: 80)
                                .background(Color.white)
                                .cornerRadius(10)
                                .dynamicTypeSize(..<DynamicTypeSize.large)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .disabled(true)
                                .accessibilityLabel(viewModel.textInput.map { String($0) }.joined(separator: ", "))
                                .accessibilityHint(LocalizedStringKey("swipe_to_hear"))
                                .onTapGesture {
                                    speakTranslation()
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
                                .dynamicTypeSize(..<DynamicTypeSize.large)
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
                            .font(.title)
                            .dynamicTypeSize(..<DynamicTypeSize.large)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        // Toggle to show favorite flashcards
                        Button(action: {
                            viewModel.showingFavorites.toggle()
                        }) {
                            Text(LocalizedStringKey("view_favorites"))
                                .foregroundColor(.blue)
                                .dynamicTypeSize(..<DynamicTypeSize.large)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Flashcard Grid Display
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.flashcardManager.flashcards) { flashcard in
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

// Aggiungi questa estensione alla fine del file, prima del Preview
extension ContentView {
    private func speakTranslation() {
        let textToSpeak = viewModel.isTextToBraille ? viewModel.textInput : viewModel.brailleOutput
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
        synthesizer.speak(utterance)
    }
}

