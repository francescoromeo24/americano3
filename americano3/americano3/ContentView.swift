//
//  ContentView.swift
//  americano3
//
//  Created by Francesco Romeo on 10/12/24.
//

import SwiftUI

struct ContentView: View {
    //customization of navigation title
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
   
    @State private var textInput = ""
    @State private var brailleOutput = ""
    @State private var isTextToBraille = true
    
    //translation from text to braille
    func translateToBraille(text: String) -> String {
        guard !text.isEmpty else {return " "}
        var translatedText = ""
        for char in text.lowercased() {
            if let brailleChar = brailleDictionary[char] {
                translatedText += brailleChar
            } else {
                translatedText += " "
            }
        }
        return translatedText
    }
    
    //translation from braille to text
    func translateToText(braille: String) -> String {
        guard !braille.isEmpty else {return " "}
        _ = " "
        let reverseDictionary = brailleDictionary.reduce(into: [String: Character]()) { result, pair in
            let (key, value) = pair
            if result[value] == nil {
                result[value] = key
            }
        }
        let brailleUnits = braille.split(separator: " ")
        var reversedText = ""
        for unit in brailleUnits {
            if let textChar = reverseDictionary[String(unit)] {
                reversedText += String(textChar)
            } else {
                reversedText += "?"
            }
        }
        
        return reversedText
    }
    
    var body: some View {
        NavigationStack {
                ScrollView{
                    VStack {
                        //rectangle, text section and buttons
                        VStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .frame(width: 370, height: 334)
                                    
                                
                                //text section and text label
                                VStack(alignment: .leading){
                                    Text(isTextToBraille ? "Text": "Braille")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.black)
                                        .padding(.trailing, 230)
                                    TextField("Enter \(isTextToBraille ? "text" : "braille")", text: isTextToBraille ? $textInput : $brailleOutput)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.gray)
                                        .padding(.trailing, 245)
                                        .padding(.bottom, 20)
                                    
                                        .onChange(of: isTextToBraille ? textInput : brailleOutput) {
                                            if isTextToBraille {
                                                brailleOutput = translateToBraille(text: textInput)
                                            } else {
                                                textInput = translateToText(braille: brailleOutput)
                                            }
                                        }

                                    
                                    //line in the middle of the rectangle, switch button
                                    
                                    Button(action:{
                                        isTextToBraille.toggle()
                                        textInput = " "
                                        brailleOutput = " "
                                    }){
                                        
                                        ZStack {
                                            Divider()
                                                .overlay(.blue)
                                             Image(systemName: "circle.fill")
                                            .foregroundStyle(Color("Background"))
                                                .font(.system(size: 40))
                                            Image(systemName: "arrow.trianglehead.swap")
                                                .font(.system(size: 20))
                                        }
                                        .padding(.top, 10)
                                    }
                                    
                                    //braille section, output
                                    VStack(alignment: .leading){
                                        Text(isTextToBraille ? "Braille": "Text")
                                            .font(.title)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.black)
                                        Text(brailleOutput)
                                            .font(.body)
                                           .fontWeight(.semibold)
                                           .foregroundColor(Color.gray)
                                           .padding(.bottom, 30.0)
                                        
                                            
                                    }.padding(.trailing, 200)
                                    
                                    
                                    //final part of the rectangle: link to Icloud and microphone
                                   
                                    HStack{
                                        
                                        ZStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(Color("Background"))
                                                .font(.system(size: 50))
                                            Image(systemName: "square.and.arrow.down")
                                                .font(.system(size: 25))
                                        }
                                        
                                        Spacer()
                                            .frame(width: 100)
                                        
                                        ZStack{
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(Color("Background"))
                                                .font(.system(size: 50))
                                            Image(systemName: "microphone")
                                                .font(.system(size: 25))
                                        }
                                        
                                    }
                                  
                                    
                                }
                                .padding()
                                
                            }
                        }
                        Spacer()
                        
                        
                        //history section and flashcards
                        HStack {
                            Text("History")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        //flashcards to track history
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 146, height: 164)
                                VStack{
                                    Text(textInput)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.black)
                                    
                                        .padding(.bottom,3)
                                    
                                    Text(brailleOutput)
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.gray)
                                    
                                }
                                Image(systemName: "star")
                                    .padding(.bottom, 120)
                                    .padding(.leading, 100)
                                
                            }
                            Spacer()
                                .frame(width: 30)
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 146, height: 164)
                                VStack{
                                    Text("Elevator")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.black)
                                    
                                        .padding(.bottom,3)
                                    
                                    Text("⠑⠇⠑⠧⠁⠞⠕⠗")
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.gray)
                                    
                                }
                                Image(systemName: "star.fill")
                                    .padding(.bottom, 120)
                                    .padding(.leading, 100)
                            }
                        }
                        
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 146, height: 164)
                                VStack{
                                    Text("Home")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.black)
                                    
                                        .padding(.bottom,3)
                                    
                                    Text("⠓⠕⠍⠑")
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.gray)
                                    
                                }
                                Image(systemName: "star")
                                    .padding(.bottom, 120)
                                    .padding(.leading, 100)
                            }
                            Spacer()
                                .frame(width: 30)
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 146, height: 164)
                                VStack{
                                    Text("Enterprise")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.black)
                                    
                                        .padding(.bottom,3)
                                    
                                    Text("⠢⠞⠻⠏⠗⠊⠎⠑")
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.gray)
                                    
                                }
                                Image(systemName: "star")
                                    .padding(.bottom, 120)
                                    .padding(.leading, 100)
                            }
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
        
    }


#Preview {
    ContentView()
}
