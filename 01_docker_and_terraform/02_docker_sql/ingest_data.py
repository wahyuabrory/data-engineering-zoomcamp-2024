from sqlalchemy import create_engine
from time import time
import pandas as pd
import argparse
import os

def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    
    url = params.url
    
    csv_name = 'output.csv'
    
    os.system(f'wget{url} -O {csv_name}')
    
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    df_iter = pd.read_csv(csv_name, chunksize=1000000, iterator=True)

    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.head(n=0).to_sql({table_name}, engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append', index=False)


    while True:
        try:
            
            t_start = time()
            
            df = next(df_iter)
            
            df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
            df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
            
            df.to_sql(name=table_name, con=engine, if_exists='append', index=False)
            
            t_end = time()
            
            print('inserted another chunk, took %.3f second' % (t_end - t_start))
        
        except StopIteration:
            print("Finished ingesting data into the postgres database")
            break

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to postgres.')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password',required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host name for postgres')
    parser.add_argument('--port', required=True, help='post name for postgres')
    parser.add_argument('--db', required=True, help='db name for postgres')
    parser.add_argument('--table-name', required=True, help='name of the table to be created')
    parser.add_argument('--url', required=True, help='url of the csv file')

    args = parser.parse_args()

    main(args)





