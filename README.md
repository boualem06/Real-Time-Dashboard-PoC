# 🌍 Real-Time Dashboard PoC (Proof of Concept) 🌍


This project presents a real-time dashboard for analyzing and visualizing specific activities in a chosen geographical area. It integrates multiple **data sources** and leverages automated scripts to collect, process, analyze, and visualize data seamlessly and efficiently.

---

## 📖 Table of Contents

1. [Project Overview](#project-overview)  
2. [Data Sources](#data-sources)  
3. [Implementation Steps](#implementation-steps)  
   - [Data Collection](#data-collection)  
   - [Data Aggregation](#data-aggregation)  
   - [Data Analysis & Visualization](#data-analysis--visualization)  
5. [Tech Stack](#tech-stack)  
6. [How to Run](#how-to-run)  
7. [Authors](#authors)

---

## 🌟 Project Overview

### Problem Statement
The goal of this project is to create a **real-time dashboard** to analyze **[chosen activities]** in the region **[chosen geographical area]**. The focus is to demonstrate the feasibility of the project through a **PoC**, incorporating automated scripts to:
- **Download data**.  
- **Summarize insights**.  
- **Provide visual and interactive analyses**.  

---

## 📂 Data Sources

### Sources used:  
1. **Change Rate EUR/USD**: https://twelvedata.com/
2. **Gold Price**: https://metalpriceapi.com/
3. **Petrol Price**: finhub.io  
4. **Naturel GAz Price**: www.alphavantage.com


For each source, we studied:
- **Data content** (main variables).  
- **Update frequency**.  
- **Data reuse rights**.  
- **Estimated annual data volume**.  

---

## 🛠 Implementation Steps

### 1️⃣ Data Collection  
- **Goal**: Retrieve data from APIs every minute/hour and store them in JSON/XML files.  
- **Script**: A **Bash script** downloads the data and saves them in a dedicated directory with a descriptive filename (e.g., `data_YYYYMMDD_HHMM.json`).  
- **Automation**: A **cron job** schedules the script execution.  

### 2️⃣ Data Aggregation  
- **Goal**: Summarize the collected data hourly/daily and store the results in MongoDB.  
- **Script**: A **Python script**:
  - Reads the JSON/XML files.  
  - Computes statistical summaries.  
  - Inserts data into MongoDB.  
  - Deletes processed files.  
- **Automation**: A **cron job** schedules the script execution.

### 3️⃣ Data Analysis & Visualization  
- **Goal**: Generate visual analyses via an interactive dashboard or a PDF report.  
- **Script**: A **R (Rshiny)**  script produces:
  - Interactive visualizations (line plots, histograms, heatmaps, etc.).  
  - Trend and anomaly analyses.  
- **Automation**: A **cron job** schedules the script execution.

---

## 🛠 Tech Stack

- **Languages**: Python, R, Bash.  
- **Frameworks**: Shiny.  
- **Database**: MongoDB.  
- **Automation Tools**: Cron jobs.  

---

## 🚀 How to Run

1. **Setup**:  
   - Install dependencies with `pip install -r requirements.txt` (Python) or the necessary R packages.  
2. **Scripts**:  
   - Run `cron_getting_data.sh` to collect data.  
   - Run `cron_traitement_and_save.py` to aggregate data.  
   - Launch `appli_web.R`  for analysis and visualization.  
3. **Automation**:  
   - Add cron jobs to schedule the scripts automatically.(cron.txt)

---
**video**: https://youtu.be/BhL0gpuQrfM

🎉 Thank you for exploring this project! Feel free to ask questions or suggest improvements. 😊
