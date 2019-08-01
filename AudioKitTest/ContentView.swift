//
//  ContentView.swift
//  AudioKitTest
//
//  Created by Chuchu Jiang on 7/25/19.
//  Copyright © 2019 adajiang. All rights reserved.
//

import SwiftUI
import AudioKit
import Combine

struct ContentView: View {
    @ObjectBinding var audioEngine: AudioEngine
    @State var recordingFinished: Bool = false
    @State var audioSaved: Bool = false
    
    var body: some View {
        VStack {
            if !recordingFinished {
                RecordButton(audioEngine: audioEngine, recordingFinished: $recordingFinished)
//                            Button("record"){
//                                do {
//                                    try self.audioEngine.recorder.reset()
//                                    try self.audioEngine.recorder.record()
//                                } catch { AKLog("Errored recording.") }
//                            }
//                            .font(.title)
//
//                            Button("stop"){
//                                print("recorderDuration\(self.audioEngine.recorder.audioFile!.duration)")
//
//                                self.audioEngine.normalPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
//                                self.audioEngine.echoPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
//                                self.audioEngine.fastPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
//                                self.audioEngine.slowPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
//                                self.audioEngine.robotPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
//                                self.audioEngine.chorusPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
//
//                                //export original recording file
//                                if let _ = self.audioEngine.recorder.audioFile?.duration {
//                                    self.audioEngine.recorder.stop()
//                                    self.audioEngine.recorder.audioFile!.exportAsynchronously(
//                                        name: "tempRecording.wav",
//                                        baseDir: .documents,
//                                        exportFormat: .wav) { file, exportError in
//                                            if let error = exportError {
//                                                AKLog("Export Failed \(error)")
//                                            } else {
//                                                AKLog("Export succeeded")
//                                            }
//                                        }
//                                }
//                            }
//                            .font(.title)
//                            .padding(.bottom, 50)
                
            } else {
                
                if !audioSaved {
                    
                    EffectPreview(audioEngine: audioEngine, audioSaved: $audioSaved)

                } else {
                    SavedAudioView(audioEngine: audioEngine)
                    .padding()
                    Button("new recording"){
                        self.recordingFinished = false
                        self.audioSaved = false
                    }
                    .font(.title)
                    .foregroundColor(Color.red)
                    .frame(width: 200, height: 30, alignment: .center)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(5)
                }
            }
        }
    }
}
