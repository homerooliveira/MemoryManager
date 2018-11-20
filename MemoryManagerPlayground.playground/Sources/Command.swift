import Foundation

public struct Command {
    public enum Operation: String {
        case alloc = "S"
        case free = "L"
    }
    public let operation: Operation
    public let value: Int
    public var isApplyed: Bool = false
    
    public init(operation: Operation, value: Int) {
        self.operation = operation
        self.value = value
        self.isApplyed = false
    }
}
