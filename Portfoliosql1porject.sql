--select *
--from Portfolioproject11..CovidDeaths

--select *
--from Portfolioproject11..Covidvaccinations

--select data that we are going to be using

select location, date, total_cases,new_cases,total_deaths,population
from Portfolioproject11..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject11..CovidDeaths
where location like '%India%' and where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage got covid

select location, date, population, total_cases, (total_cases/population)*100 as Percentageinfected
from Portfolioproject11..CovidDeaths
where continent is not null
--where location like '%India%'
order by 1,2


--Looking at Countries with Highest Infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as Percentageinfected
from Portfolioproject11..CovidDeaths
--where location like '%India%'
where continent is not null
group by location, population
order by Percentageinfected desc

--showing countries with highest drath count per population
select location, MAX(cast( Total_deaths as int)) as Totaldeathcount
from Portfolioproject11..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by Totaldeathcount desc


--Let's break things down by continent

--Showing the continents with highest deathcount per population

select continent, MAX(cast( Total_deaths as int)) as Totaldeathcount
from Portfolioproject11..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by Totaldeathcount desc


-- Global Numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from Portfolioproject11..CovidDeaths
--where location like '%India%' 
 where continent is not null
 --group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolioproject11..CovidDeaths dea
join Portfolioproject11..Covidvaccinations vac
       on dea.location = vac.location
	   and dea.date = vac.date
	   where dea.continent is not null
	   order by 2,3

	   --Use cte

with PopvsVac (continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolioproject11..CovidDeaths dea
join Portfolioproject11..Covidvaccinations vac
       on dea.location = vac.location
	   and dea.date = vac.date
	   where dea.continent is not null
	  -- order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(case(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject11..CovidDeaths dea
Join Portfolioproject11..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






