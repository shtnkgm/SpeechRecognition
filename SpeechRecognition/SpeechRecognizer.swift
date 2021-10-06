//
//  SpeechRecognizer.swift
//  SpeechRecognition
//
//  Created by shtnkgm on 2021/05/16.
//

import Foundation
import Speech

class SpeechRecognizer: NSObject, ObservableObject {
    @Published var isActive: Bool = false
    @Published var text: String?
    @Published var transcription: SFTranscription?
    private var textList: [String] = []
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))//.autoupdatingCurrent)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask? {
        didSet {
            isActive = recognitionTask != nil
        }
    }
    private let audioEngine = AVAudioEngine()
    
    // 参考: https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio
    
    func start() {
        guard !isActive else { return }
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
        }
        
        speechRecognizer?.delegate = self
        // 既に認識タスクが存在する場合にはキャンセル
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
        }
        // AudioSessionの設定
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true
        // recognitionRequest.taskHint = .dictation
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self,
                  let result = result else {
                print("resultなし")
                return
            }
                        
            //self.text = (self.textList + [result.bestTranscription.formattedString]).joined(separator: "\n")
            self.text = result.transcriptions.last?.formattedString
            self.transcription = result.bestTranscription
            print(result.bestTranscription.formattedString)
            
            if let error = error {
                print(error.localizedDescription)
            }
            
//            if error != nil || result.isFinal {
//                self.textList.append(result.bestTranscription.formattedString)
//                self.stop()
//                print("isFinal == true")
//            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stop() {
        guard isActive else { return }
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask = nil
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        isActive = available
    }
}
