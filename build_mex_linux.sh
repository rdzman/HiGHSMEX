docker build --progress=plain -t highs-builder build
docker create --name highs-container highs-builder

docker cp highs-container:/root/HiGHSMEX/highsmex.mexa64 ./highsmex.mexa64
docker rm -f highs-container