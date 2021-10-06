//
//  ContentView.swift
//  SpeechRecognition
//
//  Created by shtnkgm on 2021/05/16.
//

import SwiftUI
import Speech

struct ContentView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("音声認識テスト" + (speechRecognizer.isActive ? "👂" : "😪"))
                    .font(.largeTitle)
//                if let text = speechRecognizer.text {
//                    Text(text)
//                        .font(.system(size: 30, weight: .bold))
//                        .multilineTextAlignment(.leading)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .animation(.easeIn)
//                }
                if let transcription = speechRecognizer.transcription {
                    TagListView(
                        items: transcription.segments,
                        itemSpacing: 0,
                        lineSpacing: 8,
                        alignment: .leading
                    ) { segment in
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(segment.substring)
                                .font(.system(size: 30, weight: .bold))
                                .opacity(Double(segment.confidence == 0 ? 0.5 : segment.confidence))
                            if let alternativeSubstring = segment.alternativeSubstrings.first {
                                Text("(" + alternativeSubstring + ")")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                }
                Button(action: {
                    speechRecognizer.isActive ? speechRecognizer.stop() : speechRecognizer.start()
                }, label: {
                    Text(speechRecognizer.isActive ? "停止" : "再開")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                })
                .frame(width: 200, height: 60)
                .background(speechRecognizer.isActive ? Color.red : Color.blue)
                .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .onAppear {
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
                speechRecognizer.text = "認識された言葉"
                return
            }
            speechRecognizer.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
