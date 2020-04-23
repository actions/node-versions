# Node.js for Actions
This repository contains the code and scripts that we use to prepare Node.js packages used in [virtual-environments](https://github.com/actions/virtual-environments) and accessible through the [setup-node](https://github.com/actions/setup-node) Action.  
File [versions-manifest.json](./versions-manifest.json) contains the list of available and released versions.  

> Caution: this is prepared for and only permitted for use by actions `virtual-environments` and `setup-node` action.

**Status**: Currently under development and in use for beta and preview actions.  This repo is undergoing rapid changes.

Some versions are pre-installed on [virtual-environments](https://github.com/actions/virtual-environments) images.  
More versions will (soon!) be available to install on-the-fly through the [`setup-node`](https://github.com/actions/setup-node) action.

## Adding new versions
We are trying to prepare packages for new versions of Node.js as soon as they are released. Please open an issue if any versions are missing.

## Contribution
Contributions are welcome! See [Contributor's Guide](./CONTRIBUTING.md) for more details about contribution process and code structure
