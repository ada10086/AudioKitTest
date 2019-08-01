//
//  AudioEngine.swift
//  AudioKitTest
//
//  Created by Chuchu Jiang on 7/30/19.
//  Copyright © 2019 adajiang. All rights reserved.
//

import Foundation
import AudioKit
import SwiftUI
import Combine

class AudioEngine: BindableObject {
    
    var willChange = PassthroughSubject<AudioEngine, Never>()
    
    var file: AKAudioFile!
    
    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    
    var recordedFileData: RecordedFileData? {
        willSet {
            self.willChange.send(self)
        }
    }
    
    var recordedFiles: [RecordedFileData] = [] {
        willSet {
            willChange.send(self)
        }
    }
    
    var activePlayer: AKPlayer! {
        willSet {
            self.willChange.send(self)
        }
    }
    
    var micBooster: AKBooster!
    let mic = AKMicrophone()
    
//    var normalPlayer: AKPlayer!
    
//    var echoPlayer: AKPlayer!
    var echoDelay: AKDelay!
    var echoReverb: AKReverb!
    
//    var fastPlayer: AKPlayer!
    var variSpeedFast: AKVariSpeed!
    
//    var slowPlayer: AKPlayer!
    var variSpeedSlow: AKVariSpeed!
    
//    var robotPlayer: AKPlayer!
    var robotDelay: AKDelay!
    
//    var chorusPlayer: AKPlayer!
    var chorus: AKChorus!
    
//    var normalPlayerData: PlayerData!
//    var echoPlayerData: PlayerData!
//    var fastPlayerData: PlayerData!
//    var slowPlayerData: PlayerData!
//    var robotPlayerData: PlayerData!
//    var chorusPlayerData: PlayerData!
    var normalPlayerData = PlayerData()
    var echoPlayerData = PlayerData()
    var fastPlayerData = PlayerData()
    var slowPlayerData = PlayerData()
    var robotPlayerData = PlayerData()
    var chorusPlayerData = PlayerData()
    var effectPlayers : [PlayerData] = []

    var mainMixer: AKMixer!
    var booster: AKBooster!
    
    var recordedPlayer: AKPlayer!
    
    init() {
        do {
//            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("tempRecording.wav")
//            file = try AKAudioFile(forReading: url)
            file = try AKAudioFile(readFileName: "hello.mp3")
            
        } catch {
            AKLog("File Not Found")
            return
        }
        
        micMixer = AKMixer(mic)
        recorder = try? AKNodeRecorder(node: micMixer)
        
          //normal
//        normalPlayer = AKPlayer(audioFile: file)
//        normalPlayer.isLooping = false
//        normalPlayer.buffering = .always
        normalPlayerData.effect = "normal"
        
          //echo
//        echoPlayer = AKPlayer(audioFile: file)
//        echoPlayer.isLooping = false
//        echoPlayer.buffering = .always
//        echoDelay = AKDelay(echoPlayer)
        echoPlayerData.effect = "echo"
        echoDelay = AKDelay(echoPlayerData.player)
        echoDelay.time = 0.1
        echoDelay.feedback = 0.4
        echoDelay.dryWetMix = 0.5
        echoReverb = AKReverb(echoDelay)
        echoReverb.loadFactoryPreset(.cathedral)
        
        //speedUp
//        fastPlayer = AKPlayer(audioFile: file)
//        fastPlayer.isLooping = false
//        fastPlayer.buffering = .always
//        variSpeedFast = AKVariSpeed(fastPlayer)
        fastPlayerData.effect = "fast"
        variSpeedFast = AKVariSpeed(fastPlayerData.player)
        variSpeedFast.rate = 1.7
        
        //slowDown
//        slowPlayer = AKPlayer(audioFile: file)
//        slowPlayer.isLooping = false
//        slowPlayer.buffering = .always
//        variSpeedSlow = AKVariSpeed(slowPlayer)
        slowPlayerData.effect = "slow"
        variSpeedSlow = AKVariSpeed(slowPlayerData.player)
        variSpeedSlow.rate = 0.7
        
        //robot
//        robotPlayer = AKPlayer(audioFile: file)
//        robotPlayer.isLooping = false
//        robotPlayer.buffering = .always
//        robotDelay = AKDelay(robotPlayer)
        robotPlayerData.effect = "robot"
        robotDelay = AKDelay(robotPlayerData.player)
        robotDelay.time = 0.015 // seconds
        robotDelay.lowPassCutoff = 17593 //Hz
        robotDelay.feedback = 0.75 // Normalized Value 0 - 1
        robotDelay.dryWetMix = 0.47 // Normalized Value 0 - 1
        
        //chorus
//        chorusPlayer = AKPlayer(audioFile: file)
//        chorusPlayer.isLooping = false
//        chorusPlayer.buffering = .always
//        chorus = AKChorus(chorusPlayer)
        chorusPlayerData.effect = "chorus"
        chorus = AKChorus(chorusPlayerData.player)
        chorus.feedback = 0.7
        chorus.depth = 0.5
        chorus.dryWetMix = 0.5
        chorus.frequency = 8
        
        effectPlayers = [normalPlayerData, echoPlayerData, fastPlayerData, slowPlayerData, robotPlayerData, chorusPlayerData]
        
        recordedPlayer = AKPlayer(audioFile: file)
        recordedPlayer.isLooping = false
        recordedPlayer.buffering = .always
        
        activePlayer = normalPlayerData.player
        
        //mixer
        mainMixer = AKMixer(normalPlayerData.player, echoReverb, variSpeedFast, variSpeedSlow, robotDelay, chorus, recordedPlayer)
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

struct RecordedFileData: Hashable {
    var id: UUID
    var fileURL: URL
    var title: String
    //var effect
}

struct PlayerData: Hashable {
    var player: AKPlayer!
    var effect = "effect"
    
//    static func ==(lhs: PlayerData, rhs: PlayerData) -> Bool {
//        return lhs.player == rhs.player && lhs.effect == rhs.effect
//    }
    
    init(){
        do {
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("tempRecording.wav")
            let myFile = try AKAudioFile(forReading: url)
            player = AKPlayer(audioFile: myFile)

        } catch {
            AKLog("File Not Found")
            return
        }
        
        player.isLooping = false
        player.buffering = .always
    }
}

