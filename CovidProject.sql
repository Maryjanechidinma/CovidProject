Select * from CovidProject..covid_death
order by 3, 4

Select * from CovidProject..vaccination_Info
order by 3, 4

--Columns of Analysis
select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..covid_death
order by 2, 3

--Total cases va tatol death over percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..covid_death
where location like '%canada%'
order by DeathPercentage desc

--Total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercent
from CovidProject..covid_death
where location like '%canada%'
order by PopulationPercent desc

---Countries with highest number of covid
select location, population, Max(total_cases) as highestinfected, MAX((total_cases/population))*100 as PopulationPercentinfected
from CovidProject..covid_death
where continent is not null
group by location, population
order by PopulationPercentinfected desc

---Countries with highest death count
select location, Max(cast(total_deaths as int))  as deathcount 
from CovidProject..covid_death
where continent is not null
group by location
order by deathcount desc

---continent with highest death count

select continent, sum(cast(total_deaths as int)) as Totalcontcount ---MAX((total_deaths/population))*100 as PopulationPercentdeaths
from CovidProject..covid_death
where continent is not null
group by continent
order by Totalcontcount desc

---Global Cases

select sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as Totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercent
from CovidProject..covid_death
where continent is not null
--group by date
order by 1, 2

Select * from CovidProject..vaccination_Info
order by 3, 4

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;

---Total Vaccinations vs population

--Creat CTE

with CDvsVI (continent, location, date, population, new_vaccinations, vaccinationsrollingCount)
as
(
select CD.continent, CD.location, CD.date, CD.population, VI.new_vaccinations,
sum(cast(VI.new_vaccinations as int)) over (partition By CD.location order by CD.location, CD.date) as vaccinationsrollingCount
from CovidProject..covid_death CD
join CovidProject..vaccination_Info VI
	on CD.location = VI.location
	and CD.date = VI.date
where CD.continent is not null
)


select *, (vaccinationsrollingCount/population)*100 as RollingPercent
from CDvsVI 


---Temp Table
Drop Table if exists PopulationPercentVaccinated
Create Table #PopulationPercentVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinationsrollingCount numeric
)

insert into #PopulationPercentVaccinated
select CD.continent, CD.location, CD.date, CD.population, VI.new_vaccinations,
sum(cast(VI.new_vaccinations as int)) over (partition By CD.location order by CD.location, CD.date) as vaccinationsrollingCount
from CovidProject..covid_death CD
join CovidProject..vaccination_Info VI
	on CD.location = VI.location
	and CD.date = VI.date
where CD.continent is not null

select *, (vaccinationsrollingCount/population)*100 as RollingPercent
from #PopulationPercentVaccinated


-----View Creation
create view PopulationPercentVaccinated as 
select CD.continent, CD.location, CD.date, CD.population, VI.new_vaccinations,
sum(cast(VI.new_vaccinations as int)) over (partition By CD.location order by CD.location, CD.date) as vaccinationsrollingCount
from CovidProject..covid_death CD
join CovidProject..vaccination_Info VI
	on CD.location = VI.location
	and CD.date = VI.date
where CD.continent is not null


Select *
from PopulationPercentVaccinated