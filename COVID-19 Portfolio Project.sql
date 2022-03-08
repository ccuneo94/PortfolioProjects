Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows COVID impact in your country
Select Location, date, total_cases, population, (total_cases/population)*100 as COVIDImpact
From PortfolioProject..CovidDeaths
--where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as COVIDImpact
From PortfolioProject..CovidDeaths
Group by Location, population
order by COVIDImpact desc

-- Looking at Countries with Highest Death Count compared to Population
Select Location, population, max(total_deaths) as TotalDeathCount, Max((total_deaths/population))*100 as COVIDImpactDeaths
From PortfolioProject..CovidDeaths
Group by Location, population
order by COVIDImpactDeaths desc

-- Looking at Countries with Highest Death Count compared to Population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Looking at Countries with Highest Death Count compared to Population By Continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Looking at Countries with Highest Death Count compared to Population By Continent and more
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by date
order by 1,2

--Global Numbers no date
Select SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
order by 1,2

--Join two databases: Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

--Join two databases: Looking at Total Population vs Vaccinations Extra Data
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location order by dea.location,dea.date) as VaccinationDevelopment
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

--Use CTE
with PopVsVac (Continent, Location, Date, Population, new_vaccinations, VaccinationDevelopment)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location order by dea.location,dea.date) as VaccinationDevelopment
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
	 )
Select *, (VaccinationDevelopment/Population)*100
From PopVsVac
--where location like '%canada%'
Order by 2,3

--TEMP Table
DROP table if exists #PercetangePopulationVaccinated
Create Table #PercetangePopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
VaccinationDevelopment numeric)
Insert Into #PercetangePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location order by dea.location,dea.date) as VaccinationDevelopment
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
Select *, (VaccinationDevelopment/Population)*100
From #PercetangePopulationVaccinated
--where location like '%canada%'
Order by 2,3

--Create View to Store Data  for Later Visualizations

Create View PercetangePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location order by dea.location,dea.date) as VaccinationDevelopment
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null

--Call Data from View
Select*
From PercetangePopulationVaccinated
