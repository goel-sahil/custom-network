export FABRIC_CFG_PATH=${PWD}
CHANNEL1_NAME="channel1"
CHANNEL2_NAME="channel2"
COMPOSE_FILE=docker-compose-cli.yaml
COMPOSE_FILE_COUCH=docker-compose-couch.yaml

echo "Generate Certificates\n"
cryptogen generate --config=./crypto-config.yaml

echo "Generate Artifcats\n"
configtxgen -profile ThreeOrgsOrdererGenesis -channelID sahil -outputBlock ./channel-artifacts/genesis.block

echo "Create Channel\n"
configtxgen -profile Org1Org2 -outputCreateChannelTx ./channel-artifacts/channel1.tx -channelID $CHANNEL1_NAME

configtxgen -profile Org1Org3 -outputCreateChannelTx ./channel-artifacts/channel2.tx -channelID $CHANNEL2_NAME

echo "Anchor Peer for Org 1"
configtxgen -profile Org1Org2 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL1_NAME -asOrg Org1MSP

echo "Anchor Peer for Org 2"
configtxgen -profile Org1Org2 -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL1_NAME -asOrg Org2MSP

echo "Anchor Peer for Org 1"
configtxgen -profile Org1Org3 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors1.tx -channelID $CHANNEL2_NAME -asOrg Org1MSP

echo "Anchor Peer for Org 3"
configtxgen -profile Org1Org3 -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL2_NAME -asOrg Org3MSP

docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up

