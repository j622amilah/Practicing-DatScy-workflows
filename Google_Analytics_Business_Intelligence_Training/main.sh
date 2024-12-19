#!/bin/bash


clear


export cur_path=$(pwd)

# This library contains two function that are used: organize_zip_files_from_datasource_download and upload_csv_files.
# The functions are given below.
# source ./GCP_bigquery_case_study_library.sh

cd $cur_path
# cd /../Specialization_Google_Analytics_Business_Intelligence_Training/analysis_0


# ---------------------------
# Functions START
# ---------------------------
organize_zip_files_from_datasource_download(){
 
 # Automatically organizes a folder of zipped csv files into 3 folders: csvdata, remaining_files, zipdata
 
 # Inputs:
 # $1 = path_folder_2_organize (path where the zip files are located) (this should exist)
 # $2 = ingestion_folder (folder name to put the files into) = output_folder_NAME (one chooses this)
 # $3 = path_outside_of_ingestion_folder (path where the ingestion folder should be located) = output_folder_PATH (one chooses this)
 
 # Path inside of the ingestion folder
 export path_ingestion_folder=$(echo "$3/$2")
 
 # ---------------------------------------------
 # Make ingestion folder and transfer files
 # ---------------------------------------------
 export val=$(echo "X0")

 if [[ $val == "X0" ]]
 then

     mkdir $path_ingestion_folder
     
     cp -a $1/. $path_ingestion_folder
     
 fi

 # ---------------------------------------------

 # ---------------------------------------------
 # Unzip files
 # ---------------------------------------------
 export val=$(echo "X0")

 if [[ $val == "X0" ]]
 then 

     # Unzip file options
     # -f  freshen existing files, create none
     # -n  never overwrite existing files
     # -o  overwrite files WITHOUT prompting

     cd $path_ingestion_folder

     ls *.zip > arr
     
     for i in $(cat arr)
     do
        unzip -o $i
     done

     mkdir zipdata
     mv *.zip zipdata

     # Clean-up treatment files
     rm arr
     
 fi

 # ---------------------------------------------
 
 
 # Rename all the files so they do not have any spaces
 for f in *\ *; do mv "$f" "${f// /_}"; done
 
 
 # ---------------------------------------------
 # Convert xlsx files to csv
 # ---------------------------------------------
 export val=$(echo "X0")

 if [[ $val == "X0" ]]
 then 

     # Unzip file options
     # -f  freshen existing files, create none
     # -n  never overwrite existing files
     # -o  overwrite files WITHOUT prompting

     cd $path_ingestion_folder
     echo "Output: " 
     echo $path_ingestion_folder
     
     # Read all file names into a file
     ls *.xlsx > arr
     
     
     for i in $(cat arr)
     do
        echo $i
        libreoffice --headless --convert-to csv $i
     done

     # Clean-up treatment files
     rm arr
     
 fi

 # ---------------------------------------------

 # ---------------------------------------------
 # Secondary clean up of files
 # ---------------------------------------------
 export val=$(echo "X0")

 if [[ $val == "X0" ]]
 then 
     
     # get main path
     # export cur_path=$(pwd)
     # echo "cur_path:"
     # echo $cur_path
     
     # Get path of folder to search
     # export path_ingestion_folder=$(echo "${cur_path}/${folder_2_organize}")
     # echo "path_ingestion_folder:"
     # echo $path_ingestion_folder
     
     # find folders inside of the folder to search
     cd $path_ingestion_folder
     
     # write folder names in file
     ls -d */ >> folder_list
    
     # move folder contents into data
     # export i=$(echo "Divvy_Stations_Trips_2013/")
     for i in $(cat folder_list)
     do
       export new_path=$(echo "${path_ingestion_folder}/${i}")
       echo "new_path:"
       echo $new_path
       
       cd $new_path
       
       # Save an array of values 
       # remove the text folder_list2 from the file, then remove blank or empty lines
       ls  | sed 's/folder_list2//g' | sed '/^$/d' >> folder_list2
       
       #echo "contents of folder_list2:"
       for j in $(cat folder_list2)
       do
  #echo $j
  export new_path2=$(echo "${new_path}${j}")
  #echo "new_path2:"
  #echo $new_path2
  mv $new_path2 $path_ingestion_folder 
       done
       
       # delete folders
       rm folder_list2
       
       cd $path_ingestion_folder
       
       rm -rf $i
     done
     
     
     rm folder_list
    
     # Recreate main folders
     # --------------
     # zipfile folder
     mkdir zipdata
     mv *.zip zipdata
     # --------------
     
     # --------------
     # csv folder
     mkdir csvdata
     mv *.csv csvdata
     # --------------
     
     # --------------
     # The rest in a folder
     mkdir remaining_files
     
     find $path_ingestion_folder -maxdepth 1 -type f >> nondir_folder_list
     
     # remove the directory items from the file all_file_list
     for i in $(cat nondir_folder_list)
     do
       mv $i remaining_files
     done
     
     rm remaining_files/nondir_folder_list
     # --------------

 fi

 # ---------------------------------------------

}


upload_csv_files(){
 
    # Inputs:
    # $1 = location
    # $2 = cur_path
    # $3 = dataset_name

    cd $2
    
    
    if [ -f file_list_names ]; then
       rm file_list_names
    fi
  
    if [ -f table_list_names ]; then
       rm table_list_names
    fi
    
    # Get list of csv files : do not remove the .csv for bq load
    ls  | sed 's/file_list_names//g' | sed '/^$/d' >> file_list_names
    
    
    # Generic name of tables
    export Generic_CSV_FILENAME=$(cat file_list_names | head -n 1 | sed 's/.csv//g' | tr -d [0-9] | sed 's/-//g' | sed 's/  */ /g' | sed 's/^ *//g' | tr '[:upper:]' '[:lower:]' | sed -e '/[[:space:]]\+$/s///' | sed 's/[[:space:]]/_/g')
    echo "Generic_CSV_FILENAME: "
    echo $Generic_CSV_FILENAME 
    
    # Load CSV file into a BigQuery table FROM PC
    cnt=0
    for CSV_NAME in $(cat file_list_names)
    do
       echo "CSV_NAME: "
       echo $CSV_NAME 
       
       # -----------------------------
       # Edit csv file to prevent bq load errors : this section could get bigger
       # -----------------------------
       # Remove and from all csv files to prevent TIMESTAMP error 
       # cat $CSV_NAME | sed 's///g' | sed 's///g' > temp_csv
       # mv temp_csv $CSV_NAME
       # -----------------------------
       
       # Use the csv file names directly
       # remove the .csv from the filename
       export TABLE_name=$(echo $CSV_NAME | sed 's/.csv//g')
       
       echo "TABLE_name: "
       echo $TABLE_name
       
       # Need to save a list of TABLE_name, to do the UNION query next
       echo $TABLE_name >> table_list_names
       # OR
       # Save tables to a dataset folder dedicated to one thing, and use bq ls to get table names in next query
       
       # Load with a specific schema: https://cloud.google.com/bigquery/docs/reference/bq-cli-reference#bq_load
       # --schema=col_name0:STRING,col_name1:STRING,col_name2:INTEGER
       
       # Upload with schema options: autodetect the schema fields
        bq load \
            --location=$1 \
            --source_format=CSV \
            --skip_leading_rows=1 \
            --autodetect \
            $3.$TABLE_name \
            ./$CSV_NAME
            
        cnt=$((cnt + 1))
       
    done

}
# ---------------------------
# Functions END
# ---------------------------





# ---------------------------------------------
# Setup google cloud sdk path settings
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    # Google is SDK is not setup correctly - one needs to relink to the gcloud CLI everytime you restart the PC
    source '/usr/lib/google-cloud-sdk/path.bash.inc'
    source '/usr/lib/google-cloud-sdk/completion.bash.inc'
    export PATH="/usr/lib/google-cloud-sdk/bin:$PATH"
    
    # Get latest version of the Google Cloud CLI (does not work)
    gcloud components update
fi

# ---------------------------------------------




# ---------------------------------------------
# Obtain Authorization Information
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    # Way 0 : gcloud init


    # Way 1 : gcloud auth login

    # A browser pop-up allows you to authorize with your Google account
    gcloud auth login
    
    # gcloud auth login --no-launch-browser
    # gcloud auth login --cred-file=CONFIGURATION_OR_KEY_FILE
    
    # Allow for google drive access, moving files to/from GCP and google drive
    # gcloud auth login --enable-gdrive-access
    
else
    echo ""
    # echo "List active account name"
    # gcloud auth list
fi

# ---------------------------------------------




# ---------------------------------------------
# Set Desired location
# https://cloud.google.com/bigquery/docs/locations
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

	# Set the project region/location
	export location=$(echo "")

	dotenv set location $location

else
    export location=$(dotenv get location)
fi 

# ---------------------------------------------





# ---------------------------------------------
# ENABLE API Services
# ---------------------------------------------
export val=$(echo "X0")

if [[ $val == "X0" ]]
then

    gcloud services enable iam.googleapis.com \
        bigquery.googleapis.com \
        logging.googleapis.com
  
fi

# ---------------------------------------------






# ---------------------------------------------
# SELECT PROJECT_ID
# ---------------------------------------------
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
    # List projects
    # gcloud config list project
    
    # Set project
    export PROJECT_ID=$(echo "")
    gcloud config set project $PROJECT_ID

    # List DATASETS in the current project
    # bq ls $PROJECT_ID:
    # OR
    # bq ls
    
    dotenv set PROJECT_ID $PROJECT_ID

else
    export PROJECT_ID=$(dotenv get PROJECT_ID)
fi

# ---------------------------------------------







# ---------------------------------------------
# SELECT dataset_name
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    # ---------------------------------------------
    # Create a new DATASET named PROJECT_ID
    # ---------------------------------------------
    export dataset_name=$(echo "")
    bq --location=$location mk $PROJECT_ID:$dataset_name
    
    dotenv set dataset_name $dataset_name

else

    # ---------------------------------------------
    # SELECT an existing dataset_name
    # ---------------------------------------------
    export dataset_name=$(dotenv get dataset_name)
    
    # Use existing dataset
    # export dataset_name=$(echo "")

    # ------------------------

    # List TABLES in the dataset
    # echo "bq ls $PROJECT_ID:$dataset_name"
    # bq --location=$location ls $PROJECT_ID:$dataset_name


    # echo "bq show $PROJECT_ID:$dataset_name"
    # bq --location=$location show $PROJECT_ID:$dataset_name

fi


# ---------------------------------------------















# ---------------------------------------------
# Download data from datasource
# ---------------------------------------------
export path_outside_of_ingestion_folder=$(echo "/../Specialization_Google_Analytics_Business_Intelligence_Training/analysis_0")


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	cd $path_outside_of_ingestion_folder
	
	export NAME_OF_DATASET=$(echo "NAME_OF_DATASET")
	
	kaggle datasets download -d $NAME_OF_DATASET
	
	sudo mkdir $path_outside_of_ingestion_folder/data_download
	
	sudo chmod 777 $path_outside_of_ingestion_folder/data_download
	
	sudo mv /default/download/path/*.zip $path_outside_of_ingestion_folder/data_download
	
fi








# ---------------------------------------------
# Organize zip files
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export path_folder_2_organize=$(echo $path_outside_of_ingestion_folder/data_download)

	export ingestion_folder=$(echo "ingestion_folder")

	organize_zip_files_from_datasource_download $path_folder_2_organize $ingestion_folder $path_outside_of_ingestion_folder
	
fi








# ---------------------------------------------
# Upload csv files from the PC to GCP
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export path_folder_2_upload2GCP=$(echo $path_outside_of_ingestion_folder/ingestion_folder/csvdata)
	    
	upload_csv_files $location $path_folder_2_upload2GCP $dataset_name

fi






# -------------------------
# Get table info
# -------------------------
export TABLE_name=$(echo "Telecom_Churn_Rate_Dataset")
dotenv set TABLE_name $TABLE_name


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	bq query \
		    --location=$location \
		    --allow_large_results \
		    --use_legacy_sql=false \
	    'SELECT COUNT(*)
	     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`;'



	VIEW_the_columns_of_a_table $location $PROJECT_ID $dataset_name $TABLE_name
# +------------------+-----------+
# |   column_name    | data_type |
# +------------------+-----------+
# | customerID       | STRING    |
# | gender           | STRING    |  M, F
# | SeniorCitizen    | INT64     |
# | Partner          | BOOL      |
# | Dependents       | BOOL      |
# | tenure           | INT64     |
# | PhoneService     | BOOL      |
# | MultipleLines    | STRING    |
# | InternetService  | STRING    | No, DSL, Fiber optic
# | OnlineSecurity   | STRING    |
# | OnlineBackup     | STRING    |
# | DeviceProtection | STRING    |
# | TechSupport      | STRING    | No internet service, Yes, No
# | StreamingTV      | STRING    |
# | StreamingMovies  | STRING    |
# | Contract         | STRING    | One year, Two year, Month-to-month
# | PaperlessBilling | BOOL      |
# | PaymentMethod    | STRING    |
# | MonthlyCharges   | FLOAT64   |
# | TotalCharges     | STRING    |
# | numAdminTickets  | INT64     |
# | numTechTickets   | INT64     |
# | Churn            | BOOL      |
# +------------------+-----------+
	
fi

# ---------------------------------------------






# -------------------------
# Initially Clean the TABLE :  Need to create a column for repeated contact
# 
# Combine columns numAdminTickets and numTechTickets to indicate number_of_times_contacted
# 
# Everytime a ticket is created it means that a customer contacted/called.
# 
# Metric
# Repeat calls = how often customers call customer support two times or more
# 
# Fictional call center dataset needs to include:
#     Number of calls
#     Number of repeat calls after first contact
#     Call type
#     Market city
#     Date

# Churn rate, sometimes known as attrition rate, is the rate at which customers stop doing business with a company over a given period of time. Churn may also apply to the number of subscribers who cancel or don't renew a subscription. The higher your churn rate, the more customers stop buying from your business.


# Goal : communicate with the customers to reduce the call volume and increase customer satisfaction and improve operational optimization. 
# -------------------------
export OUTPUT_TABLE_name=$(echo "repeat_call0") 
	

export val=$(echo "X1")

if [[ $val == "X0" ]]
then

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name

     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH tabtemp AS (
    SELECT customerID,
    gender,
    InternetService AS market_city, 
    Contract,
    TechSupport,
    CAST(Churn AS INT64) AS Churn_INT,
    numAdminTickets+numTechTickets AS total_problem_type,
    numAdminTickets AS account_mang_problem_type,
    numTechTickets AS tech_troubleshoot_problem_type,
    CASE WHEN Contract = "One year" THEN 12 WHEN Contract = "Two year" THEN 24 WHEN Contract = "Month-to-month" THEN 1 END AS duration
    FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
    )
    SELECT *, 
    total_problem_type/duration AS total_problem_type_call_freq,
    account_mang_problem_type/duration AS accmang_problem_type_call_freq,
    tech_troubleshoot_problem_type/duration AS techtrob_problem_type_call_freq
    FROM tabtemp;'




fi

# RESULT : create the desired dataset measuring repeated contact for an Internet service company
# OUTPUT TABLE NAME: repeat_call0

# ---------------------------------------------







# -------------------------
# Get table info
# -------------------------
export OUTPUT_TABLE_name=$(echo "repeat_call1") 

export val=$(echo "X1")

if [[ $val == "X0" ]]
then

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name

     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT market_city, 
    Contract, 
    TechSupport, 
    SUM(total_problem_type) AS tot_probtype, 
    SUM(account_mang_problem_type) AS acc_mang_probtype, 
    SUM(tech_troubleshoot_problem_type) AS techtrob_probtype, 
    IF(AVG(Churn_INT) > 0.5, True, False) as churn,
    AVG(total_problem_type_call_freq) AS tot_probtype_call_freq, 
    AVG(accmang_problem_type_call_freq) AS acc_mang_probtype_call_freq, 
    AVG(techtrob_problem_type_call_freq) AS techtrob_probtype_call_freq
    FROM `'$PROJECT_ID'.'$dataset_name'.repeat_call0` 
    GROUP BY market_city, Contract, TechSupport
ORDER BY acc_mang_probtype DESC, techtrob_probtype DESC;'


fi


# ---------------------------------------------

# So Fiber optic InternetService customers contact more than 2 times on average. Women with one year contracts contact the most.

# +-------------+----------------+---------------------+--------------------+---------------------+----------------------+-------+------------------------+-----------------------------+-----------------------------+
# | market_city |    Contract    |     TechSupport     |    tot_probtype    |  acc_mang_probtype  |  techtrob_probtype   | churn | tot_probtype_call_freq | acc_mang_probtype_call_freq | techtrob_probtype_call_freq |
# +-------------+----------------+---------------------+--------------------+---------------------+----------------------+-------+------------------------+-----------------------------+-----------------------------+
# | Fiber optic | Two year       | No                  | 1.4462809917355375 |  0.6942148760330579 |   0.7520661157024796 | false |   0.060261707988980714 |        0.028925619834710745 |         0.03133608815426997 |
# | DSL         | Month-to-month | Yes                 |  0.808259587020649 |  0.6165191740412974 |  0.19174041297935113 | false |      0.808259587020649 |          0.6165191740412974 |         0.19174041297935113 |
# | Fiber optic | Two year       | Yes                 |  1.305194805194805 |  0.5779220779220777 |   0.7272727272727277 | false |     0.0543831168831169 |         0.02408008658008658 |        0.030303030303030304 |
# | Fiber optic | One year       | Yes                 | 1.6769911504424775 |  0.5707964601769911 |    1.106194690265487 | false |    0.13974926253687311 |         0.04756637168141594 |         0.09218289085545726 |
# | No          | Month-to-month | No internet service | 0.5763358778625955 |  0.5515267175572519 | 0.024809160305343515 | false |     0.5763358778625955 |          0.5515267175572519 |        0.024809160305343515 |
# | Fiber optic | One year       | No                  | 1.5878594249201283 |  0.5335463258785943 |    1.054313099041534 | false |    0.13232161874334403 |        0.044462193823216214 |         0.08785942492012778 |
# | DSL         | One year       | Yes                 | 0.8619631901840492 |  0.5306748466257669 |   0.3312883435582823 | false |    0.07183026584867075 |         0.04422290388548057 |         0.02760736196319018 |
# | Fiber optic | Month-to-month | No                  | 1.1069042316258337 |  0.5228285077951008 |   0.5840757238307354 |  true |     1.1069042316258337 |          0.5228285077951008 |          0.5840757238307354 |
# | DSL         | Two year       | Yes                 |  0.791423001949318 |  0.5204678362573101 |   0.2709551656920079 | false |    0.03297595841455489 |        0.021686159844054583 |        0.011289798570500317 |
# | No          | Two year       | No internet service | 0.7586206896551726 |  0.5203761755485891 |  0.23824451410658307 | false |    0.03160919540229886 |          0.0216823406478579 |        0.009926854754440965 |
# | DSL         | One year       | No                  | 0.8770491803278687 | 0.49590163934426224 |   0.3811475409836066 | false |    0.07308743169398906 |         0.04132513661202186 |        0.031762295081967214 |
# | No          | One year       | No internet service | 0.5494505494505495 |  0.4697802197802197 |  0.07967032967032966 | false |    0.04578754578754579 |         0.03914835164835165 |        0.006639194139194141 |
# | DSL         | Two year       | No                  | 0.8347826086956519 |  0.4695652173913043 |   0.3652173913043479 | false |    0.03478260869565218 |        0.019565217391304342 |        0.015217391304347825 |
# | Fiber optic | Month-to-month | Yes                 | 1.1114457831325295 | 0.46686746987951805 |   0.6445783132530121 | false |     1.1114457831325295 |         0.46686746987951805 |          0.6445783132530121 |
# | DSL         | Month-to-month | No                  | 0.5882352941176471 | 0.41176470588235287 |   0.1764705882352941 | false |     0.5882352941176471 |         0.41176470588235287 |          0.1764705882352941 |
# +-------------+----------------+---------------------+--------------------+---------------------+----------------------+-------+------------------------+-----------------------------+-----------------------------+

# -------------------------
# Get table info
# -------------------------
export OUTPUT_TABLE_name=$(echo "repeat_call2") 

export val=$(echo "X1")

if [[ $val == "X0" ]]
then

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name

     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT market_city, 
    Contract, 
    TechSupport, 
    SUM(total_problem_type) AS tot_probtype, 
    SUM(account_mang_problem_type) AS acc_mang_probtype, 
    SUM(tech_troubleshoot_problem_type) AS techtrob_probtype, 
    IF(AVG(Churn_INT) > 0.5, True, False) as churn,
    AVG(total_problem_type_call_freq) AS tot_probtype_call_freq, 
    AVG(accmang_problem_type_call_freq) AS acc_mang_probtype_call_freq, 
    AVG(techtrob_problem_type_call_freq) AS techtrob_probtype_call_freq
    FROM `'$PROJECT_ID'.'$dataset_name'.repeat_call0` 
    GROUP BY market_city, Contract, TechSupport
ORDER BY techtrob_probtype DESC, acc_mang_probtype DESC;'


fi

# ---------------------------------------------

# +-------------+----------------+---------------------+--------------------+---------------------+----------------------+-------+------------------------+-----------------------------+-----------------------------+
# | market_city |    Contract    |     TechSupport     |    tot_probtype    |  acc_mang_probtype  |  techtrob_probtype   | churn | tot_probtype_call_freq | acc_mang_probtype_call_freq | techtrob_probtype_call_freq |
# +-------------+----------------+---------------------+--------------------+---------------------+----------------------+-------+------------------------+-----------------------------+-----------------------------+
# | Fiber optic | One year       | Yes                 | 1.6769911504424775 |  0.5707964601769911 |    1.106194690265487 | false |    0.13974926253687311 |         0.04756637168141594 |         0.09218289085545726 |
# | Fiber optic | One year       | No                  | 1.5878594249201283 |  0.5335463258785943 |    1.054313099041534 | false |    0.13232161874334403 |        0.044462193823216214 |         0.08785942492012778 |
# | Fiber optic | Two year       | No                  | 1.4462809917355375 |  0.6942148760330579 |   0.7520661157024796 | false |   0.060261707988980714 |        0.028925619834710745 |         0.03133608815426997 |
# | Fiber optic | Two year       | Yes                 |  1.305194805194805 |  0.5779220779220777 |   0.7272727272727277 | false |     0.0543831168831169 |         0.02408008658008658 |        0.030303030303030304 |
# | Fiber optic | Month-to-month | Yes                 | 1.1114457831325295 | 0.46686746987951805 |   0.6445783132530121 | false |     1.1114457831325295 |         0.46686746987951805 |          0.6445783132530121 |
# | Fiber optic | Month-to-month | No                  | 1.1069042316258337 |  0.5228285077951008 |   0.5840757238307354 |  true |     1.1069042316258337 |          0.5228285077951008 |          0.5840757238307354 |
# | DSL         | One year       | No                  | 0.8770491803278687 | 0.49590163934426224 |   0.3811475409836066 | false |    0.07308743169398906 |         0.04132513661202186 |        0.031762295081967214 |
# | DSL         | Two year       | No                  | 0.8347826086956519 |  0.4695652173913043 |   0.3652173913043479 | false |    0.03478260869565218 |        0.019565217391304342 |        0.015217391304347825 |
# | DSL         | One year       | Yes                 | 0.8619631901840492 |  0.5306748466257669 |   0.3312883435582823 | false |    0.07183026584867075 |         0.04422290388548057 |         0.02760736196319018 |
# | DSL         | Two year       | Yes                 |  0.791423001949318 |  0.5204678362573101 |   0.2709551656920079 | false |    0.03297595841455489 |        0.021686159844054583 |        0.011289798570500317 |
# | No          | Two year       | No internet service | 0.7586206896551726 |  0.5203761755485891 |  0.23824451410658307 | false |    0.03160919540229886 |          0.0216823406478579 |        0.009926854754440965 |
# | DSL         | Month-to-month | Yes                 |  0.808259587020649 |  0.6165191740412974 |  0.19174041297935113 | false |      0.808259587020649 |          0.6165191740412974 |         0.19174041297935113 |
# | DSL         | Month-to-month | No                  | 0.5882352941176471 | 0.41176470588235287 |   0.1764705882352941 | false |     0.5882352941176471 |         0.41176470588235287 |          0.1764705882352941 |
# | No          | One year       | No internet service | 0.5494505494505495 |  0.4697802197802197 |  0.07967032967032966 | false |    0.04578754578754579 |         0.03914835164835165 |        0.006639194139194141 |
# | No          | Month-to-month | No internet service | 0.5763358778625955 |  0.5515267175572519 | 0.024809160305343515 | false |     0.5763358778625955 |          0.5515267175572519 |        0.024809160305343515 |
# +-------------+----------------+---------------------+--------------------+---------------------+----------------------+-------+------------------------+-----------------------------+-----------------------------+







# -------------------------
# Output data table to a display method
# -------------------------
# Way 2 : Connected Google Sheets with Google Apps Script
# https://cloud.google.com/bigquery/docs/connected-sheets?hl=en

# Go to Google Sheets - new spreadsheet - Data - Data connectors - Select BigQuery database

# -------------------------







# -------------------------
# Remove tables
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    
    export TABLE_name=$(echo "")
    
    bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name
    
fi

# -------------------------
