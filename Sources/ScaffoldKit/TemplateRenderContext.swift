//
//  TemplateRenderContext.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/08.
//

struct TemplateRenderContext {
    let context: [String: Any]?

    init(name: String?, context: String?) {
        if let name = name {
            self.context = ["name": name]
            //        } else if let context = context {
            //            // TODO: parse context w/ parser combinator
        } else {
            self.context = nil
        }
    }
}
