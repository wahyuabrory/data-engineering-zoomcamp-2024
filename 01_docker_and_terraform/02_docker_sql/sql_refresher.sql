-- Joining yellow_taxi_data with taxi_zones (implicit inner join)
select
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_loc",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_loc"
from
	yellow_taxi_data t,
	taxi_zones zpu,
	taxi_zones zdo
where
	t."PULocationID" = zpu."LocationID"
	and t."DOLocationID" = zdo."LocationID"
limit
	100;

-- Joining yellow_taxi_data with taxi_zones (explicit inner join)
select
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_loc",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_loc"
from
	yellow_taxi_data t
	join taxi_zones zpu on t."PULocationID" = zpu."LocationID"
	Join taxi_zones zdo on t."DOLocationID" = zdo."LocationID"
limit
	100;

-- You can try delete some locationID in the taxi_zones table to see the difference

-- Checkif any IDs are not present in the lookup zones database
SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
FROM
	yellow_taxi_data t
WHERE
	"PULocationID" NOT IN (SELECT "LocationID" FROM taxi_zones)
	OR "DOLocationID" NOT IN (SELECT "LocationID" FROM taxi_zones)
LIMIT 100;

-- group by aggregates 
SELECT 
    CAST(tpep_pickup_datetime AS DATE) AS "day", -- removin hour time
    COUNT(1)
FROM 
    yellow_taxi_data t 
GROUP BY
    CAST(tpep_pickup_datetime AS DATE)
ORDER BY
    "day" asc

-- gorup by order by most count 
SELECT 
    CAST(tpep_pickup_datetime AS DATE) AS "day", -- removin hour time
    COUNT(1)
FROM 
    yellow_taxi_data t 
GROUP BY
    CAST(tpep_pickup_datetime AS DATE)
ORDER BY
    count(1) DESC

-- other aggregates 
-- we can see some district drop off location from this query
SELECT 
    CAST(tpep_pickup_datetime AS DATE) AS "day", -- removin hour time
    CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_loc",
    COUNT(1) AS "count",
    MAX(total_amount) as "max_amount",
    MAX(passenger_count) as "max_passangers"
FROM 
    yellow_taxi_data t 
    JOIN taxi_zones zdo ON t."DOLocationID" = zdo."LocationID"
GROUP BY
	CONCAT(zdo."Borough", ' / ', zdo."Zone"),
    CAST(tpep_pickup_datetime AS DATE)
ORDER BY
    count(1) DESC