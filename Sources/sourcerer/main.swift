import Foundation
import ShellInterface
import SourceryRuntime
import SourcererArchiver
import SourcererUnarchiver
import SourcererRenderer

// What follows is a demonstration on how to load Sourcery's Types class into your own code.
// In this example, Types information is used to render some (not necessarily accurate) code metrics reports.

// -- Usecases

let readLaunchOptions = ReadLaunchOptions().execute
let expandPath = ExpandFilePath().execute
let archiveTypes = GenerateTypesArchiveWithOptions().execute
let unarchiveTypes = UnarchiveTypesFromPath().execute
let ignoreUnknownLaunchOptions = true
let archiveFilename = "archive.bin"

// -- Get launch options

var launchOptions: LaunchOptions! = nil

// If you don't want to use command line arguments, you can create and customize LaunchOptions by code:
//launchOptions = LaunchOptions()
//launchOptions.sourceryPath = "/path/to/sourcery"
//launchOptions.sources.append(expandPath("~/path/to/sources/"))
//launchOptions.excludeSources.append(expandPath("~/path/to/sources/Pods/"))
//launchOptions.excludeSources.append(expandPath("~/path/to/sources/Carthage/"))
//launchOptions.excludeSources.append(expandPath("~/path/to/sources/.git/"))
//launchOptions.excludeSources.append(expandPath("~/path/to/sources/build/"))
//launchOptions.output = expandPath("~/Documents/")

guard launchOptions != nil || CommandLine.arguments.count >= 2 else {
    // If you are running from Xcode you can still pass command line arguments.
    // Go to: Product > Scheme > Manage Schemes > sourcerer > Run > Arguments > Arguments Passed On Launch
    // Add at least --sourcery-path and --sources:
    // [x] --sourcery-path $PODS_ROOT/Sourcery/bin/sourcery
    // [x] --sources ~/path/to/sources/
    // [ ] --output ~/Documents/
    // [ ] --exclude-sources ~/path/to/sources/Pods/
    // [ ] --exclude-sources ~/path/to/sources/Carthage/
    // [ ] --exclude-sources ~/path/to/sources/.git/
    // [ ] --exclude-sources ~/path/to/sources/build/
    let usage =
    """
    Usage:

    $ \(CommandLine.arguments.first ?? "sourcerer")

    Options:
    --sourcery-path - Path to the sourcery executable.
    --output - Path to the output directory.
    Sourcery options:
    --sources, --watch, --disableCache, --verbose, --quiet, --prune, --exclude-sources, --templates, --exclude-templates, --config, --force-parse, --args, --ejsPath
    """
    print(usage)
    exit(1)
}

if launchOptions == nil {
    launchOptions = try readLaunchOptions(ignoreUnknownLaunchOptions)
}

// -- Archive and unarchive Sourcery's Types

print("Archiving Types...")
let typesArchivePath = try archiveTypes(archiveFilename, launchOptions)

print("Unarchiving Types...")
let types = try unarchiveTypes(typesArchivePath)

// -- Render output

print("Rendering reports...")

let stats = StatsRenderer(types: types)
let rankings = RankingsRenderer(types: types)
let references = ReferenceCyclesRenderer(types: types)
let untested = UntestedRenderer(types: types)

if let outputPath = launchOptions.output {
    // write to a file
    let url = URL(fileURLWithPath: outputPath)
    try stats.write(url: url)
    try rankings.write(url: url)
    try references.write(url: url)
    try untested.write(url: url)
} else {
    // write to the console
    var output = String()
    output.append("\n\n=== \(stats.filename) ===\n")
    stats.write(to: &output)
    output.append("\n\n=== \(rankings.filename) ===\n")
    rankings.write(to: &output)
    output.append("\n\n=== \(references.filename) ===\n")
    references.write(to: &output)
    output.append("\n\n=== \(untested.filename) ===\n")
    untested.write(to: &output)
    print(output)
}
