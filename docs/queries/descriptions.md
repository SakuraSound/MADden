### Compare NFL teams to college teams

Many reporters try to make comparisons between college football programs and 
nfl programs. We can cluster nfl teams and then for each college team we can
produce a nfl equvalent.
Additionally, we can use different features such as plays and positional
statistics to perform comparisons.


### Plot the the popularity of a team over minutes

```SQL

	SELECT timestamp, Team.name, count( * )
	FROM Twitter
	WHERE t.text in (SELECT name FROM Team)
	GROUP BY timestamp.seconds, Team.name
```


### Most successful team (MST) score

```SQL

	SELECT team, succesful( * )
	FROM SELECT team, AVG(sentiment)
				FROM Team t, (SELECT sentiment( * ), team
										FROM Blogs b UNION ALL Team t)
	
```


### Something Association Rule mining

TODO



