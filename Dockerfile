# Ubuntu container image to run our static analyzer
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update
RUN apt-get install -y git unzip curl

# Install node 16
RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN chmod a+x ./nodesource_setup.sh
RUN ./nodesource_setup.sh
RUN apt-get install -y nodejs

# Copy files from our repository location to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# The code file to execute when the docker container run
ENTRYPOINT [ "/entrypoint.sh" ]