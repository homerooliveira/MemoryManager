import Foundation

guard let url = Bundle.main.url(forResource: "test", withExtension: "txt") else {
    fatalError("Url invalida")
}

let (range, commands) = readFile(from: url)

let manager = MemoryManager(range: range)

commands.forEach { (command) in
    switch command.operation {
    case .alloc:
        print(manager.alloc(size: command.value), manager)
    case .free:
        manager.free(id: command.value)
        print("Liberando bloco \(command.value)")
    }
}
