import ArgumentParser
import Foundation
import Stencil
import PathKit
import ProjectSpec
import XcodeGenKit

struct Paths {
    let productName: String
    let useFlatStructure: Bool

    /// ディレクトリ構成がフラットであれば root、それ以外は root/productName
    var root: Path {
        if useFlatStructure {
            Path(".")
        } else {
            Path("./\(productName)")
        }
    }
    
    var sourceDir: Path { root + productName }

    var projectYml: Path { root + "project.yml" }
    var projectYmlURL: URL { projectYml.url }

    var xcodeProjDir: Path { root }
    var xcodeProjFile: Path { xcodeProjDir + "\(productName).xcodeproj" }

    func outputFilePath(fileName: String) -> URL {
        (sourceDir + fileName).url
    }
}

@main
struct XprojGen: ParsableCommand {
    
    @Argument(help: "The name of the product for the generated Xcode project.")
    private var productName: String
    
    @Flag(
        name: [.customLong("flat"), .short],
        help: """
        Generate Xcode project with flat directory structure.
        For example, output will be at './MyApp.xcodeproj' instead of './MyApp/MyApp.xcodeproj'.
        """
    )
    private var flat: Bool = false
    
    mutating func run() throws {
        let paths = Paths(productName: productName, useFlatStructure: flat)

        if FileManager.default.fileExists(atPath: paths.root.string) && !flat {
            Logger.error("\(productName) already exists.")
            return
        }

        try FileManager.default.createDirectory(atPath: paths.sourceDir.string, withIntermediateDirectories: true)

        try copyFile(templateName: "App.swift", paths: paths)
        try copyFile(templateName: "ContentView.swift", paths: paths)
        try copyFile(templateName: "project.yml", filePath: paths.projectYmlURL, paths: paths)

        try makeXcodeProject(paths: paths)
        
        // project.ymlはXcodeGenを実行した後に削除する
        try? FileManager.default.removeItem(at: paths.projectYmlURL)
    }

    private func copyFile(templateName: String, fileName: String? = nil, filePath: URL? = nil, paths: Paths) throws {
        let outputURL = filePath ?? paths.outputFilePath(fileName: fileName ?? templateName)

        let fileSystemLoader = FileSystemLoader(bundle: [Bundle.main, Bundle.module])
        let environment = Environment(loader: fileSystemLoader)
        // ./Resources/hogehoge.stencil　の {{productName}} が置き換えられる
        let context = ["productName": productName]

        do {
            let content = try environment.renderTemplate(name: templateName + ".stencil", context: context)
            Logger.info("Copying \(templateName)...")
            try content.write(to: outputURL, atomically: true, encoding: .utf8)
        } catch {
            Logger.error("Failed to render or write template '\(templateName)': \(error)")
            throw error
        }
    }


    private func makeXcodeProject(paths: Paths) throws {
        guard let userName = ProcessInfo.processInfo.environment["LOGNAME"] else {
            Logger.error("No user name found. Please set $LOGNAME in your environment.")
            return
        }

        Logger.info("Generating Xcode project...")

        let specLoader = SpecLoader(version: xcodeGenVersion)
        let project = try specLoader.loadProject(path: paths.projectYml)

        try specLoader.validateProjectDictionaryWarnings()

        try project.validateMinimumXcodeGenVersion(xcodeGenVersion)
        try project.validate()

        let fileWriter = FileWriter(project: project)
        try fileWriter.writePlists()
        
        let projectGenerator = ProjectGenerator(project: project)
        let xcodeProject = try projectGenerator.generateXcodeProject(
            in: paths.xcodeProjDir,
            userName: userName
        )

        try fileWriter.writeXcodeProject(xcodeProject, to: paths.xcodeProjFile)
        Logger.success("Xcode project generated successfully at: \(paths.xcodeProjFile.string)")
    }
}
