import Foundation
import ShellInterface

public struct ArchiveSourceryTypes
{
    public typealias Func = (LaunchOptions) throws -> Void

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
            throw TaskFailure.stillRunning(domain: #function, code: #line)
        }
        guard terminationStatus == 0 else {
            throw TaskFailure.nonzeroTerminationStatus(
                domain: #function,
                code: #line,
                terminationStatus: terminationStatus,
                uncaughtSignal: result.terminatedDueUncaughtSignal
            )
        }
    }
}
