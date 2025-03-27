# Start from a base image
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    bash \
    openssh-client \
    git \
    jq \
    coreutils \
    wget \
    gnupg \
    software-properties-common \
    && apt-get clean

# Add MongoDB repository and install tools & shell
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && apt-get install -y \
    mongodb-database-tools \
    mongodb-mongosh \
    && apt-get clean

# Ensure mongo binary is in the PATH -- symlink 'mongo' -> 'mongosh'
RUN ln -s /usr/bin/mongosh /usr/local/bin/mongo && \
    /usr/local/bin/mongo --version

# Install PostgreSQL client
RUN wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && apt-get install -y postgresql-client-16 && \
    apt-get clean

# Install MinIO client (mc)
RUN curl -sSL -o /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/bin/mc

# Install kubectl
#RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
#    chmod +x ./kubectl && \
#    mv ./kubectl /usr/local/bin/kubectl

# Set the working directory
WORKDIR /root

# Default command
ENTRYPOINT ["/bin/bash"]
