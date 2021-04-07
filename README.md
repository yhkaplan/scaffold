# 🏭Scaffold

[![Swift Version](https://img.shields.io/badge/Swift-5.3.x-orange.svg)]()

Scaffold is a tool for generating code from Stencil templates, similar to rails gen. It happens to be written in Swift, but it can output source files for any language.

Here's how it works:

```sh
$ scaffold --template ViewModel --name Search # Output one specific template
🏭 Rendering templates...
🔨 SearchViewModel.swift created at Sources/Search/SearchViewModel.swift
✅ Complete

$ scaffold --group Feature --name Search # Output multiple templates at the same time
🏭 Rendering templates...
🔨 SearchViewController.swift created at Sources/Search/SearchViewController.swift
🔨 SearchViewModel.swift created at Sources/Search/SearchViewModel.swift
🔨 SearchRouter.swift created at Sources/Search/SearchRouter.swift
🔨 SearchViewModelTests.swift created at Tests/ViewModels/SearchViewModelTests.swift
✅ Complete
```

Templates are written in a language called [Stencil](https://stencil.fuller.li/en/latest/):

```swift
//  {{ name }}ViewModel.swift

import Foundation
import RxSwift
import RxRelay

protocol {{ name }}ViewModelInputs {
    func fooButtonDidTap()
}
protocol {{ name }}ViewModelOutputs: AutoTestableOutputs {
    var fooButtonIsEnabled: Driver<Bool> { get }
    var shouldHideKeyboard: Signal<Bool> { get }
}
protocol {{ name }}ViewModelType {
    var inputs: {{ name }}ViewModelInputs { get }
    var outputs: {{ name }}ViewModelOutputs { get }
}

final class {{ name }}ViewModel: {{ name }}ViewModelType, {{ name }}ViewModelOutputs {
//...
```

Also, you can use extensions to Stencil defined in [StencilSwiftKit](https://github.com/SwiftGen/StencilSwiftKit).

## Installing

### Homebrew

```sh
$ brew tap yhkaplan/scaffold https://github.com/yhkaplan/scaffold.git
$ brew install scaffold
```

### Manually

```sh
$ git clone git@github.com:yhkaplan/scaffold.git
$ cd scaffold
$ make install
```

## Usage

### Setup
1. Make some templates (The [Stencil documentation](https://stencil.fuller.li/en/latest/) is very helpful)
1. Define templates and groups in a `.scaffold.yml` file (see Configuration)
1. You're ready to go!

If you want to pass in complex values from the your local development environment, a Makefile like below can be useful.

```makefile
SCAFFOLD_CONTEXT="name=$(name),user=$$(git config user.name),date=$$(date -u +"%Y/%m/%d")"

feature:
	scaffold --group Feature --context $(SCAFFOLD_CONTEXT)

template:
	scaffold --template $(template) --context $(SCAFFOLD_CONTEXT)
```

To use it, just call `make template template=View name=Hoge` or `make feature name=Search`

## Configuration

### Config file
```yml
templates: # Required (array of Templates)
  - name: ViewController # Required (string)
    templatePath: Templates/ # Required (string)
    fileName: "{{ name }}ViewController.swift" # Required (string)
    outputPath: Sources/Controllers/ # Optional (string)
  - name: ViewModel
    templatePath: Templates/
    fileName: "{{ name }}ViewModel.swift"
    outputPath: Sources/ViewModels/
groups: # Optional (array of TemplateGroups)
  - name: Feature # Required (string)
    templateNames: # Required (array of template names as strings)
    - ViewController
    - ViewModel
    outputPath: # Optional (string)
```

### Command line options
```
OPTIONS:
  -d, --dry-run           Print the output without writing the file(s) to disk. Default
                          is false.
  -o, --output-path <output-path>
                          Path to output folder(s).
  -t, --template <template>
                          Single template or comma-separated list of templates to
                          generate from the config file
  -g, --group <group>     Group from config file with list of templates
  --config-file-path <config-file-path>
                          Path to config file. Default is .scaffold.yml
  -n, --name <name>       Value to pass to the name variable in the stencil template
  -c, --context <context> String with context values to pass to template (overrides
                          name).
  -h, --help              Show help information.
```

## Alternatives

### Xcode's templates

Articles like those below discuss how to make custom templates for Xcode, but the biggest issues with custom Xcode templates are as below. That said, they may be enough for you.

1. The format can change with any new version of Xcode, breaking your templates
1. There's a limited range of variables and customizability available
1. Sharing templates with team members involves awkward scripts that symlink to the correct folder
1. They can't be used from the command line (more of a personal preference)

- [How to create a custom Xcode template for coordinators](https://www.hackingwithswift.com/articles/158/how-to-create-a-custom-xcode-template-for-coordinators)
- [Streamlining your development workflow with Xcode Templates](https://medium.com/kinandcartacreated/streamlining-your-development-workflow-with-xcode-templates-b99a73a5b5f8)

### Genesis

- [Genesis](https://github.com/yonaskolb/Genesis)

Genesis also uses Stencil for templating, but it seems more focused on new projects and interactive commands whereas Scaffold is more focused on continual use.

### Kuri

- [Kuri](https://github.com/bannzai/Kuri)

Kuri does not use Stencil for templating, instead choosing an Xcode-like DSL. This is enough for many use-cases, but I wanted something with the flexibility of Stencil where I could feed in any kind of information I want into the templates. Also, Kuri has a nice feature where it can add generated files to Xcode automatically. I may add this feature in later, but I am still considering whether I should.

## Credits/Inspiration

- [Stencil](https://github.com/stencilproject/Stencil) for a delightful templating language
- [StencilSwiftKit](https://github.com/SwiftGen/StencilSwiftKit) for a powerful Stencil library
- [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for its deeply thought-out example of StencilSwiftKit
- [Yams](https://github.com/jpsim/Yams) for effortless yml parsing
- [PathKit](https://github.com/kylef/PathKit) for easy-to-use path operations
- [ArgumentParser](https://github.com/apple/swift-argument-parser) for Swifty argument-parsing
- [Genesis](https://github.com/yonaskolb/Genesis) for inspiration on balancing config and template files
- [Kuri](https://github.com/bannzai/Kuri) for inpiration of how the CLI should work and config file should look
- [pointfree.co](pointfree.co) and their episodes on Parser combinators, a very direct inspiration for the Parser target

## License

Licensed under MIT license. See [LICENSE](LICENSE) for more info.
