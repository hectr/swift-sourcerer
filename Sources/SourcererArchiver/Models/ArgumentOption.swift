import Foundation

public enum ArgumentOption: String {
    case sourceryPath = "--sourcery-path"
    case output = "--output"
    case sources = "--sources"
    case excludeSources = "--exclude-sources"
    case templates = "--templates"
    case excludeTemplates = "--exclude-templates"
    case verbose = "--verbose"
    case quiet = "--quiet"
    case watch = "--watch"
    case disableCache = "--disableCache"
    case prune = "--prune"
    case config = "--config"
    case forceParse = "--force-parse"
    case args = "--args"
    case ejsPath = "--ejsPath"
}
