
install httpfs;
load httpfs;

.shell echo "Getting data for $month/$year
set s3_endpoint='${s3_endpoint}';
set s3_access_key_id='${s3_access_key_id}';
set s3_secret_access_key='${s3_secret_access_key}';

copy (
  select * from read_parquet('https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_${year}-${month}.parquet')
)
to 's3://eli-nyc/bronze/yellow_tripdata_${year}-${month}.parquet' (format parquet, OVERWRITE_OR_IGNORE 1);
.shell echo "Saved data for ${month}/${year}"
