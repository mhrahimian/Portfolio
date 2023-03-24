/*
This is a Covid19 Data Exploration Project.

I used skills such as Joins, Aggregate Functions, CTE's, Data Tyoe Conversion, Creating Views,  Temp Tables and Window Functions.
*/

-- An overview of the dataset

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4


-- The data that I'm going to use

SELECT
	location,
	date,
	population,
	new_cases,
	total_cases,
	new_deaths,
	total_deaths
FROM
	PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY
	1, 2


-- Looking at death rate compared to total cases
-- Shows the likelihood of dying in case of infection

SELECT
	location,
	date,
	total_deaths,
	total_cases,
	(CAST(total_deaths AS numeric)/CAST(total_cases AS numeric))*100 AS DeathRate
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent IS NOT NULL
ORDER BY
	1, 2


-- Looking at infection rate compared to population
-- Shows the likelihood of getting infected

SELECT
	location,
	date,
	total_cases,
	population,
	(CAST(total_cases AS numeric)/population)*100 AS InfectionRate
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent IS NOT NULL
ORDER BY
	1, 2


-- Looking at countries with highest infection rate compared to population

SELECT
	location,
	population,
	MAX(total_cases) AS TotalInfectedCount,
	(MAX(total_cases)/population)*100 AS TotalInfectionRate
FROM
	PortfolioProject..CovidDeaths$
GROUP BY
	location,
	population
ORDER BY
	4 DESC


-- Looking at countries with highest death rate compared to population

SELECT
	location,
	population,
	MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount,
	(MAX(CAST(total_deaths AS numeric))/population)*100 AS TotalDeathRate
FROM
	PortfolioProject..CovidDeaths$
GROUP BY
	location,
	population
ORDER BY
	4 DESC


-- Death count by continent

SELECT
	continent,
	MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	2 DESC


-- Global numbers

SELECT
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS numeric)) AS TotalDeaths,
	(SUM(CAST(new_deaths AS numeric))/SUM(new_cases))*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths$
WHERE 
	continent IS NOT NULL


-- Vaccination count
-- Shows the number of people who has recieved at least one Covid vaccine

SELECT
	CD.continent,
	CD.location,
	CD.date,
	CD.population,
	CV.new_vaccinations,
	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths$ CD
JOIN
	PortfolioProject..CovidVaccinations$ CV
ON
	CD.location = CV.location
AND
	CD.date = CV.date
WHERE
	CD.continent IS NOT NULL
ORDER BY
	2, 3


-- Using CTE to do the same calculations from the last query

WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS (
	SELECT
		CD.continent,
		CD.location,
		CD.date,
		CD.population,
		CV.new_vaccinations,
		SUM(CONVERT(numeric, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.date) AS RollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths$ CD
	JOIN
		PortfolioProject..CovidVaccinations$ CV
	ON
		CD.location = CV.location
	AND
		CD.date = CV.date
	WHERE
		CD.continent IS NOT NULL
	)
SELECT 
	*,
	(RollingPeopleVaccinated/Population)*100
FROM
	PopvsVac
ORDER BY
	2, 3


-- Temp table

DROP TABLE IF EXISTS VaccinatedPopulation
CREATE TABLE VaccinatedPopulation
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO
	VaccinatedPopulation
SELECT
	CD.continent,
	CD.location,
	CD.date,
	CD.population,
	CV.new_vaccinations,
	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths$ CD
JOIN
	PortfolioProject..CovidVaccinations$ CV
ON
	CD.location = CV.location
AND
	CD.date = CV.date

SELECT 
	*,
	(RollingPeopleVaccinated/Population)*100
FROM
	VaccinatedPopulation
ORDER BY
	2, 3


-- Creating a view to store data

CREATE VIEW VaccinatedPopulationView 
AS
SELECT
	CD.continent,
	CD.location,
	CD.date,
	CD.population,
	CV.new_vaccinations,
	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths$ CD
JOIN
	PortfolioProject..CovidVaccinations$ CV
ON
	CD.location = CV.location
AND
	CD.date = CV.date
WHERE
	CD.continent IS NOT NULL