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
            
            //preview buttons
            ForEach(self.audioEngine.effectPlayers, id: \.self){ playerData in
                Button(playerData.effect){
                    playerData.player.play()
                    self.audioEngine.activePlayerData = playerData
                }
                .frame(width: 90, height: 30, alignment: .center)
                .padding()
                .background(Color.black)
                .cornerRadius(5)
                .font(.title)
                .foregroundColor(Color.white)
            }

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
                        try AudioKit.renderToFile(audioFile, duration:
                            //fix duration!!
                            self.audioEngine.activePlayerData.player.duration + 1, prerender: {
                            self.audioEngine.activePlayerData.player.load(audioFile: self.audioEngine.recorder.audioFile!)
                            self.audioEngine.activePlayerData.player.play()
                        })
                        print("audio file rendered")
                        
                        //add data to recordedfiles array
                        self.audioEngine.recordedFileData = RecordedFileData(id: id, fileURL: audioFile.directoryPath.appendingPathComponent(id.uuidString + ".wav"), title: self.title, effect: self.audioEngine.activePlayerData.effect)
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
