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
//launchOptions.sourceryPath = "sourcery"
//launchOptions.sources.append("\(expandPath("~/Documents/path_to_sources"))")
//launchOptions.output = "/tmp"

guard launchOptions != nil || CommandLine.arguments.count >= 2 else {
    // If you are running from Xcode you can still pass command line arguments.
    // Go to: Product > Scheme > Manage Schemes > sourcerer > Run > Arguments > Arguments Passed On Launch
    // Add at least --sourcery-path and --sources:
    // [x] --sourcery-path $PODS_ROOT/Sourcery/bin/sourcery
    // [x] --sources ~/path/to/sources
    // [ ] --output /tmp
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

launchOptions = try readLaunchOptions(ignoreUnknownLaunchOptions)

// -- Archive and unarchive Sourcery's Types

print("Archiving Types...")
let typesArchivePath = try archiveTypes(archiveFilename, launchOptions)

print("Unarchiving Types...")
let types = try unarchiveTypes(typesArchivePath)

// -- Render output

print("Rendering reports...")

let stats = StatsRenderer(types: types)
let rankings = RankingsRenderer(types: types)
let ownership = OwnershipCyclesRenderer(types: types)

if let outputPath = launchOptions.output {
    // write to a file
    let url = URL(fileURLWithPath: outputPath)
    try stats.write(url: url)
    try rankings.write(url: url)
    try ownership.write(url: url)
} else {
    // write to the console
    var output = String()
    output.append("\n\n=== \(stats.filename) ===\n")
    stats.write(to: &output)
    output.append("\n\n=== \(rankings.filename) ===\n")
    rankings.write(to: &output)
    output.append("\n\n=== \(ownership.filename) ===\n")
    ownership.write(to: &output)
    print(output)
}
