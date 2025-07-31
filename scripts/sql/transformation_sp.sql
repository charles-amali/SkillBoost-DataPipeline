CREATE OR REPLACE PROCEDURE transform_raw_to_curated()
LANGUAGE plpgsql
AS $$

BEGIN
  -- USERS
  RAISE NOTICE 'Transforming user table...'; 
  CREATE TEMP TABLE temp_users AS
  SELECT 
    id,
    email,
    accounttype,
    istourcompleted,
    currenttourstep,
    avatar,
    provider,
    firstname,
    lastname,
    role,
    createdat,
    updatedat
  FROM raw_schema."user"
  WHERE email IS NOT NULL;

  CREATE TABLE IF NOT EXISTS curated.users (
    id VARCHAR(36) PRIMARY KEY,
    email TEXT,
    accounttype TEXT,
    istourcompleted BOOLEAN,
    currenttourstep TEXT,
    avatar TEXT,
    provider TEXT,
    firstname TEXT,
    lastname TEXT,
    role TEXT,
    createdat TIMESTAMPTZ,
    updatedat TIMESTAMPTZ
  );

  MERGE INTO curated.users 
  USING temp_users s
  ON curated.users.id = s.id
  WHEN MATCHED THEN UPDATE SET
    email = s.email,
    accounttype = s.accounttype,
    istourcompleted = s.istourcompleted,
    currenttourstep = s.currenttourstep,
    avatar = s.avatar,
    provider = s.provider,
    firstname = s.firstname,
    lastname = s.lastname,
    role = s.role,
    createdat = s.createdat,
    updatedat = s.updatedat
  WHEN NOT MATCHED THEN INSERT (
    id, email, accounttype, istourcompleted, currenttourstep,
    avatar, provider, firstname, lastname, role, createdat, updatedat
  ) VALUES (
    s.id, s.email, s.accounttype, s.istourcompleted, s.currenttourstep,
    s.avatar, s.provider, s.firstname, s.lastname, s.role, s.createdat, s.updatedat
  );

  -- SKILL AREAS
  RAISE NOTICE 'Transforming skill area table...'; 
  CREATE TEMP TABLE temp_skill_areas AS
  SELECT 
    id,
    name,
    image_url,
    total_xp,
    createdat,
    updatedat
  FROM raw_schema.skillarea
  WHERE name IS NOT NULL;

  CREATE TABLE IF NOT EXISTS curated.skill_areas (
    id VARCHAR(36) PRIMARY KEY,
    name TEXT,
    image_url TEXT,
    total_xp INT,
    createdat TIMESTAMPTZ,
    updatedat TIMESTAMPTZ
  );

  MERGE INTO curated.skill_areas 
  USING temp_skill_areas s
  ON curated.skill_areas.id = s.id
  WHEN MATCHED THEN UPDATE SET
    name = s.name,
    image_url = s.image_url,
    total_xp = s.total_xp,
    createdat = s.createdat,
    updatedat = s.updatedat
  WHEN NOT MATCHED THEN INSERT (
    id, name, image_url, total_xp, createdat, updatedat
  ) VALUES (
    s.id, s.name, s.image_url, s.total_xp, s.createdat, s.updatedat
  );


  -- USER SKILLS
  RAISE NOTICE 'Transforming user skill table...'; 
  CREATE TEMP TABLE temp_user_skill AS
  SELECT 
    id,
    userid,
    skillareaid,
    level,
    current_xp,
    createdat,
    updatedat
  FROM raw_schema.userskill
  WHERE userid IS NOT NULL AND skillareaid IS NOT NULL;

  CREATE TABLE IF NOT EXISTS curated.user_skill (
    id VARCHAR(36) PRIMARY KEY,
    userid VARCHAR(36),
    skillareaid VARCHAR(36),
    level TEXT,
    current_xp INT,
    createdat TIMESTAMPTZ,
    updatedat TIMESTAMPTZ
  );

  MERGE INTO curated.user_skill 
  USING temp_user_skill s
  ON curated.user_skill.id = s.id
  WHEN MATCHED THEN UPDATE SET
    userid = s.userid,
    skillareaid = s.skillareaid,
    level = s.level,
    current_xp = s.current_xp,
    createdat = s.createdat,
    updatedat = s.updatedat
  WHEN NOT MATCHED THEN INSERT (
    id, userid, skillareaid, level, current_xp, createdat, updatedat
  ) VALUES (
    s.id, s.userid, s.skillareaid, s.level, s.current_xp, s.createdat, s.updatedat
  );


  -- TASKS
  RAISE NOTICE 'Transforming task table...'; 
  CREATE TEMP TABLE temp_tasks AS
  SELECT 
    id,
    type,
    skillareaid,
    difficulty,
    xp,
    content,
    json_extract_path_text(content, 'prompt') AS prompt,
    json_extract_path_text(content, 'input') AS input_example,
    userid,
    completed,
    user_solution,
    starttime,
    status,
    expiredtime,
    time_limit,
    recommendation,
    createdat,
    updatedat,
    iscorrect,
    isrecommended
  FROM raw_schema.task
  WHERE userid IS NOT NULL;

  CREATE TABLE IF NOT EXISTS curated.tasks (
    id VARCHAR(36) PRIMARY KEY,
    type TEXT,
    skillareaid VARCHAR(36),
    difficulty INT,
    xp INT,
    content TEXT,
    prompt TEXT,
    input_example TEXT,
    userid VARCHAR(36),
    completed BOOLEAN,
    user_solution TEXT,
    starttime TIMESTAMPTZ,
    status TEXT,
    expiredtime TIMESTAMPTZ,
    time_limit INT,
    recommendation TEXT,
    createdat TIMESTAMPTZ,
    updatedat TIMESTAMPTZ,
    iscorrect BOOLEAN,
    isrecommended BOOLEAN
  );

  MERGE INTO curated.tasks
  USING temp_tasks s
  ON curated.tasks.id = s.id
  WHEN MATCHED THEN UPDATE SET
    type = s.type,
    skillareaid = s.skillareaid,
    difficulty = s.difficulty,
    xp = s.xp,
    content = s.content,
    prompt = s.prompt,
    input_example = s.input_example,
    userid = s.userid,
    completed = s.completed,
    user_solution = s.user_solution,
    starttime = s.starttime,
    status = s.status,
    expiredtime = s.expiredtime,
    time_limit = s.time_limit,
    recommendation = s.recommendation,
    createdat = s.createdat,
    updatedat = s.updatedat,
    iscorrect = s.iscorrect,
    isrecommended = s.isrecommended
  WHEN NOT MATCHED THEN INSERT (
    id, type, skillareaid, difficulty, xp, content, prompt, input_example,
    userid, completed, user_solution, starttime, status, expiredtime, time_limit,
    recommendation, createdat, updatedat, iscorrect, isrecommended
  ) VALUES (
    s.id, s.type, s.skillareaid, s.difficulty, s.xp, s.content, s.prompt, s.input_example,
    s.userid, s.completed, s.user_solution, s.starttime, s.status, s.expiredtime, s.time_limit,
    s.recommendation, s.createdat, s.updatedat, s.iscorrect, s.isrecommended
  );

END;
$$;

CALL transform_raw_to_curated();