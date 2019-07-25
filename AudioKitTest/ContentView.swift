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
//    var audioEngine = AudioEngine()
//    @EnvironmentObject var audioEngine: AudioEngine
    @ObjectBinding var audioEngine: AudioEngine
    @State var title: String = "type here"

    var body: some View {
        VStack {
            RecordButton(audioEngine: audioEngine)
            Button("record"){
                do {
                    try self.audioEngine.recorder.record()
                } catch { AKLog("Errored recording.") }
            }
            Button("stop"){
                        self.audioEngine.recorderPlayer.stop()
                //        micBooster.gain = 0
                        self.audioEngine.tape = self.audioEngine.recorder.audioFile!
                        self.audioEngine.recorderPlayer.load(audioFile: self.audioEngine.tape)
                        self.audioEngine.normalPlayer.load(audioFile:self.audioEngine.tape)
                        self.audioEngine.echoPlayer.load(audioFile:self.audioEngine.tape)
                        self.audioEngine.fastPlayer.load(audioFile:self.audioEngine.tape)
                        self.audioEngine.slowPlayer.load(audioFile:self.audioEngine.tape)
                        self.audioEngine.robotPlayer.load(audioFile:self.audioEngine.tape)
                        self.audioEngine.chorusPlayer.load(audioFile:self.audioEngine.tape)
                
                        
                        if let _ = self.audioEngine.recorderPlayer.audioFile?.duration {
                            self.audioEngine.recorder.stop()
                            self.audioEngine.tape.exportAsynchronously(name: "TempTestFile.m4a",
                                                      baseDir: .documents,
                                                      exportFormat: .m4a) { file, exportError in
                                                        print(file?.directoryPath)
                                                        if let error = exportError {
                                                            AKLog("Export Failed \(error)")
                                                        } else {
                                                            AKLog("Export succeeded")
                                                        }
                            }
                        }
            }
            Button("play"){
                self.audioEngine.normalPlayer!.play()
            }
            Button("echo"){
                self.audioEngine.echoPlayer!.play()
            }
            Button("fast"){
                self.audioEngine.fastPlayer!.play()
            }
            Button("slow"){
                self.audioEngine.slowPlayer!.play()
            }
            Button("robot"){
                self.audioEngine.robotPlayer!.play()
            }
            Button("chorus"){
                self.audioEngine.chorusPlayer!.play()
            }
            TextField("type here", text: $title)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioEngine: AudioEngine())
    }
}
#endif


class AudioEngine: BindableObject {
        
    var willChange = PassthroughSubject<AudioEngine, Never>()

    var file: AKAudioFile!{
        willSet {
            self.willChange.send(self)
        }
    }
    
    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!{
            willSet {
                self.willChange.send(self)
            }
        }
    
    var recorderPlayer: AKPlayer!{
            willSet {
                self.willChange.send(self)
            }
        }
    var tape: AKAudioFile!{
            willSet {
                self.willChange.send(self)
            }
        }
    var micBooster: AKBooster!
    let mic = AKMicrophone()
    
    var normalPlayer: AKPlayer!
    
    var echoPlayer: AKPlayer!
    var echoDelay: AKDelay!
    var echoReverb: AKReverb!
    
    var fastPlayer: AKPlayer!
    var variSpeedFast: AKVariSpeed!
    
    var slowPlayer: AKPlayer!
    var variSpeedSlow: AKVariSpeed!
    
    var robotPlayer: AKPlayer!
    var robotDelay: AKDelay!
    
    var chorusPlayer: AKPlayer!
    var chorus: AKChorus!
    
    var mainMixer: AKMixer!
    var booster: AKBooster!
    
    init() {
        do {
            file = try AKAudioFile(readFileName: "hello.mp3")

        } catch {
            AKLog("File Not Found")
            return
        }
        
        micMixer = AKMixer(mic)
        recorder = try? AKNodeRecorder(node: micMixer)
        if let recordedFile = recorder.audioFile {
            recorderPlayer = AKPlayer(audioFile: recordedFile)
        }
        recorderPlayer.isLooping = false
        recorderPlayer.buffering = .always
        recorderPlayer.completionHandler = playingEnded
        
        //normal
        normalPlayer = AKPlayer(audioFile: file)
        normalPlayer.isLooping = false
        normalPlayer.buffering = .always
        
        //echo
        echoPlayer = AKPlayer(audioFile: file)
        echoPlayer.isLooping = false
        echoPlayer.buffering = .always
        echoDelay = AKDelay(echoPlayer)
        echoDelay.time = 0.1
        echoDelay.feedback = 0.5
        echoDelay.dryWetMix = 0.2
        echoReverb = AKReverb(echoDelay)
        echoReverb.loadFactoryPreset(.cathedral)
        
        //speedUp
        fastPlayer = AKPlayer(audioFile: file)
        fastPlayer.isLooping = false
        fastPlayer.buffering = .always
        variSpeedFast = AKVariSpeed(fastPlayer)
        variSpeedFast.rate = 1.7
        
        //slowDown
        slowPlayer = AKPlayer(audioFile: file)
        slowPlayer.isLooping = false
        slowPlayer.buffering = .always
        variSpeedSlow = AKVariSpeed(slowPlayer)
        variSpeedSlow.rate = 0.7
        
        //robot
        robotPlayer = AKPlayer(audioFile: file)
        robotPlayer.isLooping = false
        robotPlayer.buffering = .always
        robotDelay = AKDelay(robotPlayer)
        robotDelay.time = 0.015 // seconds
        robotDelay.lowPassCutoff = 17593 //Hz
        robotDelay.feedback = 0.75 // Normalized Value 0 - 1
        robotDelay.dryWetMix = 0.47 // Normalized Value 0 - 1
        
        //chorus
        chorusPlayer = AKPlayer(audioFile: file)
        chorusPlayer.isLooping = false
        chorusPlayer.buffering = .always
        chorus = AKChorus(chorusPlayer)
        chorus.feedback = 0.7
        chorus.depth = 0.5
        chorus.dryWetMix = 0.5
        chorus.frequency = 8
        
        //mixer
        mainMixer = AKMixer(normalPlayer, echoReverb, variSpeedFast, variSpeedSlow, robotDelay, chorus, recorderPlayer)
        booster = AKBooster(mainMixer)
        AudioKit.output = booster
        startAudioKit()
    }
    
    func startAudioKit() {
            do {
                try AudioKit.start()
            } catch {
                AKLog("AudioKit did not start!")
            }
    }
    
    func playingEnded() {
        DispatchQueue.main.async {
            AKLog("Playing Ended")
        }
    }

}
