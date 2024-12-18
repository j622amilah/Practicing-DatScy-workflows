# -----------------------------------------------
# DATA INGESTION
# -----------------------------------------------
from pyspark.sql.functions import col
from pyspark.sql.types import DoubleType, IntegerType

# -----------------------------------------------

# Read data from CSV, to python
df = spark.read \
      .csv("/mnt/training/healthcare/tracker/moocs/daily-metrics.csv", header = True) \
      .select(
        "device_id",
        "dte",
        col("resting_heartrate").cast(DoubleType()),
        col("active_heartrate").cast(DoubleType()),
        col("bmi").cast(DoubleType()),
        col("vo2").cast(DoubleType()),
        col("workout_minutes").cast(DoubleType()),
        "lifestyle",
        col("steps").cast(IntegerType())
      )

# OR

# df = spark.read.csv("/mnt/training/healthcare/tracker/moocs/users.csv", header = True)


# -----------------------------------------------


# -----------------------------------------------
# ANALYSIS
# -----------------------------------------------
import math
import numpy as np
import pandas as pd

# -----------------------------------------------

# Hypothesis testing
# Q1: Do people workout more or less on weekend, than during the weekday?
# Interpretation of Results

# Null hypothesis : average workout minutes during the weekend and the weekday are the same.

# Result : The means are almost identical at weekday = 35.318524 and weekend = 35.504771, but the vector length is 312000.

# The null hypothesis is ACCEPTED, there are no significant difference in means between average exercise time during the weekend and weekday.

# The pvalue from 'scipy.stats import ttest_ind' and 'from statsmodels.stats.weightstats import ztest', report tpval: [0.000822] and zpval: [0.00082195] which are less than 0.05 indicating significance. However, by looking at the mean and manually calculating/visualizing the pdf we can see that the p-value should be large indicating NO significance between the two means. Therefore, we can say that the null hypothesis is ACCEPTED.

# -----------------------------------------------
  
# Get the data from SQL table into python
x_samp1 = spark.sql("SELECT workout_minutes FROM ht_daily_metrics3 WHERE wday == 'weekday'").toPandas()
x_samp2 = spark.sql("SELECT workout_minutes FROM ht_daily_metrics3 WHERE wday == 'weekend'").toPandas()

# -----------------------------------------------

# Q2: Are weekend exercisers likely to have a ('Sedentary') lifestyle versus weekday exerciers?

# Response : No, weekend exercisers are similarly likely to be Sedentary as weekday exercisers.

# The null hypothesis was accepted between workout minutes for weekend_Sedentary versus weekend exercisers. Similarly, the null hypothesis was accepted between workout minutes for weekday_Sedentary versus weekday exercisers.

# The mean Sedentary population value for both weekday (5.681322) and weekend (5.698815) are almost identical, and the mean population for both weekday (35.383293) and weekend (35.538244). Difference in significance of being Sedentary with respect to population, between weekday (p_value: 0.335) and weekend (p_value: 0.51) are above 0.05, so one is not likely to be more Sedentary if they exercise on the weekend than the weekday.

# Calculating the probablity of each lifestyle for the weekday and the weekend, we see that the probability of Sedentary lifestyle on the weekend (Sedentary weekend 0.01664163579812005) and the weekday (Sedentary weekday 0.016757079078135062) does not change.

# -----------------------------------------------
                                                                            
%sql
-- Calculate the probability
-- Q2: Are weekend exercisers likely to have a ('Sedentary') lifestyle versus weekday exerciers?

WITH tab2 AS
(
  SELECT *, (SELECT SUM(workout_minutes)/AVG(normval) FROM ht_daily_metrics3 WHERE wday ='weekend') AS pop_weekend FROM ht_daily_metrics3
)
SELECT lifestyle, wday, (SUM(workout_minutes)/AVG(normval))/AVG(pop_weekend) AS perc_pergrp FROM tab2
GROUP BY lifestyle, wday
ORDER BY wday, lifestyle; 

# -----------------------------------------------

# OUTPUT

# lifestyle	wday	perc_pergrp
# Athlete	weekday	0.35997169051299327
# Cardio Enthusiast	weekday	0.34714584230427
# Sedentary	weekday	0.016757079078135062
# Weight Trainer	weekday	0.28267482693426754
# Athlete	weekend	0.35675950625315356
# Cardio Enthusiast	weekend	0.34526154773590456
# Sedentary	weekend	0.01664163579812005
# Weight Trainer	weekend	0.2813373102128419

# -----------------------------------------------

# Weekend population VS weekend Sedentary
x_samp1 = spark.sql("SELECT workout_minutes FROM ht_daily_metrics3 WHERE lifestyle = 'Sedentary' and wday = 'weekend'").toPandas()
x_samp2 = spark.sql("SELECT workout_minutes FROM ht_daily_metrics3 WHERE wday = 'weekend'").toPandas()

# -----------------------------------------------

# df_samp1_mean: workout_minutes 5.681322
# dtype: float64
# df_samp1_std: workout_minutes 1.649331
# dtype: float64
# df_samp1_len: 32448
# df_samp2_mean: workout_minutes 35.594279
# dtype: float64
# df_samp2_std: workout_minutes 22.016222
# dtype: float64
# df_samp2_len: 32448
# t_critical: [-244.05924366]
# tpval: [0.]
# z_critical: [-244.05924366]
# zpval: [0.]
# t_Z_critical: -244.0592436561397
# p_value: 0.3353297188229327

# -----------------------------------------------

# Weekday population VS weekday Sedentary
x_samp1 = spark.sql("SELECT workout_minutes FROM ht_daily_metrics3 WHERE lifestyle = 'Sedentary' and wday = 'weekday'").toPandas()
x_samp2 = spark.sql("SELECT workout_minutes FROM ht_daily_metrics3 WHERE wday = 'weekday'").toPandas()

# -----------------------------------------------

# df_samp1_mean: workout_minutes 5.698815
# dtype: float64
# df_samp1_std: workout_minutes 1.666263
# dtype: float64
# df_samp1_len: 81432
# df_samp2_mean: workout_minutes 35.538244
# dtype: float64
# df_samp2_std: workout_minutes 22.039869
# dtype: float64
# df_samp2_len: 81432
# t_critical: [-385.24892785]
# tpval: [0.]
# z_critical: [-385.24892785]
# zpval: [0.]
# t_Z_critical: -385.88560868330416
# p_value: 0.5185563259888604

# -----------------------------------------------

# --------------------------------------------------------------------------
# ***RERUN for all tests*** Databricks can not do functions well: T-test and Z-test 'function'
# --------------------------------------------------------------------------
# -------------------------------------
# Data length options: can truncate the data or NOT. The t-statistic/z_score uses the length of the data, so both test are influenced by the length.
# t OR Z = ((x_samp1 - x_samp2) - (mean_samp1 - mean_samp2)) / sqrt( ((std_samp1^2)/len_samp1) + ((std_samp2^2)/len_samp2) ) .
# -------------------------------------
which_way = 'trunc'

if which_way == 'trunc':
    vec = [len(x_samp1), len(x_samp2)]
    n0 = np.argmin(vec)
    n1 = vec[n0] 

    if n0 == 0:
        df_samp1 = x_samp1
        df_samp2 = x_samp2.iloc[np.random.permutation(np.max(vec))[0:n1]]
    else:
        df_samp1 = x_samp1.iloc[np.random.permutation(np.max(vec))[0:n1]]
        df_samp2 = x_samp2
else:
    df_samp1 = x_samp1
    df_samp2 = x_samp2
# -------------------------------------

# -------------------------------------
# Check for mean, variance, length
for i in ['samp1', 'samp2']:
    globals()[f"df_{i}_mean"] = globals()[f"df_{i}"].mean()
    globals()[f"df_{i}_std"] = globals()[f"df_{i}"].std()
    globals()[f"df_{i}_len"] = len(globals()[f"df_{i}"])
    print('df_%s_mean: ' % (i), globals()[f"df_{i}_mean"])
    print('df_%s_std: '% (i), globals()[f"df_{i}_std"])
    print('df_%s_len: ' % (i), globals()[f"df_{i}_len"])
# -------------------------------------


# -------------------------------------
# Two-sampled T-test: the DISTRIBUTION/pdf_calculation is the normal distribution plus an additional tranformation that depends on the length of both vectors (T_pdf = Z_pdf/sqrt( (X^2)/(len_samp1 + len_samp2 - 2) ) ), SO it is for small sample population data
# This gives us the critical t_statistic ONLY!!
# -------------------------------------
from scipy.stats import ttest_ind
t_critical, tpval = ttest_ind(df_samp1, df_samp2, equal_var=False)
print('t_critical: ', t_critical)
print('tpval: ', tpval)

# -------------------------------------


# -------------------------------------
# Two-sampled Z-test: the DISTRIBUTION/pdf_calculation is the normal distribution only, SO it is better for larger sample population data
# This gives us the critical z_score ONLY!!
# -------------------------------------
from statsmodels.stats.weightstats import ztest
delta = 0  # hypothesized difference between the population means (0 if testing for equal means)
z_critical, zpval = ztest(df_samp1, df_samp2, value=delta) # alternative='two-sided', usevar='pooled', ddof=1.0
print('z_critical: ', z_critical)
print('zpval: ', zpval)
# -------------------------------------


# -------------------------------------
# Visualization of t_statistic/z_score vector VS DISTRIBUTION
# -------------------------------------

# ------------------
# CDF
# ------------------
# Calculate the t-statistic/z-score vector
t_OR_Z = ((df_samp1 - df_samp2) - (df_samp1_mean - df_samp2_mean)) / sqrt( ((df_samp1_std**2)/df_samp1_len) + ((df_samp2_std**2)/df_samp2_len) )
# OR
# from scipy import stats
# t_OR_Z = stats.zscore(df_samp1 - df_samp2)

t_OR_Z.columns = ['t_Z']
import seaborn as sns
sns.ecdfplot(data=t_OR_Z, x="t_Z")  # proportion means summed probability density
# ------------------

# ------------------
# PDF
# ------------------
# Calculate the pdf (the normal distribution OR the probability density function)
pdf0 = ((1/(np.sqrt(2*math.pi)*t_OR_Z.std())))*np.exp(-((t_OR_Z - t_OR_Z.mean())**2)/(2*t_OR_Z.std()**2))
pdf0 = pdf0.to_numpy()
# OR
# from scipy.stats import multivariate_normal as mvn
# pdf0 = mvn.pdf(t_OR_Z, df_samp1_mean, df_samp1_std)

# Manually calculate le valeur de significance (p-value), verifier le scipy test results.
t_Z_vec = t_OR_Z.to_numpy()
t_Z_critical = z_critical[0]  # OR t_critical
print('t_Z_critical: ', t_Z_critical)

p_value = np.sum([pdf0[ind] for ind, i in enumerate(t_Z_vec) if abs(i) > abs(t_Z_critical)])
print('p_value: ', p_value)
# ------------------

# ------------------
# Visualizer
# ------------------
import matplotlib.pyplot as plt
fig, (ax0) = plt.subplots(1)
fig.suptitle('probability density')
ax0.plot(t_Z_vec, pdf0, '*r', label='pdf1')

yy = np.linspace(0, np.max(pdf0), num=20)
plt.plot(t_Z_critical*np.ones((20)), yy, '--b')
plt.plot(-t_Z_critical*np.ones((20)), yy, '--b')
ax0.set_xlabel('T statistic')
ax0.set_ylabel('Probability density')
ax0.set_title('p-value: %f' % (p_value))
plt.legend(loc='best')
plt.tight_layout()
plt.show()

# ------------------

# df_samp1_mean:  workout_minutes    35.636086
# dtype: float64
# df_samp1_std:  workout_minutes    21.967099
# dtype: float64
# df_samp1_len:  312000
# df_samp2_mean:  workout_minutes    35.504771
# dtype: float64
# df_samp2_std:  workout_minutes    21.894664
# dtype: float64
# df_samp2_len:  312000
# t_critical:  [2.36492572]
# tpval:  [0.01803399]
# z_critical:  [2.36492572]
# zpval:  [0.01803369]
# t_Z_critical:  2.364925718435429
# p_value:  63.380927286636116

# -----------------------------------------------

# Regression

# Q1: Does number of hours of exercise predict vo2?

# No. mean workout mins can not accurately predict vo2 alone. The R-squared value of 0.09371113384276208.

%sql
-- For some reason you can not CREATE a TABLE, you can only make a TEMPORARY TABLE
CREATE OR REPLACE TEMPORARY VIEW ht_agg_new AS
SELECT device_id, MEAN(workout_minutes) AS mean_workout_minutes, MEAN(bmi) AS mean_bmi, MEAN(active_heartrate) AS mean_active_heartrate, MEAN(resting_heartrate) AS mean_resting_heartrate, MEAN(vo2) AS mean_vo2, MEAN(steps) AS mean_steps, MEAN(lifestyle_num) AS mean_lifestyle_num, lifestyle
FROM ht_daily_metrics3
GROUP BY device_id, lifestyle;

# -----------------------------------------------

%python
ht_agg_pandas_df = spark.sql("SELECT * FROM ht_agg_new").toPandas()
ht_agg_pandas_df.head()

from sklearn.linear_model import LinearRegression
lr = LinearRegression()
X = ht_agg_pandas_df[['mean_workout_minutes']]
y = ht_agg_pandas_df['mean_vo2']
lr.fit(X, y)

y_predicted = lr.predict(X)

from sklearn.metrics import r2_score
r_squared = r2_score(y, y_predicted)
print('r_squared: ', r_squared)

# -----------------------------------------------

# r_squared:  0.09371113384276208

# -----------------------------------------------

# Q2: What features are most important for predicting vo2 ('natural healthiness')?

# Result : 'mean_resting_heartrate' is the best predictor of vo2, with an r-squared score of 0.8 or higher. Adding 'mean_active_heartrate' increases the r-squared score, and then adding additional features in the following order help to increase the r-squared score: 'mean_steps', 'mean_lifestyle_num', 'mean_workout_minutes', 'mean_bmi'.

# -----------------------------------------------

def sort_dict_by_value(d, reverse = False):
    return dict(sorted(d.items(), key = lambda x: x[1], reverse = reverse))


import itertools
import math
import numpy as np


def SHAP_byhand_feature_importance(X_test, model, feat_nom, X_train, y_train):
    
    num_of_feat = X_test.shape[1]
    print('number of features: ', num_of_feat)

    y_levels = []
    y_levels_labels = []

    # zeroth level
    y = model.predict(X_test)
    y_levels.append(y)
    y_levels_labels.append([999])

    num_of_levels = num_of_feat+1

    # Get predictions for all levels : where each level is a combination of numbered features 
    # (ordering does not matter)
    for r in range(1, num_of_levels):
        vec = np.arange(num_of_feat)
        strinput = [str(i) for i in vec]
        combs = list(itertools.combinations(strinput, r))
        combs_list = [[int(k) for k in combs[j]] for j in range(len(combs))]

        temp_lev = []
        for j in range(len(combs)):
            # now we need to use j tuple as the index for grabing features

            # convert string tuple to a numbered list
            ind = [int(i) for i in combs[j]]
            # Get new feature matrix with combinatorial features
            X_test_temp = X_test[:,ind]

            which_way = 1
            if which_way == 0:
                # Way 0: use same model
                # pad with the same featues, so the model can predict with the same number of features
                feat_manque = num_of_feat - len(ind)
                rr = np.random.choice(len(ind), feat_manque)
                extra = [ind[i] for i in rr]
                X_test_temp2 = np.concatenate((X_test_temp, X_test[:,extra]), axis=1)
                predictions = model.predict(X_test_temp2)

            elif which_way == 1:
                # Way 1: use NEW model - what I did
                txt = str(type(model))
                
                if txt.find('LinearRegression') != -1:
                    model = LinearRegression()
                elif txt.find('XGBClassifier') != -1:
                    model = XGBClassifier()
                else:
                    model = XGBClassifier()
                X_train_temp = X_train[:,ind]
                model.fit(X_train_temp, y_train)
                predictions = model.predict(X_test_temp)


            # Could do the subtraction here
            temp_lev.append(predictions)

        y_levels.append(temp_lev)
        y_levels_labels.append(combs_list)
    
    print('Combinations of features levels : ', y_levels_labels)
    
    # --------------------------------

    # Now, get Margional contributions
    n = num_of_feat

    # This one is always subtracted for each feature
    MC_1st = [np.sum(y_levels[1][i] - y_levels[0]) for i in range(num_of_feat)]
    r = len(y_levels_labels[0])
    w = (r * math.comb(n, r))**(-1)

    SHAP = []
    for f in range(num_of_feat):

        # say, we are on feature 0
        base_feat = y_levels_labels[1][f][0]

        MC_feat_level = []
        # need to cycle over each level using a each feature!
        tot = 0
        for i in range(2, len(y_levels)):  # 2-6 

            cur = y_levels_labels[i]
            r = len(y_levels_labels[i][0])
            w = (r * math.comb(n, r))**(-1)

            MC_feat = []

            for ind, i2 in enumerate(cur):  # i get each nested list [0, 1], so i2 = [0, 1]
                if base_feat in i2:
                    MC_feat.append(w*np.sum(y_levels[i][ind] - y_levels[1][base_feat] ))  
                    tot = tot + 1
                    
            MC_feat_level.append(np.sum(MC_feat))  # sum of MC per level
        
        # sum SHAP value per feature
        # SHAP.append(w*MC_1st[f] + np.sum(MC_feat_level))
        
        # OR
        
        # mean SHAP value per feature: sum all level-sums together and take the mean
        SHAP.append((w*MC_1st[f] + np.sum(MC_feat_level))/(tot+1))

    # A small SHAP feature value means that it contribues to the overall prediction
    vals = dict(zip(feat_nom, SHAP))

    # -------------------------

    # Sort the columns from smallest to largest normalized SHAP value
    marquers_important = sort_dict_by_value(vals, reverse = True)

    # -------------------------
    
    return marquers_important

# -----------------------------------------------

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score

# -----------------------------------------------

X = ht_agg_pandas_df[['mean_workout_minutes','mean_bmi', 'mean_active_heartrate', 'mean_resting_heartrate', 'mean_steps', 'mean_lifestyle_num']]
y = ht_agg_pandas_df['mean_vo2']

X_train, X_test, y_train, y_test = train_test_split(X, y)

lr = LinearRegression()
lr.fit(X_train, y_train)

# Show list of important features from most to least important
feat_nom = ['mean_workout_minutes','mean_bmi', 'mean_active_heartrate', 'mean_resting_heartrate', 'mean_steps', 'mean_lifestyle_num']
marquers_important = SHAP_byhand_feature_importance(X_test.to_numpy(), lr, feat_nom, X_train.to_numpy(), y_train.to_numpy())
print('marquers_important:', marquers_important)

# -----------------------------------------------

# number of features:  6
# Combinations of features levels :  [[999], [[0], [1], [2], [3], [4], [5]], [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [1, 2], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]], [[0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 1, 5], [0, 2, 3], [0, 2, 4], [0, 2, 5], [0, 3, 4], [0, 3, 5], [0, 4, 5], [1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 3, 4], [1, 3, 5], [1, 4, 5], [2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5]], [[0, 1, 2, 3], [0, 1, 2, 4], [0, 1, 2, 5], [0, 1, 3, 4], [0, 1, 3, 5], [0, 1, 4, 5], [0, 2, 3, 4], [0, 2, 3, 5], [0, 2, 4, 5], [0, 3, 4, 5], [1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]], [[0, 1, 2, 3, 4], [0, 1, 2, 3, 5], [0, 1, 2, 4, 5], [0, 1, 3, 4, 5], [0, 2, 3, 4, 5], [1, 2, 3, 4, 5]], [[0, 1, 2, 3, 4, 5]]]
# marquers_important: {'mean_bmi': 3.8746375994456175, 'mean_workout_minutes': 3.4445623902150158, 'mean_active_heartrate': 1.0018015409254168, 'mean_resting_heartrate': -0.13938646596617582, 'mean_steps': -2.9681724286192397, 'mean_lifestyle_num': -3.13223880261985}

# -----------------------------------------------

# Re-select X matrix based on most important features
# X = ht_agg_pandas_df[['mean_resting_heartrate']] # r_squared_train:  0.886196965055299, r_squared_test:  0.8846533428399925
X = ht_agg_pandas_df[['mean_resting_heartrate', 'mean_active_heartrate']] # r_squared_train:  0.8914403642847999, r_squared_test:  0.878503199873938
# X = ht_agg_pandas_df[['mean_resting_heartrate', 'mean_active_heartrate', 'mean_steps', 'mean_lifestyle_num', 'mean_workout_minutes', 'mean_bmi']] # r_squared_train:  0.9025044165940057, r_squared_test:  0.9025830183264735

y = ht_agg_pandas_df['mean_vo2']
X_train, X_test, y_train, y_test = train_test_split(X, y)

print('X_train.shape', X_train.shape)
print('X_test.shape', X_test.shape)
print('y_train.shape', y_train.shape)
print('y_test.shape', y_test.shape)

# Re-train model
lr = LinearRegression()
lr.fit(X_train, y_train)

y_train_predicted = lr.predict(X_train)
y_test_predicted = lr.predict(X_test)

r_squared_train = r2_score(y_train, y_train_predicted)
print('r_squared_train: ', r_squared_train)

r_squared_test = r2_score(y_test, y_test_predicted)
print('r_squared_test: ', r_squared_test)

# -----------------------------------------------

# X_train.shape (2250, 2)
# X_test.shape (750, 2)
# y_train.shape (2250,)
# y_test.shape (750,)
# r_squared_train:  0.8914403642847999
# r_squared_test:  0.878503199873938

# -----------------------------------------------

# Clustering

from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

# -----------------------------------------------

# Q1: Are there more or less types of lifestyle groups? (maybe people did not report correctly)

# Result: Looking at the Variance between centroids and data, and the Bayesian information criterion (BIC) the best number of clusters are either 3 or 7. So there could probably be Sedentary, Moderate, Active.

# -----------------------------------------------

temp = ht_agg_pandas_df[['mean_workout_minutes','mean_bmi', 'mean_active_heartrate', 'mean_resting_heartrate', 'mean_steps', 'mean_vo2']]
n_best = optimal_clustering(temp)
print('The optimal number of clusters is :', n_best)

# -----------------------------------------------

# The optimal number of clusters is : 1

# -----------------------------------------------

# Q2: Can we detect what types of exercise people perform (Type_of_exercise_group), using steps and workout_minutes ?

# The elbow method with kmeans clustering tells us that there are 6 different Type_of_exercise_groups.

# Lets takes the mean steps and workout_minutes for each group, and then label them. Do they correlate with lifestyle group?

# Result: It looks like lifestyle groups are really similar

# -----------------------------------------------

temp = ht_agg_pandas_df[['mean_workout_minutes', 'mean_steps']]
n_best = optimal_clustering(temp)
print('The optimal number of clusters is :', n_best)

# 0. Scale the data from min to max
scalar = StandardScaler()
X_temp_scaled = scalar.fit_transform(temp.to_numpy())
kmeans, type_of_exercise_group, centroids = unsupervised_lab_kmeans_clustering(n_best, X_temp_scaled)

# -----------------------------------------------

# The optimal number of clusters is : 4

# -----------------------------------------------

# Lets takes the mean steps and workout_minutes for each group, and then label them.
teg = pd.Series(type_of_exercise_group)
df1 = pd.concat([temp, teg, ht_agg_pandas_df['lifestyle']], axis=1)
df1.columns = ['mean_workout_minutes', 'mean_steps', 'type_of_exercise', 'lifesyle']
df1.groupby(['type_of_exercise'])['mean_workout_minutes', 'mean_steps'].mean().sort_index()

# -----------------------------------------------

# We see similar groups Sedentary and Weight_lifting groups as lifestyle, but Cardio and Athelete appear to be different.
# We call the type_of_exercise = ['Running', 'Weights_Gym', 'Sedentary', 'Walking']
names = ['Running', 'Weights_Gym', 'Sedentary', 'Walking']
ii = [names[i] for i in type_of_exercise_group]
df1 = pd.concat([df1, pd.Series(ii)], axis=1)
df1.columns = ['mean_workout_minutes', 'mean_steps', 'type_of_exercise_num', 'lifesyle', 'type_of_exercise']
df1.groupby(['type_of_exercise'])['mean_workout_minutes', 'mean_steps'].mean().sort_index()

# -----------------------------------------------

# mean_workout_minutes 	mean_steps
# type_of_exercise 		
# Running 	34.916545 	12314.254409
# Sedentary 	5.693830 	5168.871303
# Walking 	50.379153 	12002.829128
# Weights_Gym 	39.056905 	7172.957987

# -----------------------------------------------

df1.groupby(['lifesyle'])['mean_workout_minutes', 'mean_steps'].mean().sort_index()

# -----------------------------------------------

# mean_workout_minutes 	mean_steps
# lifesyle 		
# Athlete 	44.400004 	11001.597413
# Cardio Enthusiast 	34.602923 	13235.376990
# Sedentary 	5.693830 	5168.871303
# Weight Trainer 	39.197167 	7177.089559

# -----------------------------------------------

# Do they correlate with lifestyle group?
le = LabelEncoder()
lifestyle = ht_agg_pandas_df['lifestyle']
le.fit(lifestyle)
y = le.transform(lifestyle)

df_lab = pd.DataFrame([y, type_of_exercise_group]).T
df_lab.columns = ['lifestyle', 'exercise_type']
corr_l_et = df_lab.corr(method='pearson')
print('Correlation between lifestyle and exercise_type :', corr_l_et)

# Interestingly, the type_of_exercise_group is not correlated with lifestyle

# -----------------------------------------------

# Correlation between lifestyle and exercise_type :                lifestyle  exercise_type
# lifestyle       1.000000      -0.037857
# exercise_type  -0.037857       1.000000

# --------------------------------------------------------------------------
# RERUN for all tests- Databricks can not do functions : Clustering Analysis
# --------------------------------------------------------------------------

def unsupervised_lab_kmeans_clustering(*arg):
    
    n_clusters = arg[0]
    X = arg[1]
    
    kmeans = KMeans(n_clusters=n_clusters, init='k-means++',algorithm='elkan', random_state=2)
    # n_clusters : The number of clusters to form as well as the number of centroids to generate. (int, default=8)
    
    # init : Method for initialization : (default=’k-means++’)
    # init='k-means++' : selects initial cluster centers for k-mean clustering in a smart way to speed up convergence. 
    # init='random': choose n_clusters observations (rows) at random from data for the initial centroids.
    
    # n_init : Number of time the k-means algorithm will be run with different centroid seeds (int, default=10)
    
    # max_iter : Maximum number of iterations of the k-means algorithm for a single run. (int, default=300)
    
    # tol : Relative tolerance with regards to Frobenius norm of the difference in the cluster centers 
    # of two consecutive iterations to declare convergence. (float, default=1e-4)
    
    # (extremly important!) random_state : Determines random number generation for centroid initialization
    #(int, RandomState instance or None, default=None)
    
    # algorithm{“auto”, “full”, “elkan”}, default=”auto”
    # K-means algorithm to use. The classical EM-style algorithm is “full”. The “elkan” variation is more 
    # efficient on data with well-defined clusters, by using the triangle inequality. However it’s more 
    # memory intensive due to the allocation of an extra array of shape (n_samples, n_clusters).
    
    # ------------------------------
    
    # print('shape of X : ', X.shape)
    kmeans.fit(X)

    # ------------------------------

    # Get the prediction of each category : predicted label
    label = kmeans.labels_
    # print('clusters_out : ' + str(clusters_out))
    # OR
    label = kmeans.predict(X)
    # print('clusters_out : ' + str(clusters_out))
    # print('length of clusters_out', len(clusters_out))
    
    # ------------------------------
    
    # Centroid values for feature space : this is the center cluster value per feature in X
    centroids = kmeans.cluster_centers_
    # print('centroids org : ' + str(centroids))

    # ------------------------------
    
    return kmeans, label, centroids

# -----------------------------------------------

def optimal_clustering(temp):
    # -------------------------------------------------
    # Determine what is the optimal number of clusters
    # -------------------------------------------------
    
    # ------------------------------

    # 0. Scale les donnes entre un -min et max valeur
    scalar = StandardScaler()
    X_temp_scaled = scalar.fit_transform(temp.to_numpy())

    # ------------------------------

    bic_tot = []
    # sil_val = []
    # hom_val = []
    for n_clusters in range(2, 15):
        model, y, centroids = unsupervised_lab_kmeans_clustering(n_clusters, X_temp_scaled)

        # ----------------------------

        # sil_val.append(metrics.silhouette_score(X_temp_scaled, y))
        # hom_val.append(metrics.homogeneity_score(X_temp_scaled, y))

        # Compute Bayesian information criterion (BIC) : existing function - mais, c'est prend beaucoup du temps
        # model = GaussianMixture(n_components=n_clusters)
        # y_gm = model.fit_predict(X_temp_scaled)
        # bic_tot.append(model.bic(X_temp_scaled))
        # aic = model.aic(X_temp_scaled) # Akaike information criterion (AIC) 

        # ----------------------------

        # Compute BIC : by hand

        # number of elements in each cluster
        vals, cnt = np.unique(y, return_counts=True)

        r, c = X_temp_scaled.shape

        # compute variance of clusters
        cl_var = [(1/(cnt[i]-n_clusters))*np.linalg.norm(X_temp_scaled[np.where(y == i)]-centroids[i][:], ord=2) for i in range(n_clusters)]
        # print('cl_var : ', cl_var)

        const_term = 0.5 * n_clusters * np.log(r) * (c+1)

        n = np.bincount(y)
        BIC = np.sum([n[i] * np.log(n[i]) -
                   n[i] * np.log(r) -
                 ((n[i] * c) / 2) * np.log(2*np.pi*cl_var[i]) -
                 ((n[i] - 1) * c/ 2) for i in range(n_clusters)]) - const_term
        bic_tot.append(BIC)

    # ----------------------------

    fig, (ax0, ax1) = plt.subplots(2)
    # plotting variance
    out = [np.log(2*np.pi*cl_var[i]) for i in range(len(cl_var))]
    ax0.plot(np.arange(2, 2+len(out)), out)
    ax0.set_ylabel('Variance')

    # plot clusters by BIC
    ax1.plot(np.arange(2,2+len(bic_tot)), bic_tot)
    ax1.set_ylabel('BIC score')
    ax1.set_xlabel('n_clusters')

    # ----------------------------
    
    minval = np.min(bic_tot)

    bic_tot_bs = [i -minval for i in bic_tot] # baseline shift to remove negative values
    # print('bic_tot_bs: ', bic_tot_bs)

    diff = [abs(bic_tot_bs[i-1]-bic_tot_bs[i]) for i in range(1, len(bic_tot_bs))]
    # print('diff: ', diff)

    # Determine when the difference in BIC score increases
    buffer = 0
    for i in range(1, len(diff)):
        if diff[i-1] < (diff[i]-buffer):
            break
    n_best = i-1

    return n_best

# -----------------------------------------------

# Classification

# Q1: Can the number of hours of exercise and steps predict the lifestyle?

# Result: Interesting, yes! With the two combined they perfectly predict lifestyle! Mean_steps has a prediction accuracy of 0.35 and mean_workout_minutes has a prediction accuracy of 0.66.

# -----------------------------------------------

from sklearn.preprocessing import LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, confusion_matrix

# -----------------------------------------------

X = ht_agg_pandas_df[['mean_workout_minutes', 'mean_steps']]

# y = [int(i) for i in ht_agg_pandas_df['mean_lifestyle_num'].to_numpy()] 
# OR
le = LabelEncoder()
lifestyle = ht_agg_pandas_df['lifestyle']
le.fit(lifestyle)
y = le.transform(lifestyle)

lr = LogisticRegression(max_iter=10000)
lr.fit(X, y)

y_predicted = lr.predict(X)

print("accuracy: ", accuracy_score(y, y_predicted))
print("confusion matrix")
print(confusion_matrix(y, y_predicted))

# -----------------------------------------------

# accuracy:  1.0
# confusion matrix
# [[ 859    0    0    0]
#  [   0 1064    0    0]
#  [   0    0  312    0]
#  [   0    0    0  765]]

# -----------------------------------------------

# Q2: Can we predict the type_of_exercise_group using heart rate? We know that the type_of_exercise_group was found by clustering using steps and workout_minutes, but is heart_rate a distinguishing feature to detect these type_of_exercise_group?

# Result: Using logistic regression we can predict type_of_exercise_group, with resting and active heart rate, at and accuracy of 0.62.

X = ht_agg_pandas_df[['mean_resting_heartrate', 'mean_active_heartrate']]
y = type_of_exercise_group

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y)

lr = LogisticRegression(max_iter=10000)
lr.fit(X_train, y_train)

y_train_predicted = lr.predict(X_train)
y_test_predicted = lr.predict(X_test)

print("training accuracy: ", accuracy_score(y_train, y_train_predicted))
print("test accuracy:     ", accuracy_score(y_test, y_test_predicted))
print("training confusion matrix")
print(confusion_matrix(y_train, y_train_predicted))
print("")
print("test confusion matrix")
print(confusion_matrix(y_test, y_test_predicted))

# -----------------------------------------------

# training accuracy:  0.6124444444444445
# test accuracy:      0.6293333333333333
# training confusion matrix
# [[926  99   0  20]
#  [153 361  63   5]
#  [  2 164  69   1]
#  [355  10   0  22]]

# test confusion matrix
# [[322  38   0   8]
#  [ 36 121  22   1]
#  [  0  57  18   1]
#  [112   3   0  11]]

# -----------------------------------------------

from sklearn.tree import DecisionTreeClassifier
dt = DecisionTreeClassifier()
dt.fit(X_train, y_train)

y_train_predicted = dt.predict(X_train)
y_test_predicted = dt.predict(X_test)

print("training accuracy: ", accuracy_score(y_train, y_train_predicted))
print("test accuracy:     ", accuracy_score(y_test, y_test_predicted))
print("training confusion matrix")
print(confusion_matrix(y_train, y_train_predicted))
print("")
print("test confusion matrix")
print(confusion_matrix(y_test, y_test_predicted))

# training accuracy:  1.0
# test accuracy:      0.536
# training confusion matrix
# [[1045    0    0    0]
#  [   0  582    0    0]
#  [   0    0  236    0]
#  [   0    0    0  387]]

# test confusion matrix
# [[237  45   2  84]
#  [ 33 101  39   7]
#  [  4  47  25   0]
#  [ 75  10   2  39]]

# -----------------------------------------------
