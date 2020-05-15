START_DATE="$1"
END_DATE=$(date -I -d "$START_DATE + 15 day")
while [ "$START_DATE" != "$END_DATE" ];
do
	echo $START_DATE
	FILE_ID="$(date --date="$ORDER_DATE" +'%Y%m%d')"
beeline -u <details --hivevar reportdate=$START_DATE -e "select 
col1
, col2
, TO_DATE(stop_time) as stop_date
, count(*) as record_count
, sum(case when (xyz like '2%' or (upper(xyz)='SUCCESS' and xyz='404')) THEN 1 else 0 end) as success_count
, sum(unix_timestamp(stop_time) - unix_timestamp(start_time)) as time_diff
from staging.ucc_wsg 
where date_part='$START_DATE' group by col1, col2, TO_DATE(stop_time) " | sed '/+------/d' | sed 's/[[:space:]]\+//g'| sed 's/|\+/,/g' >> /home/extract_$FILE_ID.csv
START_DATE=$(date -I -d "$START_DATE + 1 day")
done