# Ubuntu container image to run our static analyzer
FROM ghcr.io/datadog/datadog-static-analyzer:latest

# Copy files from our repository location to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# The code file to execute when the docker container run
ENTRYPOINT [ "/entrypoint.sh" ]
