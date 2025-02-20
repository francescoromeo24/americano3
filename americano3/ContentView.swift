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
                        
                        TextField(viewModel.placeholderText(), text: $viewModel.textInput, axis: .vertical)
                            .padding()
                            .frame(minHeight: 80)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                            .foregroundColor(.gray)
                            .accessibilityHint("Insert text here")
                            .accessibilityHint("Enter text here to translate")
                            .onChange(of: viewModel.textInput) {
                                viewModel.updateTranslation()
                            }
                            .padding(5)
                    }
                    
                    // Button Row: Switch & Add Flashcard
                    HStack {
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
                            .frame(width: 30)
                        
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
                                .disabled(true)
                                .accessibilityLabel(viewModel.textInput.map { String($0) }.joined(separator: ", "))
                                .accessibilityHint("Swipe per ascoltare lettera per lettera")
                        }
                        .padding(5)
                        .frame(minHeight: 80)
                    }
                    
                    // Importer and Camera Buttons
                    HStack {
                        Importer(selectedText: $viewModel.selectedText, selectedImage: $viewModel.selectedImage, translatedBraille: $viewModel.translatedBraille)
                        
                        
                        Spacer()
                            .frame(width: 20)
                        
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
                            .frame(width: 20)
                        
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
                        
                        Button(action: {
                            viewModel.showingFavorites.toggle()
                        }) {
                            Text("View Favorites")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Flashcard Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach($viewModel.flashcardManager.sortedFlashcards) { $flashcard in
                            NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                                FlashcardView(flashcard: $flashcard) { updatedFlashcard in
                                    viewModel.updateFlashcard(updatedFlashcard)
                                }
                                .frame(width: 146, height: 164)
                            }
                        }
                    }
                    .foregroundStyle(.blue)
                    .padding()
                }
            }
            .onTapGesture { viewModel.hideKeyboard() }
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
