FROM python:3-alpine

ARG VERSION=undefined
ENV VERSION ${VERSION}

# Install curl and certificates
RUN apk add --no-cache curl openssl ca-certificates

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

COPY docker-entrypoint.py /
COPY requirements.txt /

RUN pip install -r /requirements.txt

ENTRYPOINT ["python", "-u", "docker-entrypoint.py"]
