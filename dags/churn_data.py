from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import pandas as pd
from google.cloud import storage
from google.oauth2 import service_account
from googleapiclient.discovery import build
from google.cloud import bigquery

# Define default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 12, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

# Define the DAG
dag = DAG(
    'data_pipeline',
    default_args=default_args,
    description='A data pipeline to process subscription churn data',
    schedule_interval=timedelta(hours=8),
)

def pull_data_from_google_sheets():
    # Google Sheets API setup
    SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
    SERVICE_ACCOUNT_FILE = './dags/our-reason-346219-28ce89c2ba2e.json'
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES)
    service = build('sheets', 'v4', credentials=creds)
    sheet = service.spreadsheets()
    
    # Pull data from Google Sheets
    SPREADSHEET_ID = '1CpJfmK7JxpAffN9X3DofzJK_sUth0MED1ZSrP1vf7pI'
    RANGE_NAME = 'Sheet1!A1:C'
    result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range=RANGE_NAME).execute()
    values = result.get('values', [])
    
    # Convert to DataFrame
    df = pd.DataFrame(values[1:], columns=values[0])
    df.to_csv('/tmp/subscription_churn.csv', index=False)

def process_and_store_data():
    # Load data
    df = pd.read_csv('/tmp/subscription_churn.csv')
    
    # Process data
    df['subscription_started'] = pd.to_datetime(df['subscription_started'])
    df['cancel_time'] = pd.to_datetime(df['cancel_time'])
    
    # Path to the service account key file
    SERVICE_ACCOUNT_FILE = './dags/our-reason-346219-28ce89c2ba2e.json'
    
    # Store raw data in GCP Cloud Storage
    storage_credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE)
    storage_client = storage.Client(credentials=storage_credentials)
    bucket = storage_client.bucket('assessment_churn_data')
    blob = bucket.blob('subscription_churn.csv')
    blob.upload_from_filename('/tmp/subscription_churn.csv')
    
    # # Push processed data to BigQuery
    bigquery_credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE)
    bigquery_client = bigquery.Client(credentials=bigquery_credentials)
    table_id = 'our-reason-346219.subscription_churn.churn'
    job = bigquery_client.load_table_from_dataframe(df, table_id)
    job.result()

# Define tasks
pull_data_task = PythonOperator(
    task_id='pull_data_from_google_sheets',
    python_callable=pull_data_from_google_sheets,
    dag=dag,
)

process_and_store_task = PythonOperator(
    task_id='process_and_store_data',
    python_callable=process_and_store_data,
    dag=dag,
)

# Set task dependencies
pull_data_task >> process_and_store_task