CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
CHANNEL1="channel1"
CHANNEL2="channel2"
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
PEER0_ORG3_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

setGlobals() {
  PEER=$1
  ORG=$2
  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org1.example.com:7051
    fi
  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org2.example.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org2.example.com:7051
    fi

  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="Org3MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org3.example.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org3.example.com:7051
    fi
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi
}


echo "Create channel 1\n"
peer channel create -o orderer.example.com:7050 -c $CHANNEL1 -f ./channel-artifacts/channel1.tx --tls true --cafile $ORDERER_CA

echo "Create channel 2\n"
peer channel create -o orderer.example.com:7050 -c $CHANNEL2 -f ./channel-artifacts/channel2.tx --tls true --cafile $ORDERER_CA

echo "Join channel 1\n"
setGlobals 0 1
peer channel join -b $CHANNEL1.block

setGlobals 1 1
peer channel join -b $CHANNEL1.block

setGlobals 0 2
peer channel join -b $CHANNEL1.block

setGlobals 1 2
peer channel join -b $CHANNEL1.block

echo "Join channel 2\n"
setGlobals 0 1
peer channel join -b $CHANNEL2.block

setGlobals 1 1
peer channel join -b $CHANNEL2.block

setGlobals 0 3
peer channel join -b $CHANNEL2.block

setGlobals 1 3
peer channel join -b $CHANNEL2.block

setGlobals 0 1
peer channel update -o orderer.example.com:7050 -c $CHANNEL1 -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA

setGlobals 0 2
peer channel update -o orderer.example.com:7050 -c $CHANNEL1 -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA

setGlobals 0 3
peer channel update -o orderer.example.com:7050 -c $CHANNEL2 -f ./channel-artifacts/Org3MSPanchors.tx --tls true --cafile $ORDERER_CA

setGlobals 0 1
peer channel update -o orderer.example.com:7050 -c $CHANNEL2 -f ./channel-artifacts/Org1MSPanchors1.tx --tls true --cafile $ORDERER_CA

setGlobals 0 1
peer chaincode install -n mycc -v 1.0 -p ${CC_SRC_PATH}

setGlobals 1 1 
peer chaincode install -n mycc -v 1.0 -p ${CC_SRC_PATH}

setGlobals 0 2
peer chaincode install -n mycc -v 1.0 -p ${CC_SRC_PATH}

setGlobals 1 2
peer chaincode install -n mycc -v 1.0 -p ${CC_SRC_PATH}

setGlobals 0 1
peer chaincode install -n other -v 1.0 -p ${CC_SRC_PATH}

setGlobals 1 1
peer chaincode install -n other -v 1.0 -p ${CC_SRC_PATH}

setGlobals 0 3
peer chaincode install -n other -v 1.0 -p ${CC_SRC_PATH}

setGlobals 1 3
peer chaincode install -n other -v 1.0 -p ${CC_SRC_PATH}

setGlobals 0 1
peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA -C $CHANNEL1 -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"

peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA -C $CHANNEL2 -n other -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "AND ('Org1MSP.peer','Org3MSP.peer')"

