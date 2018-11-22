import Foundation

public func printAlloc(_ allocResult: AllocResult, size: Size,_ manager: MemoryManager) {
    switch allocResult {
    case .spaceAlloced(let idOfBlock, let size):
        print("Bloco criado id \(idOfBlock) com o tamanho \(size)")
    case .fragementation(let size):
        print()
        manager.printBlocks()
        print()
        let command = Command(operation: .alloc, value: size)
        manager.solicitations.append(command)
        manager.printFragmentation(size)
    case .noSpace:
        print()
        print("Não tem espaço para alocar mais um bloco")
        let command = Command(operation: .alloc, value: size)
        manager.solicitations.append(command)
        manager.printBlocks()
    }
}
