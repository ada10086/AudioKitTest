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
        //use timer to receive amplitude and update state variable
        //how to stop timer?
        var timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ timer in
            self.scale = 1 + 10 * CGFloat(self.audioEngine.tracker.amplitude)
            print("contentView amplitude: \(self.audioEngine.tracker.amplitude)")
        }
        
        return VStack {
            if !recordingFinished {
//                RecordButton(audioEngine: audioEngine, recordingFinished: $recordingFinished)
                Circle()
                .fill(Color.red)
                .frame(width: 50, height: 50, alignment: .center)
                    ///amplitude not updating
//                .scaleEffect(self.isPressed ? 1 + 10 * CGFloat(self.audioEngine.tracker.amplitude) : 1)
                .scaleEffect(self.isPressed ? self.scale : 1)
                .animation(Animation.easeInOut)
//                .animation(self.isPressed ? Animation.easeInOut : nil)
                .onLongPressGesture(minimumDuration: 10, pressing: { pressed in
                                self.isPressed = pressed
                                if pressed {
//                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
//                                            self.myRadius.endRadius = 100 * CGFloat(self.audioEngine.tracker.amplitude)
//                                            print("contentView amplitude: \(self.audioEngine.tracker.amplitude)")
//                                        }
//                                    }

//                                    timer.fire()
                                } else {
//                                    timer.invalidate()
                                }
                            }, perform: {})
                
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
                    timer.invalidate()
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
