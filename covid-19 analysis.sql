
-- Query 1: Retrieve the highest new COVID-19 cases recorded per day

select date_reported, country, new_cases, new_deaths from daily_data
order by new_cases desc;

-- Query 2: Find the first and last recorded date in the dataset

select min(date_reported) as first_date_reported, max(date_reported) as last_date_reported from daily_data;

-- Query 3: Identify the top 10 countries with the highest total COVID-19 deaths

select country, count(distinct date_reported) as num_of_day, sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths
from daily_data
group by country
order by  total_new_deaths desc
limit 10;


-- Query 4: Monthly COVID-19 deaths per country

select country, concat(monthname(date_reported), ' ',year(date_reported)) as month,
sum(new_deaths) as total_deaths_monthly
from daily_data
group by country, concat(monthname(date_reported), ' ',year(date_reported))
order by total_deaths_monthly desc;                                              -- aggrigates new death per country on the monthly basis

-- Query 5: Countries with the highest death rate (deaths per cases)

select country,
sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths,
round(sum(new_deaths)/nullif(sum(new_cases),0)*100,2) as deaths_per_rate
from daily_data
group by country
having total_cases >1000000
order by deaths_per_rate desc;

-- Query 6: Daily Growth Rate of COVID-19 Cases
select
country,
date_reported,
new_cases,
lag(new_cases) over (partition by country order by date_reported) as previces_new_cases,
round( 
( new_cases - lag(new_cases) over (partition by country order by date_reported))/ nullif(lag(new_cases) over (partition by country order by date_reported),0)*100, 2) as daily_groth_rate
from daily_data
order by daily_groth_rate;

-- Query 7: Countries with the Fastest Case Increase (Last 7 Days)

select 
country,
sum(new_cases) as new_cases_last_7days
from daily_data
 WHERE date_reported BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()                                                                         -- where date_reported >= date_sub(curdate(), interval 7 day)
group by country
order by new_cases_last_7days ;

SELECT COUNT(*) FROM daily_data 
WHERE date_reported >= CURDATE() - INTERVAL 7 DAY;

SELECT COUNT(*) FROM daily_data 
WHERE STR_TO_DATE(date_reported, '%Y-%m-%d') >= CURDATE() - INTERVAL 7 DAY;



SELECT * FROM daily_data ORDER BY date_reported DESC LIMIT 10;
SELECT COUNT(*) FROM daily_data WHERE new_cases IS not NULL;
SELECT 
    country,
    SUM(IFNULL(new_cases, 0)) AS new_cases_last_7days
FROM daily_data
WHERE date_reported >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY country
ORDER BY new_cases_last_7days DESC;

SELECT COUNT(*) FROM daily_data 
WHERE STR_TO_DATE(date_reported, '%Y-%m-%d') >= CURDATE() - INTERVAL 7 DAY;
desc daily_data; 



-- Query 8: Global Daily Cases Trend


select date_reported,
sum(new_cases) as total_new_cases,
sum(cumulative_cases) as total_cumulative_cases,
sum(new_deaths) as total_new_deaths,
sum(cumulative_deaths) as total_cumulative_deaths
from daily_data
group by date_reported
order by  total_new_cases desc;


#03

select country, who_region,
sum(new_cases) as total_new_cases,
sum(cumulative_cases) as total_cumulative_cases,
sum(new_deaths) as total_new_deaths,
sum(cumulative_deaths) as total_cumulative_deaths,
sum(cumulative_cases)-sum(cumulative_deaths) as total_cumulative_active_cases
from daily_data
group by country, who_region
order by total_new_cases desc;

-- Query 9: Identifying the rank of deaths worldwide on a monthly basis

select 
country, 
concat(monthname(date_reported) , ' ', year(date_reported)) as month_yearly,
sum(new_cases) as total_new_cases,
sum(new_deaths) as total_deaths,
rank() over (partition by concat(monthname(date_reported) , ' ', year(date_reported)) order by sum(new_deaths) desc ) as rank_of_deaths
from daily_data
where concat(monthname(date_reported) , ' ', year(date_reported)) in ('june 2020', 'july 2021')
group by country, concat(monthname(date_reported) , ' ', year(date_reported))
order by total_deaths desc;

-- Query 10: Countries with the highest recovery rate (monthly)

select country, concat(monthname(date_reported), ' ', year(date_reported)) as monthly_recovered_casese,
sum(new_cases) as monthly_cases, sum(new_deaths) as monthly_deaths,
round((1- sum(new_deaths))/nullif(sum(new_cases),0) *100, 2) as recovered_cases_rate
from daily_data
where new_cases > 1000
group by country, concat(monthname(date_reported), ' ', year(date_reported))
order by recovered_cases_rate desc;

-- Query 11: The highest number of deaths recorded in a single day

select
country,
date_reported,
new_deaths as highest_deaths_cases
from daily_data
where new_deaths = (select max(new_deaths) from daily_data);       -- shows Highest number of deaths in a single day in Ecuador

-- Query 12: 7-Day Moving Average of New Cases Per Country

select
country,
date_reported,
new_cases,
avg(new_cases) over (
	partition by country 
    order by date_reported
    rows between 6 preceding and current row
    ) as moving_avg_cases
from daily_data
where country = 'india'
order by new_cases ;

-- Query 13: Global Mortality Rate Trend Over Time

select 
date_reported,
sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths,
round((sum(new_deaths))/nullif(sum(new_cases), 0)*100,2) as mortality_rate
from daily_data
group by date_reported
order by date_reported;


-- Query 14: Countries That Controlled the Spread (Declining Cases)

select
country,
date_reported,
new_cases,
lag( new_cases, 7) over(partition by country order by date_reported) as 7days_cases_reported,
case
when new_cases <lag( new_cases, 7) over(partition by country order by date_reported)
then 'declining'
else ' increacing'
end as cases_trend                   -- Identifies whether a country’s new cases are increasing or declining compared to 7 days ago.
from daily_data
order by new_cases;

-- Query 15: Peak Cases per Country (Highest Cases in a Single Day)

select
country,
date_reported,
new_cases
from daily_data
order by new_cases desc;


-- Query 16: The First Reported Case for Each Country

select
country,
min(date_reported) as first_day_reported
from daily_data
where new_cases >0
group by country
order by first_day_reported; 

-- Query 17: Compare COVID-19 Waves (First, Second, Third Wave)

select
country,
month(date_reported) as month,
year(date_reported) as year,
sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths,
case
when month(date_reported) between 3 and 6 then 'first-wave'
when month(date_reported) between 9 and 12 then 'second-wave'
else 'third-wave'
end as wave_category
from daily_data
group by country,year(date_reported), month(date_reported), wave_category
order by country, month, year;
select*from daily_data;
select*from hosp_icu_data;
select min(date_reported) as first_date, max(date_reported) as last_date from hosp_icu_data;

--Query 18: Retrieve covid-19 cases and hospitalizations,icu patinets daily date wises
select
a.date_reported,
b.country_code,
b.country,
a.new_cases,
a.new_deaths,
b.covid_new_hospitalizations_last_7days,
b.covid_new_icu_admissions_last_7days
from hosp_icu_data as b
join daily_data as a on a.country=b.country
where a.new_deaths >1000 and b.covid_new_hospitalizations_last_7days >1000 and a.date_reported between '2021-08-01' and '2021-12-01'
order by 
b.covid_new_icu_admissions_last_7days desc;

-- Query 20: Retrieve at top country total hospitalizations and also cases, deaths patinets

select
a.country,
date_format(a.date_reported, '%M %Y') as month_year,
sum(a.new_cases) as total_cases,
sum(a.new_deaths) as total_deaths,
sum(b.covid_new_hospitalizations_last_7days) as total_hospitalizations_last_7days,
sum(b.covid_new_icu_admissions_last_7days) as total_icu_admissions_7days
from hosp_icu_data as b
join daily_data as a on a.country = b.country and a.date_reported = b.date_reported
group by a.country, date_format(a.date_reported, '%M %Y')
having
total_hospitalizations_last_7days > 10000 and total_icu_admissions_7days >0 
order by total_hospitalizations_last_7days, total_icu_admissions_7days;

select
country,
date_reported,
sum(covid_new_hospitalizations_last_7days) as total
from hosp_icu_data
group by country, date_reported
order by total desc;
