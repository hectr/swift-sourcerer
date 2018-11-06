import Foundation

public struct LaunchOptions {
    public var sourceryPath = "sourcery"
    public var output: String?
    public var sources = [String]()
    public var excludeSources = [String]()
    public var templates = [String]()
    public var excludeTemplates = [String]()
    public var verbose = false
    public var quiet = false
    public var watch = false
    public var disableCache = false
    public var prune = false
    public var config: String?
    public var forceParse = [String]()
    public var args = [String]()
    public var ejsPath: String?

    public init() {}
}
