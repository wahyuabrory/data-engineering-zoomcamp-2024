# Week 1 Homework
In this homework we'll prepare docker environment, postgres database, and some terraform basic code

## Question 1 - Knowing docker tags
Run the command to get information on Docker
`docker --help`

Now run the command to get help on the "docker build" command: `docker build --help`

Do the same for "docker run".

Which tag has the following text? - Automatically remove the container when it exits

> --rm

## Question 2 - Understanding docker first run
first we need to run our docker with python:3.9 we installed before in `-it` mode and the entrypoint is bash. now we check the python modules that are installed using `pip --list`

the question is: what version of the package `wheel`?
> 0.42.0

## Question 3 - Count records 
Before executing the query, let's ensure that our PostgreSQL database is set up and the required datasets are prepared. We will use the Green Taxi trips dataset from September 2019, which can be obtained using the following command: `wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz`

Additionally, we need the Taxi Zones dataset, but we already have it before. check my [upload-data.ipynb](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/f24d749fd6ac3d0e0c7abb354f0dc2bc2429b924/01_docker_and_terraform/02_docker_sql/upload-data.ipynb) at `# Adding taxi zones dataset` section for details. 

Now, we can proceed to Question 3: "How many taxi trips were made on September 18th, 2019?" The query to obtain this information is as follows:
```sql
SELECT
    CAST(lpep_pickup_datetime AS date) AS "day",
    COUNT(1)
FROM
    green_taxi_data
WHERE
    CAST(lpep_pickup_datetime AS date) = '2019-09-18'
GROUP BY
    CAST(lpep_pickup_datetime AS date);
```
> Following the execution of the query, the findings reveal that on September 18th, 2019, a noteworthy total of 15,767 taxi trips were recorded.

## Question 4 - Largest trip of each day 
Which was the pick up day with the largest trip distance Use the pick up time for your calculations. 

I optimize the analysis by calculating the time span between `lpep_dropoff_datetime` and `lpep_pickup_datetime`, enabling me to determine the longest duration and thus identify it as the most extended trip.
```sql
SELECT
    CAST(lpep_pickup_datetime AS date) AS "day",
    (lpep_dropoff_datetime - lpep_pickup_datetime) AS "trip_duration"
FROM
    green_taxi_data
ORDER BY
    trip_duration DESC;
```
> The result shows that on `2019-09-26`, there was a trip lasting 4 days, 4 hours, 45 minutes, and 2 seconds. This finding establishes that September 26, 2019, is the pickup date associated with the longest distance covered during a trip.

## Question 5 - Three biggest pick up Boroughs
Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown. Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

To identify the top 3 pickup boroughs on September 18, 2019, with a sum of total_amount exceeding $50,000, I executed the following SQL query:
```sql
select
    zpu."Borough",
    sum(total_amount) as "TotalAmount"
from
    green_taxi_data g
    join taxi_zones zpu on g."PULocationID" = zpu."LocationID"
where
    zpu."Borough" is not null
    and lpep_pickup_datetime :: date = '2019-09-18'
group by
    zpu."Borough"
HAVING
    SUM(total_amount) > 50000
limit
    3;
```
The refined query ensures a more organized presentation of the results by ordering them in descending order based on total_amount. The updated output provides the top 3 pickup boroughs and their respective total amounts:
```
 "Brooklyn"	96333.23999999987
 "Manhattan"	92271.29999999865
 "Queens"	78671.70999999909
```

## Question 6 - Largest tip
For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip? We want the name of the zone, not the id. Note: it's not a typo, it's `tip` , not `trip`

I create an SQL query to extract valuable insights regarding taxi rides where passengers were picked up in Astoria during September 2019. To accomplish this, I merged data from the "green_taxi_data" and "taxi_zone" tables, linking pickup and drop-off locations through corresponding IDs.
```sql
SELECT
    zpu."Zone" as "pick_up_loc",
    CAST(lpep_pickup_datetime AS date) AS "day",
    zdo."Zone" as "drop_off_loc",
    SUM(tip_amount)
from
    green_taxi_data g
    join taxi_zones zpu on g."PULocationID" = zpu."LocationID"
    JOIN taxi_zones zdo ON g."DOLocationID" = zdo."LocationID"
WHERE
    zpu."Zone" = 'Astoria'
    and lpep_pickup_datetime between '2019-09-01'
    AND '2019-09-30'
GROUP BY
    zpu."Zone",
    CAST(lpep_pickup_datetime AS date),
    zdo."Zone"
ORDER BY
    SUM(tip_amount) DESC;
```
The query strategically narrows down the dataset by specifying key conditions: the pickup location must be "Astoria," the pickup date should fall within September 1 to September 30, 2019. The results are then grouped based on the pickup location, pickup date, and drop-off location. To pinpoint the drop-off zone with the most substantial tips, the dataset is sorted in descending order according to the sum of tip amounts. Finally, only the top result is selected to reveal the drop-off zone associated with the largest tip.

> As a result of this query, it was determined that on September 14, 2019, passengers picked up in Astoria had their highest tip when they were dropped off in the "Long Island City/Queens Plaza" zone, with a tip amount totaling `$121.07`.

## Question 7 - Creating Resources
After creating [main.tf](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/3a8a6e0082eb4ca743919e553bf02133fb5e9f4a/01_docker_and_terraform/01_terraform/terraform_variables/main.tf) and [variables.tf](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/3a8a6e0082eb4ca743919e553bf02133fb5e9f4a/01_docker_and_terraform/01_terraform/terraform_variables/variable.tf). The Terraform environment is initialized using `terraform init`. Subsequently, the planned resources are reviewed by executing `terraform plan`. This step provides an overview of the changes that will be made.

Upon confirming the plan, the actual deployment of resources is initiated with `terraform apply`. The outcome of this process is the creation of two key resources: a Google BigQuery dataset named "demo_dataset" and a Google Cloud Storage bucket with the identifier "terraform-bucket-dtc-de-course-412401," located in the "US" region.

The detailed result from the `terraform apply` command confirms the successful creation of these resources. Specifically, the Google BigQuery dataset is established, and the Google Cloud Storage bucket is configured with lifecycle rules governing object deletion and incomplete multipart uploads.

here's the example of the result:
```
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following       
symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.bq_demo_dataset will be created
  + resource "google_bigquery_dataset" "bq_demo_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "demo_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "US"
      + max_time_travel_hours      = (known after apply)
      + project                    = "dtc-de-course-412401"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.demo-bucket will be created
  + resource "google_storage_bucket" "demo-bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US"
      + name                        = "terraform-bucket-dtc-de-course-412401"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }
          + condition {
              + age                   = 3
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
      + lifecycle_rule {
          + action {
              + type = "AbortIncompleteMultipartUpload"
            }
          + condition {
              + age                   = 1
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.bq_demo_dataset: Creating...
google_storage_bucket.demo-bucket: Creating...
google_bigquery_dataset.bq_demo_dataset: Creation complete after 2s [id=projects/dtc-de-course-412401/datasets/demo_dataset]
google_storage_bucket.demo-bucket: Creation complete after 2s [id=terraform-bucket-dtc-de-course-412401]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

