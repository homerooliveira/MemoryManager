import Foundation

public func print(_ allocResult: AllocResult, _ manager: MemoryManager) {
    switch allocResult {
    case .spaceAlloced(let idOfBlock, let size):
        print("Bloco criado id \(idOfBlock) com o tamanho \(size)")
    case .fragementation(let size):
        print()
        manager.printBlocks()
        print()
        manager.printFragmentation(size)
    case .noSpace:
        print()
        print("Não tem espaço para alocar mais um bloco")
        manager.printBlocks()
    }
}
