## Personal Development School (Churn Rate Assessment) 

##### Setup Airflow environment. 

This is the site used to setup the environment locally: https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html

1. Install Docker (https://docs.docker.com/desktop/setup/install/windows-install/)
2. Install Airflow locally using Docker Compose (https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)
3. SetUp steps:
    - fetch docker-compose for airflow setup: `curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.10.4/docker-compose.yaml'`
    - create necessary folders: `mkdir ./dags ./logs ./plugins ./config`
    - setip environment variable: `export AIRFLOW_UID=$(id -u)`
    - Initialize Airflow: `docker-compose up airflow-init`
    - Docker compose to spin up the environment: `docker-compose up -d`
4. Access the Airflow UI at `http://localhost:8080`
5. To stop the environment: `docker-compose down`

##### Google sheets : 

1. Import data from the excel sheet to google sheets: https://docs.google.com/spreadsheets/d/1CpJfmK7JxpAffN9X3DofzJK_sUth0MED1ZSrP1vf7pI/edit?usp=sharing  
2. Share the google sheet with the service account email to access the data.
3. This is the file that is fetched in the dag to push to bigquery table and the gcs bucket.

##### Create DAGs

1. Create a new DAG file: `touch dags/churn_data.py`
2. Python DAG includes config of the DAG, tasks, and task dependencies
    ```
    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
        'start_date': datetime(2024, 12, 1),
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=1),
    }
    ```
3. Schedule the DAG: `schedule_interval=timedelta(hours=8)`
4. Create a task for pull data from google sheets.
5. Create a task for store the data after processing to bucket.
6. Also the dataframe used to create the csv file is stored in the bucket would be used to create a bigquery table.


##### Create a bigquery view for the curn rate calculation

1. Considering that the data moved from the google sheets to the bigquery table, the data is processed to get the churn rate.
2. Create a bigquery view to get the churn rate. [churn_view.sql](churn_view.sql)


##### Connect Bigquery view generated 

1. Connect the bigquery view created to Looker Studio to visualize the data. 
2. Create a dashboard to visualize the churn rate.