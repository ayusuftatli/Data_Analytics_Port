SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..covid_death
WHERE location = 'Germany'
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Covid_Percentage
FROM PortfolioProject..covid_death
--WHERE location = 'Denmark'
ORDER BY 1, 2 DESC

-- Looking at Countries with Highest Infection Rate compared to population (cumulative)
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS Max_Covid_Percentage
FROM PortfolioProject..covid_death
GROUP BY location, population
ORDER BY Max_Covid_Percentage desc

-- Showing Countries with Highest Death count per population

SELECT location, MAX(CAST(total_deaths AS bigint)) as TotalDeathCount
FROM PortfolioProject..covid_death
WHERE continent is not null -- Filtering out continents from the location column
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths AS bigint)) as TotalDeathCount
FROM PortfolioProject..covid_death
WHERE continent is null -- Filtering out continents from the location column
GROUP BY location
ORDER BY TotalDeathCount DESC

-- global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_death
where continent is not null
GROUP by date
order by 1,2
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject..covid_death dea
 JOIN PortfolioProject..covid_vacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject..covid_death dea
JOIN PortfolioProject..covid_vacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject..covid_death dea
JOIN PortfolioProject..covid_vacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject..covid_death dea
JOIN PortfolioProject..covid_vacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

