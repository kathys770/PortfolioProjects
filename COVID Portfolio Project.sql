
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths
-- Additional Syntax to pouplate numberic function
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE ISNUMERIC(total_cases) = 0 OR ISNUMERIC(total_deaths) = 0;

UPDATE PortfolioProject..CovidDeaths$
SET total_cases = NULL
WHERE ISNUMERIC(total_cases) = 0;

UPDATE PortfolioProject..CovidDeaths$
SET total_deaths = NULL
WHERE ISNUMERIC(total_deaths) = 0;

ALTER TABLE PortfolioProject..CovidDeaths$
ALTER COLUMN total_cases INT;

ALTER TABLE PortfolioProject..CovidDeaths$
ALTER COLUMN total_deaths INT;
--Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths,(total_deaths * 1.0 / total_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%state%'
ORDER BY 1,2

--Total Cases vs Population
-- Additional Syntax to pouplate numberic function
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE ISNUMERIC(total_cases) = 0 OR ISNUMERIC(population) = 0;

UPDATE PortfolioProject..CovidDeaths$
SET total_cases = NULL
WHERE ISNUMERIC(total_cases) = 0;

UPDATE PortfolioProject..CovidDeaths$
SET population = NULL
WHERE ISNUMERIC(population) = 0;

SELECT Location, date, total_cases, total_deaths,
       (COALESCE(total_cases, 0) / NULLIF(COALESCE(population, 1), 0)) * 100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%state%'
ORDER BY Location, date;
--Total Cases vs Population
SELECT Location, date, total_cases, total_deaths,(total_cases/ population) *100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE location like '%state%'
ORDER BY 1,2

-- Countries with Highest Infection Rates compared to Population
-- Additional Syntax to pouplate numberic function
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE ISNUMERIC(total_cases) = 0 OR ISNUMERIC(population) = 0;

UPDATE PortfolioProject..CovidDeaths$
SET total_cases = NULL
WHERE ISNUMERIC(total_cases) = 0;

UPDATE PortfolioProject..CovidDeaths$
SET population = NULL
WHERE ISNUMERIC(population) = 0;
--Highest Countries with Highest Infection Rate
SELECT Location,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((COALESCE(total_cases, 0) * 1.0 / NULLIF(COALESCE(population, 1), 0)) * 100) AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC

--Countries with the Highest Death Counts per Population
SELECT Location, MAX(cast(total_deaths as INT)) as TotalDeathCount    
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC

--Showing Continent with Highest Death Counts Per Population
SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount    
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers
-- GROUP BY DATE
SELECT 
    date,
    SUM(new_cases) AS TotalNewCases, 
    SUM(COALESCE(cast(new_deaths as INT), 0)) AS TotalNewDeaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0  -- Handle divide by zero
        ELSE SUM(COALESCE(cast(new_deaths as INT), 0)) * 100.0 / SUM(new_cases) 
    END as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers
-- Order BY 1,2
SELECT 
    
    SUM(new_cases) AS TotalNewCases, 
    SUM(COALESCE(cast(new_deaths as INT), 0)) AS TotalNewDeaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0  -- Handle divide by zero
        ELSE SUM(COALESCE(cast(new_deaths as INT), 0)) * 100.0 / SUM(new_cases) 
    END as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations
DROP TABLE if exist #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT*, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac

--TEMP Table

CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated / Population) * 100 as PercentageVaccinated
FROM #PercentPopulationVaccinated

DROP TABLE #PercentPopulationVaccinated; -- Don't forget to drop the temporary table after use if you no longer need it

-- CREATE VIEW to Store Data for Later Visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
