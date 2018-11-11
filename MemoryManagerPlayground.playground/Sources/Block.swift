import Foundation

public typealias Size = Int

public enum Block {
    case free(range: Range<Size>)
    case alloced(id: Int, range: Range<Size>)
}

extension Block {
    public var id: Int? {
        switch self {
        case .free:
            return nil
        case .alloced(let id, _):
            return id
        }
    }
    
    public var range: Range<Size> {
        switch self {
        case .free(let range):
            return range
        case .alloced(_, let range):
            return range
        }
    }
    
    public var size: Size {
        return range.count
    }
    
    public var isFree: Bool {
        switch self {
        case .free:
            return true
        case .alloced:
            return false
        }
    }
    
    public func hasSize(_ size: Size) -> Bool {
        return isFree && self.size >= size
    }
}

extension Block: CustomStringConvertible {
    public var description: String {
        let rangeDescription = "\(range.lowerBound)-\(range.upperBound)"
        let isFreeDescription: String
        switch self {
        case .alloced(let id, _):
             isFreeDescription = "bloco \(id)"
        case .free:
            isFreeDescription = "livre"
        }
        let sizeDescription = "tamanho \(size)"
        return "\(rangeDescription) \(isFreeDescription) (\(sizeDescription))"
    }
}
