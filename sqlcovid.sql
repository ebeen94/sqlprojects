SELECT *
FROM Portfolio..covidDeaths
WHERE continent is not NULL
ORDER BY 4

ALTER TABLE Portfolio..covidDeaths ALTER COLUMN total_cases DECIMAL;  
GO  


SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as deathpercases
FROM Portfolio..covidDeaths
WHERE location like '%states%'
ORDER BY deathpercases DESC


SELECT location, max((total_cases/population)*100) as highestcaseperpop
FROM Portfolio..covidDeaths
WHERE continent is not NULL
GROUP BY location 
ORDER BY highestcaseperpop DESC 

SELECT location, max(total_cases) as highestcasesabs
FROM Portfolio..covidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY highestcasesabs desc 

SELECT sum(new_cases) as worldcases, sum(new_deaths) as worlddeaths, (sum(new_deaths) /sum(new_cases))*100 as perc
FROM Portfolio..covidDeaths
where continent is not NULL
ORDER BY 1,2


select *
from Portfolio.dbo.covidVaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio..covidDeaths as dea
JOIN Portfolio..covidVaccinations as vac
ON dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not NULL
order by 1,2

-- total vaccination based on location + accumulated count of vaccinations
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.[location] order by dea.location, dea.date) as rollingPplVaccinated
from Portfolio..covidDeaths as dea
join Portfolio..covidVaccinations as vac
on dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.[continent] is not NULL
order by 2,3


-- total vaccination based on location + accumulated count of vaccinations
WITH popvervac(continent, location, date,population,new_vaccinations,rollingPplVaccinated)
as
(
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.[location] order by dea.location, dea.date) as rollingPplVaccinated
from Portfolio..covidDeaths as dea
join Portfolio..covidVaccinations as vac
on dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.[continent] is not NULL
)
SELECT *, (rollingPplVaccinated/population) * 100
FROM popvervac



-- temp table
DROP TABLE if EXISTS #percentPplVaccinated 
CREATE TABLE #percentPplVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations numeric,
    rollingPplVaccinated numeric

)

Insert into #percentPplVaccinated
-- total vaccination based on location + accumulated count of vaccinations
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.[location] order by dea.location, dea.date) as rollingPplVaccinated
from Portfolio..covidDeaths as dea
join Portfolio..covidVaccinations as vac
on dea.[location] = vac.[location]
and dea.[date] = vac.[date] 
where dea.[continent] is not NULL
 
SELECT *, (rollingPplVaccinated/population) * 100 as perc  
FROM #percentPplVaccinated

-- create view to store data for visualizations

CREATE VIEW PplVaccinated as
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.[location] order by dea.location, dea.date) as rollingPplVaccinated
from Portfolio..covidDeaths as dea
join Portfolio..covidVaccinations as vac
on dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.[continent] is not NULL
