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
    @ObjectBinding var audioEngine: AudioEngine
    
    var lineWidth: CGFloat = 5
    var buttonRadius: CGFloat = 25
    var trackPathRadius: CGFloat = 40
    @State var arc: MyArc = MyArc(startAngle: Angle(degrees: 270), finalAngle: Angle(degrees: 270))
    
    var body: some View {
        
        ZStack{
            //center circle button
            CircleButton(audioEngine: audioEngine, arc: $arc, radius: buttonRadius)
            
            //circular path
            Circle()
                .stroke(Color.gray, lineWidth: lineWidth)
                .frame(width: trackPathRadius*2, height: trackPathRadius*2, alignment: .center)
            
            //track path
            TrackPathView(arc: arc, lineWidth: lineWidth, radius: trackPathRadius)
                .frame(width: trackPathRadius*2, height: trackPathRadius*2, alignment: .center)
        }
        
    }
}

struct CircleButton : View {
    @ObjectBinding var audioEngine: AudioEngine
    
    @Binding var arc: MyArc
    var radius: CGFloat
    
    @State private var startTime : Date = Date()
    @State private var scale : Length = 1
    @State private var isPressed : Bool = false
    
    var pulse: Animation {
        Animation.basic(duration: 0.8, curve: .easeInOut)
            .repeatForever(autoreverses:true)
    }
    
    var pulseReturn: Animation {
        Animation.basic(duration: 0.4, curve: .easeInOut)
            .repeatCount(1)
    }
    
    var fill: Animation {
        Animation.basic(duration: 10, curve: .linear)
    }
    
    var body: some View {
        
        return Circle()
            .fill(Color.gray)
            .frame(width: radius*2, height: radius*2, alignment: .center)
            //.animation(nil)
            .scaleEffect(scale)
            .animation(isPressed ? pulse : pulseReturn)
            .longPressAction(minimumDuration: 10, {},
                             pressing: { pressed in
                                self.isPressed = pressed
                                self.scale = pressed ? 1.1 : 1
                                print("recording1")
//                                do {
//                                    try self.audioEngine.recorder.reset()
//                                    try self.audioEngine.recorder.record()
//                                } catch { AKLog("Errored recording.") }
                                if pressed {
                                                                    do {
                                                                        try self.audioEngine.recorder.reset()
                                                                        try self.audioEngine.recorder.record()
                                                                    } catch { AKLog("Errored recording.") }
                                    self.startTime = Date()
                                    self.arc.finalAngle = Angle(degrees: 270)
                                    withAnimation(self.fill) {
                                        self.arc.finalAngle = Angle(degrees: 630)
                                    }
                                } else {
                                    print("elapsed: \(self.startTime.timeIntervalSinceNow * -1)")
                                    withAnimation(.empty) {
                                        self.arc.finalAngle = Angle(degrees: 270 + self.startTime.timeIntervalSinceNow * -36)
                                    }
                                    
                                    self.audioEngine.normalPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
                                    self.audioEngine.echoPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
                                    self.audioEngine.fastPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
                                    self.audioEngine.slowPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
                                    self.audioEngine.robotPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
                                    self.audioEngine.chorusPlayer.load(audioFile: self.audioEngine.recorder.audioFile!)
                                    
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
                                }
            }
        )
    }
}

//struct to store arc angle values
struct MyArc : Equatable {
    private(set) var startAngle: Angle
    var finalAngle: Angle
}

extension MyArc: Animatable {
    typealias AnimatableData = AnimatablePair<Double, Double>
    
    var animatableData: AnimatableData{
        get{
            .init(startAngle.degrees, finalAngle.degrees)
        }
        set{
            startAngle = Angle(degrees: newValue.first)
            finalAngle = Angle(degrees: newValue.second)
        }
    }
}


struct TrackPathShape: Shape {
    var arc: MyArc
    var radius: CGFloat
    
    init(_ arc: MyArc, _ radius:CGFloat) {self.arc = arc
        self.radius = radius}
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        //change center to be frame center
        path.addArc(center: CGPoint(x:radius, y:radius), radius: radius, startAngle: arc.startAngle, endAngle: arc.finalAngle, clockwise: false)
        return path
    }
    
    var animatableData: MyArc.AnimatableData {
        get{arc.animatableData}
        set{arc.animatableData = newValue}
    }
}

struct TrackPathView: View {
    var arc: MyArc
    var lineWidth: CGFloat
    var radius: CGFloat
    
    var body: some View {
        TrackPathShape(arc, radius)
            .stroke(style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .miter, miterLimit: 5, dash:[Length](), dashPhase: 0))
            .fill(Color.red)
    }
}


//#if DEBUG
//struct RecordButton_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordButton()
//    }
//}
//#endif
