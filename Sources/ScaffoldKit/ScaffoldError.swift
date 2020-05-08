//
//  ScaffoldError.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/08.
//

import Foundation

public enum ScaffoldError: String, LocalizedError {
    case noTemplates = "No templates or groups specified!"
    case templatesAndGroups = "Cannot specify both templates and groups!"
    case noOutputPath = "No output path specified!"
    case noFileName = "No output fileName specified!"

    public var errorDescription: String? { rawValue }
}
