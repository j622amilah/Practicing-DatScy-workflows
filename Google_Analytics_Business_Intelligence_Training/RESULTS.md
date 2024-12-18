# Project Requirements Document:

## Purpose:
The purpose of this project is to evaluate the technical ability of a potential fictional Data Science team member. The project requires the fictional candidate to; find a dataset; analyze the dataset with SQL to identify the correct metrics/features; investigate, select, and implement tools for presenting the dataset metrics to stakeholders. No statistical analysis should be used. The fictional candidate is interviewing for a BI Professional position, however the requirements for the fictional candidate appears to exceed the abilities for a BI Professional therefore Data Science team member is used instead of BI Professional; BI Professionals are likely not responsible for writing code that automates data ingestion of the found dataset/s to database systems, nor write automated client-server side Javascript/HTML code to dynamically connect databases to dashboard interfaces.   
As part of the interview process scenario, the Fiber customer service team has asked for a dashboard using fictional call center data based on the data they use regularly on the job to gain insights about repeat callers. The team’s ultimate goal is to communicate with the customers to reduce the call volume and increase customer satisfaction and improve operational optimization. The goal of the dashboard is to inform stakeholders about insights about repeat caller volumes in different markets and the types of problems they represent.

## Key dependencies:
No datasets were given for the fictional scenario, but one was tasked to find fictionalized versions of the actual data. Stakeholders have data access to all datasets on the Google Cloud BigQuery platform for the project, so they can explore the steps taken. 

## Stakeholder requirements:
Below is a list of the established stakeholder requirements, based on the Stakeholder Requirements Document, prioritizing the requirements as: R - required, D - desired, or N - nice to have. Quantitative project success is measured by the fulfillment of these requirements. In order to continuously improve customer satisfaction, the dashboard must help Google Fiber decision-makers understand how often customers are having to repeatedly call and what problem types or other factors might be influencing those calls. 
    • A chart or table measuring repeat calls by their first contact date R
    • A chart or table exploring repeat calls by market and problem type R
    • Charts showcasing repeat calls by week, month, and quarter D
    • Provide insights into the types of customer issues that seem to generate more repeat calls D
    • Explore repeat caller trends in the three different market cities R
    • Design charts so that stakeholders can view trends by week, month, quarter, and year.  R

## Success criteria: 
Specific: BI insights must clearly identify the specific characteristics of a repeat calls, including how often customers are repeating calls. Measurable: Calls should be evaluated using measurable metrics, including frequency and volume. For example, do customers call with a specific problem more often than others? Which market city experiences the most call? How many customers are calling more than once? Action-oriented: These outcomes must quantify the number of repeat callers under different circumstances to provide the Google Fiber team with insights into customer satisfaction. Relevant: All metrics must support the primary question: How often are customers repeatedly contacting the customer service team? Time-bound: Analyze data that spans at least one year to understand how repeat callers change over time. Exploring data that spans multiple months will capture peaks and valleys in usage. 

## User journeys: 
The team’s ultimate goal is to communicate with the customers to reduce the call volume and increase customer satisfaction and improve operational optimization. The dashboard should show relationships between: number of calls, contract type, Internet Service/market type, and problem type. Understanding relationships between these four attributes will help stakeholders understand which caller demographics calls the most for a specific concern, thus allowing them to target specific help to call demographics and reduce calls and churn.

## Assumptions: 
In order to anonymize and fictionalize the data, the datasets the columns market_1=Fiber optic, market_2=DSL, and market_3=No to indicate three different city service areas the data represents. 
The data also lists two problem types:
    • Type_1 is account management
    • Type_2 is technician troubleshooting
Additionally, the best found fictional dataset appears to have been partitioned by the CustomerId and the calls per problem type were SUM aggregated, causing the original DateTime information to be lost. The removal of the DateTime information added a restriction for completing the requirements. 

## Compliance and privacy: 
The datasets are fictionalized versions of the actual data this team works with. Because of this, the data is already anonymized and approved. However, you will need to make sure that stakeholders have data access to all datasets so they can explore the steps you’ve taken.


# Stakeholder Requirements Document:

## Business problem: 
The team’s ultimate goal is to communicate with the customers to reduce the call volume and increase customer satisfaction and improve operational optimization. 

The dashboard (https://script.google.com/macros/s/XXXXXXXX/exec - Refer to Code.gs) gives viewers information about customer call behavior with respect to their contract type and internet service/market type; the Strategy document further explains each dashboard figure with respect to the question. The number of calls were totaled per problem type, such that relationships between call volume, problem type, contract, and internet service/market type could be identified. 

## Stakeholders: 
The major stakeholders of this project are the following list of individuals:
    • Hiring Manager
    • Project Manager
    • Lead BI Analyst
    • BI Analyst
    • BI Analyst

## Stakeholder usage details:
The stakeholders can use the BI tool to view the direct aggregated results of call requests  from the BigQuery database, it is a dynamically connected webapp. The BI tool uses  a Google connected sheet directly connected to BigQuery, thus all results are up-to-date with respect to call center data; the webapp simply aggregates categorical related data and plots them to a chart.
If this scenario was not with fictional static Kaggle data, data would be continuously being created by customers calling and the dashboard would be continuously changing with respect to the most recent information. Stakeholders can be reassured to know that the information that they are looking at is the most up to date data from the database.

## Primary requirements:  
The following requirements must be met by the BI tool in order for the  project to be successful:
    1. |Required] A chart or table measuring repeat calls by their first contact date: completed
    2. |Required] A chart or table exploring repeat calls by market and problem type: completed
    3. |Desired] Charts showcasing repeat calls by week, month, and quarter: unable to complete due to dataset not having DateTime information
    4. |Desired] Provide insights into the types of customer issues that seem to generate more repeat calls: completed
    5. |Required] Explore repeat caller trends in the three different market cities: completed
    6. |Required] Design charts so that stakeholders can view trends by week, month, quarter, and year. : unable to complete due to dataset not having DateTime information
    
3 out of the 4 required requirements were accomplished successfully (75% completion), and 1 out of 2 desired requirements were accomplished successfully (50% completion). Therefore, with the best dataset that I was able to find for the project on Kaggle the project was 75% completed despite understanding insights about customer call behavior. If the Google Professional Business Certificate program provided a link for the correct dataset, as was done in the Google Professional Data Analytics Certificate program the project objectives could have been 100% completed.


# Strategy Document: 

## Primary dataset: contains the needed metrics to respond to the stakeholders questions, including:
    • The type of internet service received (Market_city) : no_internetservice, DSL, Fiber_optic
    • Contract : One year, Two year, Month-to-month
    • TechSupport : No internet service, Yes, No
    • The average repeat calls related to combined problem types (total_problem_type): integer
    • The average repeat calls related to the problem type of account management (account_mang_problem_type): integer
    • The average repeat calls related to the problem type of technician troubleshooting (tech_troubleshoot_problem_type): integer
    • The average churn or customer retention:  boolean (True=customers stop service, False=customers keep service)
    • The average frequency of repeat calls related to combined problem types [Contract/number of tickets] (total_problem_type_call_freq): integer 
    • The average frequency of repeat calls related to the problem type of account management (accmang_problem_type_call_freq): integer 
    • The average frequency of repeat calls related to the problem type of technician troubleshooting (techtrob_problem_type_call_freq): integer 

A BigQuery SQL database was constructed from a single Kaggle .csv file. Automatic ingestion was performed via the main.sh and self-written GCP library on Practicing DatScy "BigQuery Machine Learning/Deep Learning function library in bash". Two basic queries were performed to create a final aggregated SQL database with the listed columns above for visualizing the results. A Google sheet was created and Data - Data Connectors - Connect to BigQuery were selected to connect to the BigQuery database.

## Secondary dataset: 
none

## User Profiles :
The intended audience for this dashboard is a technical audience including the Hiring Manager, Project Manager, Lead BI Analyst, and BI Analysts. The intention for the dashboard is to give answers for the three asked questions:  
    1. How often does the customer service team receive repeat calls from customers?
    2. What problem types generate the most repeat calls?
    3. Which market city’s customer service team receives the most repeat calls?


## Dashboard Functionality
A dashboard was constructed from a BigQuery Google connected sheet using Google Apps Script GET Request doGet function; the web app is located at (https://script.google.com/macros/s/XXXXXXXX/exec - Refer to Code.gs) for anyone to view updated information regarding the BigQuery SQL database. This dashboard solution is automatic and directly connected to the BigQuery SQL database; the diagrams change when the BigQuery SQL database has updated changes.

A dashboard could have been created using several methods: Looker/LookML, Tableau, Google Apps Script, Cloud Function. Connecting the BigQuery database to a Google connected sheet and deploying the connected sheet with Google Apps Scripts was faster than the procedure to connect the BigQuery database to Looker/LookML, Tableau, and Cloud Function. The Looker/LookML, Tableau, and Cloud Function methods required more time investment to learn how to use their specific protocol and/or language. Google Apps Scripts uses a JavaScript derived language called Google Scripts and HTML thus coding the deployment functionality was with well-known familiar tools.
