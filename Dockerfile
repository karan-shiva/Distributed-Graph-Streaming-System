# Base image: ubuntu:22.04
FROM ubuntu:22.04

# ARGs
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG TARGETPLATFORM=linux/amd64,linux/arm64
ARG DEBIAN_FRONTEND=noninteractive

# neo4j 5.5.0 installation and some cleanup
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common && \
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable latest' > /etc/apt/sources.list.d/neo4j.list && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y nano unzip neo4j python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# TODO: Complete the Dockerfile
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk
    
RUN apt-get install -y git
    
RUN mkdir -p /var/lib/neo4j/plugins && \
    chmod 777 /var/lib/neo4j/plugins

RUN wget https://graphdatascience.ninja/neo4j-graph-data-science-2.15.0.jar -P /var/lib/neo4j/plugins/ && \
    chmod 777 var/lib/neo4j/plugins/neo4j-graph-data-science-2.15.0.jar

RUN git clone https://karan-shiva-asu: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@github.com/SP-2025-CSE511-Data-Processing-at-Scale/Project-1-kshivare.git /cse511 && \
cp /cse511/yellow_tripdata_2022-03.parquet /

RUN pip3 install --upgrade pip && \
    pip3 install neo4j pandas pyarrow

RUN echo 'server.config.strict_validation.enabled=false' >> /etc/neo4j/neo4j.conf && \
    echo 'dbms.security.procedures.unrestricted=gds.*' >> /etc/neo4j/neo4j.conf && \
    echo 'dbms.security.procedures.allowlist=gds.*' >> /etc/neo4j/neo4j.conf

RUN neo4j-admin dbms set-initial-password project1phase1

RUN echo "dbms.security.auth_enabled=true" >> /etc/neo4j/neo4j.conf && \
    echo "server.http.listen_address=0.0.0.0:7474" >> /etc/neo4j/neo4j.conf && \
    echo "server.bolt.listen_address=0.0.0.0:7687" >> /etc/neo4j/neo4j.conf


# Run the data loader script
RUN chmod +x /cse511/data_loader.py && \
    neo4j start && \
    python3 /cse511/data_loader.py && \
    neo4j stop

# Expose neo4j ports
EXPOSE 7474 7687

# Start neo4j service and show the logs on container run
CMD ["/bin/bash", "-c", "neo4j start && tail -f /dev/null"]
