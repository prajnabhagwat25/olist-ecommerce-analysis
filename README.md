# Olist Brazilian E-Commerce Analysis
## End-to-End Data Analyst Project | Excel · SQL · Power BI

## Project Overview
Analyzed 9 datasets from Olist, a Brazilian e-commerce marketplace,
covering 100,000+ orders from October 2016 to September 2018.
Built a complete analytical pipeline from raw data to interactive dashboard.

## Business Problem
Despite growing revenue, Olist had a 3% repeat customer rate.
This project investigates what drives poor retention and where
the business should focus to fix it.

## Tools Used
- **Excel** — data cleaning, profiling, data dictionary (9 tables)
- **MySQL** — 25+ queries including CTEs, window functions, multi-table JOINs
- **Power BI** — star schema model, 9 DAX measures, 3-page dashboard

## Dataset
- Source: [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 9 tables, 100,000+ orders, Oct 2016 – Sep 2018

## Key Findings
1. Late deliveries score 40% lower on satisfaction (2.5 vs 4.2 stars)
2. Only 31.8% of orders arrive within 7 days
3. 3% repeat customer rate — retention is a logistics problem
4. SP + RJ account for 50%+ of all platform revenue

## Recommendation
Reducing average delivery time from 12.5 days to under 7 days
would move platform-wide satisfaction above 4.0 and directly
improve repeat purchase rates.

## Project Files
| File | Description |
|------|-------------|
| SQL_Brazilian.sql.sql | All SQL queries — exploratory, joins, CTEs, window functions |
| [olist_cleaned_data.xlsx](https://docs.google.com/spreadsheets/d/1U1V5TRZioxAQCG5M-sp2FmH4iATX6WkN/edit?usp=sharing&ouid=116042435288741724822&rtpof=true&sd=true) | Cleaned data, data dictionary, cleaning log (Google Drive) |
| Brazilian_Project.pbix.pbix | Power BI interactive dashboard |

## Dashboard Preview

![Executive Overview](Screenshot%202026-09-13%20152800.png)

![Delivery & Satisfaction](Screenshot%202026-09-13%20152827.png)

![Product & Seller Performance](Screenshot%202026-09-13%20152853.png)

## How to Run

1. Download the raw Olist data from the Kaggle link above.
2. Import the CSV files into MySQL and run `SQL_Brazilian.sql.sql`.
3. Open `Brazilian_Project.pbix.pbix` in Power BI Desktop.
