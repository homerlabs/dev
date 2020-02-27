//
//  ContentView.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct CryptoView: View {

    @ObservedObject var cryptoViewModel = HLCryptoViewModel()
    let HLSavePanelTitle = "HLCrypto Save Panel"
    let HLOpenPanelTitle = "HLCrypto Open Panel"

    var body: some View {
        VStack {
        
            //  set Plaintext path
            HStack {
                Button(action: {
                    print("PlainTextPath")
                    let path = "PlainText.txt"
                    self.cryptoViewModel.plainTextURL = path.getOpenFilePath(title: self.HLOpenPanelTitle)
                }) {
                    Text("PlainText")
                }
                
                if cryptoViewModel.plainTextURL != nil {
                    Text(cryptoViewModel.plainTextURL!.path)
                } else {
                    Text("Plaintext Path not set")
                }
                Spacer()
            }
            
            //  set Ciphertext path
            HStack {
                Button(action: {
                    print("CipherTextPath")
                    let path = "CipherText.txt"
                    self.cryptoViewModel.cipherTextURL = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set CipherText File Path")
                }) {
                    Text("CipherText")
                }
                
                if cryptoViewModel.cipherTextURL != nil {
                    Text(cryptoViewModel.cipherTextURL!.path)
                } else {
                    Text("Ciphertext Path not set")
                }
                Spacer()
            }
            
            //  set DeCiphertext path
            HStack {
                Button(action: {
                    print("DeCipherTextPath")
                    let path = "DeCipherText.txt"
                    self.cryptoViewModel.decipherTextURL = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set DeCipherText File Path")
                }) {
                    Text("DeCipherText")
                }
                
                if cryptoViewModel.decipherTextURL != nil {
                    Text(cryptoViewModel.decipherTextURL!.path)
                } else {
                    Text("DeCiphertext Path not set")
                }
                Spacer()
            }
            
            Form {
                HStack {
                    Text("Character Set:")
                    Spacer()
                    Text("Chunk Size:")
                    Text(cryptoViewModel.chunkSize)
                    Spacer()
                    Text("Character Set Size:")
                    Text(cryptoViewModel.characterSetCountString)
                }
                
                TextField(cryptoViewModel.characterSet, text: $cryptoViewModel.characterSet)
                Spacer()
            }
                
            Form {
              //  set P, Q
              HStack {
                  Text("P:")
                  TextField(cryptoViewModel.pString, text: $cryptoViewModel.pString)
                  Spacer()
                  Text("Q:")
                  TextField(cryptoViewModel.qString, text: $cryptoViewModel.qString)
                  Spacer()
                  Text("P*Q: \(cryptoViewModel.pqString)")
                  Spacer()
                  Text("(P-1)(Q-1): \(cryptoViewModel.gammaString)")
              }

              //  set chosenKey
              HStack {
                  Text("Chosen Key:")
                  TextField(cryptoViewModel.chosenKeyString, text: $cryptoViewModel.chosenKeyString)
                  Spacer()
                  Text("Calculated Key:"+cryptoViewModel.calculatedKeyString)
              }

              //  Encode and Decode Buttons
              HStack {
                  Spacer()
                  Button(action: {
                      print("Encode")
                  }) {
                      Text("Encode")
                  }
                  .disabled(cryptoViewModel.plainTextURL == nil || cryptoViewModel.cipherTextURL == nil)
                  Spacer()
                  
                  Button(action: {
                      print("Decode")
                  }) {
                      Text("Decode")
                  }
                  .disabled(cryptoViewModel.cipherTextURL == nil || cryptoViewModel.decipherTextURL == nil)
                  Spacer()
              }
            }

            Spacer()
        }
        .onAppear() {
            self.cryptoViewModel.setupRSA()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoView()
    }
}
