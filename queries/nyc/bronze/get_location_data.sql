
install httpfs;
load httpfs;

.shell echo "Getting location data"
create table if not exists location_data as (
  select
    *
  from
    'https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv'
);

.shell echo "Saving location data"

copy location_data to '/app/data/nyc/bronze/location_data.parquet' (format parquet, OVERWRITE_OR_IGNORE 1);
