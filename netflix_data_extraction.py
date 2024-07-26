# -*- coding: utf-8 -*-
"""Importing dataset from CSV file"""
import pandas as pd
df = pd.read_csv('netflix_titles.csv')

"""Connecting to SQL server"""
import sqlalchemy as sal
engine = sal.create_engine('mssql://HARITHA\SQLEXPRESS01/master?driver=ODBC+DRIVER+17+FOR+SQL+SERVER')
conn=engine.connect()

"""Creating table in SQL"""
df.to_sql('netflix_raw', con=conn , index=False, if_exists = 'append')
conn.close()
df.head()

"""finding character length of all columns"""
max(df.show_id.str.len())
max(df.type.str.len())
max(df.title.str.len())
max(df.director.str.len())
max(df.cast.dropna().str.len())
max(df.country.dropna().str.len())
max(df.date_added.dropna().str.len())
max(df.rating.dropna().str.len())
max(df.duration.dropna().str.len())
max(df.listed_in.dropna().str.len())
max(df.description.dropna().str.len())

"""Number of nulll values present per column"""
df.isna().sum()