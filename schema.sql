DROP TABLE todos;
DROP TABLE lists;

CREATE TABLE lists (
  id serial PRIMARY KEY,
  name varchar(200) NOT NULL UNIQUE
);

CREATE TABLE todos (
  id serial PRIMARY KEY,
  name varchar(200) NOT NULL,
  list_id int NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
  completed boolean DEFAULT false NOT NULL
);

