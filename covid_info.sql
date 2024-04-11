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

low_hdi as(select '0.3-0.55' as hdi, round(avg(death_percentage)::numeric, 2)
as avg_death_percentage from cte where hdi between 0.3 and 0.55),

mid_hdi as(select '0.551-0.75' as hdi, round(avg(death_percentage)::numeric, 2)
as avg_death_percentage from cte where hdi between 0.551 and 0.75),

high_hdi as(select '0.751-1' as hdi, round(avg(death_percentage)::numeric, 2)
as avg_death_percentage from cte where hdi between 0.751 and 1)

select * from low_hdi union all select * from mid_hdi union all select * from high_hdi



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





-- Creating table with some information about covid deaths and vaccinations 
create table covid_dea_vac as
(select cd.location, cd.continent, cd.date, cd.population, cd.total_cases, cd.new_cases,
cd.total_deaths, cd.new_deaths, cv.total_tests, cv.new_tests, cv.total_vaccinations,
cv.people_vaccinated, cv.people_fully_vaccinated, cv.new_vaccinations
from covid_deaths cd join covid_vaccinations cv on cd.location = cv.location
and cv.date = cd.date)



select * from covid_dea_vac where continent is not null order by location, date







select * from covid_deaths



-- change name of the table
drop table death_rate_countries

-- show all existing tables
SELECT * FROM pg_catalog.pg_tables;



-- countries where vaccination rate is greater than the average rate of all countries
-- with cte as
-- (select cv.location, max(cv.people_fully_vaccinated) as people_fully_vaccinated
-- from covid_vaccinations cv
-- where cv.people_fully_vaccinated is not null group by cv.location), 
-- cte2 as
-- (select distinct cd.location, cd.population from covid_deaths cd), 
-- cte3 as
-- (select cte.location, people_fully_vaccinated, population,
-- round((people_fully_vaccinated/population)::numeric * 100, 2) as vaccination_rate
-- from cte join cte2 on cte.location = cte2.location order by vaccination_rate desc)
-- select * from cte3 where cte3.vaccination_rate > (select avg(vaccination_rate) from cte3)




