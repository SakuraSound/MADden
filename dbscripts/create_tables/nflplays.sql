-- DROP SEQUENCE plays_id_seq;
CREATE SEQUENCE plays_id_seq;

--DROP TABLE nflplays; 
CREATE TABLE nflplays ( 
  id INTEGER DEFAULT NEXTVAL ('plays_id_seq'),
  playnum INTEGER DEFAULT -1,
  gamedate DATE NOT NULL,
  team1 CHAR(4) NOT NULL,
  team2 CHAR(4) NOT NULL,
  fileloc VARCHAR(50) DEFAULT NULL,
  play TEXT NOT NULL,
  PRIMARY KEY(id, gamedate, team1, team2, playnum)
);

