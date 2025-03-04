--15 Business issues

select * from public.netflix

--1 count the number of movies vs TV shows

select type,count(show_id)
from public.netflix
group by type


--2 find the most commom rating for movies and TV shows

select type,rating
from
(select type, rating,count(*), rank() over(partition by type order by count(*) desc )
from public.netflix
group by type, rating)
where rank = 1


--3 List all the movies relesed in specific year

select * from public.netflix
where type = 'Movie' and release_year = 2020


--4 find the top 5 countries with the most content on netflix

Select 
unnest(string_to_array(country,',')) as new_country, count(show_id) Total_Content 
from public.netflix
group by country
order by Total_Content desc
limit 5

--5 Identify the longestt movie

Select * from public.netflix
where type = 'Movie' and duration = (select max(duration)from public.netflix)

--6 find the content dded in the last 5 years 

Select * from public.netflix
where to_date(date_added,'Month DD, YYYY')>= current_date - interval '5 years'

--7 find all the movies/tv shows by director 'Rajiv Chilaka'

select * from public.netflix
where director Ilike '%Rajiv Chilaka%'

--8 list all the TV shows with more than 5 seasons

select * from public.netflix
where type = 'TV Show' and 
split_part(duration,' ',1)::numeric > 5


--9 count the number of content items in each genre

Select unnest(string_to_array(listed_in,',')) as Genre, count(show_id) Total_Content 
from public.netflix
group by Genre 
order by Total_Content desc


--10 find each year and the average number of content release by India on netflix
--return top 5 years with hightest avg content relese

--Total content eg. (333/972 *100)

Select extract(year from to_date(date_added,'month dd,yyyy'))as date, count(*) as yearly_content,
Round (count (*)::numeric/(select count(*) from public.netflix where country = 'India')::numeric *100, 2) as Avg_content_per_year
from public.netflix
where country = 'India'
group by date
order by Avg_content_per_year desc
limit 5


--11 list all the movies that ar documentories

Select * 
from public.netflix
where listed_in ilike '%Documentaries%'

--12 find all the content without a director

Select * 
from public.netflix
where director is null

--13 find how many movies actor 'Salman Khan' appeared in last 10 years

Select * 
from public.netflix
where casts ilike '%Salman Khan%' 
and release_year > extract (year from current_date )- 10


--14 Find the top 10 actors who have appeared in the hightest number of movies produced in India

Select unnest(string_to_array (casts, ',')) Actors, count(show_id) TOtal_content, country
from public.netflix
where country ilike '%India%'
group by Actors, country
order by TOtal_content desc
limit 10


--15 categorize the content based on the presence of the keywords 'kill' and 'violence' in the discriptiion field.
-- label content containing these key words as 'bad' and all other content as 'good'. count how many itmes fall into each category.


with content_category
as
(select * ,
case
when 
description ilike '%kill%' 
or 
description ilike '%violence%'
then 'Bad_content'
else 'Good_content'
end category
from public.netflix)
select category, count(*) total_content
from content_category
group by category











