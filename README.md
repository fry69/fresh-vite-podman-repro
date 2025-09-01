# Fresh build problem with Podman

Run `make build` to reproduce this problem:

```
STEP 10/13: RUN deno task build
Task build vite build
failed to load config from /app/vite.config.ts
error during build:
TypeError: Text file busy (os error 26)
    at https://jsr.io/@fresh/plugin-vite/0.9.5/src/plugins/patches.ts:2:24
    at async loadConfigFromBundledFile (file:///app/node_modules/.deno/vite@7.1.3_1/node_modules/vite/dist/node/chunks/dep-Bj7gA1-0.js:36525:12)
    at async bundleAndLoadConfigFile (file:///app/node_modules/.deno/vite@7.1.3_1/node_modules/vite/dist/node/chunks/dep-Bj7gA1-0.js:36409:21)
    at async loadConfigFromFile (file:///app/node_modules/.deno/vite@7.1.3_1/node_modules/vite/dist/node/chunks/dep-Bj7gA1-0.js:36376:42)
    at async resolveConfig (file:///app/node_modules/.deno/vite@7.1.3_1/node_modules/vite/dist/node/chunks/dep-Bj7gA1-0.js:36022:22)
    at async createBuilder (file:///app/node_modules/.deno/vite@7.1.3_1/node_modules/vite/dist/node/chunks/dep-Bj7gA1-0.js:34478:19)
    at async CAC.<anonymous> (file:///app/node_modules/.deno/vite@7.1.3_1/node_modules/vite/dist/node/cli.js:648:19)
Error: building at STEP "RUN deno task build": while running runtime: exit status 1
```

## Setup

Laptop:

```shell
$ uname -a
Darwin macbookair.local 24.6.0 Darwin Kernel Version 24.6.0: Mon Jul 14 11:30:34 PDT 2025; root:xnu-11417.140.69~1/RELEASE_ARM64_T8103 arm64

$ podman --version
podman version 5.6.0
```

Remote build machine:

```shell
$ podman version
Client:        Podman Engine
Version:       5.6.0
API Version:   5.6.0
Go Version:    go1.25.0
Built:         Fri Aug 15 15:42:35 2025
Build Origin:  brew
OS/Arch:       darwin/arm64

Server:       Podman Engine
Version:      5.4.1
API Version:  5.4.1
Go Version:   go1.24.1
Built:        Thu Mar 20 14:36:49 2025
OS/Arch:      linux/amd64
```
