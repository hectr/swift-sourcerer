import Foundation
import Idioms

public struct ReadLaunchOptions
{
    public typealias Func = (_ ignoreUnknownArguments: Bool) throws -> LaunchOptions

    public enum Error: Swift.Error
    {
        case unpairedArgument   (value: String)
        case missingOptionValue (option: String)
    }

    public init() {}

    // MARK: -

    public func execute(ignoreUnknown: Bool = false) throws -> LaunchOptions
    {
        var options = LaunchOptions()

        func handleArgument(option: ArgumentOption, value: String) {
            let path = pathByReplacingTilde(value)
            let boolean = value == "false" ? false : true
            switch option {
            case .sourceryPath:     options.sourceryPath = path
            case .sources:          options.sources.append(path)
            case .output:           options.output = path
            case .excludeSources:   options.excludeSources.append(path)
            case .templates:        options.templates.append(path)
            case .excludeTemplates: options.excludeTemplates.append(path)
            case .verbose:          options.verbose = boolean
            case .quiet:            options.quiet = boolean
            case .watch:            options.watch = boolean
            case .disableCache:     options.disableCache = boolean
            case .prune:            options.prune = boolean
            case .config:           options.config = path
            case .forceParse:       options.forceParse.append(value)
            case .args:             options.args.append(path)
            case .ejsPath:          options.ejsPath = path
            }
        }

        try CommandLine.arguments.iterate { arguments, index in
            guard let option = ArgumentOption(rawValue: arguments[index.current]) else {
                if !ignoreUnknown {
                    let currentValue = arguments[index.current]
                    try checkValueIsPaired(arguments: arguments,
                                           value: currentValue,
                                           previousIndex: index.previous)
                }
                return
            }
            guard let nextIndex = index.next else {
                throw Error.missingOptionValue(option: option.rawValue)
            }
            let optionValue = arguments[nextIndex]
            handleArgument(option: option, value: optionValue)
        }

        return options
    }

    private func checkValueIsPaired(arguments: [String], value: String, previousIndex: Int?) throws {
        guard let previousIndex = previousIndex else { return }
        guard let _ = ArgumentOption(rawValue: arguments[previousIndex]) else {
            throw Error.unpairedArgument(value: value)
        }
        return
    }

    private func pathByReplacingTilde(_ path: String) -> String {
        guard path.hasPrefix("~") else { return path }
        return path.replacingOccurrences(of: "~", with: ProcessInfo.processInfo.environment["HOME"] ?? "${HOME}")
    }
}
