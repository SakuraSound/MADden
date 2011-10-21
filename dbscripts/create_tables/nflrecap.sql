-- DROP SEQUENCE recap_id_seq;
CREATE SEQUENCE recap_id_seq;

-- DROP TABLE nflrecap;
CREATE TABLE nflrecap (
  id INTEGER DEFAULT NEXTVAL ('recap_id_seq') PRIMARY KEY, 
  year INTEGER NOT NULL,
  recap TEXT NOT NULL 
);

