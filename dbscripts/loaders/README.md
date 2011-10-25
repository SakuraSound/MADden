
## Loader scripts
 
 These are scripts to load the database
 These scripts are tied tightly with the create scripts


### db.json

Be sure to include and condifuge a file 'db.json' that
defines all the access information for your database.
The reposory contains a sample but it should be changes 
to fit your configuration.
This is be used by all loaders.

It is important to not that *table names* are not include
in this file.


### tweet\_load.py

This tile takes a json file, usually from the twetter's streaming api


### nflrecap\_load.py

This takes a directory location as an input.
Under this directoru should be a series of directories
of the formay `20YY`, this number represents the year.
Under each of these year folders are fliles of the
format `NFL_20XXMMDD_{TEAM1}@{TEAM2}.txt`. XX is the
year, MM if hte month, DD is the day, TEAM1 and TEAM2 are 
two or three leter team name.

Each file line is a description from a play.


### nflplays\_load.py

This is similar to the previous loader in structure. It inserts plays
oin to the database.
