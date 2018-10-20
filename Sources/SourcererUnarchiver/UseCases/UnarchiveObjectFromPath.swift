import Foundation

public struct UnarchiveObjectFromPath
{
    public typealias Func = (_ path: String) throws -> Any?

    public init() {}

    // MARK: -

    public func execute(path archivePath: String) throws -> Any?
    {
        let fileURL = URL(fileURLWithPath: archivePath)
        let data = try Data(contentsOf: fileURL)
        let topLevelObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        return topLevelObject
    }
}
