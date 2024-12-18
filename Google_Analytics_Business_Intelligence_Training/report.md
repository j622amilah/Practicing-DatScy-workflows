
# Strategy Document: 

### Primary dataset: contains the needed metrics to respond to the stakeholders questions, including:
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

### Secondary dataset: none

### User Profiles :
The intended audience for this dashboard is a technical audience including the Hiring Manager, Project Manager, Lead BI Analyst, and BI Analysts. The intention for the dashboard is to give answers for the three asked questions:  
    1. How often does the customer service team receive repeat calls from customers?
    2. What problem types generate the most repeat calls?
    3. Which market city’s customer service team receives the most repeat calls?


## Dashboard Functionality
A dashboard was constructed from a BigQuery Google connected sheet using Google Apps Script GET Request doGet function; the web app is located at https://script.google.com/macros/s/XXXXXXXX/exec for anyone to view updated information regarding the BigQuery SQL database. This dashboard solution is automatic and directly connected to the BigQuery SQL database; the diagrams change when the BigQuery SQL database has updated changes.

A dashboard could have been created using several methods: Looker/LookML, Tableau, Google Apps Script, Cloud Function. Connecting the BigQuery database to a Google connected sheet and deploying the connected sheet with Google Apps Scripts was faster than the procedure to connect the BigQuery database to Looker/LookML, Tableau, and Cloud Function. The Looker/LookML, Tableau, and Cloud Function methods required more time investment to learn how to use their specific protocol and/or language. Google Apps Scripts uses a JavaScript derived language called Google Scripts and HTML thus coding the deployment functionality was with well-known familiar tools.
