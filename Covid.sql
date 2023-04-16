SELECT * 
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM Vacinations
ORDER BY 3,4

-- Select Data to be utilised

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

-- Calculating at total cases vs total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases*100) AS Percentage
FROM CovidDeaths
WHERE continent is Null
ORDER BY 1,2

-- Calculating at total cases vs total deaths @ Malaysia

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases*100) AS Percentage
FROM CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2

-- Calculation total cases vs population

SELECT location,date,total_cases,population,((total_cases/population)*100) AS InfectedPercentage
FROM CovidDeaths
ORDER BY 1,2

SELECT location,date,population,total_cases,(total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2

-- Calculation of Country with Highest Infection Rate againts population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)*100) AS MaxPercentageInfected
FROM CovidDeaths
WHERE continent is not null
Group BY location, population
ORDER BY MaxPercentageInfected DESC

-- Calculation of countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Calculation of continent with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is null AND location <> 'World'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers Max Case, Death and Percentage

SELECT date,SUM(new_cases) AS TotalCase , SUM(CAST(new_deaths as int)) AS TotalDeath,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) AS TotalCase , SUM(CAST(new_deaths as int)) AS TotalDeath,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2 DESC

-- Calculating Total Population Vs Vacination

SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollVacinationSum
FROM CovidDeaths Dea
JOIN  Vacinations Vac
	ON Dea.location = Vac.location
	AND dea.date = Vac.date
WHERE Dea.continent is not null
ORDER by 2,3

-- Using CTE

WITH popVsVac (continent, Location, Date, Population,new_vaccinations, RollVacinationSum)
AS 
(
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollVacinationSum
FROM CovidDeaths Dea
JOIN  Vacinations Vac
	ON Dea.location = Vac.location
	AND dea.date = Vac.date
WHERE Dea.continent is not null
)

SELECT *, (RollVacinationSum/Population)*100 AS VacPercentage
FROM popVsVac

-- Using Temp Table
DROP TABLE IF EXISTS #percentPopVac
CREATE TABLE #percentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollVacinationSum numeric
)

INSERT INTO #percentPopVac
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollVacinationSum
FROM CovidDeaths Dea
JOIN  Vacinations Vac
	ON Dea.location = Vac.location
	AND dea.date = Vac.date
WHERE Dea.continent is not null

SELECT *, (RollVacinationSum/Population)*100 AS VacPercentage
FROM #percentPopVac

-- Create View to store data

CREATE VIEW percentPopVac AS 
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollVacinationSum
FROM CovidDeaths Dea
JOIN  Vacinations Vac
	ON Dea.location = Vac.location
	AND dea.date = Vac.date
WHERE Dea.continent is not null

SELECT * FROM percentPopVac