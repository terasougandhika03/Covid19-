-- 1.

SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, 
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL 
-- GROUP BY date
ORDER BY 1, 2;

-- 2.

SELECT 
    location, 
    SUM(CAST(new_deaths AS SIGNED)) AS TotalDeathCount
FROM 
    CovidDeaths
WHERE 
    continent IS NULL 
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

-- 3.

SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM 
    CovidDeaths
GROUP BY 
    Location, Population
ORDER BY 
    PercentPopulationInfected DESC;

-- 4.

SELECT 
    Location, 
    Population, 
    date, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM 
    CovidDeaths
GROUP BY 
    Location, Population, date
ORDER BY 
    PercentPopulationInfected DESC;

-- 5.

SELECT 
    Location, 
    date, 
    population, 
    total_cases, 
    total_deaths
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL 
ORDER BY 
    1, 2;

-- 6. Using a Common Table Expression (CTE) for MySQL 8.0 and later

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM 
        CovidDeaths dea
    JOIN 
        CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL 
)
SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS PercentPeopleVaccinated
FROM 
    PopvsVac;

-- 7.

SELECT 
    Location, 
    Population, 
    date, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM 
    CovidDeaths
GROUP BY 
    Location, Population, date
ORDER BY 
    PercentPopulationInfected DESC;
