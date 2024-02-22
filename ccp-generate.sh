#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
    	-e "s/\${ORGC}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGC}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=buyer
ORGC=Buyer
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/buyer.example.com/tlsca/tlsca.buyer.example.com-cert.pem
CAPEM=organizations/peerOrganizations/buyer.example.com/ca/ca.buyer.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/buyer.example.com/connection-buyer.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/buyer.example.com/connection-buyer.yaml

ORG=buyerbank
ORGC=BuyerBank
P0PORT=9051
CAPORT=9054
PEERPEM=organizations/peerOrganizations/buyerbank.example.com/tlsca/tlsca.buyerbank.example.com-cert.pem
CAPEM=organizations/peerOrganizations/buyerbank.example.com/ca/ca.buyerbank.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/buyerbank.example.com/connection-buyerbank.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/buyerbank.example.com/connection-buyerbank.yaml

ORG=buyercp
ORGC=BuyerCP
P0PORT=1051
CAPORT=1054
PEERPEM=organizations/peerOrganizations/buyercp.example.com/tlsca/tlsca.buyercp.example.com-cert.pem
CAPEM=organizations/peerOrganizations/buyercp.example.com/ca/ca.buyercp.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/buyercp.example.com/connection-buyercp.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/buyercp.example.com/connection-buyercp.yaml

ORG=middlebank
ORGC=MiddleBank
P0PORT=1151
CAPORT=1154
PEERPEM=organizations/peerOrganizations/middlebank.example.com/tlsca/tlsca.middlebank.example.com-cert.pem
CAPEM=organizations/peerOrganizations/middlebank.example.com/ca/ca.middlebank.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/middlebank.example.com/connection-middlebank.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/middlebank.example.com/connection-middlebank.yaml

ORG=seller
ORGC=Seller
P0PORT=1251
CAPORT=1254
PEERPEM=organizations/peerOrganizations/seller.example.com/tlsca/tlsca.seller.example.com-cert.pem
CAPEM=organizations/peerOrganizations/seller.example.com/ca/ca.seller.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/seller.example.com/connection-seller.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/seller.example.com/connection-seller.yaml

ORG=sellerbank
ORGC=SellerBank
P0PORT=1351
CAPORT=1354
PEERPEM=organizations/peerOrganizations/sellerbank.example.com/tlsca/tlsca.sellerbank.example.com-cert.pem
CAPEM=organizations/peerOrganizations/sellerbank.example.com/ca/ca.sellerbank.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/sellerbank.example.com/connection-sellerbank.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/sellerbank.example.com/connection-sellerbank.yaml

ORG=sellercp
ORGC=SellerCP
P0PORT=1451
CAPORT=1454
PEERPEM=organizations/peerOrganizations/sellercp.example.com/tlsca/tlsca.sellercp.example.com-cert.pem
CAPEM=organizations/peerOrganizations/sellercp.example.com/ca/ca.sellercp.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/sellercp.example.com/connection-sellercp.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/sellercp.example.com/connection-sellercp.yaml
