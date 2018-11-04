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
        return "\(range) - isFree:\(isFree)"
    }
}

final class MemoryManager {
    var blocks = [Block(id: -1, range: 100..<1250, isFree: true)]
    
    func alloc(size: Int) {
        guard let index = blocks.firstIndex(where: { $0.hasSize(size) }) else {
            return
        }

        let blocksFromSize = blocks[index].make(from: size)
        blocks.remove(at: index)
        blocks.insert(contentsOf: blocksFromSize, at: index)
        
        printBlocks()
    }
    
    func free(id: Int) {
        guard let index = blocks.firstIndex(where: { $0.id == id && id != -1 }) else {
            return
        }
        blocks[index].id = -1
        blocks[index].isFree = true
        printBlocks()
    }
    
    private func printBlocks() {
        blocks.forEach { (block) in
            print(block)
        }
        print()
    }
}

let manager = MemoryManager()

manager.alloc(size: 250)
manager.alloc(size: 100)
manager.alloc(size: 200)
manager.free(id: 2)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.free(id: 3)

