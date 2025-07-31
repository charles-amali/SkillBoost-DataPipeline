

import sys
import logging
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


args = getResolvedOptions(sys.argv, [
    'JOB_NAME', 
    'rds_database', 
    'rds_username', 
    'rds_password', 
    'rds_url', 
    'redshift_db',
    'redshift_username', 
    'redshift_password',
    'redshift_url'
    ])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)


rds_table_list = ["Task", "UserSkill", "SkillArea", "User"]
jdbc_connection_name = "rds-skillboost-conn"
redshift_connection_name = "redshift-conn"
redshift_temp_dir = "s3://skillboost/redshift-dir/temp/"
redshift_schema = "raw_schema"
redshift_db = "skillboost_analytics"

def extract_table_from_rds(table_name):
    logger.info(f"Extracting table: {table_name}")
    try:
        return glueContext.create_dynamic_frame.from_options(
            connection_type="postgresql",
            # connection_name=jdbc_connection_name,
            connection_options={
                "url": args['rds_url'],
                "dbtable": table_name,
                "user": args['rds_username'],
                "password": args['rds_password'],
                "database": args['rds_database']
             }

        )
    except Exception as e:
        logger.error(f"Failed to extract table {table_name}: {str(e)}")
        raise

def load_table_to_redshift(dynamic_frame, table_name):
    logger.info(f"Loading table to Redshift: {table_name}")
    try:
        glueContext.write_dynamic_frame.from_jdbc_conf(
            frame=dynamic_frame,
            catalog_connection=redshift_connection_name,
            connection_options={
                "dbtable": f"{redshift_schema}.{table_name}",
                "database": args['redshift_db']
            },
            redshift_tmp_dir=redshift_temp_dir,
            transformation_ctx=f"write_to_redshift_{table_name}"

            
        )
        logger.info(f"{table_name} successfully loaded to Redshift.")
    except Exception as e:
        logger.error(f"Failed to load {table_name} to Redshift: {str(e)}")
        raise


for table in rds_table_list:
    df = extract_table_from_rds(table)
    load_table_to_redshift(df, table)

job.commit()
logger.info("ETL job completed successfully.")
