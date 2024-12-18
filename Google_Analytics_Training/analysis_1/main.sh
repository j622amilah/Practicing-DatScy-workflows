#!/bin/bash


clear


export cur_path=$(pwd)

source ./GCP_bigquery_case_study_library.sh
source ./GCP_bigquery_statistic_library.sh
# source ./GCP_common_header.sh

cd $cur_path




# ---------------------------
# Functions START
# ---------------------------


join_multiple_tables(){
	
    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name
    
	# dailyActivity_merged.csv T0
	# [Id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories]
	
	# minuteCaloriesWide_merged.csv T1
#Id,ActivityHour,Calories00,Calories01, Calories02, Calories03, Calories04, Calories05, Calories06, Calories07, Calories08, Calories09, Calories10, Calories11, Calories12, Calories13, Calories14, Calories15, Calories16, Calories17, Calories18, Calories19, Calories20, Calories21, Calories22, Calories23, Calories24, Calories25, Calories26, Calories27, Calories28, Calories29, Calories30, Calories31, Calories32, Calories33, Calories34, Calories35, Calories36, Calories37, Calories38, Calories39,Calories40, Calories41, Calories42, Calories43, Calories44, Calories45, Calories46, Calories47, Calories48, Calories49, Calories50, Calories51, Calories52, Calories53, Calories54, Calories55, alories56, Calories57, Calories58, Calories59]
     
	# dailyCalories_merged.csv T2
	# [Id, ActivityDay, Calories]
	
	# minuteIntensitiesNarrow_merged.csv T3
	# [Id, ActivityMinute, Intensity
	
	# dailyIntensities_merged.csv T4
	# [Id, ActivityDay, SedentaryMinutes, LightlyActiveMinutes, FairlyActiveMinutes, VeryActiveMinutes, SedentaryActiveDistance, LightActiveDistance, ModeratelyActiveDistance, VeryActiveDistance]

	# minuteIntensitiesWide_merged.csv T5
	# Id, ActivityHour, Intensity00, Intensity01, Intensity02, Intensity03, Intensity04, Intensity05, Intensity06, Intensity07,Intensity08,Intensity09,Intensity10,Intensity11,Intensity12,Intensity13,Intensity14,Intensity15,Intensity16,Intensity17,Intensity18,Intensity19,Intensity20,Intensity21,Intensity22,Intensity23,Intensity24,Intensity25,Intensity26,Intensity27,Intensity28,Intensity29,Intensity30,Intensity31,Intensity32,Intensity33,Intensity34,Intensity35,Intensity36,Intensity37,Intensity38,Intensity39,Intensity40,Intensity41,Intensity42,Intensity43,Intensity44,Intensity45,Intensity46,Intensity47,Intensity48,Intensity49,Intensity50,Intensity51,Intensity52,Intensity53,Intensity54,Intensity55,Intensity56,Intensity57,Intensity58,Intensity59

	# dailySteps_merged.csv T6
	# Id, ActivityDay, StepTotal
	
	# minuteMETsNarrow_merged.csv T7
	# [Id, ActivityMinute, METs]
	
	# heartrate_seconds_merged.csv T8
	# [Id, Time, Value]
	
	# *** Failed to join with dailyActivity_merged
	# minuteSleep_merged.csv T9
	# [Id, date, value, logId]
	
	# hourlyCalories_merged.csv T10
	# [Id, ActivityHour, Calories]
	
	# minuteStepsNarrow_merged.csv T11
	# [Id, ActivityMinutes, Steps]
	
	# hourlyIntensities_merged.csv T12
	# [Id, ActivityHour, TotalIntensity, AverageIntensity]
	
	# minuteStepsWide_merged.csv T13
	# [Id, ActivityHour, Steps00 to Steps59]
	
	# hourlySteps_merged.csv T14
	# Id, ActivityHour, StepTotal]
	
	# *** Failed to join with dailyActivity_merged
	# sleepDay_merged.csv T15
	# Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed]
	
	# minuteCaloriesNarrow_merged.csv T16 
	# Id, ActivityMinute, Calories]
	
	# weightLogInfo_merged.csv T17
	# [Id, Date, WeightKg, WeightPounds, Fat, BMI, IsManualReport, LogId]
	
	# export x=$(echo "weightLogInfo_merged")
	# VIEW_the_columns_of_a_table $location $PROJECT_ID $dataset_name $x
     
	# T1.ActivityHour AS hour_calories,
	# T2.ActivityDay AS day_calories,
        # T3.ActivityMinute min_intensity, 
        # T3.Intensity,
        # T7.METs,
        
     #INNER JOIN `'$2'.'$3'.minuteCaloriesWide_merged` AS T1 ON T0.Id = T1.Id
     #INNER JOIN `'$2'.'$3'.dailyCalories_merged` AS T2 ON T0.Id = T2.Id
     #INNER JOIN `'$2'.'$3'.minuteIntensitiesNarrow_merged` AS T3 ON T0.Id = T3.Id
     #INNER JOIN `'$2'.'$3'.minuteMETsNarrow_merged` AS T7 ON T0.Id = T7.Id
     
     bq rm -t $2:$3.exercise_full
     
     export TABLE_name_join=$(echo "exercise_full")

     bq query \
            --location=$1 \
            --destination_table $2:$3.$TABLE_name_join \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT 
            T0.ActivityDate, 
            T0.TotalSteps, 
            T0.TotalDistance, 
            T0.VeryActiveDistance,
            T0.ModeratelyActiveDistance, 
            T0.LightActiveDistance, 
            T0.SedentaryActiveDistance, 
            T0.VeryActiveMinutes,
            T0.FairlyActiveMinutes,
            T0.LightlyActiveMinutes,
            T0.SedentaryMinutes,
            T0.Calories,
            T8.Value AS heartrate_time,
            T8.Value AS heartrate,
            T15.TotalTimeInBed AS sleep_duration, 
            T17.WeightKg,
            T17.WeightPounds,
            T17.Fat,
            T17.BMI
            FROM `'$2'.'$3'.dailyActivity_merged` AS T0
	 JOIN `'$2'.'$3'.heartrate_seconds_merged` AS T8 ON T0.Id = T8.Id
	 JOIN `'$2'.'$3'.sleepDay_merged` AS T15 ON T0.Id = T15.Id
	 JOIN `'$2'.'$3'.weightLogInfo_merged` AS T17 ON T0.Id = T17.Id;'   

}

# When you create a query by using a JOIN, consider the order in which you are merging the data. The GoogleSQL query optimizer can determine which table should be on which side of the join, but it is still recommended to order your joined tables appropriately. As a best practice, place the table with the largest number of rows first, followed by the table with the fewest rows, and then place the remaining tables by decreasing size.

# When you have a large table as the left side of the JOIN and a small one on the right side of the JOIN, a broadcast join is created. A broadcast join sends all the data in the smaller table to each slot that processes the larger table. It is advisable to perform the broadcast join first.


# ---------------------------

# WORKED
join_2_tables(){
	
    # Inputs:
    # $1 = location
    # $2 = PROJECT_ID
    # $3 = dataset_name
    # $4 = OUTPUT_TABLE_name

     bq query \
            --location=$1 \
            --destination_table $2:$3.$4 \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT 
            T0.Id,
            T0.ActivityDate, 
            T0.TotalSteps, 
            T0.TotalDistance, 
            T0.VeryActiveDistance,
            T0.ModeratelyActiveDistance, 
            T0.LightActiveDistance, 
            T0.SedentaryActiveDistance, 
            T0.VeryActiveMinutes,
            T0.FairlyActiveMinutes,
            T0.LightlyActiveMinutes,
            T0.SedentaryMinutes,
            T0.Calories,
            T8.Value AS heartrate_time,
            T8.Value AS heartrate,
            T15.TotalTimeInBed AS sleep_duration
            FROM `'$2'.'$3'.dailyActivity_merged` AS T0
INNER JOIN `'$2'.'$3'.heartrate_seconds_merged` AS T8 ON T0.Id = T8.Id;'   

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
else
    echo "Do not setup google cloud sdk PATH"
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





# ---------------------------------------------
# Set Desired location
# https://cloud.google.com/bigquery/docs/locations
# ---------------------------------------------
# Set the project region/location
export location=$(echo "")

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
    #                       XXXXXXXX@gmail.com,                                               
    #                       projectOwners                                                       
    #                     Writers:                                                              
    #                       projectWriters                                                      
    #                     Readers:                                                              
    #                       projectReaders  

    # ------------------------

fi


# ---------------------------------------------


    
    







# ---------------------------------------------
# Download data from datasource
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export path_outside_of_ingestion_folder=$(echo "/../Case_Studies/2_case_study_exercise")
	export NAME_OF_DATASET=$(echo "NAME_OF_DATASET")
	
	download_data $path_outside_of_ingestion_folder $NAME_OF_DATASET
fi

# OUTPUT : Creates a folder called downloaded_files




# ---------------------------------------------
# Organize zip files
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export path_outside_of_ingestion_folder=$(echo "/../Specialization_Google_Analytics_Training/analysis_1")

 	export path_folder_2_organize=$(echo "$path_outside_of_ingestion_folder/downloaded_files")

  	export ingestion_folder=$(echo "ingestion_folder_exercise")

	organize_zip_files_from_datasource_download $path_folder_2_organize $ingestion_folder $path_outside_of_ingestion_folder

fi



# ---------------------------------------------
# Upload csv files from the PC to GCP
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	export cur_path=$(echo "/../Specialization_Google_Analytics_Training/analysis_1/ingestion_folder_exercise/csvdata")

	echo "cur_path"
	echo $cur_path
	    
	upload_csv_files $location $cur_path $dataset_name

fi




# -------------------------
# Get table info
# -------------------------


export TABLE_name=$(echo "exercise_full")

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
fi



# -------------------------
# Join the TABLES : logic of joining large tables
# -------------------------


export OUTPUT_TABLE_name=$(echo "exercise_2tables_full")

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	join_2_tables $location $PROJECT_ID $dataset_name $OUTPUT_TABLE_name
	
fi






# -------------------------
# Initially Clean the TABLE :  Identify the main features for the analysis
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean0") 
	

export val=$(echo "X1")

if [[ $val == "X0" ]]
then

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	
	# Partition the table by Id, ActivityDate
	# Id     | ActivityDate | TotalSteps |  TotalDistance   | VeryActiveDistance | ModeratelyActiveDistance | LightActiveDistance | SedentaryActiveDistance | VeryActiveMinutes | FairlyActiveMinutes | LightlyActiveMinutes | SedentaryMinutes | Calories | heartrate_time | heartrate 
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT Id, 
    ActivityDate,
    AVG(TotalSteps) AS mean_steps, 
    AVG(TotalDistance) AS mean_total_distance,
    AVG(VeryActiveDistance) AS mean_active_distance,
    AVG(ModeratelyActiveDistance) AS mean_moderateactive_distance,
    AVG(LightActiveDistance) AS mean_lightactive_distance,
    AVG(SedentaryActiveDistance) AS mean_sedentary_distance,
    AVG(FairlyActiveMinutes) AS mean_fairlyactive_distance,
    AVG(LightlyActiveMinutes) AS mean_light_distance,
    AVG(Calories) AS mean_calories,
    AVG(heartrate) AS mean_hr
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_2tables_full` 
GROUP BY Id, ActivityDate
ORDER BY Id, ActivityDate;'

fi

# RESULT : partition the table by Id and ActivityDate
# OUTPUT TABLE NAME: exercise_full_clean0




# -------------------------
# Join the TABLES : 
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean1")


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

	bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT 
            T0.Id,
            T0.ActivityDate, 
            T0.mean_steps, 
            T0.mean_total_distance,
            T0.mean_active_distance,
            T0.mean_moderateactive_distance,
            T0.mean_lightactive_distance,
            T0.mean_sedentary_distance,
            T0.mean_fairlyactive_distance,
            T0.mean_light_distance,
            T0.mean_calories,
            T0.mean_hr,
            T15.TotalTimeInBed AS sleep_duration,
            FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean0` AS T0
FULL JOIN `'$PROJECT_ID'.'$dataset_name'.sleepDay_merged` AS T15 ON T0.Id = T15.Id;'   
	
fi

# RESULT : join the original table with the sleep table
# OUTPUT TABLE NAME: exercise_full_clean1





# -------------------------
# Clean the TABLE :  Identify the main features for the analysis
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean2") 
	

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
     
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT Id, 
    ActivityDate,
    AVG(mean_steps) AS mean_steps, 
    AVG(mean_total_distance) AS mean_total_distance,
    AVG(mean_active_distance) AS mean_active_distance,
    AVG(mean_moderateactive_distance) AS mean_moderateactive_distance,
    AVG(mean_lightactive_distance) AS mean_lightactive_distance,
    AVG(mean_sedentary_distance) AS mean_sedentary_distance,
    AVG(mean_fairlyactive_distance) AS mean_fairlyactive_distance,
    AVG(mean_light_distance) AS mean_light_distance,
    AVG(mean_calories) AS mean_calories,
    AVG(mean_hr) AS mean_hr,
    COALESCE(AVG(sleep_duration),(SELECT AVG(sleep_duration) FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean1`)) AS sleep_duration
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean1`
    WHERE Id IS NOT NULL
GROUP BY Id, ActivityDate
ORDER BY Id, ActivityDate;'

fi

# RESULT : fill-in NULL values of sleep_duration with the mean
# OUTPUT TABLE NAME: exercise_full_clean2




# -------------------------
# Side query : figure out how to divide a Numerical feature, to make it a Categorical feature
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
     bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT 
            ROUND(AVG(mean_active_distance)), ROUND(MAX(mean_active_distance)), 
            ROUND(AVG(mean_moderateactive_distance)), ROUND(MAX(mean_moderateactive_distance)), 
    ROUND(AVG(mean_lightactive_distance)), ROUND(MAX(mean_lightactive_distance)), 
    ROUND(AVG(mean_sedentary_distance)), ROUND(MAX(mean_sedentary_distance)), 
    ROUND(AVG(mean_fairlyactive_distance)), ROUND(MAX(mean_fairlyactive_distance)),
    ROUND(AVG(mean_light_distance)), ROUND(MAX(mean_light_distance))
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean2`'
    
    # Can do by hand, but there could be too much overlap and the classification error will be high if one manually groups 
    # SELECT
    # ROUND(AVG(mean_sedentary_distance)), ROUND(MAX(mean_sedentary_distance))
    # 0, 0

    # ROUND(AVG(mean_moderateactive_distance)), ROUND(MAX(mean_moderateactive_distance))
    # 1, 4  [1, 4]
    
    # ROUND(AVG(mean_lightactive_distance)), ROUND(MAX(mean_lightactive_distance))
    # 4, 11
    
    # ROUND(AVG(mean_active_distance)), ROUND(MAX(mean_active_distance))
    # 2, 22 [11,22]

    # ROUND(AVG(mean_fairlyactive_distance)), ROUND(MAX(mean_fairlyactive_distance))
    # 14, 113  [22, 113]

    # ROUND(AVG(mean_light_distance)), ROUND(MAX(mean_light_distance))
    # 211, 518 [113, 518]

    # FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean2`

fi

# RESULT : selection of numerical cut-offs for categorical feature
# OUTPUT TABLE NAME: None







# -------------------------
# Create 3 categorical features: wday, lifestyle, binary_lifestyle
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean3")
	

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
     
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH temptab AS (
    SELECT *,
    EXTRACT(DAYOFWEEK FROM ActivityDate) AS dte
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean2`
)
    SELECT
    IF(dte > 4, 2, 5) AS bin_number,
    IF(dte > 4, "weekend", "weekday") AS wday,
    mean_steps, 
    mean_total_distance,
    mean_calories,
    mean_hr,
    sleep_duration,
    CASE WHEN mean_total_distance < 1 THEN "Sedentary" WHEN mean_total_distance > 1 AND mean_total_distance < 4 THEN "Moderate_Active" WHEN mean_total_distance > 4 AND mean_total_distance < 11 THEN "Light_Active" WHEN mean_total_distance > 11 AND mean_total_distance < 22 THEN "Active" WHEN mean_total_distance > 22 AND mean_total_distance < 113 THEN "Fairly_Active" WHEN mean_total_distance > 113 THEN "Light" END AS lifestyle,
    CASE WHEN mean_total_distance < 1 THEN 1 WHEN mean_total_distance > 1 AND mean_total_distance < 4 THEN 2 WHEN mean_total_distance > 4 AND mean_total_distance < 11 THEN 3 WHEN mean_total_distance > 11 AND mean_total_distance < 22 THEN 4 WHEN mean_total_distance > 22 AND mean_total_distance < 113 THEN 5 WHEN mean_total_distance > 113 THEN 6 END AS lifesyle_NUM,
    IF(mean_active_distance < 11, "Non_Active", "Active") AS binary_lifestyle
    FROM temptab'
  
fi  

# RESULT : manual selection of categorical feature lifestyle
# OUTPUT TABLE NAME: exercise_full_clean3













# -------------------------
# CLUSTER the mean_total_distance and compare with manual division
# -------------------------
export TRAIN_TABLE_name=$(echo "TRAIN_TABLE_name")

export PREDICTED_results_TABLE_name=$(echo "kmeans_label")

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
     
     bq rm -t $PROJECT_ID:$dataset_name.$TRAIN_TABLE_name
	
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TRAIN_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT mean_total_distance AS feature,
            CASE WHEN lifestyle = "Sedentary" THEN 1 WHEN lifestyle = "Moderate_Active" THEN 2 WHEN lifestyle = "Light_Active" THEN 3 WHEN lifestyle = "Active" THEN 4 WHEN lifestyle = "Fairly_Active" THEN 4 WHEN lifestyle = "Light" THEN 4 END AS label
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean3`'
    
    export MODEL_name=$(echo "kmeans_model_label")
    
    export NUM_CLUSTERS=$(echo "4")  # Sedentary, Moderate, Light, Active
    kmeans $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $TRAIN_TABLE_name $MODEL_name $PREDICTED_results_TABLE_name $NUM_CLUSTERS

fi





# -------------------------
# Join the tables: kmeans prediction label with orginal table
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean4")


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT 
    T0.bin_number,
    T0.wday,
    T0.mean_steps, 
    T0.mean_total_distance,
    T0.mean_calories,
    T0.mean_hr,
    T0.sleep_duration,
    T0.lifestyle,
    T0.binary_lifestyle,
    T1.CENTROID_ID AS kmeans_label, 
    T0.lifesyle_NUM AS lifesyle_NUM
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean3` AS T0
    FULL JOIN `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name'` AS T1 ON T0.mean_total_distance = T1.feature
    JOIN `'$PROJECT_ID'.'$dataset_name'.'$PREDICTED_results_TABLE_name'` ON T0.lifesyle_NUM = T1.label
    '

fi

# RESULT : Join the tables: kmeans prediction label with orginal table
# OUTPUT TABLE NAME: exercise_full_clean4



# -------------------------
# Remove NULL values in categorical features
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean5") 
	

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
     
    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT *
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean4`
    WHERE lifestyle IS NOT NULL AND binary_lifestyle IS NOT NULL'

fi


# RESULT : Create 3 categorical features: wday, lifestyle, binary_lifestyle
# OUTPUT TABLE NAME: exercise_full_clean5






# -------------------------
# Figure out which lifestyle group corresponds to each kmeans label
# Use a JOIN to create a NEW TABLE! Then select the desired columns
# -------------------------

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
    'WITH tabtemp AS(
SELECT 	lifestyle, lifesyle_NUM, kmeans_label, COUnt(*) AS count
FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean5` 
Group by 	
lifesyle_NUM, lifestyle, kmeans_label
Order by 	
lifesyle_NUM
)
SELECT T0.lifestyle,
T0.lifesyle_NUM,
T0.kmeans_label,
T1.max_count FROM tabtemp T0
JOIN (SELECT lifesyle_NUM, MAX(count) AS max_count FROM tabtemp GROUP BY lifesyle_NUM) AS T1 ON T0.lifesyle_NUM = T1.lifesyle_NUM AND T0.count = T1.max_count'

fi

# +-----------------+--------------+--------------+-----------+
# |    lifestyle    | lifesyle_NUM | kmeans_label | max_count |
# +-----------------+--------------+--------------+-----------+
# | Sedentary       |            1 |            3 |    724950 |
# | Light_Active    |            3 |            1 |     51435 |
# | Moderate_Active |            2 |            3 |     52650 |
# | Active          |            4 |            2 |      8100 |
# +-----------------+--------------+--------------+-----------+

# 1 = Light_Active, 2 = Active, 3 = Sedentary 4 = Moderate_Active





# ---------------------------------------------
# Figure out which lifestyle group corresponds to each kmeans label.
#
# Look at the mean of the 4 features and confirm that the data makes logical sense with the assignment of these cluster groups.
#
# Compare the mean of categories with respect to others
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	declare -a NUM_FEATS=('mean_steps' 'mean_total_distance' 'mean_calories' 'mean_hr' 'sleep_duration');

	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name

	    bq query \
		    --location=$location \
		    --allow_large_results \
		    --use_legacy_sql=false \
	    'SELECT kmeans_label AS category, 
	AVG('$samp1_FEAT_name') AS mean 
	FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean5`
	GROUP BY kmeans_label
	ORDER BY mean DESC;'

	done

fi

# These groups are in order from most to least of the following numerical features: mean_steps, mean_total_distance, mean_calories
# 2 = Active, 1 = Light_Active, 4 = Moderate_Active, 3 = Sedentary



# -------------------------
# Calculate the accuracy for both labels
# -------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT WITH tabtemp AS(
    SELECT CASE 
    WHEN kmeans_label = 5 THEN 1 
    WHEN kmeans_label = 4 THEN 3
    WHEN kmeans_label = 3 THEN 3 
    WHEN kmeans_label = 2 THEN 4 
    WHEN kmeans_label = 1 THEN 5 
    WHEN lifestyle = "Light" THEN 6 END AS predicted
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean5`
    )
    SELECT (1 - AVG(kmeans_label - predicted))*100 AS Accuracy FROM tabtemp'

fi

# RESULT : Calculate the accuracy for both labels
# OUTPUT TABLE NAME: None
    
    


# -------------------------
# Final CLEAN TABLE : make a text label for the kmeans_label to prevent confusion
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean6") 
	

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

     bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
     
     bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT *, 
    CASE WHEN kmeans_label = 2 THEN "Active" WHEN kmeans_label = 1 THEN "Light_Active" WHEN kmeans_label = 4 THEN "Moderate_Active" WHEN kmeans_label = 3 THEN "Sedentary" END AS kmeans_CATlabel
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean5`
    WHERE lifestyle IS NOT NULL AND binary_lifestyle IS NOT NULL'
	
	
     VIEW_the_columns_of_a_table $location $PROJECT_ID $dataset_name $OUTPUT_TABLE_name
     
fi


# RESULT : Create a clear kmeans_CATlabel for number kmeans_label
# OUTPUT TABLE NAME: exercise_full_clean6
    




















# Categorial features
# lifestyle
# wday
# binary_lifestyle

# Numerical features
# mean_steps, mean_total_distance, mean_calories, mean_hr, sleep_duration


export TABLE_name=$(echo "exercise_full_clean6")


declare -a NUM_FEATS=('mean_steps' 'mean_total_distance' 'mean_calories' 'mean_hr' 'sleep_duration');


# ********* CHANGE *********
echo "Categorical feature 1 sample t-test:"
export category_FEAT_name_1samptest=$(echo "kmeans_CATlabel")
# export category_FEAT_name_1samptest=$(echo "lifestyle")  # handmade label
echo $category_FEAT_name_1samptest
# ********* CHANGE *********


# ********* CHANGE *********
echo "Categorical feature 2 sample t-test:"
export category_FEAT_name_2samptest=$(echo "binary_lifestyle")
export category_FEAT_name_VAR1_2samptest=$(echo "'Non_Active'")
export category_FEAT_name_VAR2_2samptest=$(echo "'Active'")
echo $category_FEAT_name_2samptest" where variables are "$category_FEAT_name_VAR1_2samptest" and "$category_FEAT_name_VAR2_2samptest
# ********* CHANGE *********



# ---------------------------------------------
# Statistical Analysis : Hypothesis Testing
# ---------------------------------------------
# TYPE A RESULTS : probability of a categorical event happening 

# Statistical significance of probablistic count for CATEGORICAL features
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    
    export TABLE_name_probcount=$(echo "TABLE_name_probcount_CATEGORY")

    bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name_probcount

    # Calculation of percentage/probability of occurence across all samples
    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_probcount \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT ROW_NUMBER() OVER(ORDER BY '$category_FEAT_name_1samptest') AS row_num,
    '$category_FEAT_name_1samptest', 
    wday, 
    COUNT(*)/(SELECT COUNT(*) FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`) AS prob_perc
     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
     GROUP BY '$category_FEAT_name_1samptest', wday
     ORDER BY '$category_FEAT_name_1samptest', wday;'

    export prob_perc=$(echo "prob_perc")  # name of numerical column to find z-statistic values per row
    ONE_SAMPLE_TESTS_zstatistic_per_row $location $prob_perc $PROJECT_ID $dataset_name $TABLE_name_probcount
  
    
fi



# ---------------------------------------------


# Statistical significance of probablistic count for NUMERICAL features per BIN_NUMBER (sort of like ONE-WAY ANOVA)
# ---------------------------------------------
# To determine the average (numerical) feature value per category over a span of time (weekend, weekday)
# ---------------------------------------------
# *** NOT AUTOMATED, but written out *** 
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

	export TABLE_name_probcount=$(echo "TABLE_name_probcount_NUMERICAL")

	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name

	       bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name_probcount

		# Calculation of percentage/probability of occurence of a numerical feature (workout_minutes) for a bin_number [ie: days (weekday=5, weekend=2)] across all samples
	    bq query \
		    --location=$location \
		    --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_probcount \
		    --allow_large_results \
		    --use_legacy_sql=false \
	    'WITH tab2 AS
	(
	  SELECT *, 
	  (SELECT AVG('$samp1_FEAT_name')/AVG(bin_number) FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'` WHERE wday ="weekend") AS pop_weekend
	  FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
	)
	SELECT ROW_NUMBER() OVER(ORDER BY '$category_FEAT_name_1samptest') AS row_num, '$category_FEAT_name_1samptest', wday, (AVG('$samp1_FEAT_name')/AVG(bin_number))/AVG(pop_weekend) AS prob_perc 
	FROM tab2
	GROUP BY wday, '$category_FEAT_name_1samptest'
	ORDER BY wday, '$category_FEAT_name_1samptest';'

	    export prob_perc=$(echo "prob_perc")  # name of numerical column to find z-statistic values per row
	    ONE_SAMPLE_TESTS_zstatistic_per_row $location $prob_perc $PROJECT_ID $dataset_name $TABLE_name_probcount

	done

fi
# ---------------------------------------------





# ---------------------------------------------
# ONE-WAY ANOVA
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	declare -a NUM_FEATS=('mean_steps');
	
	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name
		
		
   		# ONE_WAY_ANOVA $location $samp1_FEAT_name $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name_2samptest $category_FEAT_name_VAR1_2samptest $category_FEAT_name_VAR2_2samptest
   		

# Try 1: More simplistic thinking, no ARRAY 

		# Create a table with even sampling
		export OUTPUT_TABLE_name=$(echo "exercise_full_clean7")
		bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
   		bq query \
		    --location=$location \
		    --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
		    --allow_large_results \
		    --use_legacy_sql=false \
            'WITH first_tabtemp AS (
  SELECT ROW_NUMBER() OVER(PARTITION BY kmeans_CATlabel ORDER BY RAND() DESC) AS num_row_per_class, *
FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean6`
)
SELECT * FROM first_tabtemp
    WHERE num_row_per_class < (SELECT COUNT(*) FROM first_tabtemp WHERE num_row_per_class IS NOT NULL GROUP BY kmeans_CATlabel ORDER BY COUNT(*) ASC LIMIT 1)'
	    
	    
	    # Normalize the mean_steps - no need to do this, the F-value is the same
	    export OUTPUT_TABLE_name=$(echo "exercise_full_clean8")
	    bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT *,
            ML.STANDARD_SCALER(mean_steps) OVER() AS mean_steps_norm
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean7`'
	    
	    

	    # Compute SSR
	    export OUTPUT_TABLE_name=$(echo "exercise_full_clean9")
	    bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'WITH first_tabtemp AS (
  SELECT 
  kmeans_CATlabel, 
  AVG(mean_steps_norm) AS mean_per_grp, 
  COUNT(*) AS len_per_grp,
  (SELECT AVG(mean_steps_norm) FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean8`) AS pop_mean
FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean8`
GROUP BY kmeans_CATlabel
), second_tabtemp AS(
SELECT * FROM first_tabtemp T0
-- Sum of the squared error with respect to the population mean (my probablistic ratio with respect to the population mean algorithm)
CROSS JOIN (SELECT SUM(len_per_grp*POW(mean_per_grp - pop_mean, 2)) AS SSR FROM first_tabtemp) T1
)
SELECT * FROM second_tabtemp'


	    # Compute SSE
	    export OUTPUT_TABLE_name=$(echo "exercise_full_clean10")
	    bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'WITH first_tabtemp AS (
  SELECT 
  kmeans_CATlabel, IF(kmeans_CATlabel = "Sedentary", mean_steps_norm, NULL) AS Sedentary_vals,
  IF(kmeans_CATlabel = "Light_Active", mean_steps_norm, NULL) AS Light_vals,
  IF(kmeans_CATlabel = "Moderate_Active", mean_steps_norm, NULL) AS Moderate_vals,
  IF(kmeans_CATlabel = "Active", mean_steps_norm, NULL) AS Active_vals
  FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean8`
),
second_temporary_table AS (
  SELECT
  SUM(POW(T0.Sedentary_vals - T1.Sedentary_mean, 2)) AS SSE_Sedentary, 
  SUM(POW(T0.Light_vals - T1.Light_mean, 2)) AS SSE_Light,
  SUM(POW(T0.Moderate_vals - T1.Moderate_mean, 2)) AS SSE_Moderate,
  SUM(POW(T0.Active_vals - T1.Active_mean, 2)) AS SSE_Active
  FROM first_tabtemp T0 
  CROSS JOIN (SELECT AVG(Sedentary_vals) AS Sedentary_mean,
  AVG(Light_vals) AS Light_mean,
  AVG(Moderate_vals) AS Moderate_mean,
  AVG(Active_vals) AS Active_mean FROM first_tabtemp) T1
)
SELECT 
-- Sum of squared error with respect to each category/group mean
SSE_Sedentary + SSE_Light + SSE_Moderate + SSE_Active AS SSE
FROM second_temporary_table'





	    # Compute SSE
	    export OUTPUT_TABLE_name=$(echo "exercise_full_clean11")
	    bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	    bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'WITH first_tabtemp AS (
SELECT *,
-- k = number of observations per group = 4
4 AS k,
T0.SSR AS SSR_scalar,
T1.SSE AS SSE_scalar,
-- Total sum of the squared error wrt population and individual group means
T0.SSR + T1.SSE AS SST_scalar
FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean9` T0
CROSS JOIN (SELECT SSE FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean10`) T1
),
second_tabtemp AS (
SELECT *,
-- df_treatment = k-1
k-1 AS df_treatment,
-- n = total length of data across groups = len_per_grp
k*(SELECT len_per_grp FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean9` LIMIT 1) AS n
FROM first_tabtemp
),
third_tabtemp AS (
SELECT *,
-- df_error = n-k
n-k AS df_error,
-- MS_treatement = SST/df_treatment
SST_scalar/df_treatment AS MS_treatement
FROM second_tabtemp
),
fourth_tabtemp AS (
SELECT *,
-- MS_error = SSE/df_error
SSE_scalar/df_error AS MS_error
FROM third_tabtemp
)
SELECT 
kmeans_CATlabel,
mean_per_grp,
len_per_grp,
pop_mean,
SSR_scalar,
SSE_scalar,
SST_scalar,
df_treatment,
df_error,
MS_treatement,
MS_error,
-- F_critical = MS_treatement/MS_error
MS_treatement/MS_error AS F_critical
FROM fourth_tabtemp
ORDER BY mean_per_grp DESC;'

   		
	done

fi

# Step 6: Interpret the results

# RESULT tells if there is significant difference between the group means.
# But it does not rank the group means with respect to the population mean and/or other group means  

# +-----------------+----------------------+-------------+-----------------------+-------------------+--------------------+-------------------+--------------+----------+-------------------+---------------------+-------------------+
# | kmeans_CATlabel |     mean_per_grp     | len_per_grp |       pop_mean        |    SSR_scalar     |     SSE_scalar     |    SST_scalar     | df_treatment | df_error |   MS_treatement   |      MS_error       |    F_critical     |
# +-----------------+----------------------+-------------+-----------------------+-------------------+--------------------+-------------------+--------------+----------+-------------------+---------------------+-------------------+
# | Active          |   1.1005356766532488 |       22679 | 1.511140659219562E-16 | 79942.61881494262 | 10772.381185058042 | 90715.00000000065 |            3 |    90712 | 30238.33333333355 | 0.11875365095090001 | 254630.7679065456 |
# | Light_Active    |  0.45993389893419667 |       22679 | 1.511140659219562E-16 | 79942.61881494262 | 10772.381185058042 | 90715.00000000065 |            3 |    90712 | 30238.33333333355 | 0.11875365095090001 | 254630.7679065456 |
# | Moderate_Active | -0.11513643697292167 |       22679 | 1.511140659219562E-16 | 79942.61881494262 | 10772.381185058042 | 90715.00000000065 |            3 |    90712 | 30238.33333333355 | 0.11875365095090001 | 254630.7679065456 |
# | Sedentary       |  -1.4453331386145112 |       22679 | 1.511140659219562E-16 | 79942.61881494262 | 10772.381185058042 | 90715.00000000065 |            3 |    90712 | 30238.33333333355 | 0.11875365095090001 | 254630.7679065456 |
# +-----------------+----------------------+-------------+-----------------------+-------------------+--------------------+-------------------+--------------+----------+-------------------+---------------------+-------------------+


# degrees of freedom = 
# F_statistic = 0.243 (it calculates)
# Probability = 0.05
# 

# The F test statistic for this one-way ANOVA is 2.358. To determine if this is a statistically significant result, we must compare this to the F critical value found in the F distribution table with the following values:

#     α (significance level) = 0.05
#     DF1 (numerator degrees of freedom) = df treatment = 2
#     DF2 (denominator degrees of freedom) = df error = 27

# We find that the F critical value is 3.3541.

# Since the F test statistic in the ANOVA table is less than the F critical value in the F distribution table, we fail to reject the null hypothesis. This means we don’t have sufficient evidence to say that there is a statistically significant difference between the mean exam scores of the three groups.




# ---------------------------------------------
# To determine the average (numerical) feature value per category : probablity of the mean with respect to others
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 

	export TABLE_name_probcount=$(echo "TABLE_name_probcount_NUMERICAL")

	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name

	       bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name_probcount

		# Calculation of percentage/probability of occurence of a numerical feature (workout_minutes) for a bin_number [ie: days (weekday=5, weekend=2)] across all samples
	    bq query \
		    --location=$location \
		    --destination_table $PROJECT_ID:$dataset_name.$TABLE_name_probcount \
		    --allow_large_results \
		    --use_legacy_sql=false \
	    'WITH tab2 AS
	(
	  SELECT *, 
	  (SELECT AVG('$samp1_FEAT_name') FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`) AS pop_weekend
	  FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
	)
	SELECT ROW_NUMBER() OVER(ORDER BY '$category_FEAT_name_1samptest') AS row_num, 
	'$category_FEAT_name_1samptest', 
	AVG('$samp1_FEAT_name')/AVG(pop_weekend) AS prob_perc 
	FROM tab2
	GROUP BY '$category_FEAT_name_1samptest'
	ORDER BY '$category_FEAT_name_1samptest';'


	    # Is the probability occurence (percentage) per group across all samples statistically significant?
	    # Could improve this and add the p-value function as a new column
	    export prob_perc=$(echo "prob_perc")  # name of numerical column to find z-statistic values per row
	    ONE_SAMPLE_TESTS_zstatistic_per_row $location $prob_perc $PROJECT_ID $dataset_name $TABLE_name_probcount

	done

fi
# ---------------------------------------------













# ---------------------------------------------


# TYPE B RESULTS : statistial probability of numerical features being different for categorical events

# ---------------------------------------------
# Run NUMERICAL FEATURES ONE SAMPLE TESTS (AUTOMATED)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name
   		ONE_SAMPLE_TESTS_t_and_zstatistic_of_NUMfeat_perCategory $location $samp1_FEAT_name $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name_1samptest
	done
	
fi
# ---------------------------------------------




# ---------------------------------------------
# Run CATEGORICAL FEATURES ONE SAMPLE TESTS (NOT AUTOMATED)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	# ********* CHANGE *********
	echo "Transform categorical feature into a Numerical feature:"
	echo "wday"  # Need to copy paste into function
	ONE_SAMPLE_TESTS_t_and_zstatistic_of_CATfeat_perCategory $location $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name_1samptest
	# ********* CHANGE *********
	
	# Confirm the numerical values with the categories
	bq query \
            --location=$location \
            --allow_large_results \
            --use_legacy_sql=false \
    'SELECT wday, transformed_FEAT, COUNT(*)
     FROM `'$PROJECT_ID'.'$dataset_name'.'$TABLE_name'`
     GROUP BY wday, transformed_FEAT;'
fi
# ---------------------------------------------





# ---------------------------------------------
# Run NUMERICAL FEATURES TWO SAMPLE TEST for a [binary categorical feature] (AUTOMATED)
# ---------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	
	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name
   		TWO_SAMPLE_TESTS_zstatistic_perbinarycategory $location $samp1_FEAT_name $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name_2samptest $category_FEAT_name_VAR1_2samptest $category_FEAT_name_VAR2_2samptest
	done

fi


# ---------------------------------------------


# ---------------------------------------------
# Run NUMERICAL FEATURES TWO SAMPLE TEST for a [multi-categorical feature] (AUTOMATED)
# ***** The values need to be put into a table, too many output values *****
# ---------------------------------------------
export val=$(echo "X1")

declare -a CAT_FEATS=("'Active'" "'Sedentary'" "'Light_Active'" "'Moderate_Active'");

if [[ $val == "X0" ]]
then 
	for samp1_FEAT_name in "${NUM_FEATS[@]}"
	do	
		echo "Numerical feature:"
		echo $samp1_FEAT_name
	
		for category_FEAT_name_VAR1_2samptest in "${CAT_FEATS[@]}"
		do
			echo "Categorical feature 2 sample t-test:"
			echo $category_FEAT_name_VAR1_2samptest
			
			for category_FEAT_name_VAR2_2samptest in "${CAT_FEATS[@]}"
			do
				
				if [[ $category_FEAT_name_VAR1_2samptest != $category_FEAT_name_VAR2_2samptest ]]
				then 
					echo $category_FEAT_name_2samptest" where variables are "$category_FEAT_name_VAR1_2samptest" and "$category_FEAT_name_VAR2_2samptest
					TWO_SAMPLE_TESTS_zstatistic_perbinarycategory $location $samp1_FEAT_name $PROJECT_ID $dataset_name $TABLE_name $category_FEAT_name_2samptest $category_FEAT_name_VAR1_2samptest $category_FEAT_name_VAR2_2samptest
				fi
				
			done
			
		done
		
         done

fi




















# ---------------------------------------------
# MODELING
# ---------------------------------------------

# Predict Type_of_exercise 

# -------------------------
# Feature engineering
# 0. Fill NULL values, 1. Normalize the features from 0 to 1
# -------------------------
export OUTPUT_TABLE_name=$(echo "exercise_full_clean12") 


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	# Types of normalization : https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-standard-scaler
	# ML.MAX_ABS_SCALER -  range [-1, 1]
	# ML.MIN_MAX_SCALER range [0, 1]
	# ML.STANDARD_SCALER function scales a numerical expression using z-score.
	
	bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT
            ML.STANDARD_SCALER(mean_steps) OVER() AS mean_steps_norm,
            ML.STANDARD_SCALER(mean_total_distance) OVER() AS mean_total_distance_norm,
            ML.STANDARD_SCALER(mean_calories) OVER() AS mean_calories_norm,
            ML.STANDARD_SCALER(mean_hr) OVER() AS mean_hr_norm,
            CAST(2*RAND() AS INT64) AS label
    FROM `'$PROJECT_ID'.'$dataset_name'.exercise_full_clean6`'
          
        # Need to make a label for kmeans  (it forces you to do this eventhough it is an unsupervised method)
        
        # Way 0: make a dummy vector of ones
        # CAST((0*mean_steps)+1 AS INT64)) AS label
        
        # Way 1 : make a random label of expected values [1,2,3]
        # CAST(2*RAND() AS INT64) AS label
        
        # Way 2: make what I hope it to be
	# For kmeans/unsupervised we need to give it a label, try to make a close label for what we want to redic
	# Runner (large mean_steps, large mean_total_distance, high mean_calories, high mean_hr) = 1
	# Walker (moderate mean_steps, high mean_total_distance, moderate mean_calories, low-moderate mean_hr) = 2
	# Gym (low-moderate mean_steps, high mean_calories, mixed mean_hr) = 3

	# CASE WHEN value > 1 AND value%2 != 0 THEN value 
	# WHEN value > 1 AND value%2 = 0 THEN NULL 
	# WHEN value > 9 AND value%2 != 0 AND value%3 != 0 AND value%5 != 0 AND value%7 != 0 AND value%9 != 0 THEN value 
	# WHEN value > 9 AND value%2 = 0 AND value%3 = 0 AND value%5 = 0 AND value%7 = 0 AND value%9 = 0 THEN NULL 
	# END AS prime_number
	
fi




# ERROR HERE!

# -------------------------
# Test Train split
# -------------------------
export label_name=$(echo "label")
export train_split=$(echo "0.75")
export TRAIN_TABLE_name=$(echo "TRAIN_TABLE_name")
export TESTING_TABLE_name=$(echo "TESTING_TABLE_name")


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
	echo "Test Train split: "
	# Downsampling : Creates two class balanced randomized tables (TRAIN_TABLE_name, TEST_TABLE_name) from TABLE_name using the train_split value 
	# test_train_split_equal_class_samples $location $PROJECT_ID $dataset_name $label_name $train_split $TRAIN_TABLE_name $TESTING_TABLE_name $TABLE_name

	# Model weights : The test data is equally divided by class, but the train data contains the rest (the model weights can be used to account for class imbalance)
	test_train_split_NONequal_class_samples $location $PROJECT_ID $dataset_name $label_name $train_split $TRAIN_TABLE_name $TESTING_TABLE_name $OUTPUT_TABLE_name

fi






# -------------------------
# CLUSTER the mean_total_distance and compare with manual division
# Predict exercise_type: Running , Walking, Gym
# -------------------------
export PREDICTED_results_TABLE_name=$(echo "kmeans_predict_exercise_type")

export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
     
    export MODEL_name=$(echo "kmeans_model_predict_exercise_type")
    
    export NUM_CLUSTERS=$(echo "3")  
    
    
    kmeans $location $PROJECT_ID $dataset_name $TRAIN_TABLE_name $TRAIN_TABLE_name $MODEL_name $PREDICTED_results_TABLE_name $NUM_CLUSTERS

fi

# ---------------------------------------------


# Query to match the clusters to the features, so that I can know which cluster is 

# Run/Walk (high steps, high distance, high calories, moderate hr)=2 , 
# (low steps, low distance, low calories, low hr) they do nothing, 
# (low steps, low distance, semi-low calories, high hr) Probably at the Gym

# +-------------+---------------------+----------------------+---------------------+---------------------+
# | CENTROID_ID |        steps        |       distance       |      calories       |         hr          |
# +-------------+---------------------+----------------------+---------------------+---------------------+
# |           3 |  -0.429742850050325 | -0.41945225503768796 | -0.2758035817795051 | 0.08928496956032417 |
# |           1 | -0.4196294211903514 | -0.41027305043508516 | -0.2582096080946233 | 0.04740478504750922 |
# |           2 |   1.925752435154324 |   1.8809878065450987 |  1.2142717700912848 |  -0.325985199489712 |
# +-------------+---------------------+----------------------+---------------------+---------------------+


		
export OUTPUT_TABLE_name=$(echo "kmeans_predict_exercise_type1") 

export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
	bq rm -t $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name
	
	bq query \
            --location=$location \
            --destination_table $PROJECT_ID:$dataset_name.$OUTPUT_TABLE_name \
            --allow_large_results \
            --use_legacy_sql=false \
            'SELECT CENTROID_ID,
    AVG(mean_steps_norm) AS steps,
    AVG(mean_total_distance_norm) AS distance,
    AVG(mean_calories_norm) AS calories,
    AVG(mean_hr_norm) AS hr
FROM `'$PROJECT_ID'.'$dataset_name'.kmeans_predict_exercise_type`
GROUP BY CENTROID_ID
ORDER BY steps, distance, calories, hr, CENTROID_ID DESC'

fi


# ---------------------------------------------





# ---------------------------------------------





# ---------------------------------------------



# ---------------------------------------------


export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    
    echo "---------------- Query Delete Tables ----------------"
    
    export TABLE_name_join=$(echo "TABLE_name")
    
    # bq rm -t $PROJECT_ID:$dataset_name.$TABLE_name_join
    bq rm -t $PROJECT_ID:$dataset_name.exercise_2tables_full
    bq rm -t $PROJECT_ID:$dataset_name.table0
    # bq rm -t $PROJECT_ID:$dataset_name.table1
    
fi


# ---------------------------------------------




# ---------------------------------------------
# RESULTS
# ---------------------------------------------



# -------------------------------------
# Step 0 : Figure out which lifestyle group corresponds to each kmeans label
# -------------------------------------

- Did a count query to determine the maximum counts per cluster. And matched the label as
1 = Light_Active, 2 = Active, 3 = Sedentary 4 = Moderate_Active

+-----------------+--------------+--------------+-----------+
|    lifestyle    | lifesyle_NUM | kmeans_label | max_count |
+-----------------+--------------+--------------+-----------+
| Sedentary       |            1 |            3 |    724950 |
| Light_Active    |            3 |            1 |     51435 |
| Moderate_Active |            2 |            3 |     52650 |  # 3 is taken by Sedentary so let this group be Moderate_Active=4
| Active          |            4 |            2 |      8100 |
+-----------------+--------------+--------------+-----------+


-------------------------------------
Step 1 : Look at the mean of the 4 features and confirm that the data makes logical sense with the assignment of these cluster groups.
Figure out which lifestyle group corresponds to each kmeans label.
-------------------------------------
Numerical feature:
mean_steps
I0720 10:25:31.654829 140283291202880 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+----------+--------------------+
| category |        mean        |
+----------+--------------------+
|        2 | 13952.709677419389 |
|        1 | 10495.238805970133 |
|        4 |  7418.750000000008 |
|        3 |  297.1307291666687 |
+----------+--------------------+
Numerical feature:
mean_total_distance
I0720 10:25:34.262447 139741584086336 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+----------+--------------------+
| category |        mean        |
+----------+--------------------+
|        2 | 10.355403200272507 |
|        1 |  7.307238835007453 |
|        4 |   5.04535714217598 |
|        3 | 0.2003802077524562 |
+----------+--------------------+
Numerical feature:
mean_calories
I0720 10:25:36.611809 140595090158912 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+----------+--------------------+
| category |        mean        |
+----------+--------------------+
|        2 |   3014.45161290323 |
|        1 | 2529.6417910447494 |
|        4 |  2291.982142857137 |
|        3 | 1736.6692708333583 |
+----------+--------------------+
Numerical feature:
mean_hr
I0720 10:25:39.068351 140517274256704 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+----------+-------------------+
| category |       mean        |
+----------+-------------------+
|        3 |  82.0109830818046 |
|        4 | 81.79351970599234 |
|        2 | 78.98634597694367 |
|        1 | 76.79526224126202 |
+----------+-------------------+
Numerical feature:
sleep_duration
I0720 10:25:41.417542 139715729474880 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+----------+--------------------+
| category |        mean        |
+----------+--------------------+
|        1 | 431.33762469029716 |
|        2 |  413.3834687830469 |
|        3 |  402.5575733897062 |
|        4 | 364.44050474858057 |
+----------+--------------------+

# These groups are in order from most to least of the following numerical features: mean_steps, mean_total_distance, mean_calories
# 2 = Active, 1 = Light_Active, 4 = Moderate_Active, 3 = Sedentary


-------------------------------------
Step 2 : Now that it is confirmed that the label is 2 = Active, 1 = Light_Active, 4 = Moderate_Active, 3 = Sedentary
-------------------------------------
Numerical feature:
mean_steps
I0721 22:03:39.219891 139992548513088 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
rm: remove table 'northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL'? (y/N) y
I0721 22:03:43.777057 140030150509888 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
Waiting on bqjob_r71d65d5d1c3f6b4d_000001897a0d1024_1 ... (1s) Current status: DONE   
+---------+-----------------+---------+----------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc       |
+---------+-----------------+---------+----------------------+
|       1 | Active          | weekday |    2.613885531044661 |
|       3 | Light_Active    | weekday |     2.00343638442924 |
|       6 | Moderate_Active | weekday |        1.42397185309 |
|       7 | Sedentary       | weekday | 0.054410657041594715 |
|       2 | Active          | weekend |    6.866634957826329 |
|       4 | Light_Active    | weekend |   5.0331078922807535 |
|       5 | Moderate_Active | weekend |   3.5363506749944866 |
|       8 | Sedentary       | weekend |   0.1518482658844506 |
+---------+-----------------+---------+----------------------+
I0721 22:03:48.461475 140003458151744 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+---------+-----------------+---------+----------------------+--------------------+--------------------+----------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc       |      pop_mean      |      pop_std       | z_critical_onesample |
+---------+-----------------+---------+----------------------+--------------------+--------------------+----------------------+
|       1 | Active          | weekday |    2.613885531044661 | 2.7104557770739395 | 2.3638930302675147 | -0.04085220642084214 |
|       3 | Light_Active    | weekday |     2.00343638442924 | 2.7104557770739395 | 2.3638930302675147 | -0.29909111097327784 |
|       6 | Moderate_Active | weekday |        1.42397185309 | 2.7104557770739395 | 2.3638930302675147 |  -0.5442225631666386 |
|       7 | Sedentary       | weekday | 0.054410657041594715 | 2.7104557770739395 | 2.3638930302675147 |  -1.1235893866702453 |
|       2 | Active          | weekend |    6.866634957826329 | 2.7104557770739395 | 2.3638930302675147 |    1.758192577894291 |
|       4 | Light_Active    | weekend |   5.0331078922807535 | 2.7104557770739395 | 2.3638930302675147 |   0.9825538150277326 |
|       5 | Moderate_Active | weekend |   3.5363506749944866 | 2.7104557770739395 | 2.3638930302675147 |  0.34937913321191316 |
|       8 | Sedentary       | weekend |   0.1518482658844506 | 2.7104557770739395 | 2.3638930302675147 |   -1.082370258902933 |
+---------+-----------------+---------+----------------------+--------------------+--------------------+----------------------+
I0721 22:03:50.884605 139660474922304 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
rm: remove table 'northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL'? (y/N) y
Numerical feature:
mean_total_distance
I0721 22:03:59.009962 140408184255808 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
BigQuery error in rm operation: Not found: Table northern-
eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL
I0721 22:04:01.496368 140254600262976 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
Waiting on bqjob_r814f8fe62daa07e_000001897a0d555c_1 ... (1s) Current status: DONE   
+---------+-----------------+---------+---------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc      |
+---------+-----------------+---------+---------------------+
|       1 | Active          | weekday |  2.7826662685102552 |
|       3 | Light_Active    | weekday |  1.9756716956805767 |
|       6 | Moderate_Active | weekday |  1.3766125002012344 |
|       7 | Sedentary       | weekday | 0.05210528289099534 |
|       2 | Active          | weekend |   7.111599260814157 |
|       4 | Light_Active    | weekend |   4.972370006756713 |
|       5 | Moderate_Active | weekend |   3.399115394940613 |
|       8 | Sedentary       | weekend | 0.14481271939000928 |
+---------+-----------------+---------+---------------------+
I0721 22:04:06.031268 140065621488960 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+---------+-----------------+---------+---------------------+--------------------+--------------------+----------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc      |      pop_mean      |      pop_std       | z_critical_onesample |
+---------+-----------------+---------+---------------------+--------------------+--------------------+----------------------+
|       1 | Active          | weekday |  2.7826662685102552 | 2.7268691411480694 | 2.4181465265184987 | 0.023074336790715126 |
|       3 | Light_Active    | weekday |  1.9756716956805767 | 2.7268691411480694 | 2.4181465265184987 | -0.31065009387542014 |
|       6 | Moderate_Active | weekday |  1.3766125002012344 | 2.7268691411480694 | 2.4181465265184987 |  -0.5583849556423915 |
|       7 | Sedentary       | weekday | 0.05210528289099534 | 2.7268691411480694 | 2.4181465265184987 |  -1.1061214979838454 |
|       2 | Active          | weekend |   7.111599260814157 | 2.7268691411480694 | 2.4181465265184987 |   1.8132607232775746 |
|       4 | Light_Active    | weekend |   4.972370006756713 | 2.7268691411480694 | 2.4181465265184987 |   0.9286041358467968 |
|       5 | Moderate_Active | weekend |   3.399115394940613 | 2.7268691411480694 | 2.4181465265184987 |  0.27800062834091505 |
|       8 | Sedentary       | weekend | 0.14481271939000928 | 2.7268691411480694 | 2.4181465265184987 |   -1.067783276754345 |
+---------+-----------------+---------+---------------------+--------------------+--------------------+----------------------+
I0721 22:04:08.457894 140463777662272 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
rm: remove table 'northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL'? (y/N) y
Numerical feature:
mean_calories
I0721 22:04:14.542232 139831750329664 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
BigQuery error in rm operation: Not found: Table northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL
I0721 22:04:16.732836 140404138550592 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
Waiting on bqjob_r1dcce73aa051ff7_000001897a0d90df_1 ... (1s) Current status: DONE   
+---------+-----------------+---------+--------------------+
| row_num | kmeans_CATlabel |  wday   |     prob_perc      |
+---------+-----------------+---------+--------------------+
|       1 | Active          | weekday | 0.6328787708455136 |
|       3 | Light_Active    | weekday |  0.531263976668993 |
|       6 | Moderate_Active | weekday |  0.484298895003764 |
|       7 | Sedentary       | weekday |  0.365053266205282 |
|       2 | Active          | weekend | 1.6004947711016488 |
|       4 | Light_Active    | weekend | 1.3409511667735643 |
|       5 | Moderate_Active | weekend | 1.2067670311937393 |
|       8 | Sedentary       | weekend | 0.9212319439915988 |
+---------+-----------------+---------+--------------------+
I0721 22:04:21.414157 140341590680896 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+---------+-----------------+---------+--------------------+-------------------+---------------------+----------------------+
| row_num | kmeans_CATlabel |  wday   |     prob_perc      |     pop_mean      |       pop_std       | z_critical_onesample |
+---------+-----------------+---------+--------------------+-------------------+---------------------+----------------------+
|       1 | Active          | weekday | 0.6328787708455136 | 0.885367477723013 | 0.45422936303259953 |  -0.5558617020964772 |
|       3 | Light_Active    | weekday |  0.531263976668993 | 0.885367477723013 | 0.45422936303259953 |  -0.7795698162045204 |
|       6 | Moderate_Active | weekday |  0.484298895003764 | 0.885367477723013 | 0.45422936303259953 |  -0.8829648969445086 |
|       7 | Sedentary       | weekday |  0.365053266205282 | 0.885367477723013 | 0.45422936303259953 |   -1.145487839103851 |
|       2 | Active          | weekend | 1.6004947711016488 | 0.885367477723013 | 0.45422936303259953 |   1.5743748678072842 |
|       4 | Light_Active    | weekend | 1.3409511667735643 | 0.885367477723013 | 0.45422936303259953 |   1.0029815906415862 |
|       5 | Moderate_Active | weekend | 1.2067670311937393 | 0.885367477723013 | 0.45422936303259953 |    0.707571063493004 |
|       8 | Sedentary       | weekend | 0.9212319439915988 | 0.885367477723013 | 0.45422936303259953 |  0.07895673240748154 |
+---------+-----------------+---------+--------------------+-------------------+---------------------+----------------------+
I0721 22:04:24.049922 140155489039680 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
rm: remove table 'northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL'? (y/N) y
Numerical feature:
mean_hr
I0721 22:04:43.897716 140438597338432 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
BigQuery error in rm operation: Not found: Table northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL
I0721 22:04:45.864409 140238175495488 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
Waiting on bqjob_r6f29f18d749a93f8_000001897a0e02ab_1 ... (1s) Current status: DONE   
+---------+-----------------+---------+---------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc      |
+---------+-----------------+---------+---------------------+
|       1 | Active          | weekday | 0.38721973884100075 |
|       3 | Light_Active    | weekday | 0.37123156813466845 |
|       6 | Moderate_Active | weekday |  0.4044813597159126 |
|       7 | Sedentary       | weekday |  0.3978236128859887 |
|       2 | Active          | weekend |  0.9560253635729457 |
|       4 | Light_Active    | weekend |   0.945550532842494 |
|       5 | Moderate_Active | weekend |  0.9822262817527799 |
|       8 | Sedentary       | weekend |  1.0083741728619213 |
+---------+-----------------+---------+---------------------+
I0721 22:04:50.380335 140713387922752 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+---------+-----------------+---------+---------------------+--------------------+-------------------+----------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc      |      pop_mean      |      pop_std      | z_critical_onesample |
+---------+-----------------+---------+---------------------+--------------------+-------------------+----------------------+
|       1 | Active          | weekday | 0.38721973884100075 | 0.6816165788259639 | 0.312238179102836 |  -0.9428598412624076 |
|       3 | Light_Active    | weekday | 0.37123156813466845 | 0.6816165788259639 | 0.312238179102836 |  -0.9940648884871629 |
|       6 | Moderate_Active | weekday |  0.4044813597159126 | 0.6816165788259639 | 0.312238179102836 |  -0.8875763364568447 |
|       7 | Sedentary       | weekday |  0.3978236128859887 | 0.6816165788259639 | 0.312238179102836 |  -0.9088989910055415 |
|       2 | Active          | weekend |  0.9560253635729457 | 0.6816165788259639 | 0.312238179102836 |   0.8788444306697192 |
|       4 | Light_Active    | weekend |   0.945550532842494 | 0.6816165788259639 | 0.312238179102836 |   0.8452968652805367 |
|       5 | Moderate_Active | weekend |  0.9822262817527799 | 0.6816165788259639 | 0.312238179102836 |   0.9627576736149548 |
|       8 | Sedentary       | weekend |  1.0083741728619213 | 0.6816165788259639 | 0.312238179102836 |    1.046501087646746 |
+---------+-----------------+---------+---------------------+--------------------+-------------------+----------------------+
I0721 22:04:52.722564 139694839113024 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
rm: remove table 'northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL'? (y/N) y
Numerical feature:
sleep_duration
I0721 22:04:57.749671 140682170778944 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
BigQuery error in rm operation: Not found: Table northern-eon-377721:google_analytics_exercise.TABLE_name_probcount_NUMERICAL
I0721 22:04:59.701134 139973476447552 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
Waiting on bqjob_r81ad47fd7c19006_000001897a0e38b8_1 ... (1s) Current status: DONE   
+---------+-----------------+---------+---------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc      |
+---------+-----------------+---------+---------------------+
|       1 | Active          | weekday | 0.42057956952821957 |
|       3 | Light_Active    | weekday |  0.4482136543684808 |
|       6 | Moderate_Active | weekday | 0.36145575059195006 |
|       7 | Sedentary       | weekday |   0.418709576750043 |
|       2 | Active          | weekend |  1.0552122262005743 |
|       4 | Light_Active    | weekend |   1.074225939437099 |
|       5 | Moderate_Active | weekend |   0.954896952253091 |
|       8 | Sedentary       | weekend |  0.9914466383002619 |
+---------+-----------------+---------+---------------------+
I0721 22:05:04.155054 140568128144704 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
+---------+-----------------+---------+---------------------+-------------------+--------------------+----------------------+
| row_num | kmeans_CATlabel |  wday   |      prob_perc      |     pop_mean      |      pop_std       | z_critical_onesample |
+---------+-----------------+---------+---------------------+-------------------+--------------------+----------------------+
|       1 | Active          | weekday | 0.42057956952821957 | 0.715592538428715 | 0.3271954445255897 |   -0.901641431249886 |
|       3 | Light_Active    | weekday |  0.4482136543684808 | 0.715592538428715 | 0.3271954445255897 |  -0.8171840058712145 |
|       6 | Moderate_Active | weekday | 0.36145575059195006 | 0.715592538428715 | 0.3271954445255897 |  -1.0823402151892372 |
|       7 | Sedentary       | weekday |   0.418709576750043 | 0.715592538428715 | 0.3271954445255897 |  -0.9073566476731707 |
|       2 | Active          | weekend |  1.0552122262005743 | 0.715592538428715 | 0.3271954445255897 |   1.0379719322323817 |
|       4 | Light_Active    | weekend |   1.074225939437099 | 0.715592538428715 | 0.3271954445255897 |   1.0960831118183114 |
|       5 | Moderate_Active | weekend |   0.954896952253091 | 0.715592538428715 | 0.3271954445255897 |   0.7313806406178747 |
|       8 | Sedentary       | weekend |  0.9914466383002619 | 0.715592538428715 | 0.3271954445255897 |    0.843086615314941 |
+---------+-----------------+---------+---------------------+-------------------+--------------------+----------------------+
I0721 22:05:06.501202 139857512662336 bigquery_client.py:730] There is no apilog flag so non-critical logging is disabled.
