import Foundation

/// Representa o resultado da aloção
public enum AllocResult {
    case spaceAlloced(idOfBlock: Int, size: Size)
    case fragementation(Size)
    case noSpace
}

/// Representa a classe que gerencia os blocos, faz a aloção e libera blocos.
public final class MemoryManager {
    /// Representa os blocos da memoria
    var blocks: [Block] = []
    /// Representa as solitações que ficaram para ser aplicadas.
    public var solicitations: [Command] = []
    // Representa o ultimo identificador
    var lastId = 1
    /// Representa o espaço vazio da memoria
    var freeSize: Int {
        return blocks.lazy
            .filter { $0.isFree }
            .map { $0.size }
            .reduce(0, +)
    }
    
    /// Construtor da classe
    public init(range: Range<Size>) {
        let block = Block.free(range: range)
        blocks.append(block)
    }
    
    /// Faz a aloção a partir de um tamanho
    public func alloc(size: Int) -> AllocResult {
        guard size < freeSize else { return .noSpace }
        
        guard let index = blocks.firstIndex(where: { $0.hasSize(size) }) else {
            return .fragementation(size)
        }
        
        let blocksFromSize = make(block: blocks[index], from: size)
        blocks.remove(at: index)
        blocks.insert(contentsOf: blocksFromSize, at: index)
        return .spaceAlloced(idOfBlock: lastId - 1, size: size)
    }
    
    /// Divide um bloco vazio em um bloco ocupado e um vazio.
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
    
    /// Imprimi resultado da fragmentação
    public func printFragmentation(_ size: Size) {
        print("\(freeSize) livres, \(size) solicitados - fragmentação externa.")
    }
    
    /// Libera um bloco a partir de um id
    public func free(id: Int) {
        guard id > 0 else { return }
        guard let index = blocks.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let rangeOfBlock = blocks[index].range
        blocks[index] = .free(range: rangeOfBlock)
        
        defragmentBlocks(index: index)
        attempToAlloc()
    }
    
    /// Imprimi os blocos do array
    public func printBlocks() {
        blocks.forEach { (block) in
            print(block)
        }
    }
    
    /// Tenta fazer uma alocação a partir de uma solicitação feita anteriomente que teve fragmentação ou falta de espaço
    private func attempToAlloc() {
        for (index, command) in solicitations.enumerated() {
            let result = alloc(size: command.value)
            switch result {
            case let .spaceAlloced(idOfBlock, size):
                print("Consegui criar o bloco \(idOfBlock) com o tamanho \(size)")
                solicitations[index].isApplyed = true
            default:
                print("Não conseguiu allocar o bloco com tamanho \(command.value)")
            }
        }
        solicitations.removeAll { $0.isApplyed }
    }
    
    /// "Junta" os blocos que estão livres.
    private func defragmentBlocks(index: Int) {
        var minIndex = index
        var maxIndex = index
        
        if blocks.startIndex == index { // Verifica se o bloco que está sendo liberado é primeiro indice do array
            if let maxIndex2 = blocks.index(index, offsetBy: 1, limitedBy: blocks.count), blocks[maxIndex2].isFree {
                maxIndex = maxIndex2
            }
        } else if blocks.endIndex - 1 == index { // Verifica se o bloco que está sendo liberado é último indice do array
            if let minIndex2 = blocks.index(index, offsetBy: -1, limitedBy: blocks.count), blocks[minIndex2].isFree {
                minIndex = minIndex2
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
