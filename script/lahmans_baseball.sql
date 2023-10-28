-- ## Lahman Baseball Database Exercise
-- - this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
-- - A data dictionary is included with the files for this project.

-- ### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.



-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(year) as first_year, MAX(year) as most_recent_year
FROM homegames;

--a: 1871- 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
	playerid,
	namefirst || ' '|| namelast AS full_name,
	height,
	t.name AS team_name,
	(SELECT COUNT(g_all)
		FROM appearances
		WHERE playerid = 'gaedeed01') AS num_games_played
FROM people p
INNER JOIN appearances a
	USING (playerid)
LEFT JOIN teams t
	USING (teamid)
ORDER BY height
LIMIT 1

--a: Eddie Gaedel, 43", St Louis Browns, 1 game
-- he batted. I bet he got walked! Let's see
SELECT *
FROM batting
WHERE playerid = 'gaedeed01'
--yup.

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--this gives me playerids for vandy kids
SELECT DISTINCT(playerid)
FROM collegeplaying
JOIN
	(SELECT s.schoolID,
	schoolname
	FROM schools AS s
	WHERE schoolname LIKE 'Vanderbilt%') AS v
	USING (schoolid)

--goal: vandy kids names
SELECT namefirst,
	namelast
FROM people 
WHERE playerid IN
	(SELECT DISTINCT(playerid)
	FROM collegeplaying
	JOIN
	(SELECT s.schoolID,
	schoolname
	FROM schools AS s
	WHERE schoolname LIKE 'Vanderbilt%') AS v
	USING (schoolid));

--goal: find salaries of vandy kids
SELECT namefirst,
	namelast,
	SUM(salary) AS total_salary
FROM salaries
INNER JOIN people
	USING (playerid)
WHERE playerid IN
	(SELECT DISTINCT(playerid)
	FROM collegeplaying
	JOIN
	(SELECT s.schoolID,
	schoolname
	FROM schools AS s
	WHERE schoolname LIKE 'Vanderbilt%') AS v
	USING (schoolid))
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;

--a: David Price, $81,851,296

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--1ST PART OF Q
SELECT
	playerid,
	CASE WHEN pos = 'OF' THEN 'outfield'
	WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'infield'
	WHEN pos = 'P' OR pos = 'C' THEN 'battery'
	END AS position
FROM fielding

--2ND PART OF Q. ABOVE ISN'T SUMMING THE PUTOUTS
-- SELECT
-- 	COUNT(PO) AS total_putouts,
-- 	COUNT(CASE WHEN pos = 'OF' THEN 'outfield' END) AS total_outfield,
-- 	COUNT(CASE WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'infield' END) AS total_infield,
-- 	COUNT(CASE WHEN pos = 'P' OR pos = 'C' THEN 'battery' END) AS total_battery
-- FROM fielding

--below is better:
SELECT
	COUNT(PO) AS total_putouts,
	CASE WHEN pos = 'OF' THEN 'outfield'
		 WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'infield'
		 WHEN pos = 'P' OR pos = 'C' THEN 'battery'
		 END AS position
FROM fielding
GROUP BY position

--a:
-- total_putout
-- 136815	
-- total_outfield
-- 28434	
-- total_infield
-- 52186	
-- total_battery
-- 56195


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 
	CONCAT(LEFT(CAST(yearid AS varchar),3),'0s') AS decade,
	ROUND((SUM(so)/SUM(g)),2) AS av_so_pg
FROM teams
GROUP BY decade
ORDER BY decade

SELECT *
FROM teams

-- SELECT 
-- 	CONCAT(LEFT(CAST(yearid AS varchar),3),'0s') AS decade,
-- 	ROUND(AVG(so/g),2) AS av_so_pg
-- FROM teams
-- GROUP BY decade
-- ORDER BY decade

--now for homeruns
SELECT 
	CONCAT(LEFT(CAST(yearid AS varchar),3),'0s') AS decade,
	AVG(hr/g) AS av_hr_pg
FROM teams
GROUP BY decade
ORDER BY av_hr_pg DESC

--above rounding makes everything 0s ???

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

WITH x AS (
	SELECT playerid,
	SUM(sb)+SUM(cs) AS attempts
	FROM batting
	GROUP BY playerid
)
SELECT
	playerid,
	(SUM(sb)/SUM(x.attempts))*100 AS success_rate
FROM batting
INNER JOIN X
	USING (playerid)
WHERE attempts >=20
	AND yearid = 2016
GROUP BY playerid
ORDER BY success_rate DESC

--a: broxtke01

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?




-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
