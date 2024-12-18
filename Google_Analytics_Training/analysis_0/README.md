# Project Summary/Executive Summary
The objective of this work was to understand how annual members and casual riders use Cyclistic bikes differently, and then predict membership using key features from the Cyclistic data at an accuracy of 95% or better.

The Baseline Solution is to use at least the features trip time and rideable type to predict whether new customers are will be members or casual users; using a kmeans model, the member centroid location was estimated using the cosine similarity distance measure. Thus the distance from the estimated centroid to each feature (trip time, rideable type, and birthyear) was calculated and the feature with the largest deviation (ie: outlier) was suggested as a marketing recommendation. The methodology used to implement the baseline solution, train and test lifestyle prediction models,
is classification analysis using kmeans. The evaluation metric includes prediction accuracy for the test dataset, and feature distance difference from the member centroid location.

In summary, the project/business objective was SATISFIED because the baseline solution produced an analysis result showing that membership likelihood can be predicted at 98% accuracy for the test data. In addition, the predominate recommendations based on outliers for predicted casual users were in alignment with statistically significant variables for member vs casual, such as trip time and birthyear.
The project can be improved by collecting more data from casual users and women; the dataset was statistically significantly (one sample z-test: p < 0.05) biased to male members. Higher prediction accuracy between members and casual users or better detection of outliers, maybe possible if demographic samples were equally represented.

# Business Objective/Ask
The business objective provides a list of problems that need to be solved, with measurable objectives of successful for each solved problem. The first problem should correspond with the last problem (Act), because it shows that the main global problem was indeed solved by the specific problems.

The problems that need to be solved for the bikeshare case study, from general to specific, are :
1. Cyclistic bikes needs to gain more money to stay in business, by converting casual users into members. Measurable success for this task is creating a marketing campaign that increases more new members in comparison to casual users.
2. In order to convert casual users into members, one needs to understand which key factors/features identify a person as a member in comparison to a casual user. Measurable success for this task is to statistically prove which factors/features are statistically different for casual users in comparison to members.
3. A model needs to be built using the key factors/features, such that one can predict whether a new customer will be a member or a casual user. Measurable success for this task is to measure prediction accuracy of 95% or better in identifying members in comparison to casual users, using a test dataset.
4. If a new customer is predicted to be a casual user, the model needs to show which factor/feature of the new customer’s profile needs to be modified such that they would become a member. Measurable success is to rank the factors/features from strongest to weakest predictors for a member, using either the statistical analysis significance of factors or feature importance/SHAP. The model should recommend improvements of the strongest member predictors more than the weakest member predictors, measurable success that recommendations are correct is to perform a group by count of how many times the model recommended a feature for predicted casual users.
5. Act: Marketing needs to create marketing campaigns for each of the key factors/features, such that casual users deficient in these key factors/features would be given marketing that would change their ideas/behavior about the member-deficient key factors/features such that they would start to think/behave similarly to members. Measurable success for this task is observing an increase in more new members in comparison to casual users, as was stated in the first problem/objective; thus solving the global problem by executing the specific problems.

# Project Background
Cyclistic is a bike-share program that features more than 5,800 bicycles and 600 docking stations. Cyclistic sets itself apart by also offering reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike. The majority of riders opt for traditional bikes; about 8 percent of riders use the assistive options. Cyclistic users are more likely to ride for leisure, but about 30 percent use them to commute to work each day.

Future success of Cyclistic depends on maximizing the number of annual memberships, thus it is necessary to design a new marketing strategy to convert casual riders into annual members. Casual riders are customers who purchase single-ride or full-day passes, and Cyclistic members are customers who purchase annual memberships.

There are three teams that operate Cyclistic :
- Manager: responsible for promoting the program (social, media, email, etc)
- Marketing analytics team : responsible for doing the data analysis
- Executive team: responsible for approving the proposal

# Baseline Solution
The Baseline Solution (top three recommendations) is to :
1. use trip time, rideable type, and birthyear to predict member casual.
2. recommend bike routes: if the model predicts that a new customer is a casual user and the feature furthest away from the member cluster is trip time, marketing should encourage usage of the bikes like a member such as recommending short trip time routes that are beautiful/interesting.
3. recommend bike usage type: if the model predicts that a new customer is a casual user and the feature furthest away from the member cluster is rideable type, marketing should encourage usage of member bike preferences such as classic or electric bikes
4. recommend age-targeted activities/appearances: if the model predicts that a new customer is a casual user and the feature furthest away from the member cluster is birthyear, marketing should encourage age related activities connected with membership. Members are typically six years older than casual user, if age is used a marketing tool there could be two types of age populations that are members.

# Project Deliverables

## Prepare
The bikeshare data from the AWS bucket was assumed to have data integrity, credibility, with minimal errors because it was given directly from a trustworthy source (the company). Null values were filled using the population mean for the particular value. Data filtering could be performed, such as removing data from unrealistic ranges to improve data integrity and credibility.

## Methodology/Process
An automatic GCP ingestion program was written in bash that:
1. Downloaded the data from the public bucket using the AWS SDK,
2. organized/unzipped the zip files into three folders (csvdata, remaining files, zipdata),
3. Evaluated the header of each csv file using the first header file as a main reference of comparison for all the other files; similar words with respect to the main reference header were replaced in each csv file. Three folders were created such that identical csv files could be grouped together: exact match header, no match header, similar match header. The evaluation algorithm was re-run on the files in the similar match header folder to find all unique table types, in a recursive decision tree like fashion.
4. Files in each of the exact match header folders were uploaded to GCP and a UNION operation was performed to append all the csv files; for this analysis two table types were found. The two types of datasets were: A) 39 datasets targeting latitude & longitude, member type, and bike preference (rideable type), B) 25 datasets targeting trip duration, member type (usertype), gender, and birthyear. The two large datasets were joined using a FULL JOIN on the ride id and trip id primary key. The SQL table was reduced to 12 columns: fin trip ID, rideable type, trip time, fin stsname, fin stsID, fin esname, fin esID, trip distance, member casual, bikeid INT, gender, birthyear.
5. An automatic bigquery statistical analysis program was written such that main features/columns were compared with the member casual column; two categorical columns [rideable type, gender] and three numerical columns [trip distance, trip time, birthyear]. The categorical columns were evaluated by calculation the probability of occurrence, and the numerical columns were evaluated using the one and two sample z-statistic with respect to the popula-
tion and individual sample means respectively.
6. A bigquery kmeans ML model was used to predict the binary label member casual using the three features.
7. Outlier detection via the kmeans model, using the difference from average member centroid feature values to sample feature values, was used to give marketing recommendations to make casual users into members.

## Analyze
The numerical z-statistic results show that member statistically have shorter trip time than casual users, also members are statistically older than casual users by 6 years. In terms of occurrence, men are more likely to be members than women because more men use bikes. Classic and electric bikes tend to be used more by members than casual members. Based on these statistics, casual riders might buy annual membership if they grow older, have an age similar to the average age of membership. Similarly, casual riders might buy membership if they start to desire to do short trip time sessions, or have a preference for classic or electric bikes . Digital media about a short organized trip routes, usage of classic or electric bikes, and marketing for young adults might help casual users to become members; members like short trip time sessions and classic or electric bikes. Also, young adults are less likely to be members so special marketing to non-likely member candidates may encourage them to join thus gaining more money for Cyclistic; older adults are already motivated to be members so they need little to no marketing. The categorical probability of occurrence of each feature for member casual shows that the dataset was statistically bias for male member data (p < 0.05); roughly 30 percent of the data consisted of samples from male members. The key factors/features that were selected for the kmeans, a clustering algorithm that is used to detect outliers, were the most statistically significant features found that distinguished members from causal riders; trip time, birthyear, and rideable type were found to be the most statistically relavant features in order of significance. The prediction accuracy of kmeans model for the test dataset was 98.25049%; refer to ACCURACY_RESULT in main.sh.

Feature recommendations were calculated by finding the feature furthest away from the member cluster. The equation in the Appendix was implemented to estimate the location of the member cluster, such that the feature furthest away from the member cluster could be found and given as a marketing recommendation to convert casual users into members. The results shows that the marketing recommendations that were given to casual users; trip time and birthyear were the most recommended forms of marketing which were in alignment with numerical feature statistical results. This analysis shows that kmeans is an effective way to recommend marketing using outlier detection of features. Please refer to RECOMMENDATION_RESULT in main.sh.


## Evaluation metrics
Evaluation metrics were : 0) probability of occurrence for categorical features, 1) one and two sample z-statistic for numerical features, 2) one sample z-statistic for categorical features, 3) prediction accuracy for kmeans using the test dataset. The train test split percentage was 0.75 and 0.25 respectively.

# Recommendations for improving the project in the future
The project can be improved by collecting more data from casual users and women; the dataset was statistically significantly (one sample z-test: p < 0.05) biased to male members. Higher prediction accuracy between members and casual users or better detection of outliers, maybe possible if demographic samples were equally represented.

# Appendix

## Calculation of the ”should of, would of, could of” cluster centroid
The "should of, would of, could of" cluster centroid (SWC centroid) is an equivalent point in feature space that represents the actual cluster centroid, using the assumption that all the features have the same value.
The goal is to solve for the A variables of the cosine similarity equation. The A variables are the feature values of the desired member cluster.

\[ cos \theta = \frac{A \cdot B }{\|A\| \|B\|} = \frac{\sum^{n-1}_{i=0} A_i B_i}{\sqrt{\sum^{n-1}_{i=0} (A_i)^{2}} \sqrt{\sum^{n-1}_{i=0} (B_i)^{2}} } \]

Move the B variables to the left side of the equation, because the B variables are the features and the values are known.

\[ \left(  \frac{ \sqrt{\sum^{n-1}_{i=0} (B_i)^{2}} }{ \sum^{n-1}_{i=0} B_i } cos \theta  \right) = \frac{\sum^{n-1}_{i=0} A_i}{\sqrt{\sum^{n-1}_{i=0} (A_i)^{2}} } \]

Square both sides to remove the square root on the denominator on the right side.

\[ \left(  \frac{ \sqrt{\sum^{n-1}_{i=0} (B_i)^{2}} }{ \sum^{n-1}_{i=0} B_i } cos \theta  \right)^{2} = \left(  \frac{\sum^{n-1}_{i=0} A_i}{\sqrt{\sum^{n-1}_{i=0} (A_i)^{2}} } \right)^{2} \]

\[ \frac{ \sum^{n-1}_{i=0} (B_i)^{2}} { (\sum^{n-1}_{i=0} B_i)^{2} } cos^{2} \theta  =   \frac{(\sum^{n-1}_{i=0} A_i)^{2} }{\sqrt{\sum^{n-1}_{i=0} (A_i)^{2}} } \]

Let the left portion equal to EQN to simplify the equation. Write the summation out into series expansion to see how to reduce the right side equation.

\[ EQN  =   \frac{(A_0 + A_1 + A_2 + \ldots)^{2} }{(A_{0}^{2} + A_{1}^{2} + A_{2}^{2} + \ldots)} \]

\[ EQN  =   \frac{(A_0 + A_1 + A_2 + \ldots)(A_0 + A_1 + A_2 + \ldots) }{(A_{0}^{2} + A_{1}^{2} + A_{2}^{2} + \ldots)} \]

\[ EQN  =   \frac{A_{0}^{2} + A_{1}^{2} + A_{2}^{2} + 2A_{0}A_{1} + 2A_{0}A_{2} + 2A_{1}A_{2} + \ldots }{A_{0}^{2} + A_{1}^{2} + A_{2}^{2} + \ldots} \]

\[ EQN  =  2A_{0}A_{1} + 2A_{0}A_{2} + 2A_{1}A_{2} + \ldots\]

Let the A variables equal each other, so that the estimated centroid distance for one feature does not bias the other features. 

Let q = A_0 = A_1 = A_2 = \ldots 

\[ EQN  =  2q^{2} + 2q^{2} + 2q^{2} + \ldots = n \cdot 2q^{2}\]

Solve for q

\[ q  =  \sqrt{ \frac{ EQN }{ n \cdot 2 }} = \sqrt{ \frac{ \frac{ \sum^{n-1}_{i=0} (B_i)^{2}} { (\sum^{n-1}_{i=0} B_i)^{2} } cos^{2} \theta }{ n \cdot 2 }}\]

In GCP, q will be calculated per row/sample so the SWC_centroid for the member centroid is the average of all the rows when member_casual is equal to member.
