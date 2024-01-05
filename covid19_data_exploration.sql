SELECT * 
FROM new_schema.vaccines
;

SELECT * 
FROM new_schema.deaths
where continent != ''
order by date desc
;

-- Select Data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM new_schema.deaths
;

-- Looking at Total Cases vs Total Deaths
-- Shows likihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
FROM new_schema.deaths
where location like '%states'
and continent != ''
;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM new_schema.deaths
where location like '%states'
;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, cast(population as unsigned) as population,max(cast(total_cases as unsigned)) as HighestInfectionCount, (max(cast(total_cases as unsigned))/population)*100 as PercentPopulationInfected
FROM new_schema.deaths
group by location, population
order by PercentPopulationInfected desc
-- where location like '%ina%'
;

-- Showing Countires with Highest Death Count per Population
-- https://dev.mysql.com/doc/refman/8.2/en/cast-functions.html#function_cast

SELECT location, max(cast(total_deaths as unsigned)) as TotalDeathCount
FROM new_schema.deaths
where continent != ''
group by location
order by TotalDeathCount desc
-- where location like '%ina%'
;

-- LET'S BREAK THINGS BY CONTINENT

-- Showing continets with the highest death count per population

SELECT location, max(cast(total_deaths as unsigned)) as TotalDeathCount
FROM new_schema.deaths 
where continent = ''
and location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location
order by TotalDeathCount desc
;

-- GLOBAL NUMBERS

SELECT date,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as deathpercentage
FROM new_schema.deaths
where continent != ''
group by date
order by 2
;

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as deathpercentage
FROM new_schema.deaths
where continent != ''
;



-- Looking at Total Population vs Vaccinations

SELECT * 
FROM new_schema.vaccines
;

SELECT * 
FROM new_schema.deaths dea
Join new_schema.vaccines vac
	on dea.location = vac.location
    and dea.date = vac.date
;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecaccinated
FROM new_schema.deaths dea
Join new_schema.vaccines vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
-- order by 2,3
;

-- USE CTE to use a just defined data in select

with popvsvac (Continent, location, date, population, new_vaccinations, rollingpeoplecaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecaccinated
FROM new_schema.deaths dea
Join new_schema.vaccines vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
)
select *, (rollingpeoplecaccinated/population)*100
from popvsvac
;





-- TEMP TABLE

drop table if exists PercentPopulationVaccinated
;

create table PercentPopulationVaccinated
(
continent text,
location text,
date text,
population text,
new_vaccinations text,
rollingpeoplevaccinated text
)
;

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecaccinated
FROM new_schema.deaths dea
Join new_schema.vaccines vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
;

select *, (rollingpeoplevaccinated/population)*100
from PercentPopulationVaccinated
;

-- Creating View to store data for later visualization

create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecaccinated
FROM new_schema.deaths dea
Join new_schema.vaccines vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
;