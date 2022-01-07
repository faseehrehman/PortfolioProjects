select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations


-- Select the data I will be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths
-- Show the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths /total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2


--- looking at total cases vs population
----Shows what percent of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as Percentage
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2


------ Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentagePopulationInfected
from PortfolioProject..CovidDeaths
---where location like '%states%'
group by Location, Population
order by PercentagePopulationInfected desc

--Showing countries witht the Highest death count per population
SELECT Location,  MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


---Break things down by continent

SELECT continent,  MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing countries with the highest death count per population

SELECT continent,  MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(New_Deaths as int))/SUM(New_cases)*100 as 
	DeathPercentage
from PortfolioProject..CovidDeaths
--where location like'%states%'
where continent is not null
--group by date
order by 1,2

---Looking at total Population vs Vaccination
-- use CTE


DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255)
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating to view to store data  for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create view TotalDeathsvsTotalCases as

SELECT location, date, total_cases, total_deaths, (total_deaths /total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like'%states%'
--order by 1,2


create view GlobalNumbers as 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(New_Deaths as int))/SUM(New_cases)*100 as 
	DeathPercentage
from PortfolioProject..CovidDeaths
--where location like'%states%'
where continent is not null
--group by date
--order by 1,2




