#!/usr/bin/env bash

export version="$(curl -sL https://github.com/zardoy/minecraft-web-client/releases | grep -oP "v[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1)"
export node_version="$(nvm ls-remote | tr -s ' ' | sed 's|^ ||g' | grep -i latest | grep -i lts | cut -d ' ' -f1 | tr -d 'v' | sort -V | tail -n 1)"
export url="https://github.com/zardoy/minecraft-web-client/releases/download/${version}/self-host.zip"
export repo="/minecraft-on-codespaces"
export codespace="$(echo $(gh codespace list | grep -i ${repo}) | tr -s ' ' | cut -d ' ' -f1)"

sudo apt install wget -y

nvm install $node_version
nvm use $node_version
nvm alias default $node_version

wget $url
unzip self-host.zip
rm -r dist
cp server.js proxy.js
mv server.js client.js
sed -i 's|8080|6767|g' proxy.js

cat << "EOF" >> ~/.profile
node proxy.js &
export repo="/minecraft-on-codespaces"
export codespace="$(echo $(gh codespace list | grep -i ${repo}) | tr -s ' ' | cut -d ' ' -f1)"
export proxy="$(echo $(gh codespace ports -c $codespace | grep -i $codespace) | tr -s ' ' | cut -d ' ' -f3,4 | grep -P '.*-6767\.app')"
sed -i "s|defaultProxy.*|defaultProxy: \"${proxy}:443\",|g" client.js
node client.js &
EOF

source ~/.profile
