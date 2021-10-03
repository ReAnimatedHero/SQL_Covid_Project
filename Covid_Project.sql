Select *
From CovidProject..covidDeath
where continent is not null
order by 3,4

--Select *
--From CovidProject..covidVacc
--order by 3,4

--Select Data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from CovidProject..covidDeath
order by 1,2

-- Looking at Total cases vs Total Deaths

select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
from CovidProject..covidDeath
where location like '%india%'
order by 1,2

-- Looking at Total Cases vs Population

select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentages
from CovidProject..covidDeath
where location like '%india%'
order by 1,2

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidProject..covidDeath
where continent is not null
order by 1,2

-- Looking at countries with Highest infection rate vs Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidProject..covidDeath
--where location like '%india%'
where continent is not null
group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..covidDeath
where continent is not null
group by Location, population
order by TotalDeathCount desc

-- Lets Break things by Continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..covidDeath
where continent is null
group by location
order by TotalDeathCount desc


-- Showing Continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..covidDeath
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentages
from CovidProject..covidDeath
where continent is not null
--group by date
order by 1,2


------- Covid Vaccination
select * 
from CovidProject..covidVacc

-- Join thw two tables

select * 
from CovidProject..covidDeath dea
join CovidProject..covidVacc vac
   on dea.location = vac.location
   and dea.date = vac.date

-- Looking at total population vs Vaccination

  -- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidProject..covidDeath dea
join CovidProject..covidVacc vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--- TEMP TABLE


drop table if exists #PercentPolulationvaccinated
create table #PercentPolulationvaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPolulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidProject..covidDeath dea
join CovidProject..covidVacc vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPolulationvaccinated



-- Creating View to store data for visualization


create view PercentPolulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidProject..covidDeath dea
join CovidProject..covidVacc vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPolulationvaccinated