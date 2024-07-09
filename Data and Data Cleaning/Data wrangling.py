"""
Samuel Rea
last modified: Samuel Rea july 6, 2024
Descprition: this wrangles and cleans the data that will be used to train the lstm to make predicitons
"""
#importing packages
#importing packages
import pandas as pd
import numpy as np
import chardet
import datetime

with open('data.csv', 'rb') as f:
    result = chardet.detect(f.read())

encoding = result['encoding']

# Loading in the data set with the detected encoding and handling bad lines
data = pd.read_csv('data.csv', encoding=encoding, delimiter='\t', header=0, on_bad_lines='warn')

print(data.head())
print(data.info())

#cleaning the data
#we want to make all of the numeric variables into floats and not objects so further analysis can be done on them
data['Median Sale Price'] = data['Median Sale Price'].str.replace("$",'').str.replace('K', '000').astype(float)
#cleaning percentage
percentage_col=['Median Sale Price MoM ','Median Sale Price YoY ','Homes Sold MoM ','Homes Sold YoY ','New Listings MoM ',
    'New Listings YoY ','Inventory MoM ','New Listings YoY ','Inventory MoM ',' Inventory YoY ','Average Sale To List',
    'Average Sale To List MoM ', 'Average Sale To List YoY ']
#cleaning the precentage
for col in percentage_col:
    data[col] = data[col].astype(str).str.replace('%','').astype(float)
#cleaning miscolanious columns
random_objects= ['Homes Sold', 'New Listings', 'Inventory']

for col in random_objects:
    data[col] = data[col].astype(str).str.replace(',','').astype(float)
#finally changing the date column to be an actual datetime variable
data['Month of Period End'] = pd.to_datetime(data['Month of Period End'], format='%B %Y')

print(data.head())
print(data.info())

#adding the mortgage rate for each month to gain more insight into the market and hopefully add to the predicitive power
data_m=pd.read_csv('MORTGAGE30US.csv')
#converting the dat into datetime formate
data_m['DATE']=pd.to_datetime(data_m['DATE'])
data_m['DATE'] = data_m['DATE'] + pd.offsets.MonthBegin(0)
data_m.sort_values(by='DATE', inplace=True)
data_m_clean = data_m.groupby(data_m['DATE'].dt.to_period('M')).first().reset_index(drop=True)
print(data_m_clean.head())
print(data_m_clean.info())

#merging the two data sets so further EDA and eventually build the model on it
merged_data = pd.merge(data_m_clean, data, left_on='DATE', right_on='Month of Period End', how='inner')
merged_data.drop(['Region','Month of Period End'], axis =1,inplace=True)
merged_data.rename(columns={'MORTGAGE30US':'30 year Mortgage rate'}, inplace=True)
print(merged_data.head())
print(merged_data.info())
merged_data.to_csv('clean_data.csv', index=False)