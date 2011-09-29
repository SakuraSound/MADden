

To plot the the popularity of a team over minutes

<code>
	SELECT timestamp, Team.name, count( * )
	FROM Twitter
	WHERE t.text in (SELECT name FROM Team)
	GROUP BY timestamp.seconds, Team.name
</code>


Most successful team (MST) score

<code>
	SELECT team, succesful( * )
	FROM SELECT team, AVG(sentiment)
				FROM Team t, (SELECT sentiment( * ), team
										FROM Blogs b UNION ALL Team t)
	
<code>



Something Association Rule mining

TODO



