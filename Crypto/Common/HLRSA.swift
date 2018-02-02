//
//  HLRSA.swift
//  RSATool
//
//  Created by Matthew Homer on 10/30/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

//************************************************************************
//        Z(N) = { 1, 2, ... N-1 } but I don't use '1' so it is really
//        Z(N) = { 2, 3, ... N-1 }
//        N = RSA_P * RSA_Q
//        Gamma = lcm( RSA_P-1, RSA_Q-1 )
//        RSA_KeyPublic * RSA_KeyPrivate is congruant to 1 mod( Gamma )
//        C = M**RSA_KeyPublic  % N
//        M = C**RSA_KeyPrivate % N
//************************************************************************
import Cocoa

typealias HLPrimeType = Int64

class HLRSA: NSObject {

    let N: HLPrimeType
    let Gamma: HLPrimeType
    var keyPrivate: HLPrimeType = 0
    var keyPublic: HLPrimeType = 0
    let chuckSize: Int
    
    var charSetSize: HLPrimeType    //  use HLPrimeType instead of int to avoid typecasting
    var charSet: [Character]
    
    
/*    func setCharacterSetWith(set: String)   {
        charSet = Array(set)
        charSetSize = Int64(charSet.count)
    }   */
    
    func chunker(workingString: inout String) -> String   {
        var chunk = ""
//        print( "chunker-  workingString: \(workingString)" )
        
        if workingString.count > chuckSize  {
            chunk = String( workingString.prefix(chuckSize+1) )
            let chunkInt = stringToInt(text: chunk)
            if chunkInt < N     {
                //  done
   //             print( "chunker-  chunkPlusOne: \(chunk)    chunkInt: \(chunkInt)" )
                workingString.removeFirst(chunk.count)
            }
            
            else    {
                chunk = String( workingString.prefix(chuckSize) )
  //              print( "chunker-  chunk: \(chunk)    chunkInt: \(stringToInt(text: chunk))" )
                workingString.removeFirst(chunk.count)
            }
        }
        else    {
            chunk = String( workingString.prefix(chuckSize) )
   //         print( "chunker-  chunk: \(chunk)    chunkInt: \(stringToInt(text: chunk))" )
            workingString.removeFirst(chunk.count)
        }
        
        return chunk
    }

    func fastExp2Of(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        let arraySize = 100
        var value: [Float80] = Array(repeatElement(0, count: arraySize))
        var weight: [HLPrimeType] = Array(repeatElement(0, count: arraySize))
        var i = 0
        var partialResult = Float80(a)
        value[0] = Float80(a)
        weight[0] = 1
        let bigMod = Float80(mod)
        
        while weight[i] < exp   {
            i += 1
            let temp = partialResult * partialResult
            partialResult = temp.truncatingRemainder(dividingBy: bigMod)
            value[i] = partialResult
            weight[i] = weight[i-1] * 2
  //      print( "i: \(i)   weight[i]: \(weight[i])   partialResult: \(partialResult)" )
       }
       
 //       print( "fastExp2Of: \(a)   exp: \(exp)   mod: \(mod)   i: \(i)" )
       partialResult = 1
       var count = exp
       
        while count > 0  {
            var j = 0
            while weight[j+1] < count   {
                j += 1
            }
            
            let temp = partialResult * value[j]
            partialResult = temp.truncatingRemainder(dividingBy: bigMod)
   //         print( "count: \(count)   j: \(j)" )
            count -= weight[j]
        }

        return Int64(partialResult)
    }
    
    
    func fastExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {

        var weight: HLPrimeType = 0
        var d: Float80 = 1
        var i: Int = 60
        var bitIndex = Int64(pow(2.0, Double(i)))
        let bigMod = Float80(mod)
        let bigA = Float80(a)

//        print( "fastExpOf: \(a)   exp: \(exp)   mod: \(mod)" )

        while i >= 0 {
        
            weight = weight << 1
            var bigD = d
            bigD *= bigD
            d = bigD.truncatingRemainder(dividingBy: bigMod)
            d = Float80(Int64(d))

            let testB = exp & bitIndex > 0
 //           print( "i: \(i)   bitIndex: \(bitIndex)    weight: \(weight)    testB: \(testB)   d: \(d)   temp: \(temp.debugDescription)" )

           if testB   {
                weight += 1
                let temp = d * bigA
                d = temp.truncatingRemainder(dividingBy: bigMod)
       //         d = Int64(temp2)
       //      print( "i: \(i)   bitIndex: \(bitIndex)    weight: \(weight)   d: \(d)   temp: \(temp.debugDescription)" )
           }
            
 //          print( "i: \(i)   testB: \(testB)    weight: \(weight)   d: \(d)   " )
            bitIndex = bitIndex >> 1
            i -= 1
        }
        
        return Int64(d)
    }

    func slowExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        
        let bigMod = Float80(mod)
        let bigA = Float80(a)
        var bigC = bigA

        for _ in 2...exp    {
            bigC *= bigA
            bigC = bigC.truncatingRemainder(dividingBy: bigMod)
        }

       return Int64(bigC)
    }

    func encode( m: HLPrimeType, key: HLPrimeType) -> HLPrimeType {
        let result = fastExpOf(a: m, exp: key, mod: N)
//        let result2 = fastExp2Of(a: m, exp: key, mod: N)
//        let result3 = slowExpOf(a: m, exp: key, mod: N)
  //      assert(result == result2 )
//        print( "encode-  result: \(result)  result2: \(result2)  result3: \(result3)" )
        return result
    }
    
    
    func stringToInt(text: String) -> HLPrimeType {
        var result: HLPrimeType = 0
        
        for char in text    {
            result *= charSetSize
            let n = Int64(indexForChar(c: char))
     //       print( "stringToInt-  char: \(char)  result: \(result)    n: \(n)" )
            result += n
       }
        
        return result
    }
    
    func intToString( n: HLPrimeType) -> String {
        var result = ""
        var workingN = n
        var power = charSetSize
        while power < n {   power *= charSetSize}
        
        while power > 1 {
            power /= charSetSize
            if workingN >= power {
                let index = Int(workingN / power)
                
     //           print( "intToString-  workingN: \(workingN)  power: \(power)" )
                result.append(charSet[index])
           }
            workingN %= power
  //          print( "intToString-  result: \(result)" )
        }
        
        return result
    }
    
    
    func decodeFile(inputFilepath: String, outputFilepath: String)  {
//        print( "HLRSA-  decode: \(path)" )
        do {
            let dataIn = try String(contentsOfFile: inputFilepath, encoding: .utf8)
            var workingString = dataIn
            var dataOut = ""
//            print( "HLRSA-  decodeFile-  text: \(dataIn)" )
            
            var chunk = chunker(workingString: &workingString)
 //           print( "HLRSA1-  decodeFile-  chunk: \(chunk)  workingString: \(workingString)" )

            while chunk.count > 0 {

                let ciphertextInt = stringToInt(text: chunk)
     //           let decoded = encode(m: ciphertextInt, key: keyPublic)
                let decoded = encode(m: ciphertextInt, key: keyPrivate)
                let decodedChuck = intToString(n: decoded)
                
                dataOut.append(decodedChuck)
                
    //            let reCypherInt = encode(m: cypher, key: keyPrivate)
                let reCypherInt = encode(m: decoded, key: keyPublic)
                let reCypherString = intToString(n: reCypherInt)
print( "chunk: \(chunk)    cypherInt: \(ciphertextInt)    reCypherInt: \(reCypherInt)    cypherString: \(decodedChuck)    reCypher: \(reCypherString)" )

                chunk = chunker(workingString: &workingString)
            }
            
            try dataOut.write(toFile: outputFilepath, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func encodeFile(inputFilepath: String, outputFilepath: String)  {
//        print( "HLRSA-  encode: \(path)" )
        do {
            let dataIn = try String(contentsOfFile: inputFilepath, encoding: .utf8)
            var workingString = dataIn
            var dataOut = ""
//            print( "HLRSA-  encodeFile-  text: \(dataIn)" )
            
            var chunk = chunker(workingString: &workingString)
 //           print( "HLRSA1-  encodeFile-  chunk: \(chunk)  workingString: \(workingString)" )

            while chunk.count > 0 {
                let plaintextInt = stringToInt(text: chunk)
                let cypher = encode(m: plaintextInt, key: keyPublic)
      //           let cypher = encode(m: plaintextInt, key: keyPrivate)
               let cypherChunk = intToString(n: cypher)

                dataOut.append(cypherChunk)
                
                let deCypherInt = encode(m: cypher, key: keyPrivate)
    //            let deCypherInt = encode(m: cypher, key: keyPublic)
                let deCypherString = intToString(n: deCypherInt)
print( "chunk: \(chunk)    plaintextInt: \(plaintextInt)    cypherInt: \(cypher)    cypherString: \(cypherChunk)    deCypher: \(deCypherString)" )
                
                chunk = chunker(workingString: &workingString)
            }
            
            try dataOut.write(toFile: outputFilepath, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func indexForChar( c: Character) -> Int {
        var index = Int(charSetSize - 1)
        while index >= 0  {
            let d = charSet[index]
            if c == d   {
                break
            }
            
            index -= 1
        }
        
        return index
    }
    
    
    func calculateKey(publicKey: HLPrimeType) -> HLPrimeType  {
        let arraySize = 50
        let bigGamma = Float80(exactly: Gamma)!
        var s: [Float80] = Array(repeating: 0, count: arraySize)
        var t: [Float80] = Array(repeating: 0, count: arraySize)
        var r: [Float80] = Array(repeating: 0, count: arraySize)
        s[0] = 1
        s[1] = 0
        t[0] = 0
        t[1] = 1
        r[0] = bigGamma
        r[1] = Float80(exactly: publicKey)!
        var i = 1
        
        while r[i].rounded() != 1 && r[i].rounded() != 0    {
            i += 1
            let bigQ = r[i-2] / r[i-1]
            let bigInt = Int64(bigQ)
            let q = Float80(exactly: bigInt)!
            s[i] = s[i-2] - q * s[i-1]
            t[i] = t[i-2] - q * t[i-1]
            r[i] = r[i-2] - q * r[i-1]
  //          print( "i: \(i)    r[i]: \(r[i])" )
        }

        if r[i].rounded() == 1        {
            var privateKey = t[i]
            if privateKey <= 0     {   privateKey += bigGamma       }
            
            let product = Float80(exactly: publicKey)! * Float80(exactly: privateKey)!
            let keyVerify = product.truncatingRemainder(dividingBy: bigGamma)
            assert( keyVerify.rounded() == 1 )
            return Int64(exactly: privateKey)!
        }
        
        else                {   return -1            }
    }

    func calculateKey2(publicKey: HLPrimeType) -> HLPrimeType  {
        let arraySize = 50
        var s: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        var t: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        var r: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        s[0] = 1
        s[1] = 0
        t[0] = 0
        t[1] = 1
        r[0] = Gamma
        r[1] = publicKey
        var i = 1
        
        while r[i] != 1 && r[i] != 0    {
            i += 1
            let q = r[i-2] / r[i-1]
            s[i] = s[i-2] - q * s[i-1]
            t[i] = t[i-2] - q * t[i-1]
            r[i] = r[i-2] - q * r[i-1]
  //          print( "i: \(i)    r[i]: \(r[i])" )
        }

        if r[i] == 1        {
            var privateKey = t[i]
            if privateKey <= 0     {   privateKey += Gamma       }
            
            let product = Float80(exactly: publicKey)! * Float80(exactly: privateKey)!
            let keyVerify = product.truncatingRemainder(dividingBy: Float80(exactly: Gamma)!)
            assert( keyVerify == 1 )
            return privateKey
        }
        
        else                {   return -1            }
    }
    
    init(p: Int64, q: Int64, characterSet: String) {
    var TODOneedToValidateAllCharsInCharacterSet = 0
        charSet = Array(characterSet)
        charSetSize = Int64(charSet.count)

        N = p * q
        Gamma = (p-1) * (q-1)
        charSetSize = Int64(charSet.count)
        let x = log(Double(N)) / log(Double(charSetSize)) + 0.000001    //  fudge factor due to Int() call below
    //    print( "HLRSA-  init-  x: \(x)" )
        chuckSize = Int(x)
        
        print( "HLRSA-  init-  p: \(p)    q: \(q)    N: \(N)    Gamma: \(Gamma)    charSetSize: \(charSetSize)    chuckSize: \(chuckSize)" )
        super.init()
    }
}
