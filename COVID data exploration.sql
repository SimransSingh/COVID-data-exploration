SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3 ,4 ;

SELECT location, date, total_cases, new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2;

--Looking at total cases vs total deaths

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2;

--Looking at total cases vs population 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS AffectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2;

--Looking at highest infection rates compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionRateCount , MAX((total_cases/population)*100) AS AffectedPercentageCount
FROM [Portfolio Project]..CovidDeaths
GROUP BY location,population
ORDER BY AffectedPercentageCount DESC;

--Looking at Countries with Highest Death Count compared to Population

SELECT continent, MAX(Cast(total_deaths AS int)) AS TotalDeathcount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount DESC ;

--Looking at global deaths 

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;
 

SELECT dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations ,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2 , 3;

--using CTE to perform Calculation on Partition By in previous query -- 

With PopvsVac (continent, date, location, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations ,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS Rollpercent
FROM PopvsVac;




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
Date datetime ,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations ,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/population)*100 AS Rollpercent
FROM #PercentPopulationVaccinated;


--Creating view to store data for later visualization

Create view #PercentPopulationVaccinated AS 
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations ,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null;