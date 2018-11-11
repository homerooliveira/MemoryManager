import Foundation

let manager = MemoryManager(range: 100..<1250)

manager.alloc(size: 250)
manager.alloc(size: 100)
manager.alloc(size: 200)
//manager.free(id: 2)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.alloc(size: 150)
manager.printBlocks()
//manager.free(id: 5)
manager.alloc(size: 200)
