select *
from PortofolioProject..CovidDeaths
where continent is null
order by 1, 2

--looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
order by 1, 2

--looking at total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortofolioProject..CovidDeaths
where location like '%Leb%' and total_cases>100
order by 1, 2

--looking at highest infection rate
select location,  population , max(cast (total_cases as int)) as highestinfectionpercountry, max((total_cases/population)*100) as InfectionPercentage
from PortofolioProject..CovidDeaths
Group by location, population
order by 4 desc

--showing countries with highest death 
--Ah hon awal mahal we need max of a column and those columns are varchar225 so use cast(     as int) to get better results)
--ya3ne hatto el 999 akbar men el 19000 fhemet
--ahhh when continent is null ya3ne el location(country) houwe el continent fa ma bedna hol e ar2am el kbar
select location, max(cast(total_deaths as int)) as TotalDeathcount
from PortofolioProject..CovidDeaths
where continent is not null--(ma bednA EL CONTINENT BAS EL COUNTRIES)--Ahhhhh lama cont null el loc hiye el cont fa ma bedn yeha
group by location
order by 2 desc

--showing country with highest total deaths
--keep el where cont is not null la2ano bkun 3am 3edon marten khals ma hene ha yejma3o te3oul kel el countries bala el sum fhemet 
--hon fi ghalta north america ma fiya cannada chuf leh later 
--continent null means el location hiye el cont
--1)take location where cont is null(majmou3 el kbar)- bas hon ka2ano 3am yejma3o el chaghe marten aw hay el sah dk
select location, max(cast(total_deaths as int)) as TotalDeathcount
from PortofolioProject..CovidDeaths
where continent is  null
group by location
order by 2 desc
--2)take cont where cont is not null w jma3 majmou3 kel el loc la kel cont(majmou3 el sghar)
select continent, max(cast(total_deaths as int)) as TotalDeathcount
from PortofolioProject..CovidDeaths
where continent is not null--lama cnt not null el cont houwe cont 3ade
group by continent
order by 2 desc

--Global Death percentages By day
--ahhh sarit ma3na mechklit el divide by 0 la2ano ama el cont null fi el internationa w fiya fatra kel el new_cases 0
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) 
as deathpercentage
from PortofolioProject..CovidDeaths
where continent is not null
group by date


--Global Death percentages Total
--ahhh sarit ma3na mechklit el divide by 0 la2ano ama el cont null fi el internationa w fiya fatra kel el new_cases 0
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) 
as deathpercentage
from PortofolioProject..CovidDeaths
where continent is not null


----Looking at population vs vaccinated people 
--If i partiton only on location it will give the total final sum next to each date
--Partition by location is not enough
--Partition by Loc and date would be identical
--Partition by location then adding order by date would work 
select d.continent, d.location, d.date, population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) 
over (partition by  d.location order by d.date) Totalpeoplevacinatedpercountry 
from PortofolioProject..CovidDeaths d
Join PortofolioProject..CovidVaccination v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
order by  2,3

--Vaccinated people per population percentage
--you create a new column so can't use it in calculation so need CTE's

--Using CTE's
With PopvsVAc
as
(select d.continent, d.location, d.date, population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) 
over (partition by  d.location order by d.date) Totalpeoplevacinatedpercountry 
from PortofolioProject..CovidDeaths d
Join PortofolioProject..CovidVaccination v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
--order by  2,3
)
Select *, (Totalpeoplevacinatedpercountry/population)*100 as VAccinationPercentage
from PopvsVAc

--Using TempTable
Drop Table if exists #PercentPeopleVaccinated
Create Table  #PercentPeopleVaccinated
(continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
Totalpeoplevacinatedpercountry numeric,)

Insert into #PercentPeopleVaccinated 
select d.continent, d.location, d.date, population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) 
over (partition by  d.location order by d.date) Totalpeoplevacinatedpercountry 
from PortofolioProject..CovidDeaths d
Join PortofolioProject..CovidVaccination v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
--order by  2,3

Select *, (Totalpeoplevacinatedpercountry/population)*100 as VaccinationPercentage
from #PercentPeopleVaccinated

--Creating data for visualiation

Create view Percentpopulationvaccinated as
With PopvsVAc
as
(select d.continent, d.location, d.date, population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) 
over (partition by  d.location order by d.date) Totalpeoplevacinatedpercountry 
from PortofolioProject..CovidDeaths d
Join PortofolioProject..CovidVaccination v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
--order by  2,3
)
Select *, (Totalpeoplevacinatedpercountry/population)*100 as VAccinationPercentage
from PopvsVAc

Create view TotalGlobaldeath as
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) 
as deathpercentage
from PortofolioProject..CovidDeaths
where continent is not null

