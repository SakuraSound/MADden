-- DROP SEQUENCE recap_id_seq;
CREATE SEQUENCE recap_id_seq;

-- DROP TABLE nflrecap;
CREATE TABLE nflrecap (
  id INTEGER DEFAULT NEXTVAL ('recap_id_seq') NOT NULL, 
  gamedate DATE NOT NULL,
	team1 CHAR(4) NOT NULL,
	team2 CHAR(4) NOT NULL,
	fileloc VARCHAR(50) DEFAULT NULL, 
  recap TEXT NOT NULL,
	PRIMARY KEY(id,gamedate,team1,team2)
);

