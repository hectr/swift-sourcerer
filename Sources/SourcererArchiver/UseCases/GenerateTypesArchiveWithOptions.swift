import Foundation

public struct GenerateTypesArchiveWithOptions
{
    public typealias Func = (_ filename: String, _ sourceryOptions: LaunchOptions) throws -> String

    private let writeTemplate: WriteArchiverTemplateToDirectory.Func
    private let archive:       ArchiveSourceryTypes.Func

    public init(writeTemplate: @escaping WriteArchiverTemplateToDirectory.Func = WriteArchiverTemplateToDirectory().execute,
                archive:       @escaping ArchiveSourceryTypes.Func             = ArchiveSourceryTypes().execute)
    {
        self.writeTemplate = writeTemplate
        self.archive = archive
    }

    // MARK: -

    public func execute(filename: String = "archive.bin", sourceryOptions: LaunchOptions) throws -> String
    {
        var options = sourceryOptions
        let archiverDirectory = try writeTemplate(filename)
        options.templates.append(archiverDirectory)
        if options.output == nil {
            options.output = archiverDirectory
        }
        try archive(options)
        return archiverDirectory + filename
    }
}
