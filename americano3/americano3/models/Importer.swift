//
//  Importer.swift
//  americano3
//
//  Created by Francesco Romeo on 13/12/24.
//

import SwiftUI

struct Importer: View {
    @State private var showImporter = false
    @State private var importedText: String? = nil
    var body: some View {
        HStack{
            
            Button(action: {
                showImporter = true
            }) {
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(Color("Background"))
                        .font(.system(size: 50))
                    
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 25))
                }
                
                .fileImporter(
                    isPresented: $showImporter,
                    allowedContentTypes: [.text],
                    allowsMultipleSelection: false
                ) { result in
                    print("result: \(result)")
                    
                    switch result {
                    case .success(let urls):
                        print("success url: \(urls)")
                        guard let url = urls.first else {return}
                        guard let fileContent = try? String(contentsOf: url, encoding: .utf8) else {return}
                        self.importedText = fileContent
                    case .failure(let error):
                        print("failed with error: \(error.localizedDescription)")
                    }
                }
            }
            
            Spacer()
                .frame(width: 100)
        }
        
    }
}

#Preview {
    Importer()
}
