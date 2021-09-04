# Function used in midbootcamp project

#Credit Card Revival



import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix
from sklearn.preprocessing import StandardScaler
from scipy.stats import chi2_contingency
from imblearn.over_sampling import SMOTE
from sklearn.neighbors import KNeighborsClassifier
from sklearn import metrics
import pickle
import scikitplot as skplt
from imblearn.under_sampling import TomekLinks
import functions as func






def thing():
    x = 2+3
    return x

#1. Function to get unique values of columns

def unique_val(df):
    for col_names in list(df):
        print("\n" + col_names)
        print(df[col_names].unique(), '\n')

#2. Check for null values with percentage


def check_null(df):
    nulls = pd.DataFrame(df.isna().sum()*100/len(df), columns=['percentage'])
    nulls.sort_values('percentage', ascending = False)
    return nulls




#3. Function to count values for each columns

def value_count(df):
    for column in df.select_dtypes(np.object):
        print("\n" + column)
        print(df[column].value_counts())

#3 Function to show distribution plots and boxplots (for outliers) of numerical columns

def dist_boxplot_num(data):
    for col in data.select_dtypes(np.number):
        fig, axes = plt.subplots(1, 2, figsize=(15, 5))
        sns.distplot(data[col], ax=axes[0])
        sns.boxplot(data[col], ax=axes[1])
        plt.show()


#4. BoxCox transformation 

def boxcox_transform(data, skip_columns=[]):
    numeric_cols = data.select_dtypes(np.number).columns
    _ci = {column: None for column in numeric_cols}
    for column in numeric_cols:
        if column not in skip_columns:
# since i know any columns should take negative numbers, to avoid -inf in df
            data[column] = np.where(data[column]<=0, np.NAN, data[column]) 
            data[column] = data[column].fillna(data[column].mean())
            transformed_data, ci = stats.boxcox(data[column])
            data[column] = transformed_data
            _ci[column] = [ci] 
        return data, _ci




#6 Function to show distribution of data categorical columns

def dist_cat(df):
    for col in df.select_dtypes(np.object):
        fig, axes = plt.subplots(1, figsize=(7, 4))
        sns.countplot(x=df[col], data=df)
        plt.show()

#7. Function to run the ChiSquare test to all variables

def col_cat_val(data, columns=[]):
    for i in columns:
        for j in columns:
            if i != j:
                data_crosstab = pd.crosstab(data[i], data[j], margins = False)
                print (i, j)
                print (chi2_contingency(data_crosstab, correction=False), '\n')


#7 Function to apply Logistic regression plus metrics (confusion matrix, ROC and report)

def LogRegression(X_train, y_train, X_test, y_test):

    classification = LogisticRegression(random_state=42, max_iter=1000)
    classification.fit(X_train, y_train)
    score = classification.score(X_test, y_test)
    print (score)
    
    predictions = classification.predict(X_test)
    
    #confusion matrix 
    
    confusion_matrix(y_test, predictions)
    cf_matrix = confusion_matrix(y_test, predictions)
    group_names = ['True No', 'False No', 'False Yes', 'True Yes']
    group_counts = ["{0:0.0f}".format(value) for value in cf_matrix.flatten()]
    group_percentages = ["{0:.2%}".format(value) for value in cf_matrix.flatten()/np.sum(cf_matrix)]
    labels = [f"{v1}\n{v2}\n{v3}" for v1, v2, v3 in zip(group_names,group_counts,group_percentages)]
    labels = np.asarray(labels).reshape(2,2)
    sns.heatmap(cf_matrix, annot=labels, fmt='', cmap='Blues')
    
    ## ROC from 

    predicted_probas = classification.predict_proba(X_test)

    skplt.metrics.plot_roc(y_test, predicted_probas)
    plt.show()

    ## report
    print(metrics.classification_report(y_test, predictions))



   #8. Function to apply KNN Classifier lus metrics (confusion matrix, ROC and report)

def KNNClass(X_train, y_train, X_test, y_test,n):
    model = KNeighborsClassifier(n_neighbors=n)
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
    print (score)
    
    predictions = model.predict(X_test)
    
    cf_matrix = confusion_matrix(y_test, predictions)
    group_names = ['True No', 'False No',
                   'False Yes', 'True Yes',]

    group_counts = ["{0:0.0f}".format(value) for value in cf_matrix.flatten()]
    group_percentages = ["{0:.2%}".format(value) for value in cf_matrix.flatten()/np.sum(cf_matrix)]
    labels = [f"{v1}\n{v2}\n{v3}" for v1, v2, v3 in zip(group_names,group_counts,group_percentages)]
    labels = np.asarray(labels).reshape(2,2)
    sns.heatmap(cf_matrix, annot=labels, fmt='', cmap='Blues')
    
    ## ROC

    predicted_probas = model.predict_proba(X_test)

    skplt.metrics.plot_roc(y_test, predicted_probas)
    plt.show()

    ## report
    print(metrics.classification_report(y_test, predictions))
    






