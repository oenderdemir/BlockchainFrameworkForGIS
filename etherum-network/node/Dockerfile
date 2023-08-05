FROM ubuntu:latest

RUN apt-get update \
     && apt-get install -y wget software-properties-common \
     && rm -rf /var/lib/apt/lists/*

WORKDIR "/root"

RUN add-apt-repository -y ppa:ethereum/ethereum

ARG binary
RUN apt-get update \
     && apt-get install -y ethereum

ARG password
ARG privatekey
RUN echo $password > ~/.accountpassword
RUN echo $privatekey > ~/.privatekey
ADD ./genesis.json ./genesis.json
RUN geth init genesis.json
RUN geth account import --password ~/.accountpassword  ~/.privatekey

ENV address=""
ENV bootnodeId=""
ENV bootnodeIp=""


CMD exec geth --bootnodes "enode://$bootnodeId@$bootnodeIp:30301" --networkid "6660001" --verbosity=4  --syncmode=full --allow-insecure-unlock --http --http.addr "0.0.0.0" --http.corsdomain '*' --http.port '8545' --http.api  eth,net,web3,personal  --graphql --unlock "0x3590aca93338b0721966a8d0c96ebf2c4c87c544" --password ~/.accountpassword

EXPOSE 8545
EXPOSE 30303
