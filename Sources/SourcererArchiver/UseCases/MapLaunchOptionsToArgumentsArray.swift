import Foundation

public struct MapLaunchOptionsToArgumentsArray
{
    public typealias Func = (LaunchOptions) -> [String]

    public init() {}

    // MARK: -

    public func execute(launchOptions: LaunchOptions) -> [String]
    {
        var arguments = [String]()

        if let output = launchOptions.output {
            arguments += [ArgumentOption.output.rawValue, output]
        }
        arguments += launchOptions.sources.map { return [ArgumentOption.sources.rawValue, $0] }.flatMap { $0 }
        arguments += launchOptions.excludeSources.map { return [ArgumentOption.excludeSources.rawValue, $0] }.flatMap { $0 }
        arguments += launchOptions.templates.map { return [ArgumentOption.templates.rawValue, $0] }.flatMap { $0 }
        arguments += launchOptions.excludeTemplates.map { return [ArgumentOption.excludeTemplates.rawValue, $0] }.flatMap { $0 }
        arguments += launchOptions.verbose ? [ArgumentOption.verbose.rawValue] : []
        arguments += launchOptions.quiet ? [ArgumentOption.quiet.rawValue] : []
        arguments += launchOptions.watch ? [ArgumentOption.watch.rawValue] : []
        arguments += launchOptions.disableCache ? [ArgumentOption.disableCache.rawValue] : []
        arguments += launchOptions.prune ? [ArgumentOption.prune.rawValue] : []
        if let config = launchOptions.config {
            arguments += [ArgumentOption.config.rawValue, config]
        }
        arguments += launchOptions.forceParse.map { return [ArgumentOption.forceParse.rawValue, $0] }.flatMap { $0 }
        arguments += launchOptions.args.map { return [ArgumentOption.args.rawValue, $0] }.flatMap { $0 }
        if let ejsPath = launchOptions.ejsPath {
            arguments += [ArgumentOption.ejsPath.rawValue, ejsPath]
        }

        return arguments
    }
}
