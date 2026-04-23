import {compile} from '@tailwindcss/node'
import {Scanner} from '@tailwindcss/oxide'
import {dirname} from 'path'

const TAILWIND_RE = /(?:^|\n)\s*@(?:import\s+["']tailwindcss["']|reference\b|tailwind\b)/

export default function tailwind({root}) {
  return async (content, args) => {
    if (!TAILWIND_RE.test(content)) return content

    const compiler = await compile(content, {
      base: dirname(args.path),
      from: args.path,
      onDependency: () => {}
    })

    const baseSources =
      compiler.root === 'none' ? [] :
      compiler.root === null
        ? [{base: root, pattern: '**/*', negated: false}]
        : [{...compiler.root, negated: false}]

    const scanner = new Scanner({sources: [...baseSources, ...compiler.sources]})

    return compiler.build(scanner.scan())
  }
}
