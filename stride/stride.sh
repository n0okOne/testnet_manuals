#!/bin/bash

echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"


sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
STRIDE_PORT=16
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export STRIDE_CHAIN_ID=STRIDE-1" >> $HOME/.bash_profile
echo "export STRIDE_PORT=${STRIDE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$STRIDE_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$STRIDE_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout c53f6c562d9d3e098aab5c27303f41ee055572cb
make build
sudo cp $HOME/stride/build/strided /usr/local/bin

# config
strided config chain-id $STRIDE_CHAIN_ID
strided config keyring-backend test
strided config node tcp://localhost:${STRIDE_PORT}657

# init
strided init $NODENAME --chain-id $STRIDE_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"

# set peers and seeds
SEEDS="baee9ccc2496c2e3bebd54d369c3b788f9473be9@seedv1.poolparty.stridenet.co:26656"
PEERS="f99a118fa5b80485c0c5f04e734fc85b245ce19d@20.7.58.154:16656,bfea1a928ffaaa5c8ceb5625f426a235103ef997@192.46.221.20:16656,fe57762fb3ffa460c24f27580ecf02f5ac2f7284@95.217.83.28:26656,67e98e9b2a3c99f7334d21dce4ab130167e4be40@185.167.96.174:16656,9344f67a8552858363aef42be56e79492e5456b2@65.108.145.145:26656,62166b3d2f45178a8288c87b93193e7409bb1feb@89.58.45.204:26656,4420710617a1cc3ecfe091c2ed1a40dfac71564c@195.201.243.40:26656,97c7e2eeea3f4883e548f6f27db326c6e3872cd1@178.236.129.143:26656,23e259c787fcd3255ebf5dc148c02bd47c6df4de@38.242.135.64:16656,f0c7aaa7bcd159e4fe2775abc5968e3548af866d@34.135.153.30:16656,a61adfacf8b2fca61573a420df70eedb459f7168@194.36.88.39:16656,b0bbb7841bfd8644494d1e90761299afc6cc4f3f@149.102.130.66:16656,4e26c5b8206c116192ceb7f6b5efa176312198ad@185.205.244.117:16656,7caf1e1c356e37d5430709745c08488e2c834db9@136.243.110.52:16656,aee022dea9fd935767550f245e9ead04a0e0b73e@161.97.116.115:26656,bb7a964dd3fa5d7f65df96f9f2980dc1bcd3e3b6@34.77.125.86:16656,49cea10c834374755d3daab130a7efe4169082d7@149.102.139.101:16656,ca5bdd030ea211dddf3f9eb3c778498e1f464e9f@38.242.222.245:16656,2928bce24cabc63af0f03a72752ad4c0039df40b@46.0.203.78:23356,e1907b587b9859bd0669c60ab41464cdc6df1ba1@167.172.33.220:16656,a4524deccb19b0b60a08c4cf70e0f48353c9086c@113.30.189.25:16656,c24faf46b3d1b83729a9fbfcac30ee85c0043489@155.248.182.26:16656,4894863befa8edb312608c2ffc3429a96873586d@116.202.112.175:16656,e18082de3ac17d2e10c6bd9ce33ea101e8a99f8d@176.213.213.119:16656,39242860e603f31c000b90cbf756ad7270b40a96@20.223.147.37:16656,137f72eecbc6193a207faafe4a38805cf758b65b@40.76.99.149:16656,4c33f5e89938e96e0eddc7b57034b511d2735928@149.102.141.89:16656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${STRIDE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${STRIDE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${STRIDE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${STRIDE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${STRIDE_PORT}660\"%" $HOME/.stride/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${STRIDE_PORT}317\"%; s%^address = \":8080\"%address = \":${STRIDE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${STRIDE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${STRIDE_PORT}091\"%" $HOME/.stride/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.stride/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ustrd\"/" $HOME/.stride/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.stride/config/config.toml

# reset
strided tendermint unsafe-reset-all --home $HOME/.stride

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/strided.service > /dev/null <<EOF
[Unit]
Description=stride
After=network-online.target

[Service]
User=$USER
ExecStart=$(which strided) start --home $HOME/.stride
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable strided
sudo systemctl restart strided

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u strided -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${STRIDE_PORT}657/status | jq .result.sync_info\e[0m"
