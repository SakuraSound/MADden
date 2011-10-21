-- DROP SEQUENCE plays_id_seq;
CREATE SEQUENCE plays_id_seq;

--DROP TABLE nflplays; 
CREATE TABLE nflplays ( 
  id INTEGER DEFAULT NEXTVAL ('recap_id_seq') PRIMARY KEY,
  year INTEGER NOT NULL,
  plays TEXT NOT NULL
);

