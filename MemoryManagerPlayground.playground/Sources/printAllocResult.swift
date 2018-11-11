import Foundation

public func print(_ allocResult: AllocResult, _ size: Size, _ manager: MemoryManager) {
    switch allocResult {
    case .spaceAlloced(let idOfBlock):
        print("Bloco criado id \(idOfBlock) com o tamanho \(size)")
    case .fragementation:
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
