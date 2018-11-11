//
//  FileReader.swift
//  ProcessSchedulerCore
//
//  Created by Homero Oliveira on 25/09/18.
//  Copyright © 2018 Homero Oliveira. All rights reserved.
//
import Foundation

/// Lê o arquivo e retorna um array contendo os dados.
public func readFile(from url: URL) -> (range: Range<Size>, commands: [Command]) {
    let text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    
    let contentsByLine = text.split(separator: "\n").dropFirst()
    guard let mi = contentsByLine.first.flatMap({ Int($0) }),
        let mf = contentsByLine.dropFirst().first.flatMap({ Int($0) }) else {
            fatalError("Fatou expor os valores minimos e maximo")
    }
    
    let commands: [Command] = contentsByLine.dropFirst(2)
        .compactMap { (line) in
            let values = line.split(separator: " ")
            guard let operation = Command.Operation(rawValue: values.first?.description ?? ""),
                let value = values.last.flatMap({ Int($0) }) else { return nil }
            return Command(operation: operation, value: value)
    }
    
    return (mi..<mf, commands)
}
