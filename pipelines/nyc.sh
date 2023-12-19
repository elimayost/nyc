#!/usr/bin/env bash

log(){
  level="$1"
  message="$2"

  now=$(date +"%d/%m/%Y %H:%M:%S")

  echo "${now}|${level}|${message}"
}

usage(){
  echo "usage: $0 [MONTH | 01..12] [YEAR | YYYY]"
  exit 1
}

IFS=" " read month year <<< "$1"
quarter=$(echo "($month - 1)/3 + 1" | bc)

log "INFO" "Getting data for ${month}/${year}"
month=$month year=$year envsubst < /app/queries/nyc/bronze/get_data.sql | duckdb && rclone copy -P /app/data/nyc/bronze/yellow_tripdata_${year}-${month}.parquet nyc:/nyc/bronze

log "INFO" "Getting location data"
month=$month year=$year envsubst < /app/queries/nyc/bronze/get_location_data.sql | duckdb && rclone copy -P /app/data/nyc/bronze/location_data.parquet nyc:/nyc/bronze

#rclone copyto -P nyc:/nyc/bronze/location_data.parquet /app/data/nyc/bronze/location_data.parquet

log "INFO" "Cleaning location data"
month=$month year=$year envsubst < /app/queries/nyc/silver/clean_location_data.sql | duckdb && rclone copy -P /app/data/nyc/silver/cleaned/location_data.parquet nyc:/nyc/silver/cleaned/ 

#rclone copyto -P nyc:/nyc/bronze/yellow_tripdata_${year}-${month}.parquet /app/data/nyc/bronze/yellow_tripdata_${year}-${month}.parquet 

log "INFO" "Cleaning data for ${month}/${year}"
month=$month year=$year envsubst < /app/queries/nyc/silver/clean_data.sql | duckdb && rclone copy -P --create-empty-src-dirs /app/data/nyc/silver/cleaned/trip_year=${year}/trip_quarter=${quarter}/trip_month=${month}/ nyc:/nyc/silver/cleaned/trip_year=${year}/trip_quarter=${quarter}/trip_month=${month}/

log "INFO" "Enriching data for ${month}/${year}"
month=$month year=$year envsubst < /app/queries/nyc/silver/enrich_data.sql | duckdb && rclone copy -P --create-empty-src-dirs /app/data/nyc/silver/enriched/trip_year=${year}/trip_quarter=${quarter}/trip_month=$(sed 's/^0*//' <<< ${month})/ nyc:/nyc/silver/enriched/trip_year=${year}/trip_quarter=${quarter}/trip_month=$(sed 's/^0*//' <<< ${month})/

