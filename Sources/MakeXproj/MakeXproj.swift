import ArgumentParser
import Foundation
import Logging
import Stencil
import PathKit
import ProjectSpec
import XcodeGenKit

let logger = Logger(label: "com.github.akidon0000.makexproj")

@main
struct MakeXproj: ParsableCommand {
    
    @Argument var productName: String

    mutating func run() throws {
        guard !FileManager.default.fileExists(atPath: productName) else {
            logger.error("\(productName) exist.")
            return
        }
        
        try FileManager.default.createDirectory(atPath: productName + "/" + productName  , withIntermediateDirectories: true)
        
        try copySwiftFile(templateName: "App.swift")
        try copySwiftFile(templateName: "ContentView.swift")
//        try copyFile(templateName: "Info.plist")

        
        let projectYmlPath = URL(fileURLWithPath: "./\(productName)/project.yml")
        try copyFile(templateName: "project.yml", filePath: projectYmlPath)
        try makeXcodeProject()
        try? FileManager.default.removeItem(at: projectYmlPath)
        logger.info("Creating \(productName) has been succeeded.")
    }

    private func copySwiftFile(templateName: String, fileName: String? = nil) throws {
        try copyFile(
            templateName: templateName,
            filePath: URL(fileURLWithPath: "./\(productName)/\(productName)/" + (fileName ?? templateName))
        )
    }

    private func copyFile(templateName: String, filePath: URL? = nil) throws {
        let fileSystemLoader = FileSystemLoader(bundle: [Bundle.main, Bundle.module])
        let environment = Environment(loader: fileSystemLoader)

        let context = [
            "productName": productName
        ]
        let content = try environment.renderTemplate(name: templateName + ".stencil", context: context)
        let url = filePath ?? URL(fileURLWithPath: "./\(productName)/\(productName)/\(templateName)")
        logger.debug("Writing to \(url.absoluteString)")
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    private func makeXcodeProject() throws {
        guard let userName = ProcessInfo.processInfo.environment["LOGNAME"] else {
            logger.error("No user name, please set $LOGNAME")
            return
        }
        let specLoader = SpecLoader(version: xcodeGenVersion)
        let project = try specLoader.loadProject(path: Path("./\(productName)/project.yml"))
        try specLoader.validateProjectDictionaryWarnings()

        let projectPath = "./\(project.name)/\(productName).xcodeproj"
        try project.validateMinimumXcodeGenVersion(xcodeGenVersion)
        try project.validate()
        let fileWriter = FileWriter(project: project)
        try fileWriter.writePlists()
        let projectGenerator = ProjectGenerator(project: project)
        let xcodeProject = try projectGenerator.generateXcodeProject(in: Path("./\(project.name)/"), userName: userName)
        try fileWriter.writeXcodeProject(xcodeProject, to: Path(projectPath))
    }
}
