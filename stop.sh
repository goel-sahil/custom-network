rm -rf ./channel-artifacts/*
rm -rf ./crypto-config/*
docker rm -f $(docker ps -aq)
docker network prune
docker volume prune
