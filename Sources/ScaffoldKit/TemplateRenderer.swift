import Stencil
import StencilSwiftKit
import PathKit

enum TemplateRenderer {
    static func renderTemplate(filePath: String, templateName: String, context: [String: Any]) throws -> String {
        let fileName = templateName + ".stencil"
        let path = Path(filePath) + Path(fileName)
        let env = StencilSwiftKit.stencilSwiftEnvironment()
        let templateString: String = try path.read()
        let template = StencilSwiftTemplate(templateString: templateString, environment: env)

        let enriched = try StencilContext.enrich(context: context, parameters: [:])
        return try template.render(enriched)
    }
}
