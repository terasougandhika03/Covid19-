Use coviddb;
-- Countries with the highest number of daily new cases
SELECT location, date, new_cases
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY new_cases DESC
LIMIT 10; -- Show top 10 countries with the highest daily new cases

-- Monthly trend of total cases for each country
SELECT location, DATE_FORMAT(date, '%Y-%m') AS month, SUM(new_cases) AS monthly_cases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, DATE_FORMAT(date, '%Y-%m')
ORDER BY location, month;

-- Average daily cases and deaths by continent
SELECT continent, AVG(new_cases) AS avg_daily_cases, AVG(new_deaths) AS avg_daily_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent;

-- Total cases and deaths by region (grouped by continent)
SELECT continent, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC;

-- Calculate the daily increase in vaccinations for each country
SELECT location, date, new_vaccinations, 
       new_vaccinations - LAG(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS DailyVaccinationIncrease
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Countries with the lowest death rate (total deaths / total cases) for countries with at least 100,000 cases
SELECT location, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, 
       (MAX(total_deaths) / MAX(total_cases)) * 100 AS DeathRate
FROM CovidDeaths
WHERE total_cases > 100000
GROUP BY location
ORDER BY DeathRate ASC
LIMIT 10;

-- Analyze vaccination rates by continent
SELECT dea.continent, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) AS total_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) / SUM(dea.population) * 100 AS VaccinationRate
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent
ORDER BY VaccinationRate DESC;

-- Compare daily new cases and deaths for the United States
SELECT date, new_cases, new_deaths
FROM CovidDeaths
WHERE location = 'Afghanistan'
ORDER BY date;

-- Days with the highest death toll for each continent
SELECT continent, date, SUM(new_deaths) AS daily_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, date
ORDER BY daily_deaths DESC;
