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
    
    // Variables for translation
    @State private var textInput = ""
    @State private var brailleOutput = ""
    @State private var isTextToBraille = true
    //variable flashcard
    @StateObject private var flashcardManager = FlashcardManager()
    //variable favourites
    @State private var showingFavorites = false
    //Variables for recording
    @State private var isRecording = false
    @State private var isCameraPresented = false
    @StateObject private var speechRecognizer = SpeechRecognizerCoordinator()
    
    @State private var selectedText: String?
    @State private var selectedImage: UIImage?
    @State private var translatedBraille: String?
    
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
                                    .accessibilityHint("This is the text label")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.black)
                                Spacer()
                            }
                            
                            // Insert text
                            /*ZStack(alignment: .topLeading){
                                if (isTextToBraille ? textInput : brailleOutput).isEmpty {
                                    Text("Enter \(isTextToBraille ? "text" : "braille")")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 8)
                                }
                                
                                TextEditor(text: isTextToBraille ? $textInput : $brailleOutput)*/
                            
                            TextField("Enter \(isTextToBraille ? "text" : "braille")", text: isTextToBraille ? $textInput : $brailleOutput)
                                    .frame(minHeight: 80)
                                    .padding(4)
                                .accessibilityHint("Insert text here")
                                .frame(height: 80)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.black)
                                .font(.body)
                            
                                .onChange(of: textInput) {
                                    if isTextToBraille {
                                        brailleOutput = Translate.translateToBraille(text: textInput)
                                    } else {
                                        textInput = Translate.translateToText(braille: brailleOutput)
                                    }
                                }
                                
                            // add flashcard everytime you insert a text
                                .onSubmit {
                                    flashcardManager.addFlashcard(textInput: textInput, brailleOutput: brailleOutput)
                                    textInput = ""
                                    brailleOutput = ""
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
                                            .accessibilityHint("This is the switch button")
                                    }
                                }
                            }
                            Spacer()
                            
                            // Braille section, output
                            VStack(alignment: .leading) {
                                Text(isTextToBraille ? "Braille" : "Text")
                                    .accessibilityHint("This is the Braille label")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.black)
                                
                                ScrollView(.vertical, showsIndicators: true) {
                                    Text(brailleOutput)
                                        .accessibilityHint("This is the Braille Output")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.clear)
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 40)
                            }
                            
                            // Importer from files
                            HStack {
                                Importer(
                                    selectedText: $selectedText,
                                    selectedImage: $selectedImage,
                                    translatedBraille: $translatedBraille
                                )
                                .onChange(of: selectedText) { newText in
                                    guard let newText else { return }
                                    handleImportedText(newText)
                                }
                                .onChange(of: selectedImage) { newImage in
                                    guard let newImage else { return }
                                    processImage(newImage)
                                }
                                
                                
                                
                                    .padding(.trailing)
                                    .accessibilityHint("You can import files here")
                                
                                
                                
        
                                Button(action: {
                                    isCameraPresented = true
                                }) {
                                    ZStack{
                                        Image(systemName: "circle.fill")
                                            .foregroundStyle(Color("Background"))
                                            .font(.system(size: 50))
                                        Image(systemName: "camera")
                                            .font(.system(size: 25))
                                    }
                                }
                                .fullScreenCover(isPresented: $isCameraPresented) {
                                    CameraView { image in
                                        processImage(image)
                                    }
                                    .edgesIgnoringSafeArea(.all)
                                }
                               
                                
                                // Microphone button
                                SpeechRecognizerView()
                                { result in
                                    textInput = result
                                    brailleOutput = Translate.translateToBraille(text: result)
                                    
                                    flashcardManager.addFlashcard(textInput: textInput, brailleOutput: brailleOutput)
                                }
                                .padding(.leading)
                            }
                            
                            .padding(.top, 5)
                        }
                        .padding()
                    }
                    .padding(.vertical, 10)
                    
                    // History section
                    HStack {
                        Text("History")
                            .accessibilityHint("This is the history section")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                            .padding(.leading, 20.0)
                        
                        Spacer()
                            
                        
                        Button(action: {
                            showingFavorites.toggle()
                        }) {
                            Text("View Favorites")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 20.0)
                    }
                }
                
                //Flashcard Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach($flashcardManager.flashcards) { $flashcard in
                        NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)){
                            FlashcardView(flashcard: $flashcard)
                            { updatedFlashcard in
                                
                                // Update the flashcard with the updated one
                                if let index = flashcardManager.flashcards.firstIndex(where: { $0.id == flashcard.id }) {
                                    flashcardManager.flashcards[index] = updatedFlashcard
                                }
                            }
                            .frame(width: 146, height: 164) // Set the size of each flashcard
                        }
                    }
                }
                
                .foregroundStyle(.blue)
                .padding()
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView(flashcards: $flashcardManager.flashcards)
            }
            .navigationTitle("Braille Translator")
            .foregroundColor(.blue)
            .background(Color("Background"))
            
        }
    }
    
    private func handleImportedText(_ text: String) {
        textInput = text
        brailleOutput = isTextToBraille ? Translate.translateToBraille(text: text) : Translate.translateToText(braille: text)

    }
    
    private func processImage(_ image: UIImage) {
        VisionProcessor.shared.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                if result.isEmpty{
                    textInput = "Nessun testo riconosciuto"
                    brailleOutput = " "
                }else{
                    if isTextToBraille{
                    textInput = result
                    brailleOutput = Translate.translateToBraille(text: result)
                    }else{
                        textInput = Translate.translateToText(braille: result)
                        brailleOutput = result
                    }
                }
            }
        }
    }

    
    
    
    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcardManager.flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcardManager.flashcards[index].isStarred.toggle()
        }
    }
}

#Preview {
    ContentView()
}
