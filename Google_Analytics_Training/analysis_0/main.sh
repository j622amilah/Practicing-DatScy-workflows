#!/bin/bash


clear


export cur_path=$(pwd)

source ./GCP_bigquery_case_study_library.sh
source ./GCP_bigquery_statistic_library.sh
source ./GCP_common_header.sh

cd $cur_path



# ---------------------------
# Functions START
# ---------------------------

download_data(){

		
	# ---------------------------------------------
	# Set Desired location
	# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
	# ---------------------------------------------
	# Set the project region/location
	export region=$(echo "")

	# Set desired output format
	export output=$(echo "text")  # json, yaml, yaml-stream, text, table

	# ---------------------------------------------



	# ---------------------------------------------
	# Setup ROOT AWS credentials 
	# ---------------------------------------------
	export val=$(echo "X0")

	if [[ $val == "X0" ]]
	then 
	    # Generate a new ROOT access key : This information gets sent to the /default/download/path/.aws/credentials and /default/download/path/.aws/config files
	    # AWS site: Go to https://aws.amazon.com/fr/ 
	    # 	- Services - Security, Identity, & Compliance - IAM
	    # 	- To go to root user settings : Quick Links - My security credentials
	    # 	- Open CloudShell - aws iam create-access-key
	    # 
	    #"AccessKey": {
	    #    "AccessKeyId": "AWS_ACCESS_KEY_ID",
	    #    "Status": "Active",
	    #    "SecretAccessKey": "AWS_SECRET_ACCESS_KEY",
	    #    "CreateDate": "2023-06-21T09:20:32+00:00"
	    #}
	    
	    # Set configuration file : aws_access_key_id and aws_secret_access_key are automatically put in /default/download/path/.aws/credentials and /default/download/path/.aws/config files
	    aws configure set region $region
	    aws configure set output $output
	    
	    export AWS_ACCESS_KEY_ID=$(echo "")
	    export AWS_SECRET_ACCESS_KEY=$(echo "")
	fi



	# ---------------------------------------------
	# Setup USER AWS credentials 
	# ---------------------------------------------
	export val=$(echo "X1")

	if [[ $val == "X0" ]]
	then 
	    # Follow instructions at CREATE a username
	    
	    export USERNAME=$(echo "")
	    
	    aws iam create-access-key --user-name $USERNAME
	    
	    # Set configuration file: put information into /default/download/path/.aws/credentials and /default/download/path/.aws/config files
	    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $USERNAME
	    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $USERNAME
	    aws configure set region $region --profile $USERNAME
	    aws configure set output $output --profile $USERNAME
	    
	    # Set environmental variables
	    export AWS_ACCESS_KEY_ID=$(echo "")
	    export AWS_SECRET_ACCESS_KEY=$(echo "")
	fi




	# ---------------------------------------------
	# Make random number for creating variable or names
	# ---------------------------------------------
	if [[ $val == "X1" ]]
	then 
	    let "randomIdentifier=$RANDOM*$RANDOM"
	else
	    let "randomIdentifier=202868496"
	fi

	# ---------------------------------------------





	# ---------------------------------------------
	# Storage S3 commands
	# ---------------------------------------------
	export val=$(echo "X0")

	if [[ $val == "X0" ]]
	then 
	    # List buckets and objects
	    aws s3 ls
	    
	    # Download files from a public S3 Bucket
	    export bucket_name=$(echo "")
	    
	    export cur_path=$(pwd)
	    echo "cur_path"
	    echo $cur_path

	    export folder_2_organize=$(echo "analysis_0/dataORG")
	    echo "folder_2_organize"
	    echo $folder_2_organize

	    export path_folder_2_organize=$(echo "${cur_path}/${folder_2_organize}")

	    aws s3 cp --recursive s3://$bucket_name $path_folder_2_organize
	    
	else
	    echo ""
	fi

	# ---------------------------------------------


}


# ---------------------------------------------


UNION_table_type0(){

    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name
    # $3 = cur_path
    
    
    
    echo "---------------- Query UNION the Tables ----------------"
    # Key : All the headers for the files need to be the same
    
    
    cd $cur_path
    
    export output_TABLE_name_prev=$(echo "output_TABLE_name_prev")
    export output_TABLE_name_cur=$(echo "output_TABLE_name_cur")
    
    # bq ls $PROJECT_ID:$dataset_name
    cnt=0
    for TABLE_name in $(cat table_list_names)
    do  
        echo "TABLE_name:"
        echo $TABLE_name
        
        
        # The output_TABLE_name can not be the same as an existing table, so it is necessary to change the table name after a UNION 
        if [[ $cnt == 0 ]]; then
            # Just save this table to have and output name
            
            # Create output_TABLE_name_prev
            echo "-----------------------------------"
            bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$output_TABLE_name_prev \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT CAST(ride_id AS STRING) AS ride_id,
            CAST(rideable_type AS STRING) AS rideable_type,
            CAST(started_at AS STRING) AS started_at,
            CAST(ended_at AS STRING) AS ended_at,
             CAST(start_station_name AS STRING) AS start_station_name,
             CAST(start_station_id AS STRING) AS start_station_id,
             CAST(end_station_name AS STRING) AS end_station_name,
             CAST(end_station_id AS STRING) AS end_station_id,
             CAST(start_lat AS STRING) AS start_lat,
             CAST(start_lng AS STRING) AS start_lng,
             CAST(end_lat AS STRING) AS end_lat,
             CAST(end_lng AS STRING) AS end_lng,
             CAST(member_casual AS STRING) AS member_casual
             FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`;'
            echo "-----------------------------------"
            
            # It fails: says table is not found ... does it take time to make the table??
            # echo "-----------------------------------"
            # echo "Print length of Unioned table"
            # Print length of Unioned table
            # bq query \
            # --location=$location \
            # --allow_large_results \
            # --use_legacy_sql=false \
            # 'SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$output_TABLE_name_cur'`;'
            echo "-----------------------------------"
            
        else
            
            # Here the table exists and it puts start_station_id and end_station_id as INTEGER
            echo "-----------------------------------"
            echo "Confirm matching table schema of both tables:"
            echo "-----------------------------------"
            echo "Show schema of output_TABLE_name_prev"
            bq --location=$location show \
		--schema \
		--format=prettyjson \
		$PROJECT_ID:$dataset_name.$output_TABLE_name_prev
            
            echo "Show schema of TABLE_name"
            bq --location=$location show \
		--schema \
		--format=prettyjson \
		$PROJECT_ID:$dataset_name.$TABLE_name
            echo "-----------------------------------"
            
            
            echo "-----------------------------------"
            echo "Union tables"
            # Union tables : UNION only takes distinct values, but UNION ALL keeps all of the values selected
            bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$output_TABLE_name_cur \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT CAST(ride_id AS STRING) AS ride_id,
            CAST(rideable_type AS STRING) AS rideable_type,
            CAST(started_at AS STRING) AS started_at,
            CAST(ended_at AS STRING) AS ended_at,
            CAST(start_station_name AS STRING) AS start_station_name,
            CAST(start_station_id AS STRING) AS start_station_id,
            CAST(end_station_name AS STRING) AS end_station_name,
            CAST(end_station_id AS STRING) AS end_station_id,
            CAST(start_lat AS STRING) AS start_lat,
            CAST(start_lng AS STRING) AS start_lng,
            CAST(end_lat AS STRING) AS end_lat,
            CAST(end_lng AS STRING) AS end_lng,
            CAST(member_casual AS STRING) AS member_casual
            FROM `'$PROJECT_ID'.'$dataset_name'.'$output_TABLE_name_prev'`
            UNION ALL 
            SELECT CAST(ride_id AS STRING) AS ride_id,
            CAST(rideable_type AS STRING) AS rideable_type,
            CAST(started_at AS STRING) AS started_at,
            CAST(ended_at AS STRING) AS ended_at,
            CAST(start_station_name AS STRING) AS start_station_name,
            CAST(start_station_id AS STRING) AS start_station_id,
            CAST(end_station_name AS STRING) AS end_station_name,
            CAST(end_station_id AS STRING) AS end_station_id,
            CAST(start_lat AS STRING) AS start_lat,
            CAST(start_lng AS STRING) AS start_lng,
            CAST(end_lat AS STRING) AS end_lat,
            CAST(end_lng AS STRING) AS end_lng,
            CAST(member_casual AS STRING) AS member_casual
            FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`;'
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            echo "Print length of Unioned table"
            # Print length of Unioned table
            bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$output_TABLE_name_cur'`;'
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            #echo "Delete output_TABLE_name_prev"
            # Delete output_TABLE_name_prev because it is now in output_TABLE_name_cur
            bq --location=$location rm -f -t $PROJECT_ID:$dataset_name.$output_TABLE_name_prev
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            # https://cloud.google.com/bigquery/docs/managing-tables#renaming-table
            echo "copy table output_TABLE_name_cur to output_TABLE_name_prev"
            bq --location=$location cp \
            -a -f -n \
            $PROJECT_ID:$dataset_name.$output_TABLE_name_cur \
            $PROJECT_ID:$dataset_name.$output_TABLE_name_prev
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            # Delete output_TABLE_name_cur because it is now in output_TABLE_name_prev
            bq --location=$location rm -f -t $PROJECT_ID:$dataset_name.$output_TABLE_name_cur
            echo "-----------------------------------"
            
        fi
        
        cnt=$((cnt + 1))
        
    done


}


# ---------------------------------------------


UNION_table_type1(){

    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name
    # $3 = cur_path

    echo "---------------- Query UNION the Tables ----------------"
    # Key : All the headers for the files need to be the same
    
    
    cd $cur_path
    
    export output_TABLE_name_prev=$(echo "output_TABLE_name_prev")
    export output_TABLE_name_cur=$(echo "output_TABLE_name_cur")
    
    # bq ls $PROJECT_ID:$dataset_name
    cnt=0
    for TABLE_name in $(cat table_list_names)
    do  
        echo "TABLE_name:"
        echo $TABLE_name
        
        
        # The output_TABLE_name can not be the same as an existing table, so it is necessary to change the table name after a UNION 
        if [[ $cnt == 0 ]]; then
            # Just save this table to have and output name
            
            # Create output_TABLE_name_prev
            echo "-----------------------------------"
            bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$output_TABLE_name_prev \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT CAST(trip_id AS STRING) AS trip_id,
            CAST(starttime AS STRING) AS starttime,
            CAST(stoptime AS STRING) AS stoptime,
            CAST(bikeid AS STRING) AS bikeid,
             CAST(tripduration AS STRING) AS tripduration,
             CAST(start_station_id AS STRING) AS start_station_id,
             CAST(start_station_name AS STRING) AS start_station_name,
             CAST(end_station_id AS STRING) AS end_station_id,
             CAST(end_station_name AS STRING) AS end_station_name,
             CAST(usertype AS STRING) AS usertype,
             CAST(gender AS STRING) AS gender,
             CAST(birthyear AS STRING) AS birthyear
             FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`;'
            echo "-----------------------------------"
            
            # It fails: says table is not found ... does it take time to make the table??
            # echo "-----------------------------------"
            # echo "Print length of Unioned table"
            # Print length of Unioned table
            # bq query \
            # --location=$location \
            # --allow_large_results \
            # --use_legacy_sql=false \
            # 'SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$output_TABLE_name_cur'`;'
            echo "-----------------------------------"
            
        else
            
            # Here the table exists and it puts start_station_id and end_station_id as INTEGER
            echo "-----------------------------------"
            echo "Confirm matching table schema of both tables:"
            echo "-----------------------------------"
            echo "Show schema of output_TABLE_name_prev"
            bq --location=$location show \
		--schema \
		--format=prettyjson \
		$PROJECT_ID:$dataset_name.$output_TABLE_name_prev
            
            echo "Show schema of TABLE_name"
            bq --location=$location show \
		--schema \
		--format=prettyjson \
		$PROJECT_ID:$dataset_name.$TABLE_name
            echo "-----------------------------------"
            
            
            echo "-----------------------------------"
            echo "Union tables"
            # Union tables : UNION only takes distinct values, but UNION ALL keeps all of the values selected
            bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$output_TABLE_name_cur \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT CAST(trip_id AS STRING) AS trip_id,
            CAST(starttime AS STRING) AS starttime,
            CAST(stoptime AS STRING) AS stoptime,
            CAST(bikeid AS STRING) AS bikeid,
             CAST(tripduration AS STRING) AS tripduration,
             CAST(start_station_id AS STRING) AS start_station_id,
             CAST(start_station_name AS STRING) AS start_station_name,
             CAST(end_station_id AS STRING) AS end_station_id,
             CAST(end_station_name AS STRING) AS end_station_name,
             CAST(usertype AS STRING) AS usertype,
             CAST(gender AS STRING) AS gender,
             CAST(birthyear AS STRING) AS birthyear
            FROM `'$PROJECT_ID'.'$dataset_name'.'$output_TABLE_name_prev'`
            UNION ALL 
            SELECT CAST(trip_id AS STRING) AS trip_id,
            CAST(starttime AS STRING) AS starttime,
            CAST(stoptime AS STRING) AS stoptime,
            CAST(bikeid AS STRING) AS bikeid,
             CAST(tripduration AS STRING) AS tripduration,
             CAST(start_station_id AS STRING) AS start_station_id,
             CAST(start_station_name AS STRING) AS start_station_name,
             CAST(end_station_id AS STRING) AS end_station_id,
             CAST(end_station_name AS STRING) AS end_station_name,
             CAST(usertype AS STRING) AS usertype,
             CAST(gender AS STRING) AS gender,
             CAST(birthyear AS STRING) AS birthyear
            FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`;'
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            echo "Print length of Unioned table"
            # Print length of Unioned table
            bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$output_TABLE_name_cur'`;'
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            #echo "Delete output_TABLE_name_prev"
            # Delete output_TABLE_name_prev because it is now in output_TABLE_name_cur
            bq --location=$location rm -f -t $PROJECT_ID:$dataset_name.$output_TABLE_name_prev
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            # https://cloud.google.com/bigquery/docs/managing-tables#renaming-table
            echo "copy table output_TABLE_name_cur to output_TABLE_name_prev"
            bq --location=$location cp \
            -a -f -n \
            $PROJECT_ID:$dataset_name.$output_TABLE_name_cur \
            $PROJECT_ID:$dataset_name.$output_TABLE_name_prev
            echo "-----------------------------------"
            
            echo "-----------------------------------"
            # Delete output_TABLE_name_cur because it is now in output_TABLE_name_prev
            bq --location=$location rm -f -t $PROJECT_ID:$dataset_name.$output_TABLE_name_cur
            echo "-----------------------------------"
            
        fi
        
        cnt=$((cnt + 1))
        
    done

}


# ---------------------------------------------


join_two_tables(){

    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name

	# ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
     export TABLE_name0=$(echo "bikeshare_table0")
     
     # trip_id, starttime, stoptime, bikeid, tripduration, start_station_id, start_station_name, end_station_id, end_station_name, usertype, gender, birthyear
     export TABLE_name1=$(echo "bikeshare_table1")
     
     export TABLE_name_join=$(echo "bikeshare_full")  # ride_id_join

     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_join \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT T0.ride_id, 
            T0.rideable_type, 
            T0.started_at, 
            T0.ended_at, 
            T0.start_station_name AS stsname_T0,
            T0.start_station_id AS ssid_T0,
            T0.end_station_name AS esname_T0,
            T0.end_station_id AS esid_T0,
            T0.start_lat, 
            T0.start_lng, 
            T0.end_lat, 
            T0.end_lng, 
            T0.member_casual,
            T1.trip_id, 
            T1.starttime, 
            T1.stoptime, 
            T1.bikeid, 
            T1.tripduration, 
            T1.start_station_id AS ssid_T1, 
            T1.start_station_name AS stsname_T1, 
            T1.end_station_id AS esid_T1, 
            T1.end_station_name AS esname_T1, 
            T1.usertype, 
            T1.gender, 
            T1.birthyear FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name0'` AS T0
FULL JOIN `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name1'` AS T1 ON T0.ride_id = T1.trip_id;'   

# Try 0: More unique identifier => problem: usertype, gender, birthyear are NULL for member_casual, rideable_type, which means that the Tables just do not align. Even if I stacked the tables and made a common header they would STILL not ALIGN. problem solved, there is no corresponding data.
# FULL JOIN `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name1'` AS T1 ON T0.ride_id = T1.trip_id
# JOIN ON ride_id=trip_id DOES NOTHING because TABLE0 (member_casual, rideable_type) does not align with TABLE1 (usertype, gender, birthyear)

# Try 1: Less unique identifier (does not work)
# FULL JOIN `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name1'` AS T1 ON T0.start_station_id = T1.start_station_id
# FULL JOIN `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name1'` AS T1 ON T0.end_station_id = T1.end_station_id
# FULL JOIN `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name1'` AS T1 ON T0.ride_id = T1.bikeid

}


# ---------------------------------------------


CLEAN_TABLE_bikeshare_full_clean0(){

    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name
    
    export TABLE_name=$(echo "bikeshare_full")
    
    export TABLE_name_clean=$(echo "bikeshare_full_clean0")
     
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_clean \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT IF(ride_id = trip_id AND ride_id IS NOT NULL, NULL, COALESCE(ride_id, trip_id)) AS fin_trip_ID,
    rideable_type,
    IF(started_at = starttime AND started_at IS NOT NULL, NULL, COALESCE(started_at, starttime)) AS fin_starttime,
    IF(ended_at = stoptime AND ended_at IS NOT NULL, NULL, COALESCE(ended_at, stoptime)) AS fin_endtime,
    IF(stsname_T0 = stsname_T1 AND stsname_T0 IS NOT NULL, NULL, COALESCE(stsname_T0, stsname_T1)) AS fin_stsname,
    IF(ssid_T0 = ssid_T1 AND ssid_T0 IS NOT NULL, NULL, COALESCE(ssid_T0, ssid_T1)) AS fin_stsID,
    IF(esname_T0 = esname_T1 AND esname_T0 IS NOT NULL, NULL, COALESCE(esname_T0, esname_T1)) AS fin_esname,
    IF(esid_T0 = esid_T1 AND esid_T0 IS NOT NULL, NULL, COALESCE(esid_T0, esid_T1)) AS fin_esID,
    SAFE_CAST(start_lat AS FLOAT64) AS start_lat_NUM,
    SAFE_CAST(start_lng AS FLOAT64) AS start_lng_NUM,
    SAFE_CAST(end_lat AS FLOAT64) AS end_lat_NUM,
    SAFE_CAST(end_lng AS FLOAT64) AS end_lng_NUM,
    member_casual,
    bikeid,
    tripduration,
    usertype,
    gender,
    birthyear
     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`;'

}


# ---------------------------------------------

CLEAN_TABLE_bikeshare_full_clean1(){

    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name
    
    export TABLE_name=$(echo "bikeshare_full")
    
    export TABLE_name_clean_prev=$(echo "bikeshare_full_clean0") 
    
    export TABLE_name_clean=$(echo "bikeshare_full_clean1") 
    
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_clean \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH temptable AS ( 
    SELECT fin_trip_ID,
    rideable_type,
    CAST(fin_starttime AS TIMESTAMP) AS start_TIMESTAMP,
    CAST(fin_endtime AS TIMESTAMP) AS end_TIMESTAMP,
    fin_stsname,
    fin_stsID,
    fin_esname,
    fin_esID,
    IF(start_lat_NUM > end_lat_NUM, start_lat_NUM, end_lat_NUM) AS MAX_LAT,
    IF(start_lat_NUM < end_lat_NUM, start_lat_NUM, end_lat_NUM) AS MIN_LAT,
    IF(start_lng_NUM > end_lng_NUM, start_lng_NUM, end_lng_NUM) AS MAX_LONG,
    IF(start_lng_NUM < end_lng_NUM, start_lng_NUM, end_lng_NUM) AS MIN_LONG,
    member_casual AS member_casual_T0,
    bikeid,
    tripduration,
    (CASE WHEN usertype="Customer" then "casual" WHEN usertype="Subscriber" then "member" WHEN usertype="Dependent" then "casual" end) AS member_casual_T1,
    gender,
    birthyear
     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name_clean_prev'`
     WHERE member_casual IS NOT NULL OR rideable_type IS NOT NULL OR gender = "Male" OR gender = "Female"
     )
     SELECT fin_trip_ID,
     rideable_type,
     IF(CAST(tripduration AS INTEGER) > TIMESTAMP_DIFF(end_TIMESTAMP, start_TIMESTAMP, SECOND), CAST(tripduration AS INTEGER), TIMESTAMP_DIFF(end_TIMESTAMP, start_TIMESTAMP, SECOND)) AS trip_time,
     fin_stsname,
    fin_stsID,
    fin_esname,
    fin_esID,
    SAFE_CAST(ABS(POWER(MAX_LAT-MIN_LAT, 2) + POWER(MAX_LONG-MIN_LONG, 2)) AS FLOAT64) AS trip_distance,
    COALESCE(member_casual_T0, member_casual_T1) AS member_casual,
    CAST(bikeid AS INTEGER) AS bikeid_INT,
    gender,
    CAST(birthyear AS INTEGER) AS birthyear_INT
     FROM temptable
     WHERE member_casual_T0 IS NOT NULL OR rideable_type IS NOT NULL OR gender = "Male" OR gender = "Female";'

}

# ---------------------------------------------


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
# Obtenir des informations Authorization
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
# Set Desired location
# https://cloud.google.com/bigquery/docs/locations
# ---------------------------------------------
# Set the project region/location
# export location=$(echo "")

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
    export PROJECT_ID=$(echo "$PROJECT_ID")
    gcloud config set project $PROJECT_ID

    # List DATASETS in the current project
    # bq ls $PROJECT_ID:
    # OR
    # bq ls

    #  datasetId         
    #  ------------------------ 
    #   datasetId_name0               
    #   datasetId_name1               
    #   datasetId_name2  

    # ------------------------

fi

# ---------------------------------------------







# ---------------------------------------------
# SELECT dataset_name
# ---------------------------------------------
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 

    # Create a new DATASET named PROJECT_ID
    # export dataset_name=$(echo "")
    # bq --location=$location mk $PROJECT_ID:$dataset_name

    # OR 

    # Use existing dataset
    export dataset_name=$(echo "")

    # ------------------------

    # List TABLES in the dataset
    # echo "bq ls $PROJECT_ID:$dataset_name"
    # bq --location=$location ls $PROJECT_ID:$dataset_name

    # ------------------------

    # echo "bq show $PROJECT_ID:$dataset_name"
    # bq --location=$location show $PROJECT_ID:$dataset_name

    #    Last modified             ACLs             Labels    Type     Max time travel (Hours)  
    #  ----------------- ------------------------- -------- --------- ------------------------- 
    #   08 Mar 11:40:52   Owners:                            DEFAULT   168                      
    #                       XXXXXXX@gmail.com,                                               
    #                       projectOwners                                                       
    #                     Writers:                                                              
    #                       projectWriters                                                      
    #                     Readers:                                                              
    #                       projectReaders  

    # ------------------------

fi


# ---------------------------------------------







# ---------------------------------------------
# Download data from datasource (AWS)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then
	download_data
fi

# OUTPUT : Creates a folder called downloaded_files




# ---------------------------------------------
# Organize zip files
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then
	export path_outside_of_ingestion_folder=$(echo "/../Specialization_Google_Analytics_Training/analysis_0")

	export path_folder_2_organize=$(echo "$path_outside_of_ingestion_folder/downloaded_files")

	export ingestion_folder=$(echo "ingestion_folder_bikeshare")

	# Call the function organize_zip_files_from_datasource_download from GCP_bigquery_case_study_library.sh
	organize_zip_files_from_datasource_download $path_folder_2_organize $ingestion_folder $path_outside_of_ingestion_folder
fi

# OUTPUT : Creates three folders inside the ingestion_folder: zipdata, csvdata, remaining_files




# ---------------------------------------------
# Organize files into separate csv files
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then
	export folder_2_organize=$(echo "$path_outside_of_ingestion_folder/$ingestion_folder/csvdata")

	# Call the function run_GCP_common_header_program from GCP_common_header.sh
	run_GCP_common_header_program $folder_2_organize
fi

# OUTPUT : Creates three folders inside folder_2_organize: exact_match_header, similar_match_header, no_match_header

# Run again because there were many csvfile inside of similar_match_header [this needs to be made automatic *** deciding when to run the algorithm again for the similar_match_header folder until less than 5-10 files are in similar_match_header ***]


export val=$(echo "X1")

if [[ $val == "X0" ]]
then
	export folder_2_organize=$(echo "$path_outside_of_ingestion_folder/$ingestion_folder/csvdata/similar_match_header")

	# Call the function run_GCP_common_header_program from GCP_common_header.sh
	run_GCP_common_header_program $folder_2_organize
fi

# OUTPUT : Creates three folders inside folder_2_organize: exact_match_header, similar_match_header, no_match_header




# ---------------------------------------------
# Upload csv files from the PC to GCP
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	    
	# ******* CHANGE *******
	declare -a UPLOAD_PATHS=('$folder_2_organize/exact_match_header' '$folder_2_organize/similar_match_header/exact_match_header');
	# ******* CHANGE *******

	for cur_path in "${UPLOAD_PATHS[@]}"
	do	
		echo "cur_path"
		echo $cur_path
		upload_csv_files $location $cur_path $dataset_name
	done

fi



# -------------------------
# UNION the rows of the TABLES 
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then
	UNION_table_type0
fi


export val=$(echo "X1")

if [[ $val == "X0" ]]
then
	UNION_table_type1
fi




# -------------------------
# Join the TABLES 
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    join_two_tables
fi





# -------------------------
# CLEAN TABLE bikeshare_full_clean0 :  Identify the main features for the analysis
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then
    CLEAN_TABLE_bikeshare_full_clean0
fi


# -------------------------
# CLEAN TABLE bikeshare_full_clean1
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    
    # Delete TABLE bikeshare_full_clean1
    bq rm -t $PROJECT_ID:$dataset_name.bikeshare_full_clean1

    # Create TABLE bikeshare_full_clean1
    CLEAN_TABLE_bikeshare_full_clean1
fi


# ---------------------------------------------
# Hypothesis Testing
# ---------------------------------------------
# TYPE A RESULTS : probability of a categorical event happening 

# Statistical significance of probablistic count for CATEGORICAL features
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    
    export TABLE_name=$(echo "bikeshare_full_clean1")
    
    export TABLE_name_probcount=$(echo "bikeshare_full_clean1_CATprobcount")

    # Calculation of percentage/probability of occurence across all samples
    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_probcount \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT ROW_NUMBER() OVER(ORDER BY member_casual) AS row_num,
    member_casual, 
    rideable_type, 
    gender, 
    COUNT(*)/(SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`) AS prob_perc
     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
     GROUP BY member_casual, rideable_type, gender
     ORDER BY member_casual, rideable_type, gender;'


    # Is the probability occurence (percentage) per group across all samples statistically significant?
    # Could improve this and add the p-value function as a new column
    export prob_perc=$(echo "prob_perc")  # name of numerical column to find z-statistic values per row
    ONE_SAMPLE_TESTS_zstatistic_per_row $location $prob_perc $PROJECT_ID $dataset_name $TABLE_name_probcount
  
    
fi


# TYPE B RESULTS : statistial probability of numerical features being different for categorical events

# ---------------------------------------------
# Run NUMERICAL FEATURES ONE SAMPLE TESTS (AUTOMATED)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export TABLE_name=$(echo "bikeshare_full_clean1")
	
	declare -a NUM_FEATS=('trip_distance' 'trip_time' 'birthyear_INT');
	
	# ********* CHANGE *********
	echo "Categorical feature:"
	export category_FEAT_name=$(echo "member_casual")
	echo $category_FEAT_name
	# ********* CHANGE *********
	
	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name
   		ONE_SAMPLE_TESTS_t_and_zstatistic_of_NUMfeat_perCategory $location $samp1_FEAT_name $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name
	done
	
fi
# ---------------------------------------------




# ---------------------------------------------
# Run CATEGORICAL FEATURES ONE SAMPLE TESTS (NOT AUTOMATED)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export TABLE_name=$(echo "bikeshare_full_clean1")
	
	# ********* CHANGE *********
	echo "Categorical feature:"
	export category_FEAT_name=$(echo "member_casual")
	echo $category_FEAT_name
	
	echo "Transform categorical feature into a Numerical feature:"
	echo "gender"  # Need to copy paste into function
	ONE_SAMPLE_TESTS_t_and_zstatistic_of_CATfeat_perCategory $location $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name
	# ********* CHANGE *********
	
	# Confirm the numerical values with the categories
	bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT gender, transformed_FEAT, COUNT(*)
     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
     GROUP BY gender, transformed_FEAT;'
fi
# ---------------------------------------------





# ---------------------------------------------
# Run NUMERICAL FEATURES TWO SAMPLE TEST (AUTOMATED)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export TABLE_name=$(echo "bikeshare_full_clean1")
	
	declare -a NUM_FEATS=('trip_distance' 'trip_time' 'birthyear_INT');
	
	# ********* CHANGE *********
	echo "Categorical feature:"
	export category_FEAT_name=$(echo "member_casual")
	export category_FEAT_name_VAR1=$(echo "'member'")
	export category_FEAT_name_VAR2=$(echo "'casual'")
	echo $category_FEAT_name" where variables are "$category_FEAT_name_VAR1" and "$category_FEAT_name_VAR2
	# ********* CHANGE *********
	
	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name
   		TWO_SAMPLE_TESTS_zstatistic_perbinarycategory $location $samp1_FEAT_name $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name $category_FEAT_name_VAR1 $category_FEAT_name_VAR2
	done

fi
# ---------------------------------------------



# -------------------------
# Feature engineering
# 0. Fill NULL values, 1. Normalize the features from 0 to 1
# -------------------------
export TABLE_name2=$(echo "bikeshare_full_cleanML1")


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	# Types of normalization : https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-standard-scaler
	# ML.MAX_ABS_SCALER -  range [-1, 1]
	# ML.MIN_MAX_SCALER range [0, 1]
	# ML.STANDARD_SCALER function scales a numerical expression using z-score.
	
	bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name2
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TABLE_name2 \
            --allow_large_results \
            --use_legacy_sql=false \
            'WITH temptab AS (
            SELECT *, 
            IF(birthyear_INT IS NULL, 1981, birthyear_INT) AS birthyear_INTfill,
            (CASE WHEN rideable_type="electric_bike" then 1 WHEN rideable_type="classic_bike" then 2 WHEN rideable_type="docked_bike" then 3 WHEN rideable_type IS NULL then 3 end) AS rideable_type_INTfill
            FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
            WHERE trip_time > 0
            )
            SELECT 
            ML.MIN_MAX_SCALER(trip_time) OVER() AS trip_time_norm, 
            ML.MIN_MAX_SCALER(birthyear_INTfill) OVER() AS birthyear_INTfill_norm, 
            ML.MIN_MAX_SCALER(rideable_type_INTfill) OVER() AS rideable_type_INTfill_norm,
            IF(member_casual = "member", 0, 1) AS label
            FROM temptab
            WHERE birthyear_INTfill > (2023-100) AND birthyear_INTfill < (2023-18) ;'  
fi



# -------------------------
# Test Train split
# -------------------------
export label_name=$(echo "label")
export train_split=$(echo "0.75")
export TRAIN_TABLE_name=$(echo "TRAIN_TABLE_name")
export TESTING_TABLE_name=$(echo "TESTING_TABLE_name")


export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
	echo "Test Train split: "
	# Downsampling : Creates two class balanced randomized tables (TRAIN_TABLE_name, TEST_TABLE_name) from TABLE_name using the train_split value 
	# test_train_split_equal_class_samples $location $PROJECT_ID $dataset_name $label_name $train_split $TRAIN_TABLE_name $TESTING_TABLE_name $TABLE_name

	# Model weights : The test data is equally divided by class, but the train data contains the rest (the model weights can be used to account for class imbalance)
	test_train_split_NONequal_class_samples $location $PROJECT_ID $dataset_name $label_name $train_split $TRAIN_TABLE_name $TESTING_TABLE_name $TABLE_name2

fi



# -------------------------
# Train the model, evaluate, predict
# -------------------------
# Creates a model called MODEL_name in the dataset folder, that is trained using the TRAIN_TABLE_name table
# https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-automl
# detailed examples : https://cloud.google.com/bigquery/docs/logistic-regression-prediction

export MODEL_name=$(echo "kmeans_model_cosine_MIN_MAX_SCALER")
export PREDICTED_results_TABLE_name=$(echo "kmeans_model_cosine_PREDICTED_results_TABLE_MIN_MAX_SCALER")


export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
	
	echo "K-means clustering: "
	bq rm -f --model $PROJECT_ID:$dataset_name.$MODEL_name
	
	kmeans $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $TESTING_TABLE_name $MODEL_name $PREDICTED_results_TABLE_name 

	# ***** Fix syntax Problems *****

	# echo "Logistic regression classification: "
	# export MODEL_name=$(echo "logistic_reg_model")
	# bq rm -f --model $PROJECT_ID:$dataset_name.$MODEL_name    # https://cloud.google.com/bigquery/docs/deleting-models
	# logistic_regression $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $MODEL_name

	# echo "Decision tree classification: "
	# export MODEL_name=$(echo "decision_tree_model")
	# bq rm -f --model $PROJECT_ID:$dataset_name.$MODEL_name 
	# decision_tree $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $MODEL_name

	# echo "Deep neural network classification: "
	# export MODEL_name=$(echo "DNN_model")
	# bq rm -f --model $PROJECT_ID:$dataset_name.$MODEL_name 
	# deep_neural_network $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $MODEL_name

	# echo "AutoML classification: "
	# export MODEL_name=$(echo "AutoML_model")
	# bq rm -f --model $PROJECT_ID:$dataset_name.$MODEL_name 
	# autoML_model $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $MODEL_name

	# Print information about model
	# echo "Model information: "
	# get_trial_info $location $dataset_name $MODEL_name
fi


# ---------------------------------------------

# ACCURACY_RESULT: Calculate accuracy using the kmeans_model_cosine_PREDICTED_results_TABLE
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
	
	bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH tabtemp AS(
    SELECT IF(CENTROID_ID=2, 0, 1) AS predicted, trip_time_norm, birthyear_INTfill_norm, rideable_type_INTfill_norm, label
    FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name'`
    )
    SELECT (1 - AVG(label - predicted))*100 AS Accuracy FROM tabtemp'

fi

+------------------+
|     Accuracy     |
+------------------+
| 98.2504964939843 |
+------------------+

# ---------------------------------------------


# UNNEST the kmeans predicted table results, add zero column
export PREDICTED_results_TABLE_name2=$(echo "kmeans_model_cosine_PREDICTED_results_TABLE2_MIN_MAX_SCALER")

export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
	bq rm -t $PROJECT_ID:$dataset_name.$PREDICTED_results_TABLE_name2
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$PREDICTED_results_TABLE_name2 \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH tabtemp AS(
    SELECT ROW_NUMBER() OVER() AS row_num,
    T0.CENTROID_ID AS CENTROID_ID_SELECTED,
    NCD.CENTROID_ID AS cosine_centroid_id,
    NCD.DISTANCE AS cosine_dist,
    T0.trip_time_norm,
    T0.birthyear_INTfill_norm,
    T0.rideable_type_INTfill_norm,
    IF(T0.label=0, "member", "casual") AS member_casual
    FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name'` T0,
    UNNEST(NEAREST_CENTROIDS_DISTANCE) AS NCD
    )
    SELECT *,
    (row_num*0) AS zero_col FROM tabtemp'

fi


# ---------------------------------------------


# RECOMMENDATION_RESULT: Calculate the recommendation using the kmeans_model_cosine_PREDICTED_results_TABLE2
export PREDICTED_results_TABLE_name3=$(echo "kmeans_model_cosine_PREDICTED_results_TABLE3_MIN_MAX_SCALER")

export val=$(echo "X0")

if [[ $val == "X0" ]]
then 	
	
	bq rm -t $PROJECT_ID:$dataset_name.$PREDICTED_results_TABLE_name3
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$PREDICTED_results_TABLE_name3 \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH tabtemp AS(
    SELECT *,
    zero_col*(SELECT AVG( SQRT( (((POW(trip_time_norm, 2) + POW(birthyear_INTfill_norm, 2) + POW(rideable_type_INTfill_norm, 2)) / POW(trip_time_norm + birthyear_INTfill_norm + rideable_type_INTfill_norm,2))*(cos(cosine_dist)*cos(cosine_dist))) / (3*2) ) ) FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name2'` WHERE member_casual = "member") AS SWC_centroid
    FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name2'`
    )
    SELECT *,
    (CASE WHEN (trip_time_norm - SWC_centroid) > (birthyear_INTfill_norm - SWC_centroid) THEN "trip_time" WHEN (trip_time_norm - SWC_centroid) > (rideable_type_INTfill_norm - SWC_centroid) THEN "trip_time" WHEN (birthyear_INTfill_norm - SWC_centroid) > (trip_time_norm - SWC_centroid) THEN "birthyear" WHEN (birthyear_INTfill_norm - SWC_centroid) > (rideable_type_INTfill_norm - SWC_centroid) THEN "birthyear" WHEN (rideable_type_INTfill_norm - SWC_centroid) > (trip_time_norm - SWC_centroid) THEN "rideable_type" WHEN (rideable_type_INTfill_norm - SWC_centroid) > (birthyear_INTfill_norm - SWC_centroid) THEN "rideable_type" END) AS feat_recommendation FROM tabtemp'


fi

Operation "operations/acat.p2-189544826227-8200ce85-dc45-4896-97ee-083c1e740c94" finished successfully.
Updated property [core/project].
Calculate recommendation based on outliers:
+---------------+----------------+---------------------------+
| member_casual | recommendation | counts_of_recommendations |
+---------------+----------------+---------------------------+
| member        | no marketing   |                   3567012 |
| casual	| trip_time      |		     2197170 |
| casual	| birthyear      |                   1369842 |
+---------------+----------------+---------------------------+



# ---------------------------------------------

# Verify the recommendations : 
export output_table_name_to_plot=$(echo "table_to_display_MIN_MAX_SCALER")

export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
	bq rm -t $PROJECT_ID:$dataset_name.$output_table_name_to_plot

	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$output_table_name_to_plot \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT member_casual, 
    IF(member_casual = "casual", feat_recommendation, "no_marketing") AS recommendations, 
    COUNT(*) AS counts_of_recommendations,
    IF(member_casual = "casual", COUNT(*)/(SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name3'` WHERE member_casual="casual"), COUNT(*)/(SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name3'` WHERE member_casual="member")) AS percentage
    FROM `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name3'`
    GROUP BY member_casual, recommendations'


fi

# ---------------------------------------------





# ---------------------------------------------
# Output data table to a display method
# ---------------------------------------------
# Way 1: GCP Data Studio: https://lookerstudio.google.com/navigation/reporting

# Way 2 : Connected Google Sheets with Google Apps Script
# https://cloud.google.com/bigquery/docs/connected-sheets?hl=en

# Go to Google Sheets - new spreadsheet - Data - Data connectors - Select BigQuery database

# ---------------------------------------------




            


# -------------------------
# Remove tables
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    
    export TABLE_name=$(echo "")
    
    bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name
    
fi


# ---------------------------------------------
