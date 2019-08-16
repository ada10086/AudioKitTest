//
//  ContentView.swift
//  AudioKitTest
//
//  Created by Chuchu Jiang on 7/25/19.
//  Copyright © 2019 adajiang. All rights reserved.
//

import SwiftUI
import AudioKit
import AudioKitUI
import Combine

struct ContentView: View {
    @ObservedObject var audioEngine: AudioEngine
    @State var recordingFinished: Bool = false
    @State var audioSaved: Bool = false
    @State private var scale : CGFloat = 1
    @State private var isPressed : Bool = false
    
    var amplitudeCanceller: Cancellable?
    
//    var animation: Animation {
//        Animation.linear(duration: 10)
//    }
    
    var body: some View {
        
        return VStack {

            if !recordingFinished {
                RecordButton(audioEngine: audioEngine, recordingFinished: $recordingFinished)
                
                Button("record"){
                    self.isPressed = true
                    ///start microphone amplitude tracker
                    self.audioEngine.tracker.start()
                    do {
                        try self.audioEngine.recorder.reset()
                        try self.audioEngine.recorder.record()
                    } catch { AKLog("Errored recording.") }
                }
                .font(.title)
                
                Button("stop"){
                    self.isPressed = false
                    ///stop microphone amplitude tracker
                    self.audioEngine.tracker.stop()
                    ///timer doesn't stop
//                    timer.invalidate()
                    print("recorderDuration\(self.audioEngine.recorder.audioFile!.duration)")
                    
                    //export original recording file
                    if let _ = self.audioEngine.recorder.audioFile?.duration {
                        self.audioEngine.recorder.stop()
                        self.audioEngine.recorder.audioFile!.exportAsynchronously(
                            name: "tempRecording.wav",
                            baseDir: .documents,
                            exportFormat: .wav) { file, exportError in
                                if let error = exportError {
                                    AKLog("Export Failed \(error)")
                                } else {
                                    AKLog("Export succeeded")
                                }
                        }
                    }
                    
                    //load effectPlayers with recorder audiofile
                    for playerData in self.audioEngine.effectPlayers {
                        playerData.player.load(audioFile: self.audioEngine.recorder.audioFile!)
                    }
                    
                    self.recordingFinished = true
                }
                .font(.title)
                .padding(.bottom, 50)
                
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
