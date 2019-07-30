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
    @State var title: String = ""
    
    var body: some View {
        VStack {
            RecordButton(audioEngine: audioEngine)
            Button("record"){
                do {
                    try self.audioEngine.recorder.reset()
                    try self.audioEngine.recorder.record()
                } catch { AKLog("Errored recording.") }
            }
            .font(.title)
            
            Button("stop"){
                //self.audioEngine.recorderPlayer.stop()
                //micBooster.gain = 0
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
            .font(.title)
            .padding(.bottom, 50)
            
//            if self.audioEngine.recorder.audioFile != nil {
            
            EffectButtons(audioEngine: audioEngine)
            
            HStack {
                Spacer()
                TextField("type your title here", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.title)
//                    .padding(.leading, 130)
//                    .padding(.trailing, 130)
                Spacer()
            }
                
            Button("save"){
                if let _ = self.audioEngine.recorder.audioFile?.duration {
                    
                    do {
                        //export .wav
                        let id = UUID()
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(id.uuidString + ".wav") //cannot be m4a, not a codec
                        let format = AVAudioFormat(commonFormat: .pcmFormatFloat64, sampleRate: 44100, channels: 2, interleaved: true)!
                        let audioFile = try! AVAudioFile(forWriting: url, settings: format.settings, commonFormat: .pcmFormatFloat64, interleaved: true)
                        try AudioKit.renderToFile(audioFile, duration: self.audioEngine.activePlayer!.duration, prerender: {
                            self.audioEngine.activePlayer!.load(audioFile: self.audioEngine.recorder.audioFile!)
                            self.audioEngine.activePlayer!.play()
                        })
                        print("audio file rendered")
                        
                        //add data to recordedfiles array
                        self.audioEngine.recordedFileData = RecordedFileData(id: id, fileURL: audioFile.directoryPath.appendingPathComponent(id.uuidString + ".wav"), title: self.title)
                        self.audioEngine.recordedFiles.append(self.audioEngine.recordedFileData!)
                        print("audioFiles: \(self.audioEngine.recordedFiles)")
                        
                        //reset recorder, clear recorder audiofile
                        try self.audioEngine.recorder.reset()

                    } catch {
                        print("error rendering", error)
                    }

                }
            }
            .font(.title)

//            }
            VStack{
                ForEach(self.audioEngine.recordedFiles, id: \.self){ file in
                    Button(file.title){
                        print("url \(file.fileURL)")
                        try? self.audioEngine.effectPlayer!.load(url: file.fileURL)
                        self.audioEngine.effectPlayer!.play()
                    }
                }
            }

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
