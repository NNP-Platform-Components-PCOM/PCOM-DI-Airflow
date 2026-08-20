# syntax=docker/dockerfile:1.7
#
# PCOM - DI - Airflow
# -------------------
# Apache Airflow 2.11.0 with Java 17 and a data/ML toolset (Spark provider,
# torch CPU, tensorflow-cpu, langchain, sentence-transformers) for the NNP
# Data Ingestion components.
#
# Build:
#   docker build -t pcom-di-airflow:2.11.0 .

FROM apache/airflow:2.11.0

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION="2.11.0"

LABEL org.opencontainers.image.title="pcom-di-airflow" \
      org.opencontainers.image.description="Apache Airflow 2.11.0 with Java 17 and data/ML tooling for NNP Data Ingestion." \
      org.opencontainers.image.vendor="Nubo Native Platform" \
      org.opencontainers.image.source="https://github.com/NNP-Platform-Components-PCOM/PCOM-DI-Airflow" \
      org.opencontainers.image.url="https://github.com/NNP-Platform-Components-PCOM/PCOM-DI-Airflow" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

USER root

# Java 17 (Bookworm-compatible) - required for Spark too.
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

USER airflow

# CPU-only torch first, so sentence-transformers uses it instead of the CUDA build.
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

RUN pip install --no-cache-dir \
    airflow-code-editor \
    black \
    isort \
    fs-s3fs \
    fs-gcsfs \
    langchain_text_splitters \
    langchain_huggingface \
    sentence-transformers \
    apache-airflow-providers-apache-spark \
    keras \
    tensorflow-cpu \
    pyspark==3.5.3
