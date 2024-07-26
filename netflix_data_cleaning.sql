-- DATA CLEANING
-- identifying duplicates
select *
from netflix_raw
where concat(upper(title),type) in 
				(select concat(upper(title),type)
				from netflix_raw
				group by upper(title), type
				having count(*)>1)
order by title;
-- getting rid of duplicates
with cte as(
	select *, 
	ROW_NUMBER() over(partition by title, type order by show_id) as rn
	from netflix_raw)
select *
from cte
where rn=1;


-- new table for listed_in, director, cast, country (to make it easy to work with the data)
-- directors table
select show_id, trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director,',');
-- country table
select show_id, trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',');
-- cast table
select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',');
-- listed_in(genre) table
select show_id , trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',');


-- populate missing values in country,duration columns
-- country - based on the director's other films we can fill in the country
insert into netflix_country
select  show_id,m.country 
from netflix_raw nr
inner join (
select director,country
from  netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director,country
) m on nr.director=m.director
where nr.country is null;
-- duration - we notice rating values of such rows is in minutes
select director,country
from  netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director,country;
select * from netflix_raw where duration is null;
-- date_added type conversion and updating duration
with cte2 as(
		select *,ROW_NUMBER() over(partition by title, type order by show_id) as rn
		from netflix_raw)
select show_id, type, title, cast(date_added as date) as date_added, release_year,
	rating, case when duration is null then rating else duration end as duration, description
into netflix
from cte2;


-- cleaned data table that can now be used for analysis
select * from netflix;