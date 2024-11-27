SELECT player_name, age, height, weight, college, country, draft_year, draft_round, draft_number, gp, pts, reb, ast, netrtg, oreb_pct, dreb_pct, usg_pct, ts_pct, ast_pct, season
	FROM public.player_seasons;

	SELECT * FROM public.player_seasons
	ORDER BY 1 ,2 ;

	-- STRUCT

	CREATE TYPE SEASON_STATS AS (
		SEASON INTEGER,
		GP INTEGER,
		pts REAL,
		reb real,
		ast real
	);

 CREATE TYPE scoring_class AS
     ENUM ('bad', 'average', 'good', 'star');

drop table if exists players;
 
 CREATE  TABLE players (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     season_stats season_stats[],
     --scoring_class scoring_class,
     --years_since_last_active INTEGER,
     --is_active BOOLEAN,
     current_season INTEGER,
	 actual_today_season INTEGER,
	 actual_yesterday_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );


select min (season) from player_seasons;

-- SEED Query for CUMULATION 

insert into players
with yesterday as (
	select * from players 
	where current_season = 2000
),
	today as (
	select * from player_seasons
	where season = 2001
	)
select 
coalesce(t.player_name,y.player_name) as player_name,
coalesce(t.height,y.height) as height,
coalesce(t.college,y.college) as college,
coalesce(t.country,y.country) as country,
coalesce(t.draft_year,y.draft_year) as draft_year,
coalesce(t.draft_round,y.draft_round) as draft_round,
coalesce(t.draft_number,y.draft_number) as player_name,
case when y.season_stats is NULL  -- this is first season for a player
	THEN array [row(
		t.SEASON,
		t.GP,
		t.pts,
		t.reb,
		t.ast
	)::season_stats	]
	when t.season is not null then y.season_stats || array[row(  -- the player is playing this season
		t.SEASON,
		t.GP,
		t.pts,
		t.reb,
		t.ast
	)::season_stats	]
	else y.season_stats  -- this holds on to the last values for a player
	end as season_stats,
	coalesce (t.season, y.current_season + 1) as current_season, t.season as ts, y.current_season as cs
from today t full outer join yesterday y
	on t.player_name = y.player_name
;

select * from players
where player_name like 'Michael Jordan'
and current_season = 2001;

-- the table can be easily inflated to make it like player_season

with unnested as (
select player_name, 
unnest(season_stats) as season_st
from players
where 
--player_name like 'Michael Jordan' and
current_season = 2001
)
select player_name, (season_st::season_stats).* from unnested
;

-- cumulative design is Sorted as well

-----------------------------------------------------------------------------

-- adding few more columns to players 


drop table if exists players;
 
 CREATE  TABLE players (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     season_stats season_stats[],
     scoring_class scoring_class,
     years_since_last_season INTEGER,
     --is_active BOOLEAN,
     current_season INTEGER,
	 actual_today_season INTEGER,
	 actual_yesterday_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );


-- SEED Query for CUMULATION 

insert into players
with yesterday as (
	select * from players 
	where current_season = 2000
),
	today as (
	select * from player_seasons
	where season = 2001
	)
select 
coalesce(t.player_name,y.player_name) as player_name,
coalesce(t.height,y.height) as height,
coalesce(t.college,y.college) as college,
coalesce(t.country,y.country) as country,
coalesce(t.draft_year,y.draft_year) as draft_year,
coalesce(t.draft_round,y.draft_round) as draft_round,
coalesce(t.draft_number,y.draft_number) as player_name,
case when y.season_stats is NULL  -- this is first season for a player
	THEN array [row(
		t.SEASON,
		t.GP,
		t.pts,
		t.reb,
		t.ast
	)::season_stats	]
	when t.season is not null then y.season_stats || array[row(  -- the player is playing this season
		t.SEASON,
		t.GP,
		t.pts,
		t.reb,
		t.ast
	)::season_stats	]
	else y.season_stats  -- this holds on to the last values for a player
	end as season_stats,
	case when t.season is not null then 
		case when t.pts > 20 then 'star'
		when t.pts > 15 then 'good'
		when t.pts > 10 then 'average'
		else 'bad'
	end :: scoring_class   --enum enumerations only the values mentioned can be used, like drop down
	else y.scoring_class
	end,   -- for first case  
	case when t.season is not null then 0
		else y.years_since_last_season + 1
	end as years_since_last_season,	
	coalesce (t.season, y.current_season + 1) as current_season, t.season as ts, y.current_season as cs
from today t full outer join yesterday y
	on t.player_name = y.player_name
;


select * from players
where player_name like 'Michael Jordan';
and current_season = 2001;

---------------------------------------------------------------------------
-- Analytics 

select player_name,
(season_stats[cardinality(season_stats)]::season_stats).pts,cardinality(season_stats),
(season_stats[1]::season_stats).pts,
(season_stats[1]::season_stats).pts/
case when (season_stats[cardinality(season_stats)]::season_stats).pts = 0 
then 1 else (season_stats[cardinality(season_stats)]::season_stats).pts
end as Growth_times
from players
where current_season = 2001
order by growth_times desc; 
