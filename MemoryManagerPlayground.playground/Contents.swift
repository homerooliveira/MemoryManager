/*
 * Homero Oliveira
 * O programa a seguir lê um arquivo e processa as informações.
 * Ele simula o gerenciador de memória de um sistema operacional, usando o algoritmo First Fit.
 * Na pasta do projeto contém três arquivos para testar o gerenciador.
 *
 * 26/11/2018
 */

import Foundation

// Para mudar os arquivos de teste basta trocar o parametro "forResource"
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
