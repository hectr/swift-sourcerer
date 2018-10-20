import Foundation

public struct CreateTemporaryDirectory
{
    public typealias Func = () throws -> String

    public init() {}

    // MARK: -

    public func execute() throws -> String
    {
        let uuid = UUID().uuidString
        let path = "/tmp/sourcerer-" + uuid + "/"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        return path
    }
}
