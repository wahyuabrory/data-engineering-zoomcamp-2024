# Installing Postgres in Docker
```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/ny_taxi_postgres_data:/var lib/postgresql/data \
    -p 5432:5432 \
    postgres:13
```
if you encountering some issues, probably you already have postgres in your computer, so you need to change the port from `5432` to `5431` or something

# Accesing the Database
first thing first you need to install `pgcli` to access the database
```bash
pip install pgcli
```
or if you are using `conda` you can use this command
```bash
conda install -c conda-forge pgcli
```
then you can access the database using this command

```bash
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

after running the command above, you will be asked to input the password, just type `root` and you will be able to access the database. And finally you can run some query to check the database. For example you can run this query to check the table in the database
```sql
SELECT (1) as test;
```
The query above will return `1` as the result, because we haven't ingesting any data into the database yet.

# Ingesting Data into the Database
You can ingest data into database using python notebook or python script. 
## Using notebook
You can use the notebook in this repository to ingest the data into the database. You can run the notebook using `jupyter notebook` or `jupyter lab`. If you are using `conda` you can install `jupyter lab` using this command
```bash
conda install -c conda-forge jupyterlab
```
after that you can just see my [notebook](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/c2d70f062ccae3e3db3b0fd4b87fba57dd407c45/01_docker_and_terraform/02_docker_sql/upload-data.ipynb) and run it. If you want to run the notebook in your own computer, you need to change the path of the data in the notebook.

## Connect pdAdmin and Postgres with Docker
To check the data in the database you need to connect pgAdmin and Postgres. Basically you need to set pgAdmin with the docker first using
```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    dpage/pgadmin4
```
after that you'll be directed to the pgAdmin page, and you can login using the email and password that you set before. 
![pgAdmin-Postgres](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/b9ed836c289e075595445741b1079e3e39a5b62d/images/pgAdmin-postgres.png)
Btw you can't just connect pgAdmin and Postgres, you need to set the network first.
![pgAdmin-Postgres-network](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/b9ed836c289e075595445741b1079e3e39a5b62d/images/pgAdmin-postgres-network.png)


So you need to set the network using this command
```bash
docker network create pg-network
```

after creating the network, we'll edit our pdAdmin and Postgres docker to add network information.

- for Postgres
```bash
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v @(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5431:5432 \
  --network=pg-network \
  --name pg-database \
  postgres:13 
```
- for pgAdmin
```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4
```

after that, we can go to `localhost:8080` and login using the email and password that we set before. Then we can add the server using the information below.
- General
    - Name: Docker localhost
- Connection
    - Host name/address: pg-database
    - Port: 5432
    - Username: root
    - Password: root

after that you can check the table and right click on the table and click `View/Edit Data > first 100 row` to check the data in the table.

## Using Python Script
firstly you need to convert `.ipynb` to `.py` using this command
```bash
jupyter nbconvert --to script upload-data.ipynb
```
you can just take a look at [ingest_data.py](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/main/01_docker_and_terraform/02_docker_sql/ingest_data.py). After that you can run the script using this command
```bash
docker build -t taxi_ingest:v001 .
```
and lastly, run the script
```bash
url="http://computer-ip:8000/01_docker_and_terraform/02_docker_sql/yellow_tripdata_2021-01.csv"

docker run -it \
--network=pg-network \
taxi-ingestion:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table-name=yellow_taxi_data \
    --url=${url} \
```
the reason `url` was from local ip, is because the download speed is pretty fast compared to the url from DataTalksClub. so i use the url from my local computer. using 
```bash
python -m http.server
```
to create local server. and you can find your ip through `ipconfig` or `ifconfig` command.

After running those command, you can check the data in the database using pgAdmin.

# Running pgAdmin and Postgres in Docker Compose
Alternatively, you can run pgAdmin and Postgres in docker compose. You can just take a look at [docker-compose.yml](https://github.com/wahyuabrory/data-engineering-zoomcamp-2024/blob/main/01_docker_and_terraform/02_docker_sql/docker-compose.yaml). After that you can run the docker compose using this command
```bash
docker-compose up
```
and shutdown the docker compose
```bash
docker-compose down
```