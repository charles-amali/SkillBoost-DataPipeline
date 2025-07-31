SELECT * FROM raw_schema.users
LIMIT 5;

SELECT * FROM raw_schema.skill_areas;

SELECT * FROM raw_schema.user_skills
LIMIT 5;


SELECT * FROM curated.tasks;

SELECT * FROM presentation.dim_date;
SELECT * FROM curated.user_skill;
SELECT * FROM presentation.dim_user;
SELECT * FROM presentation.dim_skill;
SELECT * FROM presentation.fact_task_performanceSELECT * FROM raw_schema."user"
LIMIT 5;

SELECT * FROM raw_schema.skillarea;

SELECT * FROM raw_schema.task;

SELECT * FROM raw_schema.userskill
LIMIT 5;


SELECT * FROM curated.skill_areas;
SELECT * FROM curated.user_skill;

SELECT * FROM presentation.dim_date;
SELECT COUNT(*) FROM presentation.dim_user;
SELECT * FROM presentation.dim_skill;
SELECT * FROM presentation.fact_task_performance;
SELECT * FROM presentation.fact_user_skill_level;

GRANT USAGE ON SCHEMA presentation TO admin;
GRANT SELECT ON ALL TABLES IN SCHEMA presentation TO admin;
SELECT * 
FROM information_schema.columns 
WHERE table_schema = 'raw_schema' 
  AND table_name = 'task';