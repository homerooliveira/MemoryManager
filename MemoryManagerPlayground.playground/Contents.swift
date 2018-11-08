import Foundation

struct Command {
    enum Operation: String {
        case alloc = "S"
        case free = "L"
    }
    let operation: Operation
    let value: Int
}

typealias Size = Int

var lastId = 1

struct Block {
    var id:Int
    let range: Range<Size>
    var isFree: Bool
    
    func hasSize(_ size: Size) -> Bool {
        return isFree && range.count >= size
    }
    
    func make(from size: Size) -> [Block] {
        let firstBlock = Block(id: lastId, range: range.lowerBound..<range.lowerBound + size, isFree: false)
        let secondBlock = Block(id: -1, range: (range.lowerBound + size)..<range.upperBound, isFree: true)
        var blocks = [firstBlock]
        if !secondBlock.range.isEmpty {
            blocks.append(secondBlock)
        }
        defer { lastId += 1 }
        return blocks
    }
}

extension Block: CustomStringConvertible {
    var description: String {
        let rangeDescription = "\(range.lowerBound)-\(range.upperBound)"
        let isFreeDescription = isFree ? "livre" : "bloco \(id)"
        let sizeDescription = "tamanho \(range.count)"
        return "\(rangeDescription) \(isFreeDescription) (\(sizeDescription))"
    }
}

enum AllocResult {
    case spaceAlloced(idOfBlock: Int)
    case fragementation
    case noSpace
}

final class MemoryManager {
    var blocks: [Block] = []
    
    init(range: Range<Size>) {
        let block = Block(id: -1, range: range, isFree: true)
        blocks.append(block)
    }
    
    func hasSpace(_ size: Size) -> Bool {
        return blocks.firstIndex(where: { $0.hasSize(size) }) != nil
    }
    
    func alloc(size: Int) -> AllocResult {
        guard blocks.contains(where: { $0.isFree }) else { return .noSpace }
        
        guard let index = blocks.firstIndex(where: { $0.hasSize(size) }) else {
            return .fragementation
        }

        let blocksFromSize = blocks[index].make(from: size)
        blocks.remove(at: index)
        blocks.insert(contentsOf: blocksFromSize, at: index)
        return .spaceAlloced(idOfBlock: index)
    }
    
    private func printFragmentation(_ size: Size) {
        let freeSize = blocks.lazy
            .filter { $0.isFree }
            .map { $0.range.count }
            .reduce(0, +)
        
        print("\(freeSize) livres, \(size) solicitados - fragmentação externa.")
    }
    
    func free(id: Int) {
        guard let index = blocks.firstIndex(where: { $0.id == id && id != -1 }) else {
            return
        }
        blocks[index].id = -1
        blocks[index].isFree = true
        defragmentBlocks(index: index)
    }
    
    func printBlocks() {
        blocks.forEach { (block) in
            print(block)
        }
    }
    
    private func defragmentBlocks(index: Int) {
        var minIndex = index
        var maxIndex = index
        
        if blocks.startIndex == index {
            if let minIndex2 = blocks.index(index, offsetBy: -1, limitedBy: blocks.count), blocks[minIndex2].isFree {
                minIndex = minIndex2
            }
        } else if blocks.endIndex - 1 == index {
            if let maxIndex2 = blocks.index(index, offsetBy: 1, limitedBy: blocks.count), blocks[maxIndex2].isFree {
                maxIndex = maxIndex2
            }
        } else {
            if let minIndex2 = blocks.index(index, offsetBy: -1, limitedBy: blocks.count), blocks[minIndex2].isFree {
                minIndex = minIndex2
            }
            
            if let maxIndex2 = blocks.index(index, offsetBy: 1, limitedBy: blocks.count), blocks[maxIndex2].isFree {
                maxIndex = maxIndex2
            }
        }
        
        let minBlock = blocks[minIndex]
        let maxBlock = blocks[maxIndex]
        
        blocks.removeSubrange(minIndex...maxIndex)
        let newBlock = Block(id: -1, range: minBlock.range.lowerBound..<maxBlock.range.upperBound, isFree: true)
        blocks.insert(newBlock, at: minIndex)
    }
}

let manager = MemoryManager(range: 100..<1250)

manager.alloc(size: 250)
manager.alloc(size: 100)
manager.alloc(size: 200)
//manager.free(id: 2)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.printBlocks()
//manager.free(id: 5)
manager.alloc(size: 200)
