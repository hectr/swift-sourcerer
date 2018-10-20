import Foundation

public struct WriteArchiverTemplateToDirectory
{
    public typealias Func = (_ archiverOutput: String) throws -> String

    private let createDirectory: CreateTemporaryDirectory.Func

    public init(createDirectory: @escaping CreateTemporaryDirectory.Func = CreateTemporaryDirectory().execute)
    {
        self.createDirectory = createDirectory
    }

    // MARK: -

    public func execute(archiverOutput filename: String = "archive.bin") throws -> String
    {
        let directory = try createDirectory()
        let archiveFile = directory + filename
        let template = "<% NSKeyedArchiver.archiveRootObject(types, toFile: \"\(archiveFile)\") %>"
        let templatePath = directory + "archiver.swifttemplate"
        try template.write(toFile: templatePath, atomically: true, encoding: .utf8)
        return directory
    }
}
