import Foundation

struct Command {
    enum Key: String {
        case alloc = "S"
        case free = "L"
    }
    let key: Key
    let value: Int
}

struct Memory {
    
}

final class MemoryManager {
    
}
