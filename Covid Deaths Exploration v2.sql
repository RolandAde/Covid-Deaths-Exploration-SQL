Select *
From PortfolioProject..CovidDeaths
order by 3,4;

Select *
From PortfolioProject..CovidVaccinations
order by 3,4;

-- Select Data that I'm going to use.

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2;

--Looking at Total Cases Vs Total Deaths 
--Shows the Death Percentage in Nigeria based on total_cases and total_deaths

Select location, date, total_cases, total_deaths, 
		(Convert(Float,total_deaths)/Convert(Float,total_cases))*100 as DeathPercentage
From 
	PortfolioProject..CovidDeaths
Where
	location = 'Nigeria'
order by 
	1,2;    


-- Looking the Total Cases Vs Population
-- Shows what percentage of population has covid

Select location, date, population, total_cases,
		(Convert(Float,total_cases)/Convert(Float,population))*100 as InfectedPopulationPercentage
From 
	PortfolioProject..CovidDeaths
Where 
	location Like '%Nigeria'
Order by 
	1,2;

-- Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount,
		Max(Convert(Float,total_cases)/Convert(Float,population))*100 as Infected_PopulationPercentage
From 
	PortfolioProject..CovidDeaths
--Where location Like '%Nigeria'
Group by
	location, population
Order by 
	Infected_PopulationPercentage desc;


-- Showing Countries with highest death count per population
Select location, population, 
		Max(CAST(total_deaths as int)) as HighestDeathCount
From
	PortfolioProject..CovidDeaths
where
	continent is not null
Group by
	location, population
Order by 
	HighestDeathCount desc;
																																												


-- Breaking things down by continent.

Select continent, 
		Max(CAST(total_deaths as int)) as TotalDeathCount
From
	PortfolioProject..CovidDeaths
where
	continent is not null
Group by
	continent
Order by 
	TotalDeathCount desc;



--Global Numbers 
Select date, 
	   sum(new_cases) as TotalCases, 
       sum(cast(new_deaths as int)) as TotalDeaths,
	   CASE
			When sum(new_cases) = 0 Then null
			Else sum(cast(new_deaths as int))/ (sum(new_cases)) *100
	   END as DeathPercentage
From 
	PortfolioProject..CovidDeaths
Where 
	continent is not null
Group by 
	date
order by 
	1,2;
		

--Global Numbers without date
Select
	   sum(new_cases) as TotalCases, 
       sum(cast(new_deaths as int)) as TotalDeaths,
	   CASE
			When sum(new_cases) = 0 Then null
			Else sum(cast(new_deaths as int))/ (sum(new_cases)) *100
	   END as DeathPercentage
From 
	PortfolioProject..CovidDeaths
Where 
	continent is not null

--Looking at total population vs vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
From 
	PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location and d.date = v.date
Where d.continent is not null
order by 2,3;



--Looking at total population vs vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	nullif(sum(Convert(Bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location, d.date),0) Rollingpeoplevaccinated
From 
	PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location and d.date = v.date
Where d.continent is not null
order by 2,3;




--Use CTE

With PopvsVac (continent, location, data, population, new_vaccinations,Rollingpeoplevaccinated) 
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	nullif(sum(Convert(Bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location, d.date),0) Rollingpeoplevaccinated
From 
	PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location and d.date = v.date
Where d.continent is not null
)
select *,(Rollingpeoplevaccinated/population)*100 
From PopvsVac;


--TEMPORARY TABLE

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	nullif(sum(Convert(Bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location, d.date),0) Rollingpeoplevaccinated
From 
	PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location and d.date = v.date
--Where d.continent is not null

select *,(Rollingpeoplevaccinated/population)*100 
From #PercentPopulationVaccinated;



--Creating View to store data for later vizualization
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	nullif(sum(Convert(Bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location, d.date),0) Rollingpeoplevaccinated
From 
	PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location and d.date = v.date
Where d.continent is not null;


Select *
From PercentPopulationVaccinated