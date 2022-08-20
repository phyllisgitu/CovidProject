SELECT *
FROM [CovidProject].[dbo].[CovidDeaths]
ORDER BY 3, 4

SELECT *
FROM [CovidProject].[dbo].[CovidVaccinations]
ORDER BY 3, 4

--1. Query CovidDeaths
--Select Location, Date, New Cases, Total Deaths and Population
SELECT location, date, new_cases, total_deaths, population
FROM [CovidProject].[dbo].[CovidDeaths]
ORDER BY 1, 2

--Total Deaths vs New Cases
SELECT location, date, new_cases, total_deaths, (total_deaths_per_million/total_cases_per_million)*100 AS deathpercentage
FROM [CovidProject].[dbo].[CovidDeaths]
WHERE location LIKE '%Turkey%'
ORDER BY 1, 2

-- New Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population new_cases, (new_cases/population)*100 as percentagenewinfections
From [CovidProject].[dbo].[CovidDeaths]
Order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases_per_million) as HighestInfectionCount,  MAX(new_cases/population)*100 as HighestPercentageNewInfections
From [CovidProject].[dbo].[CovidDeaths]
Group by location, population
order by HighestPercentageNewInfections desc


-- Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From [CovidProject].[dbo].[CovidDeaths]
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- Showing Contintents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From [CovidProject].[dbo].[CovidDeaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Numbers globally

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths )/SUM(new_cases)*100 as DeathPercentage
From [CovidProject].[dbo].[CovidDeaths]
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From [CovidProject].[dbo].[CovidDeaths] d
Join [CovidProject].[dbo].[CovidVaccinations] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [CovidProject].[dbo].[CovidDeaths] d
Join [CovidProject].[dbo].[CovidVaccinations] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [CovidProject].[dbo].[CovidDeaths] d
Join [CovidProject].[dbo].[CovidVaccinations] v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [CovidProject].[dbo].[CovidDeaths] d
Join [CovidProject].[dbo].[CovidVaccinations] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
