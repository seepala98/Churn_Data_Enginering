## Personal Development School (Churn Rate Assessment) 

- Please find the document for the requirements for the churn rate assessment [Round 2 Technical interview.pdf](Round_2_Technical_interview.pdf).
- Data Set used for the assessment: [Churn Rate Data](round2_technical_interview_raw_data.csv)
#### Setup Airflow environment. 

This is the site used to setup the environment locally: https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html

-  Install Docker (https://docs.docker.com/desktop/setup/install/windows-install/)
-  Install Airflow locally using Docker Compose (https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)
-  SetUp steps:
    - fetch docker-compose for airflow setup: `curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.10.4/docker-compose.yaml'`
    - create necessary folders: `mkdir ./dags ./logs ./plugins ./config`
    - setip environment variable: `export AIRFLOW_UID=$(id -u)`
    - Initialize Airflow: `docker-compose up airflow-init`
    - Docker compose to spin up the environment: `docker-compose up -d`
-  Access the Airflow UI at `http://localhost:8080`
-  To stop the environment: `docker-compose down`

![Airflow Dashboard](img\Airflow_dashboard_run.png)

#### Google sheets : 

-  Import data from the excel sheet to google sheets: https://docs.google.com/spreadsheets/d/1CpJfmK7JxpAffN9X3DofzJK_sUth0MED1ZSrP1vf7pI/edit?usp=sharing  
-  Share the google sheet with the service account email to access the data.
-  This is the file that is fetched in the dag to push to bigquery table and the gcs bucket.

#### Create DAGs

-  Create a new DAG file: `touch dags/churn_data.py`
-  Python DAG includes config of the DAG, tasks, and task dependencies
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
-  Schedule the DAG: `schedule_interval=timedelta(hours=8)`
-  Create a task for pull data from google sheets.
-  Create a task for store the data after processing to bucket.
![Bucket Data](img\gsc_bucket.png)
-  Also the dataframe used to create the csv file is stored in the bucket would be used to create a bigquery table.


##### Create a bigquery view for the curn rate calculation

-  Considering that the data moved from the google sheets to the bigquery table, the data is processed to get the churn rate.
![Bigquery Churn Table](img\Bigquery_churn_table.png)
-  Create a bigquery view to get the churn rate. [churn_view.sql](churn_view.sql)
![Bigquery Churn View](img\Bigquery_looker_view.png)



##### Connect Bigquery to Looker Studio for visualization 

-  Connect the bigquery view created to Looker Studio to visualize the data. 
-  Create a dashboard to visualize the churn rate.
[Looker Dashboard](https://lookerstudio.google.com/reporting/d74712e0-c8fc-4b77-a753-794ca2f49121)