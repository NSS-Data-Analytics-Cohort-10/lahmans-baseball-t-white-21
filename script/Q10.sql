-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- -- player names - people
-- -- max hr >=1 -batting?
-- -- 2016 
-- -- league 10+yr - player (finalgame - debut need to cast as #)

 

WITH n AS (SELECT
	playerid,
	sum(hr) AS hr_2016,
	yearid
FROM batting
WHERE hr>=1 AND yearid='2016'
GROUP BY playerid, yearid),
--ORDER BY playerid
x AS (SELECT
	playerid,
	sum(hr) AS all_yr_hr,
	yearid
FROM batting
WHERE hr>=1 
GROUP BY playerid, yearid)
,		   
nx AS(
SELECT 
	playerid,
	CASE WHEN sum(n.hr_2016) > max(x.all_yr_hr) THEN hr_2016 END AS career_high
--	CASE WHEN n.hr_2016 < x.all_yr_hr THEN 'no' END AS dont_matter
FROM batting b
INNER JOIN n
	USING (playerid)
INNER JOIN x
	ON x.playerid=n.playerid
	AND  b.yearid=n.yearid
WHERE b.yearid = n.yearid
GROUP BY playerid, hr_2016, x.all_yr_hr, n.hr_2016
ORDER BY playerid DESC
)
--
SELECT
	DISTINCT(namefirst || ' '|| namelast) AS player,
	nx.career_high,
	s.tenure
FROM people
inner JOIN batting
	USING (playerid)
INNER JOIN (SELECT playerid,
			DATE_PART('year',finalgame::date)
			-DATE_PART('year',debut::date) AS tenure
			FROM people) AS s
	USING(playerid)		
INNER JOIN nx
	USING (playerid)
WHERE tenure >=10
	AND career_high IS NOT NULL
GROUP BY player, nx.career_high, s.tenure