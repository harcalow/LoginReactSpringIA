-- Reemplaza full_name por first_name (nombres) y last_name (apellidos)
ALTER TABLE users
    ADD COLUMN first_name VARCHAR(60),
    ADD COLUMN last_name  VARCHAR(60);

UPDATE users
SET first_name = split_part(full_name, ' ', 1),
    last_name  = CASE
                     WHEN position(' ' IN full_name) > 0 THEN substring(full_name FROM position(' ' IN full_name) + 1)
                     ELSE ''
                 END;

ALTER TABLE users
    ALTER COLUMN first_name SET NOT NULL,
    ALTER COLUMN last_name SET NOT NULL,
    DROP COLUMN full_name;
