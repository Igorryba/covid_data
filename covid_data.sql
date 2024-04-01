-- create table based on covid_deaths and get
-- location, continent, total_deaths, total_cases, population per country
create table death_rate_countries as 
with cte as (select location, continent, coalesce(max(total_deaths), 0) as total_deaths,
			 max(total_cases) as total_cases, population
			 from covid_deaths group by location, continent, population order by location)
select cte.*, round((total_deaths/total_cases)::numeric * 100, 2) as death_rate
from cte where continent is not null order by death_rate


-- comparision of hdi to death_rate
with cte as (select distinct drc.location, drc.continent, drc.death_rate,
cv.human_development_index as hdi  from death_rate_countries drc
join covid_vaccinations cv on drc.location = cv.location order by hdi),
cte2 as(select '0.3-0.55' as hdi, round(avg(death_rate)::numeric, 2) as avg_death_rate 
		from cte where hdi between 0.3 and 0.55),
cte3 as(select '0.551-0.75' as hdi, round(avg(death_rate)::numeric, 2) as avg_death_rate 
		from cte where hdi between 0.551 and 0.75),
cte4 as(select '0.751-1' as hdi, round(avg(death_rate)::numeric, 2) as avg_death_rate 
from cte where hdi between 0.751 and 1)
select * from cte2 union all select * from cte3 union all select * from cte4


-- rate of cases per population - countries
select location, continent, population, total_cases,
round((total_cases/population)::numeric * 100, 2) as cases_per_pop_rate, death_rate
from death_rate_countries order by cases_per_pop_rate desc

-- rate of cases per population - continents
with cte as (select location, continent, coalesce(max(total_deaths), 0) as total_deaths,
			 max(total_cases) as total_cases, population
			 from covid_deaths group by location, continent, population order by location)
select location, total_cases, population, 
round((total_cases/population)::numeric * 100, 2) as cases_per_pop_rate,
round((total_deaths/total_cases)::numeric * 100, 2) as death_rate
from cte where continent is null and
location not in('Upper middle income', 'World', 'European Union', 'High income', 'Low income',
				'Lower middle income') order by cases_per_pop_rate desc


-- death_rate table based on continents
select location, total_cases, total_deaths,
round((total_deaths/total_cases)::numeric * 100, 2) as death_rate from continents where 
location not in('Upper middle income', 'World', 'European Union', 'High income', 'Low income',
				'Lower middle income')
order by death_rate

