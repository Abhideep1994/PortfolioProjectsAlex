SELECT location, date, total_cases, new_cases, total_deaths, population
FROM new_schema.coviddeaths
order by 1,2

-- Looking at total deaths vs cases
-- likelihood if covid contract your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM new_schema.coviddeaths
where location like '%states%'
order by 1,2 

-- Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as Percentagepopulationinfected
FROM new_schema.coviddeaths
order by 1,2 

-- Looking at countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 as Percentagepopulationinfected
FROM new_schema.coviddeaths
GROUP BY location, population 
order by Percentagepopulationinfected desc

-- Showing countries with highest death count per population
-- Lets break things down by continent
SELECT location, MAX(total_deaths) as Totaldeathcount
FROM new_schema.coviddeaths
Where continent is not null
GROUP BY location
order by Totaldeathcount desc

-- GLOBAL NUMBERS
SELECT date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM new_schema.coviddeaths
Where continent is not null
order by 1,2

SELECT SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(new_deaths/new_cases)*100 as DeathPercentage
FROM new_schema.coviddeaths
Where continent is not null
-- GROUP BY date
order by 1,2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100
FROM new_schema.coviddeaths dea
JOIN new_schema.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100
FROM new_schema.coviddeaths dea
JOIN new_schema.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (Rollingpeoplevaccinated/population)*100
From PopvsVac 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From new_schema.coviddeaths dea
Join new_schema.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From new_schema.coviddeaths dea
Join new_schema.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 