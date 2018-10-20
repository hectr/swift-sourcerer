import Foundation

public struct GenerateTypesArchive
{
    public typealias Func = (_ ignoreUnknownArguments: Bool) throws -> String

    private let readOptions:     ReadLaunchOptions.Func
    private let generateArchive: GenerateTypesArchiveWithOptions.Func

    public init(readOptions:     @escaping ReadLaunchOptions.Func               = ReadLaunchOptions().execute,
                generateArchive: @escaping GenerateTypesArchiveWithOptions.Func = GenerateTypesArchiveWithOptions().execute)
    {
        self.readOptions = readOptions
        self.generateArchive = generateArchive
    }

    // MARK: -

    public func execute(ignoreUnknownArguments: Bool = false) throws -> String
    {
        let filename = "archive.bin"
        let options = try readOptions(ignoreUnknownArguments)
        return try generateArchive(filename, options)
    }
}
