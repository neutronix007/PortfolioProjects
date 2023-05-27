--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country 
SELECT location, date, CAST(total_cases AS numeric) as total_cases, CAST(total_deaths AS numeric) as total_deaths, (CAST(total_deaths AS numeric) * 100.0 / CAST(total_cases AS numeric)) as DeathPercentage
FROM CovidDeaths
WHERE location like '%ghana%' and continent is not null
ORDER BY location, date;


-- Looking at total cases vs population
-- Shows what percentage of pupulation got covid
SELECT location, date, CAST(total_cases AS numeric) as total_cases, CAST(population AS numeric) as population, ROUND ((CAST(total_cases AS numeric) * 100.0 / CAST(population AS numeric)),5) as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is not null
ORDER BY location, date;

-- Looking at countries with highest infection rate compared to population
SELECT location, MAX(CAST(total_cases AS numeric)) AS  HighestInfectionCount, MAX(CAST(total_cases AS numeric)) * 100.0 / CAST (population AS numeric) AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


 --Sorting by income
SELECT location, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is null AND location like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- This is showing the continents with the highest death rate
SELECT continent, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBES
SELECT date, SUM(CAST(new_cases as numeric)),  SUM(CAST(new_deaths as int)), sum(CAST(new_deaths as int))/sum(CAST(new_cases as numeric))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER By 1, 2

SELECT date, SUM(CAST(new_cases AS numeric)) as total_cases, SUM(CAST(new_deaths AS numeric)) as total_deaths,
    SUM(CAST(new_deaths AS numeric)) * 100.0 / NULLIF(SUM(CAST(new_cases AS numeric)), 0) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


SELECT SUM(CAST(new_cases AS numeric)) as total_cases, SUM(CAST(new_deaths AS numeric)) as total_deaths,
    SUM(CAST(new_deaths AS numeric)) * 100.0 / NULLIF(SUM(CAST(new_cases AS numeric)), 0) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations , 
SUM(CAST(vacs.new_vaccinations as numeric) ) OVER (PARTITION by deaths.location 
	ORDER By deaths.location, deaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null
ORDER BY 1, 2, 3


--USING CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations , 
SUM(CAST(vacs.new_vaccinations as numeric) ) OVER (PARTITION by deaths.location 
	ORDER By deaths.location, deaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null
--ORDER BY 1, 2, 3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric )
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations , 
SUM(CAST(vacs.new_vaccinations as numeric) ) OVER (PARTITION by deaths.location 
	ORDER By deaths.location, deaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null
--ORDER BY 1, 2, 3
SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating a view to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW  PercentPopulationVaccinated as 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations , 
SUM(CAST(vacs.new_vaccinations as numeric) ) OVER (PARTITION by deaths.location 
	ORDER By deaths.location, deaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null and deaths.continent = 'Africa'
--ORDER BY 1, 2, 3

CREATE VIEW TotalWorldCasesVsDeathsPercentage AS
SELECT SUM(CAST(new_cases AS numeric)) as total_cases, SUM(CAST(new_deaths AS numeric)) as total_deaths,
    SUM(CAST(new_deaths AS numeric)) * 100.0 / NULLIF(SUM(CAST(new_cases AS numeric)), 0) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2

CREATE VIEW SortingByIncome AS
 --Sorting by income
SELECT location, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is null AND location like '%income%'
GROUP BY location


CREATE VIEW MaxCountriesDeathCount AS 
-- Looking at countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
--WHERE location like '%ghana%'
WHERE continent is not null
GROUP BY location, population
ORDER BY totaldeathcount DESC


CREATE VIEW MaxDeathCountGhana AS 
SELECT location, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
WHERE location like '%ghana%'
and continent is not null
GROUP BY location, population

CREATE VIEW MaxCasesCountGhana AS
SELECT location, MAX(CAST(total_cases AS numeric)) AS  TotalCaseCount
FROM CovidDeaths
WHERE location like '%ghana%'
and continent is not null
GROUP BY location, population


CREATE VIEW PercentafeVsInfectioncountVsPopulation AS
-- Looking at countries with highest infection rate compared to population
SELECT location, MAX(CAST(total_cases AS numeric)) AS  HighestInfectionCount,Max(population) AS TotalPopulation, ROUND(MAX(CAST(total_cases AS numeric)) * 100.0 / CAST (population AS numeric),2)AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%ghana%'
and continent is not null
GROUP BY location, population


CREATE VIEW MaxDeathCountAfrica AS 
SELECT continent, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount
FROM CovidDeaths
WHERE location like '%ghana%'
and continent is not null
GROUP BY continent, population


CREATE VIEW MaxDeathCountContinents AS 
SELECT continent, MAX(CAST(total_deaths AS numeric)) AS  TotalDeathCount, MAX(population) AS TotalPopulation
FROM CovidDeaths
--WHERE location like '%ghana%'
Where continent is not null and total_deaths is not null
GROUP BY continent

