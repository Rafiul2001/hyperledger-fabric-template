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

ORG=organicfood
ORGC=OrganicFood
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/organicfood.example.com/tlsca/tlsca.organicfood.example.com-cert.pem
CAPEM=organizations/peerOrganizations/organicfood.example.com/ca/ca.organicfood.example.com-cert.pem

echo "$(json_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/organicfood.example.com/connection-organicfood.json
echo "$(yaml_ccp $ORG $ORGC $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/organicfood.example.com/connection-organicfood.yaml