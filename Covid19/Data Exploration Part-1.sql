-- Create a new database named 'coviddb'
CREATE DATABASE coviddb;

-- Switch to the 'coviddb' database
USE coviddb;

-- Select all data from the CovidDeaths table
SELECT * FROM CovidDeaths;

-- Select all data from the CovidVaccinations table
SELECT * FROM CovidVaccinations;

/*
Covid-19 Data Exploration
Performed Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select all data from the CovidDeaths table where continent is not NULL, ordered by columns 3 (likely date) and 4
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select specific columns from CovidDeaths where continent is not NULL, ordered by location and date
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Calculate Death Percentage: Total Deaths / Total Cases * 100, filtered for 'states' in location
SELECT Location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY 1, 2;

-- Calculate the percentage of the population infected by total cases / population * 100
SELECT Location, date, Population, total_cases, 
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
ORDER BY 1, 2;

-- Get countries with the highest infection rate relative to their population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Get countries with the highest total death count
SELECT Location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Summarize total death counts by continent
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Summarize global statistics: total cases, total deaths, and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, 
       (SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;

-- Calculate rolling vaccinations for each location by joining CovidDeaths and CovidVaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
       OVER (PARTITION BY dea.Location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Using a CTE (Common Table Expression) to calculate rolling vaccinations and vaccination percentage
WITH PopvsVac AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
         OVER (PARTITION BY dea.Location ORDER BY dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
-- Calculate percentage of population vaccinated using the CTE
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Create a temporary table to store rolling vaccination data
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
  Continent VARCHAR(255),
  Location VARCHAR(255),
  Date DATETIME,
  Population DECIMAL(20, 2),
  New_vaccinations DECIMAL(20, 2),
  RollingPeopleVaccinated DECIMAL(20, 2)
);

-- Populate the temporary table with vaccination data
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
       OVER (PARTITION BY dea.Location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location AND dea.date = vac.date;

-- Calculate percentage of population vaccinated from the temporary table
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- Create or replace a view to store vaccination data for future use
CREATE OR REPLACE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
       OVER (PARTITION BY dea.Location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
