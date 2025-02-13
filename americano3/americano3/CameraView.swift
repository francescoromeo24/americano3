//
//  CameraView.swift
//  americano3
//
//  Created by Francesco Romeo on 31/12/24.
//
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    var isBraille: Bool // Parametro per determinare se siamo in modalità Braille
    var onImagePicked: (UIImage) -> Void
    
    // Crea l'UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        
        // Impostiamo lo sfondo della vista come nero e facciamo in modo che occupi tutto lo schermo
        picker.view.backgroundColor = .black
        picker.modalPresentationStyle = .fullScreen
        
        // Nascondiamo la status bar
        UIApplication.shared.isStatusBarHidden = true
        
        return picker
    }
    
    // Funzione che aggiorna la UI del controller (non utilizzata qui)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // Crea il Coordinatore per gestire le interazioni con l'UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Il Coordinatore gestisce l'input dell'utente
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        // Metodo chiamato quando un'immagine viene scelta
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        // Metodo chiamato se l'utente cancella la selezione dell'immagine
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    CameraView(isBraille: false) { image in
        // Aggiungi qui cosa fare con l'immagine
        print("Immagine scattata: \(image)")
    }
    .edgesIgnoringSafeArea(.all) // Per far sì che la fotocamera copra l'intero schermo
}
