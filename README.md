# Node.js for Actions
This repository contains the code and scripts that we use to prepare Node.js packages used in [runner-images](https://github.com/actions/runner-images) and accessible through the [setup-node](https://github.com/actions/setup-node) Action.  
The file [versions-manifest.json](./versions-manifest.json) contains the list of available and released versions.  

> Caution: this is prepared for and only permitted for use by actions `runner-images` and `setup-node` action.

**Status**: Currently under development and in use for beta and preview actions.  This repo is undergoing rapid changes.

Latest of LTS versions will be installed on the [runner-images](https://github.com/actions/runner-images) images. Other versions will be pulled JIT using the [`setup-node`](https://github.com/actions/setup-node) action.

## Adding new versions
We are trying to prepare packages for new versions of Node.js as soon as they are released. Please open an issue in [actions/runner-images](https://github.com/actions/runner-images) if any versions are missing.

## Contribution
Contributions are welcome! See [Contributor's Guide](./CONTRIBUTING.md) for more details about contribution process and code structure
