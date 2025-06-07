/*
--------------------------------------------------------------------------------
Project: COVID-19 Data Analysis Portfolio
Description:
This project contains a collection of SQL queries developed to analyze COVID-19 
data across multiple countries and continents. The queries provide insights into 
key metrics such as total cases, deaths, infection rates relative to population, 
and vaccination progress over time. 

Techniques used include:
- Aggregations and grouping for summary statistics
- Window functions for running totals and rolling calculations
- Joins to combine data from deaths and vaccination datasets
- Use of Common Table Expressions (CTEs), temporary tables, and views to 
  organize and optimize query logic

Purpose:
To demonstrate data exploration, transformation, and reporting capabilities using 
SQL in a real-world public health dataset.
--------------------------------------------------------------------------------
*/


-- Retrieve all records from CovidDeaths table, ordered by the 3rd and 4th columns (date and total_cases)
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

-- Retrieve all records from CovidVaccinations table, ordered by the 3rd and 4th columns (date and new_vaccinations)
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

-- Select relevant COVID death data to be used for analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Calculate death percentage in Nigeria based on total cases and total deaths
SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2;

-- Calculate percentage of the population infected in Nigeria
SELECT location, date, population, total_cases,
       (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria'
ORDER BY 1,2;

-- Find countries with the highest infection rates compared to their population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
       MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS Infected_PopulationPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Infected_PopulationPercentage DESC;

-- Identify countries with the highest death counts relative to population
SELECT location, population, 
       MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC;

-- Aggregate total deaths by continent
SELECT continent, 
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global summary of new cases, new deaths, and death percentage over time
SELECT date, 
       SUM(new_cases) AS TotalCases, 
       SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
       CASE
           WHEN SUM(new_cases) = 0 THEN NULL
           ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Global totals for new cases, deaths, and death percentage without date grouping
SELECT
       SUM(new_cases) AS TotalCases, 
       SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
       CASE
           WHEN SUM(new_cases) = 0 THEN NULL
           ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Join deaths and vaccinations to compare total population and new vaccinations by continent and location
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- Add running total of people vaccinated per location using window function
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       NULLIF(SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date), 0) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- Using CTE to calculate rolling vaccinated population percentage
WITH PopvsVac AS (
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
           NULLIF(SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date), 0) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths d
    JOIN PortfolioProject..CovidVaccinations v
        ON d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Create and populate temporary table for percentage of population vaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       NULLIF(SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date), 0) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location AND d.date = v.date;

-- Display temporary table with calculated percentage vaccinated
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;

-- Create a view for easy access to vaccination progress over time
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       NULLIF(SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date), 0) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- Query the view for final results
SELECT *
FROM PercentPopulationVaccinated;
