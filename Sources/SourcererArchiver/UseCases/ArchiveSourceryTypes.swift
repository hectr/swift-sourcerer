import Foundation
import ShellInterface

public struct ArchiveSourceryTypes
{
    public typealias Func = (LaunchOptions) throws -> Void

    public enum Error: Swift.Error
    {
        case archiveFailed (result: TaskResult, underlyingError: TaskFailure)
    }

    private let shell:  ExecuteCommand.Func
    private let mapper: MapLaunchOptionsToArgumentsArray.Func

    public init(shell:  @escaping ExecuteCommand.Func                   = ExecuteCommand().execute,
                mapper: @escaping MapLaunchOptionsToArgumentsArray.Func = MapLaunchOptionsToArgumentsArray().execute)
    {
        self.shell = shell
        self.mapper = mapper
    }

    // MARK: -

    public func execute(launchOptions: LaunchOptions) throws
    {
        let arguments = mapper(launchOptions)
        let result = shell(launchOptions.sourceryPath, arguments, nil, true)
        guard let terminationStatus = result.terminationStatus else {
            let underlyingError = TaskFailure.stillRunning(domain: #function, code: #line)
            throw Error.archiveFailed(result: result, underlyingError: underlyingError)
        }
        guard terminationStatus == 0 else {
            let underlyingError = TaskFailure.nonzeroTerminationStatus(
                domain: #function,
                code: #line,
                terminationStatus: terminationStatus,
                uncaughtSignal: result.terminatedDueUncaughtSignal
            )
            throw Error.archiveFailed(result: result, underlyingError: underlyingError)
        }
    }
}
