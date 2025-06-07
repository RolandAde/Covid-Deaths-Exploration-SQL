# COVID-19 Data Analysis SQL Project

## Project Overview

This project contains a comprehensive set of SQL queries designed to analyze COVID-19 data from a relational database. The data includes global COVID-19 cases, deaths, vaccinations, populations, and continental breakdowns. The goal is to explore and extract meaningful insights such as infection rates, death percentages, vaccination progress, and demographic comparisons.

## Key Analytical Areas Covered

- Overview of COVID-19 deaths and vaccinations by country and date  
- Calculations of death percentages relative to cases in specific locations (e.g., Nigeria)  
- Infection rates as a percentage of total population by country  
- Identifying countries and continents with the highest infection and death counts  
- Time-series analysis of global new cases and deaths, including death percentages  
- Relationship between population size and vaccination progress, including rolling vaccination totals  
- Use of CTEs and temporary tables for intermediate calculations  
- Creation of views to simplify visualization and further analysis  

## SQL Techniques Demonstrated

- Aggregations using SUM(), MAX(), COUNT()  
- Window functions such as SUM() OVER() for running totals  
- Conditional logic with CASE statements  
- Joins between fact and dimension tables for comprehensive data views  
- Creation and use of temporary tables and views for performance and modularity  
- Ordering and filtering data for clarity and analysis focus  

## How to Use

- Run individual queries to explore different facets of the COVID-19 dataset.  
- Modify filters (e.g., location or date) as needed to focus on specific regions or timeframes.  
- Use views like `PercentPopulationVaccinated` for quick access to aggregated vaccination progress data.  

---

