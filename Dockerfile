# Ubuntu container image to run our static analyzer
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update
RUN apt-get install -y git unzip curl ca-certificates gnupg

# Install trivy
RUN apt-get install -y wget apt-transport-https gnupg lsb-release
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
RUN echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list
RUN apt-get update
RUN apt-get install -y trivy

# Install node 16
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ENV NODE_MAJOR=16
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install nodejs -y

# Copy files from our repository location to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# The code file to execute when the docker container run
ENTRYPOINT [ "/entrypoint.sh" ]
