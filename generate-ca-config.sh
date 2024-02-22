#!/bin/bash

source register-enroll-org.sh
source registerEnrollOrderer.sh

mkdir -p "compose/compose-ca/"
mkdir -p "compose/compose-peers/"

NETWORK_NAME="port-network"

declare -a orderers=(
    "orderer:OrdererMSP:7050:7053:9443"
)

declare -a peers=(
    "couchdb0:4984:peer0:buyer:8051:8052:9444:BuyerMSP"
    "couchdb1:6984:peer0:buyerbank:9051:9052:9445:BuyerBankMSP"
    "couchdb2:7984:peer0:buyercp:1051:1052:9446:BuyerCPMSP"
    "couchdb3:8984:peer0:middlebank:1151:1152:9447:MiddleBankMSP"
    "couchdb4:9984:peer0:seller:1251:1252:9448:SellerMSP"
    "couchdb5:1084:peer0:sellerbank:1351:1352:9449:SellerBankMSP"
    "couchdb6:1184:peer0:sellercp:1451:1452:9450:SellerCPMSP"
)

declare -a ca_orgs=(
    "Buyer:buyer:8054:18054"
    "BuyerBank:buyerbank:9054:19054"
    "Buyercp:buyercp:1054:11054"
    "MiddleBank:middlebank:1154:11154"
    "Seller:seller:1254:11254"
    "SellerBank:sellerbank:1354:11354"
    "SellerCP:sellercp:1454:11454"
)

declare -a ca_orderer_orgs=(
    "Orderer:orderer:7054:17054"
)

function generate_ca_config {
    local CANAME=$1
    local ORGNAMEINSMALL=$2

    if [ "$CANAME" == "Orderer" ]; then
        sed -e "s/\${CANAME}/$CANAME/g" \
            fabric-ca-orderer-template.yaml
    else
        sed -e "s/\${CANAME}/$CANAME/g" \
            -e "s/\${ORGNAMEINSMALL}/$ORGNAMEINSMALL/g" \
            fabric-ca-template.yaml
    fi
}

function generate_compose_file {
    local ORGNAMEINSMALL=$1
    local PORT1=$2
    local PORT2=$3
    local NETWORK=$4

    if [ "$CANAME" == "Orderer" ]; then
        sed -e "s/\${ORGNAMEINSMALL}/$ORGNAMEINSMALL/g" \
            -e "s/\${PORT1}/$PORT1/g" \
            -e "s/\${PORT2}/$PORT2/g" \
            -e "s/\${NETWORK}/$NETWORK/g" \
            compose-ca-orderer-template.yaml
    else
        sed -e "s/\${ORGNAMEINSMALL}/$ORGNAMEINSMALL/g" \
            -e "s/\${PORT1}/$PORT1/g" \
            -e "s/\${PORT2}/$PORT2/g" \
            -e "s/\${NETWORK}/$NETWORK/g" \
            compose-ca-org-template.yaml
    fi
}

function create_ca_orderer {
    for org_info in "${ca_orderer_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        mkdir -p "organizations/fabric-ca/${ORGNAMEINSMALL}Org"

        generate_ca_config "$CANAME" "$ORGNAMEINSMALL" >"organizations/fabric-ca/${ORGNAMEINSMALL}Org/fabric-ca-server-config.yaml"

        generate_compose_file "$ORGNAMEINSMALL" "$PORT1" "$PORT2" "$NETWORK_NAME">"compose/compose-ca/compose-ca-${ORGNAMEINSMALL}.yaml"
    done
}

function create_ca_org {
    for org_info in "${ca_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        mkdir -p "organizations/fabric-ca/${ORGNAMEINSMALL}"
        generate_ca_config "$CANAME" "$ORGNAMEINSMALL" >"organizations/fabric-ca/${ORGNAMEINSMALL}/fabric-ca-server-config.yaml"
        generate_compose_file "$ORGNAMEINSMALL" "$PORT1" "$PORT2" "$NETWORK_NAME">"compose/compose-ca/compose-ca-${ORGNAMEINSMALL}.yaml"
    done
}

function ca_up {
    local command_string="docker-compose"

    for org_info in "${ca_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        command_string+=" -f compose/compose-ca/compose-ca-${ORGNAMEINSMALL}.yaml"
    done

    for org_info in "${ca_orderer_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        command_string+=" -f compose/compose-ca/compose-ca-${ORGNAMEINSMALL}.yaml"
    done

    command_string+=" up -d"

    # Execute the generated command string
    eval "$command_string"
}

function down {
    local command_string="docker-compose"

    for org_info in "${ca_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        command_string+=" -f compose/compose-ca/compose-ca-${ORGNAMEINSMALL}.yaml"
    done

    for org_info in "${ca_orderer_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        command_string+=" -f compose/compose-ca/compose-ca-${ORGNAMEINSMALL}.yaml"
    done

    command_string+=" down -v"

    eval "$command_string"

    command_string="docker-compose"

    for peer_info in "${peers[@]}"; do
        IFS=':' read -r COUCHDB_NAME COUCHDB_PORT PEER_NAME PEER_ORG PEER_PORT1 PEER_PORT2 PEER_PORT3 PEER_MSP <<<"$peer_info"

        command_string+=" -f compose/compose-peers/compose-${PEER_NAME}-${PEER_ORG}.yaml"
    done

    for orderer_info in "${orderers[@]}"; do
        IFS=':' read -r ORDERER_NAME ORDERER_MSP ORDERER_PORT1 ORDERER_PORT2 ORDERER_PORT3  <<<"$orderer_info"

        command_string+=" -f compose/compose-peers/compose-${ORDERER_NAME}.yaml"
    done

    command_string+=" -f compose/compose-peers/compose-cli.yaml"

    command_string+=" down -v"

    eval "$command_string"
    

    # Execute the generated command string
    # eval "$command_string"
    # docker-compose -f compose/compose-ca/compose-ca-buyer.yaml down -v --remove-orphans
    # docker-compose -f compose/compose-ca/compose-ca-buyer.yaml -f compose/compose-ca/compose-ca-buyerbank.yaml -f compose/compose-ca/compose-ca-buyercp.yaml -f compose/compose-ca/compose-ca-middlebank.yaml -f compose/compose-ca/compose-ca-orderer.yaml -f compose/compose-ca/compose-ca-seller.yaml -f compose/compose-ca/compose-ca-sellerbank.yaml -f compose/compose-ca/compose-ca-sellercp.yaml down -v
}

function create_peers_orderers {
    for peer_info in "${peers[@]}"; do
        IFS=':' read -r COUCHDB_NAME COUCHDB_PORT PEER_NAME PEER_ORG PEER_PORT1 PEER_PORT2 PEER_PORT3 PEER_MSP <<<"$peer_info"

        sed -e "s/\${NETWORK_NAME}/$NETWORK_NAME/g" \
            -e "s/\${COUCHDB_NAME}/$COUCHDB_NAME/g" \
            -e "s/\${COUCHDB_PORT}/$COUCHDB_PORT/g" \
            -e "s/\${PEER_NAME}/$PEER_NAME/g" \
            -e "s/\${PEER_ORG}/$PEER_ORG/g" \
            -e "s/\${PEER_PORT1}/$PEER_PORT1/g" \
            -e "s/\${PEER_PORT2}/$PEER_PORT2/g" \
            -e "s/\${PEER_PORT3}/$PEER_PORT3/g" \
            -e "s/\${PEER_MSP}/$PEER_MSP/g" \
            compose-peer-org-template.yaml > "compose/compose-peers/compose-${PEER_NAME}-${PEER_ORG}.yaml"
    done

    for orderer_info in "${orderers[@]}"; do
        IFS=':' read -r ORDERER_NAME ORDERER_MSP ORDERER_PORT1 ORDERER_PORT2 ORDERER_PORT3  <<<"$orderer_info"

        sed -e "s/\${NETWORK_NAME}/$NETWORK_NAME/g" \
            -e "s/\${ORDERER_NAME}/$ORDERER_NAME/g" \
            -e "s/\${ORDERER_MSP}/$ORDERER_MSP/g" \
            -e "s/\${ORDERER_PORT1}/$ORDERER_PORT1/g" \
            -e "s/\${ORDERER_PORT2}/$ORDERER_PORT2/g" \
            -e "s/\${ORDERER_PORT3}/$ORDERER_PORT3/g" \
            compose-orderer-org-template.yaml > "compose/compose-peers/compose-${ORDERER_NAME}.yaml"
    done

    local TEXT_STRING=""
    for peer_info in "${peers[@]}"; do
        IFS=':' read -r COUCHDB_NAME COUCHDB_PORT PEER_NAME PEER_ORG PEER_PORT1 PEER_PORT2 PEER_PORT3 PEER_MSP <<<"$peer_info"
        
        TEXT_STRING+="- ${PEER_NAME}.${PEER_ORG}.example.com \n      "
    done

    sed -e "s/\${NETWORK_NAME}/$NETWORK_NAME/g" \
        -e "s/\${TEXT_STRING}/$TEXT_STRING/g" \
        compose-cli-template.yaml > "compose/compose-peers/compose-cli.yaml"
}

function peer_up {
    # docker-compose -f compose/compose-with-couch.yaml up -d
    local command_string="docker-compose"

    for peer_info in "${peers[@]}"; do
        IFS=':' read -r COUCHDB_NAME COUCHDB_PORT PEER_NAME PEER_ORG PEER_PORT1 PEER_PORT2 PEER_PORT3 PEER_MSP <<<"$peer_info"

        command_string+=" -f compose/compose-peers/compose-${PEER_NAME}-${PEER_ORG}.yaml"
    done

    for orderer_info in "${orderers[@]}"; do
        IFS=':' read -r ORDERER_NAME ORDERER_MSP ORDERER_PORT1 ORDERER_PORT2 ORDERER_PORT3  <<<"$orderer_info"

        command_string+=" -f compose/compose-peers/compose-${ORDERER_NAME}.yaml"
    done

    command_string+=" -f compose/compose-peers/compose-cli.yaml"

    command_string+=" up -d"

    # Execute the generated command string
    eval "$command_string"
}

function create_register_enroll_org {
    for org_info in "${ca_orgs[@]}"; do
        IFS=':' read -r CANAME ORGNAMEINSMALL PORT1 PORT2 <<<"$org_info"
        registerEnrollOrg $ORGNAMEINSMALL $PORT1 $PORT2
    done

    createOrderer

}

function cleanup {
    echo "Cleaning up..."

    rm -rf channel-artifacts
    rm -rf organizations/peerOrganizations
    rm -rf organizations/ordererOrganizations
    sudo rm -rf organizations/fabric-ca/*
    rm -rf compose/compose-ca
    rm -rf compose/compose-peers
    echo "Cleanup completed."
}

function remove_docker_images {
    docker images | grep "orderplaceandletterofcredit" | awk '{print $3}' | xargs docker rmi
    docker images | grep "finalpapercontract" | awk '{print $3}' | xargs docker rmi
    docker images | grep "portcontract" | awk '{print $3}' | xargs docker rmi
}
