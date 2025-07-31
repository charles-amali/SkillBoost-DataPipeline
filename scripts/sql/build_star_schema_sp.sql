CREATE OR REPLACE PROCEDURE build_star_schema()
LANGUAGE plpgsql
AS $$
BEGIN
  -- Dimension: User
  RAISE NOTICE 'Transforming dim_user...';

  CREATE TEMP TABLE temp_dim_user AS
  SELECT 
    id AS user_id,
    firstname,
    lastname,
    email,
    accounttype,
    role,
    createdat AS joined_at
  FROM curated.users;

  CREATE TABLE IF NOT EXISTS presentation.dim_user (
    user_id VARCHAR(36) PRIMARY KEY,
    firstname TEXT,
    lastname TEXT,
    email TEXT,
    accounttype TEXT,
    role TEXT,
    joined_at TIMESTAMP
  );

  MERGE INTO presentation.dim_user
  USING temp_dim_user s
  ON presentation.dim_user.user_id = s.user_id
  WHEN MATCHED THEN UPDATE SET
    firstname = s.firstname,
    lastname = s.lastname,
    email = s.email,
    accounttype = s.accounttype,
    role = s.role,
    joined_at = s.joined_at
  WHEN NOT MATCHED THEN INSERT (
    user_id, firstname, lastname, email, accounttype, role, joined_at
  )
  VALUES (
    s.user_id, s.firstname, s.lastname, s.email, s.accounttype, s.role, s.joined_at
  );


  -- Dimension: Skill Area
  RAISE NOTICE 'Transforming dim_skill...';

  CREATE TEMP TABLE temp_dim_skill AS
  SELECT 
    id AS skill_id,
    name AS skill_name,
    image_url,
    total_xp,
    createdat,
    updatedat
  FROM curated.skill_areas;

  CREATE TABLE IF NOT EXISTS presentation.dim_skill (
    skill_id VARCHAR(36) PRIMARY KEY,
    skill_name TEXT,
    image_url TEXT,
    total_xp INT,
    createdat TIMESTAMP,
    updatedat TIMESTAMP
  );

  MERGE INTO presentation.dim_skill
  USING temp_dim_skill s
  ON presentation.dim_skill.skill_id = s.skill_id
  WHEN MATCHED THEN UPDATE SET
    skill_name = s.skill_name,
    image_url = s.image_url,
    total_xp = s.total_xp,
    updatedat = s.updatedat
  WHEN NOT MATCHED THEN INSERT (
    skill_id, skill_name, image_url, total_xp, createdat, updatedat
  )
  VALUES (
    s.skill_id, s.skill_name, s.image_url, s.total_xp, s.createdat, s.updatedat
  );

  -- Dimension: Task
  RAISE NOTICE 'Transforming dim_task...';

  CREATE TEMP TABLE temp_dim_task AS
  SELECT 
    id AS task_id,
    type AS task_type,
    difficulty,
    xp,
    prompt,
    input_example,
    createdat AS time_created
  FROM curated.tasks;

  CREATE TABLE IF NOT EXISTS presentation.dim_task (
    task_id VARCHAR(36) PRIMARY KEY,
    task_type TEXT,
    difficulty TEXT,
    xp INT,
    prompt TEXT,
    input_example TEXT,
    time_created TIMESTAMP
  );

  MERGE INTO presentation.dim_task
  USING temp_dim_task s
  ON presentation.dim_task.task_id = s.task_id
  WHEN MATCHED THEN UPDATE SET
    task_type = s.task_type,
    difficulty = s.difficulty,
    xp = s.xp,
    prompt = s.prompt,
    input_example = s.input_example,
    time_created = s.time_created
  WHEN NOT MATCHED THEN INSERT (
    task_id, task_type, difficulty, xp, prompt, input_example, time_created
  )
  VALUES (
    s.task_id, s.task_type, s.difficulty, s.xp, s.prompt, s.input_example, s.time_created
  );

  -- Fact: fact_task_performance
  RAISE NOTICE 'Transforming fact_task_performance...';
  CREATE TEMP TABLE temp_fact_task_performance AS
  SELECT
    id AS task_id,
    userid,
    skillareaid AS skill_id,
    completed,
    xp,
    user_solution,
    createdat AS attempt_time
  FROM curated.tasks
  WHERE userid IS NOT NULL;

  CREATE TABLE IF NOT EXISTS presentation.fact_task_performance (
    task_id VARCHAR(36),
    userid VARCHAR(36),
    skill_id VARCHAR(36),
    completed BOOLEAN,
    xp INT,
    user_solution TEXT,
    attempt_time TIMESTAMP,
    PRIMARY KEY (task_id, userid)
  );

  MERGE INTO presentation.fact_task_performance
  USING temp_fact_task_performance s
  ON presentation.fact_task_performance.task_id = s.task_id AND presentation.fact_task_performance.userid = s.userid
  WHEN MATCHED THEN UPDATE SET
    completed = s.completed,
    xp = s.xp,
    user_solution = s.user_solution,
    attempt_time = s.attempt_time
  WHEN NOT MATCHED THEN INSERT (
    task_id, userid, skill_id, completed, xp, user_solution, attempt_time
  )
  VALUES (
    s.task_id, s.userid, s.skill_id, s.completed, s.xp, s.user_solution, s.attempt_time
  );

  -- GET DIAGNOSTICS row_count = ROW_COUNT;
  -- RAISE NOTICE 'Inserted/updated % rows into fact_task_performance.', row_count;

  RAISE NOTICE 'Transforming fact_user_skill_level...';

  CREATE TEMP TABLE temp_fact_user_skill_level AS
  SELECT 
    userid,
    skillareaid AS skill_id,
    level,
    createdat AS level_set_at
  FROM curated.user_skill;

  CREATE TABLE IF NOT EXISTS presentation.fact_user_skill_level (
    userid VARCHAR(36),
    skill_id VARCHAR(36),
    level TEXT,
    level_set_at TIMESTAMP,
    PRIMARY KEY (userid, skill_id)
  );

  MERGE INTO presentation.fact_user_skill_level
  USING temp_fact_user_skill_level s
  ON presentation.fact_user_skill_level.userid = s.userid AND presentation.fact_user_skill_level.skill_id = s.skill_id
  WHEN MATCHED THEN UPDATE SET
    level = s.level,
    level_set_at = s.level_set_at
  WHEN NOT MATCHED THEN INSERT (
    userid, skill_id, level, level_set_at
  )
  VALUES (
    s.userid, s.skill_id, s.level, s.level_set_at
  );

  RAISE NOTICE 'Star schema build completed successfully.';
END;
$$;


CALL build_star_schema();