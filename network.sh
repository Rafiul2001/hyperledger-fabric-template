#!/bin/bash

# Function to set environment variables for a peer
set_peer_env() {
    export FABRIC_CFG_PATH=${PWD}/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_ADDRESS=$1
    export CORE_PEER_LOCALMSPID=$2
    export CORE_PEER_TLS_ROOTCERT_FILE=$3
    export CORE_PEER_MSPCONFIGPATH=$4
}

# Function to join a peer to a channel
join_peer_to_channel() {
    set_peer_env $1 $2 $3 $4

    peer channel join -b ./channel-artifacts/$5.block
}

# Function to get channel info for a peer
get_channel_info() {
    set_peer_env $1 $2 $3 $4

    peer channel getinfo -c $5
}

# Create Genesis Block:
export FABRIC_CFG_PATH=${PWD}/compose/docker/peercfg
cd configtx/
configtxgen -profile SevenOrganizationsChannel -outputBlock ../channel-artifacts/portchannel.block -channelID portchannel
cd ..

# Join the orderer to all channels:
# # Orderer
echo "Joining"
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

osnadmin channel join --channelID portchannel --config-block ./channel-artifacts/portchannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"



# Join peers to the channel:
join_peer_to_channel localhost:8051 "BuyerMSP" "${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/buyer.example.com/users/Admin@buyer.example.com/msp" portchannel

join_peer_to_channel localhost:9051 "BuyerBankMSP" "${PWD}/organizations/peerOrganizations/buyerbank.example.com/peers/peer0.buyerbank.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/buyerbank.example.com/users/Admin@buyerbank.example.com/msp" portchannel

join_peer_to_channel localhost:1051 "BuyerCPMSP" "${PWD}/organizations/peerOrganizations/buyercp.example.com/peers/peer0.buyercp.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/buyercp.example.com/users/Admin@buyercp.example.com/msp" portchannel

join_peer_to_channel localhost:1151 "MiddleBankMSP" "${PWD}/organizations/peerOrganizations/middlebank.example.com/peers/peer0.middlebank.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/middlebank.example.com/users/Admin@middlebank.example.com/msp" portchannel

join_peer_to_channel localhost:1251 "SellerMSP" "${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/seller.example.com/users/Admin@seller.example.com/msp" portchannel

join_peer_to_channel localhost:1351 "SellerBankMSP" "${PWD}/organizations/peerOrganizations/sellerbank.example.com/peers/peer0.sellerbank.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/sellerbank.example.com/users/Admin@sellerbank.example.com/msp" portchannel

join_peer_to_channel localhost:1451 "SellerCPMSP" "${PWD}/organizations/peerOrganizations/sellercp.example.com/peers/peer0.sellercp.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/sellercp.example.com/users/Admin@sellercp.example.com/msp" portchannel


# Peer Channel Info:
get_channel_info localhost:8051 "BuyerMSP" "${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/buyer.example.com/users/Admin@buyer.example.com/msp" portchannel

get_channel_info localhost:9051 "BuyerBankMSP" "${PWD}/organizations/peerOrganizations/buyerbank.example.com/peers/peer0.buyerbank.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/buyerbank.example.com/users/Admin@buyerbank.example.com/msp" portchannel

get_channel_info localhost:1051 "BuyerCPMSP" "${PWD}/organizations/peerOrganizations/buyercp.example.com/peers/peer0.buyercp.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/buyercp.example.com/users/Admin@buyercp.example.com/msp" portchannel

get_channel_info localhost:1151 "MiddleBankMSP" "${PWD}/organizations/peerOrganizations/middlebank.example.com/peers/peer0.middlebank.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/middlebank.example.com/users/Admin@middlebank.example.com/msp" portchannel

get_channel_info localhost:1251 "SellerMSP" "${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/seller.example.com/users/Admin@seller.example.com/msp" portchannel

get_channel_info localhost:1351 "SellerBankMSP" "${PWD}/organizations/peerOrganizations/sellerbank.example.com/peers/peer0.sellerbank.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/sellerbank.example.com/users/Admin@sellerbank.example.com/msp" portchannel

get_channel_info localhost:1451 "SellerCPMSP" "${PWD}/organizations/peerOrganizations/sellercp.example.com/peers/peer0.sellercp.example.com/tls/ca.crt" "${PWD}/organizations/peerOrganizations/sellercp.example.com/users/Admin@sellercp.example.com/msp" portchannel
