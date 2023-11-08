set -e

NODE_VERSION={0}
ARCH={1}

NODE_TOOLCACHE_PATH=$AGENT_TOOLSDIRECTORY/node
NODE_TOOLCACHE_VERSION_PATH=$NODE_TOOLCACHE_PATH/$NODE_VERSION
NODE_TOOLCACHE_VERSION_ARCH_PATH=$NODE_TOOLCACHE_VERSION_PATH/$ARCH

echo "Check if Node.js hostedtoolcache folder exist..."
if [ ! -d $NODE_TOOLCACHE_PATH ]; then
    mkdir -p $NODE_TOOLCACHE_PATH
fi

echo "Delete Node.js $NODE_VERSION if installed"
rm -rf $NODE_TOOLCACHE_VERSION_PATH

echo "Create Node.js $NODE_VERSION folder"
mkdir -p $NODE_TOOLCACHE_VERSION_ARCH_PATH

echo "Copy Node.js binaries to hostedtoolcache folder"
cp -R ./* $NODE_TOOLCACHE_VERSION_ARCH_PATH
rm $NODE_TOOLCACHE_VERSION_ARCH_PATH/setup.sh

echo "Create complete file"
touch $NODE_TOOLCACHE_VERSION_PATH/$ARCH.complete
