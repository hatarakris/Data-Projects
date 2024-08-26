SELECT * FROM CovidDeaths cd
WHERE continent != ''


-- Selecting Data that are going to be used.

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM CovidDeaths cd 
ORDER BY location, date


-- Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths, total_deaths / total_cases * 100 AS DeathPercentange
FROM CovidDeaths cd 
ORDER BY location, date


-- Total Cases vs. Population

SELECT location, date, population, total_cases, total_cases / population * 100 AS InfectedPercentage
FROM CovidDeaths cd 
WHERE continent IS NOT NULL
ORDER BY location, date


-- Finding out highest percentage of infected population from each countries.

SELECT location, population, MAX(CAST(total_cases AS BIGINT)) AS HighestInfectedCount, 
MAX(CAST(total_cases AS BIGINT)) / population * 100 AS HighestInfectedPercentage
FROM CovidDeaths cd 
GROUP BY location, population
ORDER BY HighestInfectedPercentage DESC


-- Finding out highest percentage of death from each countries

SELECT location, population, MAX(CAST(total_deaths AS BIGINT)) AS HighestDeathCount,
MAX(CAST(total_deaths AS BIGINT)) / population * 100 AS HighestDeathPercentage
FROM CovidDeaths cd 
WHERE continent != ''
GROUP BY location, population
ORDER BY HighestDeathCount DESC


-- Looking at total death count per continent

SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount	
FROM CovidDeaths cd 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Looking at new cases and new deaths worldwide pee day

SELECT date, sum(new_cases) AS new_cases, sum(new_deaths) AS new_deaths, sum(new_deaths) / sum(new_cases) AS DeathPercentage
FROM CovidDeaths cd 
WHERE continent != ''
GROUP BY date
ORDER BY 1,2


-- Finding out total vaccinations using CTE

WITH PopVac (Continent, Location, Date, Population, New_Vaccinations, Population_Vaccinated)
AS
(
	SELECT cd.continent, cd.location, cd.date, cd.population, cast(cv.new_vaccinations AS INT) AS new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS PopulationVaccinated
	FROM CovidDeaths cd 
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location 
		AND cd.date = cv.date
	WHERE cd.continent != ''
)
SELECT *, Population_Vaccinated / Population * 100 AS Vaccinated_Percentage
FROM PopVac
--WHERE Location = 'Indonesia'


-- Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	'Date' datetime,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	Population_Vaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent AS Continent, cd.location AS Location, cd.date AS Date, cd.population AS Population, cast(cv.new_vaccinations AS INT) AS New_Vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS Population_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent != ''
ORDER BY 2,3

SELECT *, CAST(Population_Vaccinated AS REAL) / Population * 100 AS Vaccinated_Percentage
FROM PercentPopulationVaccinated


-- Creating view

CREATE VIEW PopulationVaccinatedPercentage AS
SELECT cd.continent AS Continent, cd.location AS Location, cd.date AS Date, cd.population AS Population, cast(cv.new_vaccinations AS INT) AS New_Vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS Population_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent != ''