//
//  recordButton.swift
//  AudioKitTest
//
//  Created by Chuchu Jiang on 7/25/19.
//  Copyright © 2019 adajiang. All rights reserved.
//

import SwiftUI
import AudioKit

struct RecordButton : View {
    @ObservedObject var audioEngine: AudioEngine
    @Binding var recordingFinished: Bool
    
    var lineWidth: CGFloat = 5
    var buttonRadius: CGFloat = 25
    var trackPathRadius: CGFloat = 40
    @State var isPressed : Bool = false
    @State var endTrim : CGFloat = 0
    @State var scale : CGFloat = 1

    var body: some View {
        
        //use timer to receive amplitude and update state variable
        //how to stop timer?
        var timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ timer in
            self.scale = 1 + 10 * CGFloat(self.audioEngine.tracker.amplitude)
            print("contentView amplitude: \(self.audioEngine.tracker.amplitude)")
        }
        
        return ZStack{
            //visulizer
            Circle()
                .fill(Color.blue)
                .frame(width: 70, height: 70)
                ///amplitude not updating
                // .scaleEffect(self.isPressed ? 1 + 10 * CGFloat(self.audioEngine.trackerAmplitude) : 1)
                // .scaleEffect(self.isPressed ? 1 + 10 * CGFloat(self.audioEngine.tracker.amplitude) : 1)
                .scaleEffect(self.isPressed ? self.scale : 1)
                .animation(Animation.easeInOut)
                //                .animation(self.isPressed ? Animation.easeInOut : nil)
            
//                .onLongPressGesture(minimumDuration: 10, pressing: { pressed in
//                    self.isPressed = pressed
//                    if pressed {
//                        //                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
//                        //                                            self.myRadius.endRadius = 100 * CGFloat(self.audioEngine.tracker.amplitude)
//                        //                                            print("contentView amplitude: \(self.audioEngine.tracker.amplitude)")
//                        //                                        }
//                        //                                    }
//
//                        //                                    timer.fire()
//                    } else {
//                        //                                    timer.invalidate()
//                    }
//                }, perform: {})
            
            //center circle button
            CircleButton(audioEngine: audioEngine, recordingFinished: $recordingFinished, endTrim: $endTrim, isPressed: $isPressed, radius: buttonRadius)
            //background path
            Circle()
                .trim(from:0, to:1)
                .stroke(Color.gray, lineWidth: lineWidth)
                .frame(width: trackPathRadius*2, height: trackPathRadius*2)
            //track path
            Circle()
                .trim(from: 0, to: self.endTrim)
                .stroke(Color.red, lineWidth: lineWidth)
                .frame(width: trackPathRadius*2, height: trackPathRadius*2)
                .rotationEffect(.degrees(-90))
                .animation(Animation.linear(duration:10))
        }
        
    }
}

struct CircleButton : View {
    @ObservedObject var audioEngine: AudioEngine
    @Binding var recordingFinished: Bool
    @Binding var endTrim: CGFloat
    @Binding var isPressed : Bool
    var radius: CGFloat
    
    @State private var startTime : Date = Date()
    @State private var scale : CGFloat = 1
//    @State private var isPressed : Bool = false

    var pulse: Animation {
        Animation.easeInOut(duration: 0.8)
            .repeatForever(autoreverses:true)
    }
    
    var pulseReturn: Animation {
        Animation.easeInOut(duration: 0.4)
            .repeatCount(1)
    }
    
    var fill: Animation {
        Animation.linear(duration: 10)
    }
    
    var body: some View {
        
        return Circle()
            .fill(Color.gray)
            .frame(width: radius*2, height: radius*2, alignment: .center)
            //.animation(nil)
            .scaleEffect(scale)
            .animation(isPressed ? pulse : pulseReturn)
            .onLongPressGesture(minimumDuration: 10, pressing: { pressed in
                self.isPressed = pressed
                self.scale = pressed ? 1.1 : 1
                
                if pressed {
                    ///start microphone amplitude tracker
                    self.audioEngine.tracker.start()
                    
                    do {
                        try self.audioEngine.recorder.reset()
                        try self.audioEngine.recorder.record()
                    } catch { AKLog("Errored recording.") }
                    
                    self.startTime = Date()
                    withAnimation(self.fill) {
                        self.endTrim = 1
                    }
                    
                } else {
                    print("elapsed: \(self.startTime.timeIntervalSinceNow * -1)")
                    withAnimation() {
                        self.endTrim = CGFloat(self.startTime.timeIntervalSinceNow * -1/10)
                    }
                    
                    ///stop microphone amplitude tracker
                    self.audioEngine.tracker.stop()
                    ///timer doesn't stop
                    //timer.invalidate()
                    
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
            }, perform: {})
    }
}
