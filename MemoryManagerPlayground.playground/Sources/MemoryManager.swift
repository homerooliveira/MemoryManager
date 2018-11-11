import Foundation

public enum AllocResult {
    case spaceAlloced(idOfBlock: Int)
    case fragementation
    case noSpace
}

public final class MemoryManager {
    var blocks: [Block] = []
    public var lastId = 1
    
    public init(range: Range<Size>) {
        let block = Block.free(range: range)
        blocks.append(block)
    }
    
    public func alloc(size: Int) -> AllocResult {
        guard blocks.contains(where: { $0.isFree }) else { return .noSpace }
        
        guard let index = blocks.firstIndex(where: { $0.hasSize(size) }) else {
            return .fragementation
        }
        
        let blocksFromSize = make(block: blocks[index], from: size)
        blocks.remove(at: index)
        blocks.insert(contentsOf: blocksFromSize, at: index)
        return .spaceAlloced(idOfBlock: lastId - 1)
    }
    
    private func make(block: Block, from size: Size) -> [Block] {
        let firstBlock = Block.alloced(id: lastId, range: block.range.lowerBound..<block.range.lowerBound + size)
        let secondBlock = Block.free(range: (block.range.lowerBound + size)..<block.range.upperBound)
        var blocks = [firstBlock]
        if secondBlock.size > 0 {
            blocks.append(secondBlock)
        }
        lastId += 1
        return blocks
    }
    
    public func printFragmentation(_ size: Size) {
        let freeSize = blocks.lazy
            .filter { $0.isFree }
            .map { $0.size }
            .reduce(0, +)
        
        print("\(freeSize) livres, \(size) solicitados - fragmentação externa.")
    }
    
    public func free(id: Int) {
        guard id > 0 else { return }
        guard let index = blocks.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let rangeOfBlock = blocks[index].range
        blocks[index] = .free(range: rangeOfBlock)
        
        defragmentBlocks(index: index)
    }
    
    public func printBlocks() {
        blocks.forEach { (block) in
            print(block)
        }
    }
    
    private func defragmentBlocks(index: Int) {
        var minIndex = index
        var maxIndex = index
        
        if blocks.startIndex == index { // Verifica se o bloco que está sendo liberado é primeiro indice do array
            if let minIndex2 = blocks.index(index, offsetBy: -1, limitedBy: blocks.count), blocks[minIndex2].isFree {
                minIndex = minIndex2
            }
        } else if blocks.endIndex - 1 == index { // Verifica se o bloco que está sendo liberado é último indice do array
            if let maxIndex2 = blocks.index(index, offsetBy: 1, limitedBy: blocks.count), blocks[maxIndex2].isFree {
                maxIndex = maxIndex2
            }
        } else { // Caso o indice esteja no meio do array
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
        let newBlock = Block.free(range: minBlock.range.lowerBound..<maxBlock.range.upperBound)
        blocks.insert(newBlock, at: minIndex)
    }
}
