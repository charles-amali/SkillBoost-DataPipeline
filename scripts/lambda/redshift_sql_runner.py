

import boto3
import time
import os
import re
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


client = boto3.client('redshift-data')

CLUSTER_ID = os.environ['REDSHIFT_CLUSTER']
DATABASE = os.environ['REDSHIFT_DATABASE']
DB_USER = os.environ['REDSHIFT_DB_USER']

def wait_for_statement(statement_id):
    while True:
        response = client.describe_statement(Id=statement_id)
        status = response['Status']
        if status in ['FINISHED', 'FAILED', 'ABORTED']:
            return response
        time.sleep(2)

def lambda_handler(event, context):
    PROCEDURE_PATTERN = re.compile(r'^[a-zA-Z_][a-zA-Z0-9_]*$')

    procedure = event.get("procedure")
    if not procedure or not PROCEDURE_PATTERN.match(procedure):
        raise ValueError("Invalid or missing 'procedure' in input event")

    sql = f"CALL {procedure}();"   
    logger.info(f"Executing: {sql}")

    try:
        response = client.execute_statement(
            ClusterIdentifier=CLUSTER_ID,
            Database=DATABASE,
            DbUser=DB_USER,
            Sql=sql
        )

        result = wait_for_statement(response['Id'])

        if result['Status'] != 'FINISHED':
            raise Exception(f"Error in {procedure}: {result.get('Error', 'Unknown error')}")

        return {
            'statusCode': 200,
            'message': f"Procedure {procedure} executed successfully."
        }

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise

