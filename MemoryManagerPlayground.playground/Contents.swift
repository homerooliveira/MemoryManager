import Foundation

struct Command {
    enum Key: String {
        case alloc = "S"
        case free = "L"
    }
    let key: Key
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
        defer { lastId += 1 }
        return [firstBlock, secondBlock]
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

final class MemoryManager {
    var blocks: [Block] = []
    
    init(range: Range<Size>) {
        let block = Block(id: -1, range: range, isFree: true)
        blocks.append(block)
    }
    
    func hasSpace(_ size: Size) -> Bool {
        return blocks.firstIndex(where: { $0.hasSize(size) }) != nil
    }
    
    func alloc(size: Int) {
        guard let index = blocks.firstIndex(where: { $0.hasSize(size) }) else {
            printBlocks()
            printFragmentation(size)
            return
        }

        let blocksFromSize = blocks[index].make(from: size)
        blocks.remove(at: index)
        blocks.insert(contentsOf: blocksFromSize, at: index)
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
    
    private func printBlocks() {
        blocks.forEach { (block) in
            print(block)
        }
    }
    
    private func defragmentBlocks(index: Int) {
        var minIndex = index
        var maxIndex = index
        
        if let minIndex2 = blocks.index(index, offsetBy: -1, limitedBy: blocks.count), blocks[minIndex2].isFree {
            minIndex = minIndex2
        }
        
        if let maxIndex2 = blocks.index(index, offsetBy: 1, limitedBy: blocks.count), blocks[maxIndex2].isFree {
            maxIndex = maxIndex2
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
manager.free(id: 2)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.free(id: 5)
manager.alloc(size: 200)
