use Portfolio;
--The dataset has more than 200,000 rows for analysis
select * from CovidDeaths;
--both columns are of int data type so death rate rounded floating point values to a zero
select total_deaths,total_cases, (total_deaths/total_cases) as death_rate from CovidDeaths;


--Solution is to multiply total deaths by 1.0 a floating value 
--The percentage give an estimate of likely deaths due to covid at a particular location
SELECT location, date, total_deaths, total_cases, (total_deaths * 1.0 / total_cases)*100 AS death_percentage 
FROM CovidDeaths
where location like 'INDIA';

---Percentage vs Population 

SELECT location, date, total_deaths, Population, (total_cases * 1.0 / Population)*100 AS Covid_Percentage 
FROM CovidDeaths
where location like 'INDIA';


--countries with highest infection rate 

select location, Population, max(total_cases) as max_cases, max((total_cases*1.0 / Population))*100 as Infection_Rate  from CovidDeaths
group by location,Population
order by Infection_Rate desc; 

--countries with highest death count per population 

select location, Population, max(total_deaths) as max_deaths, max((total_deaths*1.0 / Population))*100 as Death_Rate
from CovidDeaths 
group by location,population
order by Death_Rate desc; 

select location, max(total_deaths) as max_deaths from CovidDeaths
group by location
order by max_deaths desc;

select * from CovidDeaths;

select location, max(total_deaths) as max_deaths from CovidDeaths
where continent is not null
group by location
order by max_deaths desc;

---Continental Analysis


select location, max(total_deaths) as max_deaths from CovidDeaths
where continent is null
group by location
order by max_deaths desc;


select continent, max(total_deaths) as max_deaths from CovidDeaths
where continent is not null
group by continent
order by max_deaths desc;

--Global Data 
--New cases and new deaths on each day 

select date, sum(new_cases) as Global_new_cases, sum(new_deaths) as global_new_deaths from CovidDeaths 
group by date
order by date;

-- percentage of new deaths each day  

select 
date,
sum(new_cases) as global_new_cases, 
sum(new_deaths) as global_new_deaths, 
(sum(new_deaths)/sum(cast(new_cases as float)))*100 as global_new_death_percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2;

--- 

select * from CovidVaccinations;
---



--Using both tales

select * from CovidVaccinations vac
join 
CovidDeaths dea
on 
vac.location = dea.location
and 
vac.date = dea.date;


---New vaccination by contry

select dea.date, dea.continent, dea.location, vac.new_vaccinations from CovidVaccinations vac
join 
CovidDeaths dea
on 
vac.location = dea.location
and 
vac.date = dea.date
where dea.continent is not null
order by 1,3;

--total new vaccines as per location 
select  
dea.continent, 
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Vaccine_count
from CovidVaccinations vac
join 
CovidDeaths dea
on 
vac.location = dea.location
and 
vac.date = dea.date
where dea.continent is not null
order by 2,3;

--- percentage of new vaccination for the population 
with new_table(
continent, 
location,
date, 
population,
new_vaccinations,
Vaccine_count)
as
(
select  
dea.continent, 
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Vaccine_count
from CovidVaccinations vac
join 
CovidDeaths dea
on 
vac.location = dea.location
and 
vac.date = dea.date
where dea.continent is not null
--order by 2,3;
)
select *, (Vaccine_count*1.0/population)*100 from new_table;

----creating a temp table instead 

drop table if exists #temptable;
create table #temptable(
continent varchar(255), 
location varchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
Vaccine_count numeric)

insert into #temptable  
select  
dea.continent, 
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Vaccine_count
from CovidVaccinations vac
join 
CovidDeaths dea
on 
vac.location = dea.location
and 
vac.date = dea.date
where dea.continent is not null
order by 2,3;

select *, (Vaccine_count/population) * 100 from #temptable;

---Creating Views to store data for later visualizations

Create View population_vaccinated as
select  
dea.continent, 
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Vaccine_count
from CovidVaccinations vac
join 
CovidDeaths dea
on 
vac.location = dea.location
and 
vac.date = dea.date
where dea.continent is not null
;

select * from population_vaccinated;