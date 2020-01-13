## Kraken

## How to build

### macos

https://yuque.antfin-inc.com/kraken/development/lcutf8

### Linux (x86)

https://yuque.antfin-inc.com/kraken/development/rzw5ug

### Linux (armv7, arm64, arch64)

https://yuque.antfin-inc.com/kraken/development/compile_kraken_linux

### Flutter Engine

https://yuque.antfin-inc.com/kraken/development/compile_flutter_engine

### Publish to AliOSS
```bash
OSS_AK=<your ak> OSS_SK=<your sk> npm run build:release -- --local-engine-path /path/to/flutter-engine/src
```
or

```
 node tools/oss.js --ak <your ak> --sk <your sk> -s ./tools/kraken-darwin-0.2.0-preview.1.tar.gz -n kraken-darwin.tar.gz
```
