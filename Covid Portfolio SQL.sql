
---Select the data that we are going to be using 
SELECT *
FROM CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population 
FROM CovidDeaths$
ORDER BY 1, 2


-----We'll be comparing Total Cases vs. Total Deaths 
-----Shows the likelihood of dying in your country(United States)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1, 2 


----Looking at Total Cases vs. Population 
-----This query will shows what percentage has gotten Covid 
 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infected_Population
FROM CovidDeaths$
----WHERE location like '%states%'
ORDER BY 1, 2


----Countries w/Highest Infection Rate vs. Population
SELECT location, population, MAX(total_cases) AS Infection_Count, MAX((total_cases/population))*100 AS Infected_Population
FROM CovidDeaths$
----WHERE location like '%states%'
GROUP BY location, population
ORDER BY Infected_Population desc



---Countries with Highest Death Count Per Population
SELECT continent, MAX(cast(Total_deaths as int)) AS total_death_count
FROM CovidDeaths$
----WHERE location like '%states%'
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY total_death_count desc


----CONTINENTS WITH HIGHEST DEATH COUNT 
SELECT continent, MAX(cast(Total_deaths as int)) AS total_death_count
FROM CovidDeaths$
----WHERE location like '%states%'
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY total_death_count desc

---GLOBAL NUMBERS 
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int))AS total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths$
---WHERE location like '%states%'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2

----Total Population Alongside Vaccinations 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths$ death
JOIN CovidVaccinations$ vac
ON death.location = vac.location 
AND death.date = vac.date
WHERE death.continent is NOT NULL
ORDER BY 2, 3

---will be using cte(COMMON TABLE EXPRESSIONS)
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths$ death
JOIN CovidVaccinations$ vac
ON death.location = vac.location 
AND death.date = vac.date
WHERE death.continent is NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)* 100
FROM PopVsVac

----Temporary Table 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), 
Date datetime, 
population numeric, 
new_vaccination numeric, 
RollingPeopleVaccinated numeric 
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths$ death
JOIN CovidVaccinations$ vac
ON death.location = vac.location 
AND death.date = vac.date
WHERE death.continent is NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)* 100
FROM #PercentPopulationVaccinated

---CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths$ death
JOIN CovidVaccinations$ vac
ON death.location = vac.location 
AND death.date = vac.date
WHERE death.continent is NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated