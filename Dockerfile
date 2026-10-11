# syntax=docker/dockerfile:1.7
#
# PCOM - DI - Airflow
# -------------------
# Apache Airflow 2.11.0 with Java 17, Spark 3.5.3, and a data/ML toolset
# (Spark provider, torch CPU, tensorflow-cpu, langchain, sentence-transformers)
# for the NNP Data Ingestion components.
#
# Build:
#   docker build -t pcom-di-airflow:2.11.0 .

FROM apache/airflow:2.11.0

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION="2.11.0"

LABEL org.opencontainers.image.title="pcom-di-airflow" \
      org.opencontainers.image.description="Apache Airflow 2.11.0 with Java 17, Spark 3.5.3, and data/ML tooling for NNP Data Ingestion." \
      org.opencontainers.image.vendor="Nubo Native Platform" \
      org.opencontainers.image.source="https://github.com/NNP-Platform-Components-PCOM/PCOM-DI-Airflow" \
      org.opencontainers.image.url="https://github.com/NNP-Platform-Components-PCOM/PCOM-DI-Airflow" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

USER root

# Java 17 (Bookworm-compatible) and wget - required for Spark install.
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Spark 3.5.3 binary distribution (provides spark-submit + spark-core jar)
ENV SPARK_VERSION=3.5.3
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark

RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    chown -R airflow:root ${SPARK_HOME}

ENV PATH=$SPARK_HOME/bin:$PATH

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
