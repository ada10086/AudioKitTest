//
//  EffectButtons.swift
//  AudioKitTest
//
//  Created by Chuchu Jiang on 7/30/19.
//  Copyright © 2019 adajiang. All rights reserved.
//

import SwiftUI
import AudioKit

struct EffectPreview: View {
    @ObjectBinding var audioEngine: AudioEngine
    @Binding var audioSaved: Bool
    @State var title: String = "my audio"
    
    var body: some View {
        VStack{
            
            ForEach(self.audioEngine.effectPlayers, id: \.self){ playerData in
                Button(playerData.effect){
                    playerData.player.play()
                    self.audioEngine.activePlayer = playerData.player
                }
                .frame(width: 90, height: 30, alignment: .center)
                .padding()
                .background(Color.black)
                .cornerRadius(5)
                .font(.title)
                .foregroundColor(Color.white)
            }
//            //preview buttons
//            VStack {
//                Button("play"){
//                    self.audioEngine.normalPlayer!.play()
//                    self.audioEngine.activePlayer = self.audioEngine.normalPlayer!
//                }
//                .frame(width: 90, height: 30, alignment: .center)
//                .padding()
//                .background(Color.black)
//                .cornerRadius(5)
//                
//                Button("echo"){
//                    self.audioEngine.echoPlayer!.play()
//                    self.audioEngine.activePlayer = self.audioEngine.echoPlayer!
//                }
//                .frame(width: 90, height: 30, alignment: .center)
//                .padding()
//                .background(Color.black)
//                .cornerRadius(5)
//
//                Button("fast"){
//                    self.audioEngine.fastPlayer!.play()
//                    self.audioEngine.activePlayer = self.audioEngine.fastPlayer!
//                }
//                .frame(width: 90, height: 30, alignment: .center)
//                .padding()
//                .background(Color.black)
//                .cornerRadius(5)
//
//                Button("slow"){
//                    self.audioEngine.slowPlayer!.play()
//                    self.audioEngine.activePlayer = self.audioEngine.slowPlayer!
//                }
//                .frame(width: 90, height: 30, alignment: .center)
//                .padding()
//                .background(Color.black)
//                .cornerRadius(5)
//
//                Button("robot"){
//                    self.audioEngine.robotPlayer!.play()
//                    self.audioEngine.activePlayer = self.audioEngine.robotPlayer!
//                }
//                .frame(width: 90, height: 30, alignment: .center)
//                .padding()
//                .background(Color.black)
//                .cornerRadius(5)
//
//                Button("chorus"){
//                    self.audioEngine.chorusPlayer!.play()
//                    self.audioEngine.activePlayer = self.audioEngine.chorusPlayer!
//                }
//                .frame(width: 90, height: 30, alignment: .center)
//                .padding()
//                .background(Color.black)
//                .cornerRadius(5)
//            }
//            .font(.title)
//            .foregroundColor(Color.white)
                        
            //save title
            HStack {
                Spacer()
                TextField("type your title here", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.title)
                Spacer()
            }
            .padding()
            
            Button("save"){
                if let _ = self.audioEngine.recorder.audioFile?.duration {
                    
                    do {
                        //export .wav
                        let id = UUID()
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(id.uuidString + ".wav")
                        let format = AVAudioFormat(commonFormat: .pcmFormatFloat64, sampleRate: 44100, channels: 2, interleaved: true)!
                        let audioFile = try! AVAudioFile(forWriting: url, settings: format.settings, commonFormat: .pcmFormatFloat64, interleaved: true)
                        try AudioKit.renderToFile(audioFile, duration: self.audioEngine.activePlayer!.duration + 1, prerender: {
                            self.audioEngine.activePlayer!.load(audioFile: self.audioEngine.recorder.audioFile!)
                            self.audioEngine.activePlayer!.play()
                        })
                        print("duration: \(self.audioEngine.activePlayer!.duration)")
                        print("audio file rendered")
                        
                        //add data to recordedfiles array
                        self.audioEngine.recordedFileData = RecordedFileData(id: id, fileURL: audioFile.directoryPath.appendingPathComponent(id.uuidString + ".wav"), title: self.title)
                        self.audioEngine.recordedFiles.append(self.audioEngine.recordedFileData!)
                        print("audioFiles: \(self.audioEngine.recordedFiles)")
                        
                        //reset recorder, clear recorder audiofile
                        try self.audioEngine.recorder.reset()
                        
                        self.audioSaved = true
                        
                    } catch {
                        print("error rendering", error)
                    }
                }
            }
            .font(.title)
            .foregroundColor(Color.red)
            .frame(width: 90, height: 30, alignment: .center)
            .padding()
            .background(Color.black)
            .cornerRadius(5)
        }
    }
}