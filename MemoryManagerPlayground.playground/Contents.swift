import Foundation

guard let url = Bundle.main.url(forResource: "test3", withExtension: "txt") else {
    fatalError("Url invalida")
}

let (range, commands) = readFile(from: url)

let manager = MemoryManager(range: range)

commands.forEach { (command) in
    switch command.operation {
    case .alloc:
        printAlloc(manager.alloc(size: command.value), size: command.value, manager)
    case .free:
        manager.free(id: command.value)
        print("Liberando bloco \(command.value)")
    }
}
manager.printBlocks()
