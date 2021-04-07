import Stencil
import StencilSwiftKit
import PathKit

struct TemplateRenderer {
    func render(filePath: String, templateName: String, context: ContextParser) throws -> String {
        let path = Path(filePath)
        let loader = FileSystemLoader(paths: [path])
        let env = Environment(loader: loader)

        let fileName = templateName + ".stencil"
        return try env.renderTemplate(name: fileName, context: context.context ?? [:])
    }
}
