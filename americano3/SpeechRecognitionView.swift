//
//  SpeechRecognitionView.swift
//  americano3
//
//  Created by Francesco Romeo on 16/12/24.
//

import SwiftUI
import Speech
import AVFoundation

struct SpeechRecognizerView: View {
    @State private var isRecording = false
    @StateObject private var speechRecognizer = SpeechRecognizerCoordinator()

    var onTranscriptionResult: (String) -> Void // Callback to return transcribed text

    var body: some View {
        Button(action: {
            if isRecording {
                speechRecognizer.stopRecording()
            } else {
                speechRecognizer.startRecording { result in
                    onTranscriptionResult(result) // Returns the transcribed result to ContentView
                }
            }
            isRecording.toggle()
        }) {
            ZStack {
                Image(systemName: "microphone")
                    .font(.system(size: 25))
                    .foregroundColor(.blue)
                    .padding()
                    .background(Circle().fill(isRecording ? Color.red : Color("Background")).stroke(Color.blue, lineWidth: 2))
            }
        }
    }
}

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

        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    do {
                        try self.startAudioEngine(completion: completion)
                    } catch {
                        print("Error starting audio engine: \(error.localizedDescription)")
                    }
                } else {
                    print("Speech recognition permission denied.")
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0) // Removes tap on the input node
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
        let recordingFormat = inputNode.inputFormat(forBus: 0) // Correct audio format
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

#Preview {
    SpeechRecognizerView(onTranscriptionResult: { result in
        print("Transcribed Text: \(result)")
    })
}
