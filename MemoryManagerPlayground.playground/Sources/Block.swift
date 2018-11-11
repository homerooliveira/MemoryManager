import Foundation

public typealias Size = Int

public struct Block {
    public var id:Int
    public let range: Range<Size>
    public var isFree: Bool
    public var size: Int {
        return range.count
    }
    
    public init(id: Int, range: Range<Size>, isFree: Bool) {
        self.id = id
        self.range = range
        self.isFree = isFree
        
    }
    
    public func hasSize(_ size: Size) -> Bool {
        return isFree && range.count >= size
    }
}

extension Block: CustomStringConvertible {
    public var description: String {
        let rangeDescription = "\(range.lowerBound)-\(range.upperBound)"
        let isFreeDescription = isFree ? "livre" : "bloco \(id)"
        let sizeDescription = "tamanho \(size)"
        return "\(rangeDescription) \(isFreeDescription) (\(sizeDescription))"
    }
}
