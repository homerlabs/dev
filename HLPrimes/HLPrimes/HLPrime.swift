//
//  HLPrime.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Foundation


class HLPrime: NSObject {

    let fileManager = HLFileManager(path: "/Users/mhomer/Desktop/Primes.txt")!
    
    func makePrimes(numberOfPrimes: Int)  {
        print( "HLPrime-  makePrimes-  numberOfPrimes: \(numberOfPrimes)" )
        
        let lastLine = fileManager.getLastLine()!
        let delimiter = lastLine.index(of: "\t")!
        let lastN = lastLine.prefix(upTo: delimiter)
        let lastP = lastLine.suffix(from: delimiter)
        print( "lastN: \(lastN)    lastP: \(lastP)" )

        var n = Int(lastN)!
        while( numberOfPrimes > n ) {
            n += 1
        }
    }
}
