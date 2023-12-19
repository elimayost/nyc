
.shell echo "Aggregating total pickus by hour"

copy (
  select
    hour(meter_on) as pickup_hour,
    count(*) as total
  from
    read_parquet('data/nyc/silver/cleaned/trip_year=*/trip_quarter=*/trip_month=*/*.parquet')
  group by pickup_hour
) to 'data/nyc/gold/total_trips_by_hour.parquet' (format parquet, OVERWRITE_OR_IGNORE 1)
