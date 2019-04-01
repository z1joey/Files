//
//  AUSpeechManager.swift
//  ApeUni
//
//  Created by Yi Zhang on 22/11/18.
//  Copyright © 2018 AU. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class AUSpeechManager: NSObject {
    
    static let shared = AUSpeechManager.init()
    private override init() {}

    let audioEngine = AVAudioEngine()
    // 暂时选择美式英语
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    var speechWords = [String]()

    func cancelRecording() {
        audioEngine.stop()
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionTask?.cancel()
        isRecording = false
    }

    func recordAndRecognizeSpeech(match: @escaping (String)->Void) {
        speechWords.removeAll()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            print("Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            print("Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if result != nil {
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    self.speechWords = bestString.components(separatedBy: .whitespacesAndNewlines)
                    // 将识别到的单词传给闭包以作处理
                    match(self.speechWords.last!)
                } else if let error = error {
                    //self.sendAlert(message: "There has been a speech recognition error.")
                    print("There has been a speech recognition error.")
                    print(error)
                }
            }
        })
    }

    func requestSpeechAuthorization(success: @escaping () -> Void, fail: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    success()
                case .denied:
                    fail()
                    print("User denied access to speech recognition")
                case .restricted:
                    fail()
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    fail()
                    print("Speech recognition not yet authorized")
                }
            }
        }
    }
}
