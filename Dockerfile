FROM python:3-slim-stretch

ARG VERSION=undefined
ENV VERSION ${VERSION}

# Install curl and certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

COPY docker_entrypoint.py /
COPY requirements.txt /

RUN pip install -r /requirements.txt

ENTRYPOINT ["python", "-u", "docker_entrypoint.py"]
