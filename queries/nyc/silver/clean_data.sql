
-- Pickup/drop-off date and time are strictly within the selected month period.
-- Pickup/drop-off Location ID should be within the range of [1, 263].
-- Passenger count should at least 1 and less than 7 as the maximum number of passengers allowed by law is 6.
-- Trip distance should greater than 0 miles but less than 100 miles.
-- Fare amount should be at least $2.5 but at most $250.

.shell echo "Cleaning data for ${month}/${year}"

copy (
  select
    VendorID as vendor_id,
    tpep_pickup_datetime as meter_on,
    tpep_dropoff_datetime as meter_off,
    passenger_count::integer as passenger_count,
    trip_distance,
    RatecodeID as rate_code_id,
    PULocationID as pickup_location_id,
    DOLocationID as dropoff_location_id,
    payment_type,
    fare_amount,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee,
    tip_amount/fare_amount as tip_percentage,
    date_diff('second', meter_on, meter_off) as trip_duration,
    year(meter_on) as trip_year,
    lpad(month(meter_on), 2, 0) as trip_month,
    quarter(meter_on) as trip_quarter
  from
    read_parquet('/app/data/nyc/bronze/yellow_tripdata_${year}-${month}.parquet')
  where
    trip_year = ${year}
    and trip_month = ${month}
    and pickup_location_id >= 1
    and pickup_location_id <= 263
    and dropoff_location_id >= 1
    and dropoff_location_id <= 263
    and passenger_count >= 1
    and passenger_count <= 7
    and trip_distance > 0
    and trip_distance <= 100
    and fare_amount >= 2.5
    and fare_amount <= 250
) to '/app/data/nyc/silver/cleaned/' (format parquet, partition_by (trip_year, trip_quarter, trip_month), OVERWRITE_OR_IGNORE 1)
