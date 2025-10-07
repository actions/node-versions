tar -xf node-$VERSION-linux-x64.tar.xz
sudo mv node-$VERSION-linux-x64 /opt/nodejs
sudo ln -s /opt/nodejs/bin/node /usr/local/bin/node
sudo ln -s /opt/nodejs/bin/npm /usr/local/bin/npm
