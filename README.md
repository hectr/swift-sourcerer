
# Sourcerer

*Pure-Swift meta-programming*

Proof-of-concept pure Swift code-generator that runs on top of [Sourcery](https://github.com/krzysztofzablocki/Sourcery).

## Introduction

Sourcerer consists of a series of swift modules that you can import into your macOS application to load the information that Sourcery extracts from Swift sources, the `SourceryRuntime.Types` object.

- `SourcererArchiver` uses Sourcery to write an archive of the `SourceryRuntime.Types` object to the disk.
- `SourcererUnarchiver` unarchives the `SourceryRuntime.Types` object into the running application.
- `SourceryRuntime` is required by the unarchiver to load the archive information.
- `SourcererTypes` and `SourcererRenderer` contain some helpers and extensions to `SourceryRuntime.Types`. 

### Sample project

The sample project is a command-line tool that extracts metrics (not necessarily 100% accurate) from the analyzed sources.

To see what the generated reports look like, check the *Samples* folder. There you can find the result of analyzing Sourcery's source code with `sourcerer`.

- [cycles.jpg](Samples/cycles.jpg)
- [rankings.md](Samples/rankings.md)
- [stats.md](Samples/stats.md)
- [untested.md](Samples/untested.md)

To see how it works, take a look at the sample sources:

```
$ git clone https://github.com/hectr/swift-sourcerer.git
$ cd swift-sourcerer
$ pod install
$ open sourcerer.xcworkspace
```

**Note:** after `pod install` you may see the following message:

> [!] The version of CocoaPods used to generate the lockfile (1.6.0.beta.2) is higher than the version of the current executable (1.5.3). Incompatibility issues may arise.

In that case, you need to install [CocoaPods 1.6.0.beta.2](http://blog.cocoapods.org/CocoaPods-1.6.0-beta/) and run `pod install` again:

```
$ gem install cocoapods --pre
$ pod install
```

After that, the `Vendor/SourceryRuntime` folder should contain Sourcery's files required to run the project, if this is not the case, execute the `install_sourcery_runtime.sh` script manually and re-run `pod install`.

## Usage

Steps to get started using Sourcerer in your own project:

- Create a new macOS project (e.g. *Example*):

- `pod init`

- Set up dependencies (`Podfile`):

```ruby
target 'Example' do
  # archive
  pod 'SourcererArchiver', :git => 'https://github.com/hectr/swift-sourcerer.git'
  # unarchive
  pod 'SourcererUnarchiver', :git => 'https://github.com/hectr/swift-sourcerer.git'
  pod 'SourceryRuntime', :git => 'https://github.com/hectr/swift-sourcerer.git'
end
```

- Implement initial code (`main.swift`):

```swift
import SourceryRuntime
import SourcererArchiver
import SourcererUnarchiver

let ignoreUnknownArguments = false
let archive = GenerateTypesArchive().execute
let unarchive = UnarchiveTypesFromPath().execute

let typesArchivePath = try archive(ignoreUnknownArguments)
let types = try unarchive(typesArchivePath)

print("- There are \(types.protocols.count) protocols.")
print("- There are \(types.structs.count) structs.")
print("- There are \(types.classes.count) classes.")
```

- Execute it with at least these two command line arguments: (1) the path to the Sourcery executable (`--sourcery-path`) and (2) the path to the sources (`--sources`):

`Example --sourcery-path /path/to/sourcery --sources /path/to/sources/`
