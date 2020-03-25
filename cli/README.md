## Kraken CLI for Desktop

Kraken is a Flutter & Web standards based rendering engine.

More to see https://rax.js.org/kraken

Cli Client support:

- [x] macOS
- [ ] Linux
- [ ] Windows

## Usage

```sh
Usage: kraken [filename|URL]

Start a kraken app.

Options:
  -V, --version                    output the version number
  -b --bundle <filename>           Bundle path. One of bundle or url is needed, if both determined, bundle path will be used.
  -u --url <URL>                   Bundle URL. One of bundle or URL is needed, if both determined, bundle path will be used.
  -i --instruct <instruct>         instruct file path.
  -s, --source <source>            Source code. pass source directory from command line
  -m --runtime-mode <runtimeMode>  Runtime mode, debug | release. (default: "debug")
  --enable-kraken-js-log           print kraken js to dart log (default: false)
  --show-performance-monitor       show render performance monitor (default: false)
  --js-engine <jsengine>           the JavaScript Engine that executes the code. jsc | v8 (default: "jsc")
  -d, --debug-layout               debug element's paint layout (default: false)
  -h, --help                       output usage information
```
