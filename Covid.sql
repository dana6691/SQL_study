--- ===================================
--- Death table
--- ===================================
-- Death table with columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid..death$
WHERE continent is not null
ORDER BY 1,2

-- Total cases & Total deaths over the world
SELECT date, sum(total_cases) as TotalCases, sum(CAST(total_deaths as int)) as TotalDeaths
FROM covid..death$
GROUP BY date
ORDER BY 1

-- Top 10 countries with Highest Infection Rate
SELECT top 10 location, MAX(total_cases) as HighestInfection,MAX(total_cases/population)*100 as maxInfectionPercent
FROM covid..death$
WHERE continent is not null
GROUP BY location
ORDER BY maxInfectionPercent desc

-- Top 10 countries with Highest Death Rate
SELECT top 10 location, MAX(CAST(total_deaths as int)) as HighestDeath, MAX(total_deaths/population)*100 as maxDeathPercent
FROM covid..death$
WHERE continent is not null
GROUP BY location
ORDER BY maxDeathPercent desc

-- Highest Death Rate by Continent
SELECT top 10 continent, MAX(total_deaths/population)*100 as maxDeathPercent
FROM covid..death$
WHERE continent is not null
GROUP BY continent
ORDER BY maxDeathPercent desc

-- Likelihood of dying with covid in South Korea
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM covid..death$
WHERE location like '%Korea%'
ORDER BY 1,2

-- Daily Infection Rate in South Korea
SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 as InfectionPercent
FROM covid..death$
WHERE location like '%Korea%' 
ORDER BY 1,2
--- ===================================
--- Vaccination table
--- ===================================
SELECT *
FROM covid..vaccination$
--- ===================================
--- Join two tables
--- ===================================
SELECT dead.location, dead.date, dead.continent, dead.population, vacc.new_vaccinations
FROM covid..death$ dead 
JOIN covid..vaccination$ vacc
ON dead.location = vacc.location and dead.date = vacc.date
WHERE dead.continent is not null
ORDER BY 1,2
-- Cumulative 