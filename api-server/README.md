### Build
docker build -t api-server .

### Run
docker run --rm api-server -v /config.py:/server/config.py -p 1234:1234