SELECT player_name, age, height, weight, college, country, draft_year, draft_round, draft_number, gp, pts, reb, ast, netrtg, oreb_pct, dreb_pct, usg_pct, ts_pct, ast_pct, season
	FROM public.player_seasons

SELECT * FROM public.player_seasons
	ORDER BY 1 ,2 ;
	
SELECT draft_year, avg(pts) FROM public.player_seasons
	where draft_year >= '1996' and draft_year <=  '2001'
	group by draft_year
	ORDER BY draft_year 
	;

	select count (*) FROM player_seasons; -- 12869
	select count (*) FROM players; 	   -- 3744  i.e. 1/3rd of the data

select * from players;

	select distinct  current_season from players; -- 804 * 6  = 3774;

select count (distinct player_name), sum (curr_ses) from (
	select player_name, count (current_season) as curr_ses from players -- 804
	group by player_name);

-- 804	3774
-- This gives me the unique players and the count of all records using only the primary key values 

	select * from players
	order by player_name;