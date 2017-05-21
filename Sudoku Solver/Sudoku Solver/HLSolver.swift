//
//  HLSolver.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import UIKit


enum CMGCellStatus: Int
{
    case cmgUnSolvedStatus
    case cmgGivenStatus
    case cmgSolvedStatus
    case cmgChangedStatus
}


class HLSolver: NSObject {
    let kDataKey    = "Data"
    let kStatusKey  = "Status"
    let kNameKey    = "Name"
    
    let kRows = 9
    let kColumns = 9
    let kCellCount = 81
    
    var dataSet = Matrix(rows:9, columns:9)
    var previousDataSet = Matrix(rows:9, columns:9)
    var puzzleName = ""
    var workingArray: [Set<String>] = Array(repeating: Set<String>(), count: 8)
    
    let fullSet = Set<String>(["1", "2", "3", "4", "5", "6", "7", "8", "9"])
    let blockIndexSet = [
        [ 0,  1,  2,  9, 10, 11, 18, 19, 20],
        [ 3,  4,  5, 12, 13, 14, 21, 22, 23],
        [ 6,  7,  8, 15, 16, 17, 24, 25, 26],
        
        [27, 28, 29, 36, 37, 38, 45, 46, 47],
        [30, 31, 32, 39, 40, 41, 48, 49, 50],
        [33, 34, 35, 42, 43, 44, 51, 52, 53],
        
        [54, 55, 56, 63, 64, 65, 72, 73, 74],
        [57, 58, 59, 66, 67, 68, 75, 76, 77],
        [60, 61, 62, 69, 70, 71, 78, 79, 80]
    ]
    
    
/*    func fillRow()  {
        dataSet[0] = (Set(arrayLiteral: "1", "2", "3"), .CMGUnSolvedStatus)
        dataSet[1] = (Set(arrayLiteral: "1", "2", "3", "9"), .CMGUnSolvedStatus)
        dataSet[2] = (Set(arrayLiteral: "1", "2", "3"), .CMGUnSolvedStatus)
        dataSet[3] = (Set(arrayLiteral: "1", "2", "4", "3"), .CMGUnSolvedStatus)
        dataSet[4] = (Set(arrayLiteral: "1", "2"), .CMGUnSolvedStatus)
        dataSet[5] = (Set(arrayLiteral: "1", "2", "6", "5"), .CMGUnSolvedStatus)
        dataSet[6] = (Set(arrayLiteral: "1", "2", "7", "6"), .CMGUnSolvedStatus)
        dataSet[7] = (Set(arrayLiteral: "1", "2", "8", "7"), .CMGUnSolvedStatus)
        dataSet[8] = (Set(arrayLiteral: "1", "2", "9", "8"), .CMGUnSolvedStatus)
        
        for index in 0..<kColumns   {
            previousDataSet[index] = dataSet[index]
        }
    }   */
    
    
    func findMonoCells(rows: Bool, columns: Bool)   {
    
        func monoCellRows()                 {
        
            func monoCell(_ row: Int)         {
                var numArray = Array(repeating: 0, count: 10)
                for column in 0..<kColumns     {
                    let (data, _) = dataSet[row, column]
                    if data.count > 1                                              {
                        for item: String in data {  numArray[Int(item)!] += 1   }   }
                }
                
                for index in 1..<10 {
                    if numArray[index] == 1 {
                        for column in 0..<kColumns     {
                            let (data, _) = dataSet[row, column]
                            let solutionSet: Set<String> = Set(arrayLiteral: String(index))
                            let newSet = data.intersection(solutionSet)
                            if !newSet.isEmpty {
      //          print("row: \(row)   column: \(column)   newSet: \(newSet)")
                                dataSet[row, column] = (newSet, .cmgSolvedStatus)
                            }
                        }
                    }
                }
            }
            
            //  start of monoCellRows
       //     print("monoCellRows")
            for row in 0..<kRows    {   monoCell(row)   }
        
            prunePuzzle(rows: true, columns: true, blocks: true)
        }
    
        func monoCellColumns()      {
            convertColumnsToRows()
            monoCellRows()
            convertColumnsToRows()  }

        //  start of func findMonoSectors()
        print("findMonoSectors")
        if rows     {   monoCellRows()    }
        if columns  {   monoCellColumns() }
    }
    
    
    func findMonoSectors(rows: Bool, columns: Bool)  {

        func reduceMonoSectorsForRows()     {
            
            //  returns an array of found MonoSectors as a tuple (num, sector)
            func findMonoSectorForRow(_ row: Int) -> [(Int, Int)]    {
                print("monoSector")
                
                var foundMonoSectors: [(Int, Int)] = Array()
                let sectorNotFound = -1     //  anything but 0-2
                
                for num in 1...9    {
                    
                    var sector = sectorNotFound
                    for column in 0..<kColumns
                    {
                        let (data, _) = dataSet[row, column]
                        if data.count>1
                        {
                            if data.contains(String(num))   {
                            
                                if sector == sectorNotFound {
                                    sector = sectorForIndex(column)
                                }
                                else if sector != sectorForIndex(column)    {
                                    sector = sectorNotFound     //  no mono sector here
                                    break
                                }
                            }
                        }
                    }
                    
                    if sector != sectorNotFound     {
                        foundMonoSectors.append((num, sector))
                        print("foundMonoSectors: \(row)   foundMonoSectors: \(foundMonoSectors)")
                    }
                }
             
                return foundMonoSectors
            }
    
            func reduceBlockForRow(_ row: Int, sector: Int, reduceNumber: Int)    {
                
                func reduceRowForRow(_ row: Int, sector: Int, reduceNumber: Int)    {
                    var column = sector * 3
                    var (data, status) = dataSet[row, column]
                    data.remove(String(reduceNumber))
                    dataSet[row, column] = (data, status)

                    column += 1
                    (data, status) = dataSet[row, column]
                    data.remove(String(reduceNumber))
                    dataSet[row, column] = (data, status)

                    column += 1
                    (data, status) = dataSet[row, column]
                    data.remove(String(reduceNumber))
                    dataSet[row, column] = (data, status)
                }
                
                //  start of func reduceBlockForRow()
                var reduceRow = sectorForIndex(row) * 3
                if row != reduceRow                                                         {
                    reduceRowForRow(reduceRow, sector: sector, reduceNumber: reduceNumber)  }
                
                reduceRow += 1
                if row != reduceRow                                                         {
                    reduceRowForRow(reduceRow, sector: sector, reduceNumber: reduceNumber)  }
                
                reduceRow += 1
                if row != reduceRow                                                       {
                    reduceRowForRow(reduceRow, sector: sector, reduceNumber: reduceNumber)  }
            }

            for row in 0..<kRows    {
                
                let foundSet = findMonoSectorForRow(row)
             //   print("foundSet: \(foundSet)")
                
                for item in foundSet                                                {
               //     print("foundMonoSectors: \(row)   item: \(item)")
                    reduceBlockForRow(row, sector: item.1, reduceNumber: item.0)    }
            }
        }

        func reduceMonoSectorsForColumns()    {
            convertColumnsToRows()
            reduceMonoSectorsForRows()
            convertColumnsToRows()
        }
        
        //  start of func findMonoSectors()
        print("findMonoSectors")
        if rows     {   reduceMonoSectorsForRows()    }
        if columns  {   reduceMonoSectorsForColumns() }
    }
    
    
    func findPuzzleSets(rows: Bool, columns: Bool, blocks: Bool)  {

        func findSetsForRow(_ row: Int, sizeOfSet: Int)  {
            
      //      fillRow()
            var startingSets:   [Set<String>] = [Set<String>()]
            var setsToSearch:   [Set<String>] = [Set<String>()]
            
            for column in 0..<kColumns  {
                let (data, _) = dataSet[row, column]
                if data.count == sizeOfSet  {   setsToSearch.append(data)   }
                if data.count>1             {   startingSets.append(data)   }
            }
            
            if startingSets.count>1 && startingSets[0].isEmpty  {   startingSets.remove(at: 0)   }
            if setsToSearch.count>1 && setsToSearch[0].isEmpty  {   setsToSearch.remove(at: 0)   }
            
     //       print( "startingSets:")
     //       printArrayOfSets(startingSets)
            
    //        print( "setsToSearch:")
    //        printArrayOfSets(setsToSearch)
            
            for superSet in setsToSearch                                {
                
     //           print( "superSet: \(superSet):")
                let didFindSet = searchForSets(startingSets, superSet: superSet, count: sizeOfSet)
                if didFindSet { reduceRow(row, forSet: superSet)    }   }
        }
        
        func findSetsForBlocks()    {
            convertBlocksToRows()
            for setSize in 2..<4                                                        {
                for row in 0..<kRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
            convertBlocksToRows()   }
        
        
        func findSetsForColumns()   {
            convertColumnsToRows()
            for setSize in 2..<4                                                        {
                for row in 0..<kRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
            convertColumnsToRows()  }
        
        
        func findSetsForRows()    {
            for setSize in 2..<4                                                        {
                for row in 0..<kRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
        }
        
        //  start of func findPuzzleSets()
        print("findPuzzleSets")
        if rows     {   findSetsForRows()    }
        if columns  {   findSetsForColumns() }
        if blocks   {   findSetsForBlocks()  }

        prunePuzzle(rows:true, columns:true, blocks:true)
    }
    
    
    func prunePuzzle(rows: Bool, columns: Bool, blocks: Bool)  {

        func prunePuzzleRows()                          {

            func pruneRow(_ row: Int)         {
                let solvedSet = solvedSetForRow(row)
        //        println(solvedSet)

                for column in 0..<kColumns  {
                    let (data, status) = dataSet[row, column]
                    if data.count > 1   {   dataSet[row, column] = (data.subtracting(solvedSet), status) }
                }
            }
            
            //  start of func prunePuzzleRows()
            for row in 0..<kRows {  pruneRow(row)   }
        }
    
        func prunePuzzleColumns()   {
            convertColumnsToRows()
            prunePuzzleRows()
            convertColumnsToRows()  }
        
        func prunePuzzleBlocks()    {
            convertBlocksToRows()
            prunePuzzleRows()
            convertBlocksToRows()
        }

        //  start of func prunePuzzle(
        var currentNodeCount = unsolvedCount()
        var previousNodeCount = 0

        repeat  {
            previousNodeCount = currentNodeCount

            if rows     {   prunePuzzleRows()    }
            if columns  {   prunePuzzleColumns() }
            if blocks   {   prunePuzzleBlocks()  }

            currentNodeCount = unsolvedCount()
            assert( isValidPuzzle(), "Puzzle is not valid!" )
        }
        while previousNodeCount != currentNodeCount
    }
    
    
    func searchForSets(_ setsToSearch: [Set<String>], superSet: Set<String>, count: Int) -> Bool {
        
 //       print( "searchForSets: \(setsToSearch)   count: \(count)")

        var remainingSets = setsToSearch
        var item = remainingSets.removeLast()
        
        //  remove cells that are not subset
        while !item.isSubset(of: superSet) && !remainingSets.isEmpty  {
            item = remainingSets.removeLast()                       }
        
        if !item.isSubset(of: superSet)   {   return false    }
        
        if count>1 && !remainingSets.isEmpty                                        {
            return searchForSets(remainingSets, superSet: superSet, count: count-1)
        }
        
        else if count == 1      {   return true     }
        else                    {   return false    }
    }
    
    
    func reduceRow(_ row: Int, forSet reduceSet: Set<String>)    {
 //       print( "reduceRow: \(row)   reduceSet: \(reduceSet)")

        for column in 0..<kColumns  {
            let (data, status) = dataSet[row, column]
            if data.count>1                            {
                let prunedSet = data.subtracting(reduceSet)
                if !prunedSet.isEmpty  {   dataSet[row, column] = (prunedSet, status)  }   }
    }   }
    
    
    func updateChangedCells()   {
        for index in 0..<dataSet.kCellCount {
            var (data, status) = dataSet[index]
            let (data2, _) = previousDataSet[index]
            
            //  first lets convert Changed to Solved or Unsollved
            if status == .cmgChangedStatus {
                if data.count == 1  {   status = .cmgSolvedStatus   }
                else                {   status = .cmgUnSolvedStatus }
                dataSet[index] = (data, status)
            }
            
            //  then find the cells that changed
            if data.count != data2.count        {
                status = .cmgChangedStatus
                dataSet[index] = (data, status) }
        }
    }
    
    
    func arrayToSet(_ array: [String]) -> Set<String> {
        
        var aSet: Set<String> = Set()
  //      print( "array: \(array)" )
        
        for index in 0..<array.count {
        
            let s: String = array[index]
            aSet.insert(s)
        }
        
  //      print( "aSet: \(aSet)" )
        return aSet
    }
    
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        var dataArray: [Set<String>] = Array(repeating: Set<String>(arrayLiteral: "0"), count: kCellCount)
        var statusArray: [Int] = Array(repeating: 0, count: kCellCount)
        for index in 0..<kCellCount
        {
            let (data, status) = dataSet[index]
            dataArray[index] = data
            statusArray[index] = status.rawValue
        }
    
        aCoder.encode(puzzleName,  forKey:kNameKey)
        aCoder.encode(dataArray,   forKey:kDataKey)
        aCoder.encode(statusArray, forKey:kStatusKey)
    }
    
    
    override init() {}

    required init(coder aDecoder: NSCoder)
    {
//        var newDataSet = Matrix(rows:9, columns:9)
        let puzzleName  = aDecoder.decodeObject(forKey: kNameKey)
        let data        = aDecoder.decodeObject(forKey: kDataKey) as! Set<String>
        let status      = aDecoder.decodeInteger(forKey: kStatusKey)
        
        print("data: \(data)   status: \(status)   puzzleName: \(puzzleName)")
    }
    
    
    func testData81() {
    
        var newDataSet = Matrix(rows:9, columns:9)
        for index in 0..<81                                         {
            newDataSet[index] = (Set(arrayLiteral: String(index)), .cmgUnSolvedStatus)  }
        
        dataSet = newDataSet;
    }
    

    func unsolvedCount() -> Int         {
        return dataSet.nodeCount()  }
    
    
    func solvedSetForRow(_ row: Int) -> Set<String>       {
        var solvedSet = Set<String>()
        for column in 0..<kColumns                      {
            let (data, _) = dataSet[row, column]
            if data.count == 1  {    solvedSet = solvedSet.union(data)      }
        }
        return solvedSet                                }


    func convertColumnsToRows() {
        let dataSetCopy = dataSet.copy()
        
        for row in 0..<kRows                                                                {
            for column in 0..<kColumns {  dataSet[row, column] = dataSetCopy[column, row] } }
    }
    
    
    func convertBlocksToRows() {
        let dataSetCopy = dataSet.copy()
        for row in 0..<kRows                                                                    {
            let blockSet = blockIndexSet[row]
            for index2 in 0..<kRows {  dataSet[row, index2] = dataSetCopy[blockSet[index2]]   } }
    }


    func isValidPuzzle() -> Bool {
    
        func isValidPuzzleRow(_ row: Int) -> Bool {
            var returnValue = true
            var numArray = Array(repeating: 0, count: 10)
                
            for column in 0..<kColumns {
            
                let (data, _) = dataSet[row, column]
                let cell = Array(data)
                if cell.count == 1 {
                    let value = cell[0]
                    numArray[Int(value)!] += 1
                }
            }
            
            for i in 0..<numArray.count {
                if numArray[i] > 1 {
                    returnValue = false
                    break
                }
            }

            return returnValue
        }

        var returnValue = true
        for row in 0..<kRows {
            if !isValidPuzzleRow(row) {
                returnValue = false
                break
            }
        }
        
        return returnValue
    }


    func sectorForIndex(_ index: Int)->Int    {   return index/3  }
    
    
    func load(_ data: [String])
    {
        if data.count == kCellCount     {
            for i in 0 ..< kCellCount 
            {
                let cellValue = data[i]
                var newCell: (Set<String>, CMGCellStatus)
                
                if ( cellValue == "0" )     { newCell = (fullSet, .cmgUnSolvedStatus)       }
                else    {  newCell = (Set<String>(arrayLiteral: data[i]), .cmgGivenStatus)  }
                
                dataSet[i] = newCell
            }
            
            previousDataSet = dataSet
            
            printDataSet(dataSet)
     //       printDataSet2()
        }
    }
    
    
    func read() {
        print( "HLSolver-  read" )
        
        if let statusArray: [Int] = UserDefaults.standard.object(forKey: kStatusKey) as? [Int]    {

            puzzleName = (UserDefaults.standard.object(forKey: kNameKey) as! String)

            if let dataArray: [[String]] = UserDefaults.standard.object(forKey: kDataKey) as? [[String]]    {
                
                for index in 0..<kCellCount {
                    let x: [String] = dataArray[index]
                    dataSet[index] = (arrayToSet(x), CMGCellStatus(rawValue: statusArray[index])!)
                }
                
                previousDataSet = dataSet
        printDataSet(dataSet)
            }
        }
    }
    
    
    func save() {
        print( "HLSolver-  save" )
        var dataArray: [[String]] = Array(repeating: [""], count: kCellCount)
        var statusArray: [Int] = Array(repeating: 0, count: kCellCount)
        
        for index in 0..<kCellCount                             {
            let (data, status) = dataSet[index]
                dataArray[index] = Array(data)
                statusArray[index] = status.rawValue    }
        
            UserDefaults.standard.set(puzzleName, forKey: kNameKey)
            UserDefaults.standard.set(dataArray, forKey: kDataKey)
            UserDefaults.standard.set(statusArray, forKey: kStatusKey)
    }
    
    
    func printIndexDataSet(_ index:Int) {
        print("\(dataSet.description(index)) \t", terminator: "")
    }
    
    
    func printDataSet2()         {
        print("PrintDataSet2")
        for index in 0..<kCellCount    {  printIndexDataSet(index)    }
        print("")
    }
    
    
    func printArrayOfSets(_ data:[Set<String>])   {
        for index in 0..<data.count                                         {
            print("\(setToString(data[index])) \t", terminator: "")
        }
        print("")
    }


    func setToString(_ aSet: Set<String>)->String     {
        let list = Array(aSet.sorted(by: <))
        var returnString = ""
        for index in 0..<list.count     {   returnString += list[index]     }
        return returnString
    }
    
    
    func printDataSet(_ dataSet: Matrix) {
        
        func printRowDataSet(_ dataSet: Matrix, row:Int)   {
            for column in 0..<kColumns                                                          {
                print("\(dataSet.description(row: row, column: column)) \t", terminator: "")    }
            print("")                   }
    
        //  start of func printDataSet()
        print("PrintDataSet")
        for row in 0..<kRows    {  printRowDataSet(dataSet, row: row)    }
        print("\n")
    }
}
