import Foundation
import PathKit

enum FileWriter {
    static func writeFile(_ file: RenderedTemplateFile) throws {
        let outputDirectory = Path(file.outputPath)

        if !outputDirectory.exists { // Make dir if it does not exist
            try outputDirectory.mkpath()
        }

        let fullPath = outputDirectory + Path(file.fileName)
        try fullPath.write(file.fileContents)
        print("🔨 \(file.fileName) created at \(fullPath.string)")
    }
}
