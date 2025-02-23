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
    
    init() {
        // Customize the appearance of the navigation bar title
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
    
    @StateObject private var viewModel = ContentViewFunc()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Text Input Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.isTextToBraille ? "Text" : "Braille")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding([.top, .leading], 10.0)
                        
                        // User text input field
                        TextField(viewModel.placeholderText(), text: $viewModel.textInput, axis: .vertical)
                            .padding()
                            .frame(minHeight: 80)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                            .foregroundColor(.gray)
                            .accessibilityHint("Enter text here to translate")
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
                            .foregroundColor(.black)
                            .padding([.top, .leading], 10.0)
                        
                        // Display the translated Braille output
                        ScrollView(.vertical, showsIndicators: true) {
                            TextField("Translation", text: $viewModel.brailleOutput, axis: .vertical)
                                .font(.custom("Courier", size: 20))
                                .padding()
                                .frame(minHeight: 80)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .disabled(true) // Make the output read-only
                                .accessibilityLabel(viewModel.textInput.map { String($0) }.joined(separator: ", "))
                                .accessibilityHint("Swipe to hear letter by letter")
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
                        Text("History")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        // Toggle to show favorite flashcards
                        Button(action: {
                            viewModel.showingFavorites.toggle()
                        }) {
                            Text("View Favorites")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Flashcard Grid Display
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach($viewModel.flashcardManager.sortedFlashcards) { $flashcard in
                            NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                                FlashcardView(flashcard: $flashcard) { updatedFlashcard in
                                    viewModel.updateFlashcard(updatedFlashcard)
                                }
                                .frame(
                                    width: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 146,
                                    height: UIDevice.current.userInterfaceIdiom == .pad ? 220 : 164)
                                .onLongPressGesture {
                                    viewModel.flashcardToDelete = flashcard
                                    viewModel.showingDeleteConfirmation = true
                                }
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
            .alert("Delete Flashcard?", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { viewModel.flashcardToDelete = nil }
                Button("Delete", role: .destructive) {
                    viewModel.deleteFlashcard()
                }
            } message: {
                Text("Are you sure you want to delete this flashcard?")
            }
            .navigationTitle("Translate")
            .foregroundColor(.blue)
            .background(Color("Background"))
        }
    }
}

#Preview {
    ContentView()
}
