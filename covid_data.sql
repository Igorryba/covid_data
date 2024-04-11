-- create table death_percentage_countries and then using cte get
-- location, continent, total_deaths, total_cases, population, death_percentage per country
create table death_percentage_countries as 
with cte as (select location, continent, coalesce(max(total_deaths), 0) as total_deaths,
			 max(total_cases) as total_cases, population
			 from covid_deaths group by location, continent, population order by location)
select cte.*, round((total_deaths/total_cases)::numeric * 100, 2) as death_percentage
from cte where continent is not null order by death_percentage


-- comparision of hdi to avg_death_percentage
with cte as (select distinct drc.location, drc.continent, drc.death_percentage,
cv.human_development_index as hdi  from death_percentage_countries drc
join covid_vaccinations cv on drc.location = cv.location order by hdi),

cte2 as(select '0.3-0.55' as hdi, round(avg(death_percentage)::numeric, 2)
as avg_death_percentage from cte where hdi between 0.3 and 0.55),

cte3 as(select '0.551-0.75' as hdi, round(avg(death_percentage)::numeric, 2)
as avg_death_percentage from cte where hdi between 0.551 and 0.75),

cte4 as(select '0.751-1' as hdi, round(avg(death_percentage)::numeric, 2)
as avg_death_percentage from cte where hdi between 0.751 and 1)

select * from cte2 union all select * from cte3 union all select * from cte4



-- percent of cases per population - countries
select location, continent, population, total_cases,
round((total_cases/population)::numeric * 100, 2) as cases_per_pop_ptg, death_percentage
from death_percentage_countries order by cases_per_pop_ptg desc



-- percent of cases per population - continents
with cte as 
(select location, continent, coalesce(max(total_deaths), 0) as total_deaths,
max(total_cases) as total_cases, population from covid_deaths
group by location, continent, population order by location)

select location, total_cases, population, 
round((total_cases/population)::numeric * 100, 2) as cases_per_pop_ptg,
round((total_deaths/total_cases)::numeric * 100, 2) as death_percentage
from cte where continent is null and
location not in('Upper middle income', 'World', 'European Union', 'High income',
'Low income', 'Lower middle income') order by cases_per_pop_ptg desc




-- continents and income based view
create view continents as
select * from covid_deaths where continent is null and date = '2024-03-03'

-- death_percentage table based on continents
select location, total_cases, total_deaths,
round((total_deaths/total_cases)::numeric * 100, 2) as death_percentage from continents where 
location not in('Upper middle income', 'World', 'European Union', 'High income', 'Low income',
'Lower middle income') order by death_percentage



-- death_percentage table based on income
select location, total_cases, total_deaths,
round((total_deaths/total_cases)::numeric * 100, 2) as death_percentage from continents where 
location in('Upper middle income', 'High income', 'Low income',
		 		'Lower middle income')
order by death_percentage



-- table based on top 3 highest amount of new cases per week per country,
-- percantage comparision of this new cases to overall population in a country
-- and date of this highest number of new cases
with cte as
(select location, continent, population, Coalesce(new_cases, 0) as new_cases_per_week,
rank() over (partition by location order by new_cases desc), date from covid_deaths
where new_cases > 0 and continent is not null),
cte2 as
(select location, continent, population, new_cases_per_week,
round((new_cases_per_week/population)::numeric * 100, 2) as max_cases_population_ptg,
date from cte where rank < 4)
select * from cte2 


-- table based on highest amount of new cases per week per country and their date
-- ordered descending by new cases per week
with cte as
(select location, continent, population, Coalesce(new_cases, 0) as new_cases_per_week,
rank() over (partition by location order by new_cases desc), date from covid_deaths
where new_cases > 0 and continent is not null)
select location, continent, population, new_cases_per_week, date from cte
where rank = 1 order by new_cases_per_week desc

