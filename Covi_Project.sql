
------Explore the Datas inside the two datset Excel file

select * from Portfolio_Project..Covid_Deaths
select * from Portfolio_Project..Covid_vacinations

-----Lets Explore the Data field 

select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..Covid_Deaths
order by 1,2

------Lets look at the death percentage rate from explore the total_cases vs total_deaths

select location,date,total_cases,new_cases,total_deaths,population,round((total_deaths/total_cases)*100,0) as death_percentage 
from Portfolio_Project..Covid_Deaths
order by death_percentage desc

------Lets look at the total covid cases affected from the population

select location,date,total_cases,new_cases,total_deaths,population,round((total_cases/population)*100,2) as Covid_affected_percentage 
from Portfolio_Project..Covid_Deaths
order by Covid_affected_percentage desc

------Lets look at the total covid cases affected from the population for united states

select location,date,total_cases,new_cases,total_deaths,population,round((total_cases/population)*100,2) as Covid_affected_percentage 
from Portfolio_Project..Covid_Deaths
where location like '%states%'
order by Covid_affected_percentage desc

----Highest Covid affected list in country wise

select location,population,max(total_cases) as highest_cases,max((total_cases/population)*100) as covid_affected
from Portfolio_Project..Covid_Deaths
group by location,population
order by covid_affected desc


-----showing the Highest Death rate per population from location wise

select location,max(total_deaths) as death_count
from Portfolio_Project..Covid_Deaths
where continent is not null
group by location
order by death_count desc


-----Lets explore the maximum death Death from continent wise

select continent,max(total_deaths) as death_count
from Portfolio_Project..Covid_Deaths
where continent is not null
group by continent
order by death_count desc


----Lets explore the data for the new cases vs new death percentage as per date

select sum(new_cases) as total_new_Cases,sum(new_deaths) as total_new_deaths,(sum(new_cases)/sum(new_deaths)) as Death_percentage
from Portfolio_Project..Covid_Deaths

-----Lets explore the population vs vaination by joint the covid death and covid vacination tables

select death.location,death.date,death.population,vacinate.new_vaccinations
from Portfolio_Project..Covid_Deaths death
join Portfolio_Project..Covid_vacinations vacinate
on death.location= vacinate.location 
and death.date= vacinate.date
where death.continent is not null
order by vacinate.new_vaccinations desc

----Lets Explore the vacination data in day by day porgress

select death.continent,death.location,death.date,death.population,vacinate.new_vaccinations,
sum(vacinate.new_vaccinations) over(partition by death.location order by death.location,death.date) as rolling_vacinated_people
from Portfolio_Project..Covid_Deaths death
join Portfolio_Project..Covid_vacinations vacinate
on death.location= vacinate.location 
and death.date=vacinate.date
where death.location is not null

---Lets explore vacinate people percentage rate from the population and rollling vacinated people fields
---Here we cant use the created window function record for further calculation so i have created the temporary table

drop table if exists #vacinated_people
create table #vacinated_people
(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
population numeric,
new_vaccinations numeric,
rolling_vacinated_people numeric
)
insert into #vacinated_people
select death.continent,death.location,death.date,death.population,vacinate.new_vaccinations,
sum(vacinate.new_vaccinations) over(partition by death.location order by death.location,death.date) as rolling_vacinated_people
from Portfolio_Project..Covid_Deaths death
join Portfolio_Project..Covid_vacinations vacinate
on death.location= vacinate.location 
and death.date=vacinate.date
where death.location is not null

select continent,location,date,population,new_vaccinations,(rolling_vacinated_people/population)*100 as vacinated_people_percentage
from  #vacinated_people

