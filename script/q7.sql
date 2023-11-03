--last part: How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


WITH n AS(
SELECT 
	yearid,
	max(w) AS total_wins_ws,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
GROUP BY yearid, wswin
--ORDER BY total_wins_wsl DESC
),
y AS(
SELECT 
	yearid,
	wswin AS wswin_y
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin LIKE 'Y'
GROUP BY yearid, wswin_y
--ORDER BY total_wins_y
)
SELECT 
	yearid,
	total_wins_ws
FROM teams
INNER JOIN n
USING (yearid)
INNER JOIN y
USING (yearid)
WHERE wswin_y LIKE 'Y'
GROUP BY yearid, wswin_y



	(SUM(CASE WHEN n.total_wins_wsl::numeric>y.total_wins_wsw::numeric THEN 1.0 ELSE 0 END))/SUM(y.total_wins_wsw::numeric) AS pct_wsw_max_wins
FROM n
INNER JOIN y
	USING (yearid)


SELECT 
	yearid,
	max(w) AS total_wins_wsw,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
	AND wswin LIKE 'Y'
GROUP BY yearid, wswin
ORDER BY total_wins_wsw







