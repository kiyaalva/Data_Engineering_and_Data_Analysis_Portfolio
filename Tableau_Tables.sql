select sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths, 
sum(new_deaths)*1.0/sum(new_cases) * 100.00 as death_percentage 
from CovidDeaths 
where continent is not null 
order by 1,2;


select location, sum(new_deaths) as Total_Death_Count from CovidDeaths
where continent is null and
location not in ('World','European Union', 'International','High income','Upper middle income','Lower middle income' ,'Low income')
group by location
order by Total_Death_Count desc;


select location, Population , 
max(total_cases) as highInfectioncount, 
max(total_cases*1.0/population)*100 as PercentagePopulationInfected
from CovidDeaths 
group by location, population
order by PercentagePopulationInfected desc;

select location, Population , date ,
max(total_cases) as highInfectioncount, 
max(total_cases*1.0/population)*100 as PercentagePopulationInfected
from CovidDeaths 
group by location, population, date
order by PercentagePopulationInfected desc;


