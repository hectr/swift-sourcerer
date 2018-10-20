import Foundation
import SourceryRuntime

public struct UnarchiveTypesFromPath
{
    public typealias Func = (_ path: String) throws -> Types

    public enum Error: Swift.Error
    {
        case nilObject      (path: String)
        case unexpectedType (path: String, object: Any)
    }

    private let unarchive: UnarchiveObjectFromPath.Func

    public init(unarchive: @escaping UnarchiveObjectFromPath.Func = UnarchiveObjectFromPath().execute)
    {
        self.unarchive = unarchive
    }

    // MARK: -

    public func execute(path archivePath: String) throws -> Types
    {
        guard let topLevelObject = try unarchive(archivePath) else {
            throw Error.nilObject(path: archivePath)
        }
        guard let types = topLevelObject as? Types else {
            throw Error.unexpectedType(path: archivePath, object: topLevelObject)
        }
        return types
    }
}
