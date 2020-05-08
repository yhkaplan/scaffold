//
//  FileWriter.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import Foundation
import PathKit

protocol FileWritable {
    func writeFile(_ string: String, to outputDirectory: String, named fileName: String) throws
}
struct FileWriter: FileWritable {
    func writeFile(_ string: String, to outputDirectory: String, named fileName: String) throws {
        let outputDirectory = Path(outputDirectory)

        if !outputDirectory.exists { // Make dir if it does not exist
            try outputDirectory.mkdir()
        }

        let fullPath = outputDirectory + Path(fileName)
        try fullPath.write(string)
    }
}
