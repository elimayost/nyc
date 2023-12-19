
.shell echo "Cleaning location data"

copy (
  select
    LocationID as location_id,
    Borough as borough,
    Zone as zone,
    service_zone
  from
    read_parquet('/app/data/nyc/bronze/location_data.parquet')
) to '/app/data/nyc/silver/cleaned/location_data.parquet' (format parquet, OVERWRITE_OR_IGNORE 1)
