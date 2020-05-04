//
//  FileWriter.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import Foundation
import PathKit

protocol FileWritable {
    func writeFile(_ string: String, to path: String) throws
}
struct FileWriter: FileWritable {
    func writeFile(_ string: String, to path: String) throws {
        try Path(path).write(string)
    }
}
