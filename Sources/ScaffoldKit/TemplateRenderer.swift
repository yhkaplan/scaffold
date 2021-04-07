import Stencil
import StencilSwiftKit
import PathKit

enum TemplateRenderer {
    static func renderTemplate(filePath: String, templateName: String, context: [String: Any]) throws -> String {
        let path = Path(filePath)
        let loader = FileSystemLoader(paths: [path])
        let env = Environment(loader: loader)

        let fileName = templateName + ".stencil"
        return try env.renderTemplate(name: fileName, context: context)
    }
}
