//
//  FileWriter.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import Foundation
import PathKit

protocol FileWritable {
    func writeFile(_ file: RenderedTemplateFile) throws
}
struct FileWriter: FileWritable {
    func writeFile(_ file: RenderedTemplateFile) throws {
        let outputDirectory = Path(file.outputPath)

        if !outputDirectory.exists { // Make dir if it does not exist
            try outputDirectory.mkdir()
        }

        let fullPath = outputDirectory + Path(file.fileName)
        try fullPath.write(file.fileContents)
        print("🔨 \(file.fileName) created at \(fullPath.string)")
    }
}
