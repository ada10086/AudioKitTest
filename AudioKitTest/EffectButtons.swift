//
//  EffectButtons.swift
//  AudioKitTest
//
//  Created by Chuchu Jiang on 7/30/19.
//  Copyright © 2019 adajiang. All rights reserved.
//

import SwiftUI

struct EffectButtons: View {
    @ObjectBinding var audioEngine: AudioEngine
    
    var body: some View {
        VStack {
            Button("play"){
                self.audioEngine.normalPlayer!.play()
                self.audioEngine.activePlayer = self.audioEngine.normalPlayer!
            }
            Button("echo"){
                self.audioEngine.echoPlayer!.play()
                self.audioEngine.activePlayer = self.audioEngine.echoPlayer!
            }
            Button("fast"){
                self.audioEngine.fastPlayer!.play()
                self.audioEngine.activePlayer = self.audioEngine.fastPlayer!
            }
            Button("slow"){
                self.audioEngine.slowPlayer!.play()
                self.audioEngine.activePlayer = self.audioEngine.slowPlayer!
            }
            Button("robot"){
                self.audioEngine.robotPlayer!.play()
                self.audioEngine.activePlayer = self.audioEngine.robotPlayer!
            }
            Button("chorus"){
                self.audioEngine.chorusPlayer!.play()
                self.audioEngine.activePlayer = self.audioEngine.chorusPlayer!
            }
        }
        .font(.title)
    }
}

//#if DEBUG
//struct EffectButtons_Previews: PreviewProvider {
//    static var previews: some View {
//        EffectButtons()
//    }
//}
//#endif
