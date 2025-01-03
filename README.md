## Churn Rate 

- Data Set used: [Churn Rate Data](data\round2_technical_interview_raw_data.csv)
### Setup Airflow environment. 

This is the site used to setup the environment locally: https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html

-  Install Docker (https://docs.docker.com/desktop/setup/install/windows-install/)
-  Install Airflow locally using Docker Compose (https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)
-  SetUp steps:
    - fetch docker-compose for airflow setup: `curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.10.4/docker-compose.yaml'`
    - create necessary folders: `mkdir ./dags ./logs ./plugins ./config`
    - setip environment variable: `export AIRFLOW_UID=$(id -u)`
    - Initialize Airflow: `docker-compose up airflow-init`
    - Docker compose to spin up the environment: `docker-compose up -d`

![Airflow Dashboard](https://github.com/seepala98/Churn_Data_Enginering_Assessment/blob/master/img/Docker_Containers.png)

-  Access the Airflow UI at `http://localhost:8080`
-  To stop the environment: `docker-compose down`

![Airflow Dashboard](https://github.com/seepala98/Churn_Data_Enginering_Assessment/blob/master/img/Airflow_dashboard_run.png)

### Google sheets : 

-  Import data from the excel sheet to google sheets: https://docs.google.com/spreadsheets/d/1CpJfmK7JxpAffN9X3DofzJK_sUth0MED1ZSrP1vf7pI/edit?usp=sharing  
-  Share the google sheet with the service account email to access the data.
-  This is the file that is fetched in the dag to push to bigquery table and the gcs bucket.

### Create DAGs

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
![Bucket Data](https://github.com/seepala98/Churn_Data_Enginering_Assessment/blob/master/img/gsc_bucket.png)
-  Also the dataframe used to create the csv file is stored in the bucket would be used to create a bigquery table.


### Create a bigquery view for the curn rate calculation

-  Considering that the data moved from the google sheets to the bigquery table, the data is processed to get the churn rate.
![Bigquery Churn Table](https://github.com/seepala98/Churn_Data_Enginering_Assessment/blob/master/img/Bigquery_churn_table.png)
-  Create a bigquery view to get the churn rate. [churn_view.sql](churn_view.sql)
![Bigquery Churn View](https://github.com/seepala98/Churn_Data_Enginering_Assessment/blob/master/img/Bigquery_looker_view.png)



### Connect Bigquery to Looker Studio for visualization 

-  Connect the bigquery view created to Looker Studio to visualize the data. 
-  Create a dashboard to visualize the churn rate.
[Looker Dashboard](https://lookerstudio.google.com/reporting/d74712e0-c8fc-4b77-a753-794ca2f49121)


### Key Insights: 

- High Initial Retention Followed by Rapid Drop-off:
    - Many cohorts show high retention in the first month but experience a significant drop-off in subsequent months.

- Consistent Retention for Some Cohorts:
    - Some cohorts maintain a consistent number of active users over several months. But those seems to be related to courses that are subscribed for 24 months. But looks like there isnt churn in for courses.

- Seasonal Trends:
    - There are noticeable peaks in the number of new subscriptions during certain months. For instance, the cohort from "2021/01" has a significantly higher number of new subscriptions (1111 users) compared to other months. This could indicate a seasonal trend or a successful marketing campaign during that period.

- Impact of External Factors:
    - The data shows a significant increase in new subscriptions starting from "2020/04" and peaking in "2021/01". This period coincides with the COVID-19 pandemic, suggesting that external factors may have influenced user behavior and subscription rates.

- Retention Decline Over Time:
    - There is a general trend of declining retention rates over time. This indicates that while initial acquisition is strong, retaining users over the long term remains a challenge.


### Recommendations:
- Improve Onboarding and Engagement:
    - Focus on improving the onboarding process and engagement strategies to reduce the initial drop-off in the first few months.

- Analyze Successful Cohorts:
    - Investigate the strategies used for cohorts with high long-term retention (e.g., "2019/12" and "2020/12") and apply similar tactics to other cohorts.

- Seasonal Campaigns:
    - Leverage the insights from seasonal trends to plan marketing campaigns during peak periods to maximize new subscriptions.
