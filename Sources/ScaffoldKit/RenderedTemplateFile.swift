//
//  RenderedTemplateFile.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/08.
//

import Foundation

struct RenderedTemplateFile {
    let fileContents, outputPath, fileName: String

    init(fileContents: String, outputPath: String, fileName: String, name: String) {
        self.fileContents = fileContents
        self.outputPath = outputPath.replacingOccurrences(of: "{{ name }}", with: name)
        self.fileName = fileName.replacingOccurrences(of: "{{ name }}", with: name)
    }
}
