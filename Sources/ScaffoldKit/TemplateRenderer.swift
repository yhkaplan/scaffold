//
//  TemplateRenderer.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/08.
//

import Stencil
import StencilSwiftKit
import PathKit

struct TemplateRenderer {
    func render(filePath: String, templateName: String, context: TemplateRenderContext) throws -> String {
        let path = Path(filePath)
        let loader = FileSystemLoader(paths: [path])
        let env = Environment(loader: loader)

        let fileName = templateName + ".stencil"
        return try env.renderTemplate(name: fileName, context: context.context)
    }
}
