
-- Tip percentage are less than 50%
-- Trip duration should be more than a minute and less than three hours.

.shell echo "Enriching data for ${month}/${year}"

copy (
  with pickup_data as (
    select
      *,
      borough as pickup_borough,
      zone as pickup_zone,
      service_zone as pickup_service_zone
    from '/app/data/nyc/silver/cleaned/trip_year=${year}/trip_quarter=*/trip_month=${month}/*.parquet'
    left join '/app/data/nyc/silver/cleaned/location_data.parquet' on pickup_location_id = location_id  
  )

  select
    vendor_id,
    meter_on,
    meter_off,
    passenger_count,
    trip_distance,
    rate_code_id,
    pickup_location_id,
    dropoff_location_id,
    payment_type,
    fare_amount,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee,
    tip_percentage,
    trip_duration,
    trip_year,
    trip_month,
    trip_quarter,
    pickup_borough,
    pickup_zone,
    pickup_service_zone,
    location_data.borough as dropoff_borough,
    location_data.zone as dropoff_zone,
    location_data.service_zone as dropoff_service_zone
  from pickup_data 
  left join '/app/data/nyc/silver/cleaned/location_data.parquet' location_data on dropoff_location_id = location_data.location_id  
    where
      tip_percentage <= 0.5
      and trip_duration > 60
      and trip_duration < 10800  
) to '/app/data/nyc/silver/enriched/' (format parquet, partition_by (trip_year, trip_quarter, trip_month), OVERWRITE_OR_IGNORE 1);
