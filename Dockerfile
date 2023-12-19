
FROM debian

RUN apt-get -y update && apt-get -y install wget unzip rclone gettext bc

RUN wget https://github.com/duckdb/duckdb/releases/download/v0.9.1/duckdb_cli-linux-amd64.zip \
  && unzip duckdb_cli-linux-amd64.zip \
  && rm -f duckdb_cli-linux-amd64.zip \
  && mv duckdb /usr/local/bin/

SHELL ["/bin/bash", "-ec"]

RUN mkdir -p /app /app/{queries,pipelines} /app/data/nyc/{bronze,silver,gold} /app/data/nyc/silver/{cleaned,enriched}

COPY queries /app/queries/
COPY pipelines /app/pipelines/
