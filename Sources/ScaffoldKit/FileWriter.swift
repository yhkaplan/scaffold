//
//  FileWriter.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import Foundation
import PathKit

protocol FileWritable {
    func writeFile(_ string: String, to path: Path) throws
}
struct FileWriter: FileWritable {
    func writeFile(_ string: String, to path: Path) throws {
        print(string)
        //        try path.write(string) // TODO: actually write
    }
}
