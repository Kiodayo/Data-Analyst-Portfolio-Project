SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

--Select Data that we are going to be us

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2;

--looking at total cases vs population
--shows what percentage of ppulation got covid
SELECT Location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- location like '%china%'
ORDER BY 1,2; 

--looking at countries with highest infection rate compared to population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- location like '%china%'
GROUP BY Location,population
ORDER BY PercentPopulationInfected desc; 

--showing countries with highest death count per population
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc; 

--showing continent with highest death count per population
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc; 

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


--LOOKING  at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date,population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac(CONTINENT,LOACATION,DATE,POPULATION,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population) * 100 
FROM PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE dea.continent is not null;

SELECT *,(RollingPeopleVaccinated/population) * 100 
FROM #PercentPopulationVaccinated

--create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE dea.continent is not null;

SELECT *
FROM PercentPopulationVaccinated