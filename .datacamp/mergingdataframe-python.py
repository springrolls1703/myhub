#ID01 - open multiple datafile,ffill
#ID02 - pd.append, pd.concat
#ID03 - axis = 1 (is similar with outer join), axis = columns
#ID04 - concate with keys in indexing
#ID05 - pd.IndexSlide
#ID06 - Using key-values pairs in concat without defining the keys
#ID07 - inner JOIN and outer JOIN
#ID08 - merge dataframe
    #ID09 - info:
    #df1.append(df2): stacking vertically
    #pd.concat([df1,df2]): stacking many horizontally or vertically, simple inner/outer joins
    #df1.join(df2): joins on indexes
    #pd.merge([df1,df2])
#ID09 - merge_ordered, merge_asof, resample(on='')


# Import pandas
import pandas as pd

# Create the list of file names: filenames
filenames = ['Gold.csv', 'Silver.csv', 'Bronze.csv']

# Create the list of three DataFrames: dataframes
dataframes = []
for filename in filenames:
    dataframes.append(pd.read_csv(filename))

# Print top 5 rows of 1st DataFrame in dataframes
print(dataframes[0].head())

# Import pandas
import pandas as pd

# Read 'monthly_max_temp.csv' into a DataFrame: weather1
weather1 = pd.read_csv('monthly_max_temp.csv',index_col = 'Month')

# Print the head of weather1
print(weather1.head())

# Sort the index of weather1 in alphabetical order: weather2
weather2 = weather1.sort_index()

# Print the head of weather2
print(weather2.head())

#ID04 - concate with keys in indexing
for medal in medal_types:

    file_name = "%s_top5.csv" % medal
    
    # Read file_name into a DataFrame: medal_df
    medal_df = pd.read_csv(file_name,index_col='Country')
    
    # Append medal_df to medals
    medals.append(medal_df)
    
# Concatenate medals: medals
medals = pd.concat(medals,keys=['bronze', 'silver', 'gold'])

# Print medals in entirety
print(medals)

# Sort the index of weather1 in reverse alphabetical order: weather3
weather3 = weather1.sort_index(ascending = False)

# Print the head of weather3
print(weather3.head())

# Sort weather1 numerically using the values of 'Max TemperatureF': weather4
weather4 = weather1.sort_values(by='Max TemperatureF')

# Print the head of weather4
print(weather4.head())

# Import pandas
import pandas as pd

# Reindex weather1 using the list year: weather2
weather2 = weather1.reindex(year)

# Print weather2
print(weather2)

# Reindex weather1 using the list year with forward-fill: weather3
weather3 = weather1.reindex(year).ffill()

# Print weather3
print(weather3)

# Import pandas
import pandas as pd

# Reindex names_1981 with index of names_1881: common_names
common_names = names_1981.reindex(names_1881.index)

# Print shape of common_names
print(common_names.shape)

# Drop rows with null counts: common_names
common_names = common_names.dropna()

# Print shape of new common_names
print(common_names.shape)

# Extract selected columns from weather as new DataFrame: temps_f
temps_f = weather[['Min TemperatureF', 'Mean TemperatureF', 'Max TemperatureF']]

# Convert temps_f to celsius: temps_c
temps_c = (temps_f - 32) * 5/9

# Rename 'F' in column names with 'C': temps_c.columns
temps_c.columns = temps_c.columns.str.replace('F','C')

# Print first 5 rows of temps_c
print(temps_c.head())

#ID02
# Initialize empty list: units
units = []

# Build the list of Series
for month in [jan, feb, mar]:
    units.append(month['Units'])

# Concatenate the list: quarter1
quarter1 = pd.concat(units, axis = 'rows')

# Print slices from quarter1
print(quarter1.loc['jan 27, 2015':'feb 2, 2015'])
print(quarter1.loc['feb 26, 2015':'mar 7, 2015'])

# Add 'year' column to names_1881 and names_1981
names_1881['year'] = 1881
names_1981['year'] = 1981

# Append names_1981 after names_1881 with ignore_index=True: combined_names
combined_names = names_1881.append(names_1981,ignore_index=True)

# Print shapes of names_1981, names_1881, and combined_names
print(names_1981.shape)
print(names_1881.shape)
print(combined_names.shape)

# Print all rows that contain the name 'Morgan'
print(combined_names.loc[combined_names['name'] == 'Morgan'])

#ID03 - axis = 1 (is similar with outer join), axis = columns
# Create a list of weather_max and weather_mean
weather_list = [weather_max,weather_mean]

# Concatenate weather_list horizontally
weather = pd.concat(weather_list,axis = 1)

# Print weather
print(weather)

#Initialize an empyy list: medals
medals =[]

for medal in medal_types:
    # Create the file name: file_name
    file_name = "%s_top5.csv" % medal
    # Create list of column names: columns
    columns = ['Country', medal]
    # Read file_name into a DataFrame: medal_df
    medal_df = pd.read_csv(file_name,header=0,index_col='Country',names=columns)
    # Append medal_df to medals
    medals.append(medal_df)

# Concatenate medals horizontally: medals_df
medals_df = pd.concat(medals,axis = 'columns')

# Print medals_df
print(medals_df)

#ID04 - concate with keys in indexing
for medal in medal_types:

    file_name = "%s_top5.csv" % medal
    
    # Read file_name into a DataFrame: medal_df
    medal_df = pd.read_csv(file_name,index_col='Country')
    
    # Append medal_df to medals
    medals.append(medal_df)
    
# Concatenate medals: medals
medals = pd.concat(medals,keys=['bronze', 'silver', 'gold'])

# Print medals in entirety
print(medals)

#ID05 - pd.IndexSlide
# Sort the entries of medals: medals_sorted
medals_sorted = medals.sort_index(level = 0)

# Print the number of Bronze medals won by Germany
print(medals_sorted.loc[('bronze','Germany')])

# Print data about silver medals
print(medals_sorted.loc['silver'])

# Create alias for pd.IndexSlice: idx
idx = pd.IndexSlice

# Print all the data on medals won by the United Kingdom
print(medals_sorted.loc[idx[:,'United Kingdom'], :])

# Concatenate dataframes: february
february = pd.concat(dataframes,keys=['Hardware', 'Software', 'Service'],axis=1)

# Print february.info()
print(february.info())

# Assign pd.IndexSlice: idx
idx = pd.IndexSlice

# Create the slice: slice_2_8
slice_2_8 = february.loc['2015-02-02':'2015-02-08', idx[:, 'Company']]

# Print slice_2_8
print(slice_2_8)

#ID06 - Using key-values pairs in concat without defining the keys

# Make the list of tuples: month_list
month_list = [('january', jan), ('february', feb), ('march', mar)]

# Create an empty dictionary: month_dict
month_dict = {}

for month_name, month_data in month_list:

    # Group month_data: month_dict[month_name]
    month_dict[month_name] = month_data.groupby('Company').sum()

# Concatenate data in month_dict: sales
sales = pd.concat(month_dict)

# Print sales
print(sales)

# Print all sales by Mediacore
idx = pd.IndexSlice
print(sales.loc[idx[:, 'Mediacore'], :])

#ID07 - inner JOIN and outer JOIN
# Create the list of DataFrames: medal_list
medal_list = [bronze,silver,gold]

# Concatenate medal_list horizontally using an inner join: medals
medals = pd.concat(medal_list,keys=['bronze', 'silver', 'gold'],join='inner',axis=1)

# Print medals
print(medals)


# Resample and tidy china: china_annual
china_annual = china.resample('A').last().pct_change(10).dropna()

# Resample and tidy us: us_annual
us_annual = us.resample('A').last().pct_change(10).dropna()

# Concatenate china_annual and us_annual: gdp
gdp = pd.concat([china_annual,us_annual],join='inner',axis = 1)

# Resample gdp and print
print(gdp.resample('10A').last())

#ID08 - merge dataframe
# Merge revenue with managers on 'city': merge_by_city
merge_by_city = pd.merge(revenue,managers,on = 'city')

# Print merge_by_city
print(merge_by_city)

# Merge revenue with managers on 'branch_id': merge_by_id
merge_by_id = pd.merge(revenue,managers,on = 'branch_id')

# Print merge_by_id
print(merge_by_id)

# Merge revenue & managers on 'city' & 'branch': combined
combined = pd.merge(revenue,managers,left_on='city',right_on='branch')

# Print combined
print(combined)

# Add 'state' column to revenue: revenue['state']
revenue['state'] = ['TX','CO','IL','CA']

# Add 'state' column to managers: managers['state']
managers['state'] = ['TX','CO','CA','MO']

# Merge revenue & managers on 'branch_id', 'city', & 'state': combined
combined = pd.merge(revenue,managers,on = ['branch_id','city','state'])

# Print combined
print(combined)

# Merge revenue and sales: revenue_and_sales
revenue_and_sales = pd.merge(revenue, sales, how = 'right',on = ['city','state'])

# Print revenue_and_sales
print(revenue_and_sales)

# Merge sales and managers: sales_and_managers
sales_and_managers = pd.merge(sales,managers, how = 'left',left_on = ['city','state'],right_on=['branch','state'])


# Print sales_and_managers
print(sales_and_managers)

# Perform the first merge: merge_default
merge_default = pd.merge(sales_and_managers,revenue_and_sales)

# Print merge_default
print(merge_default)

# Perform the second merge: merge_outer
merge_outer = pd.merge(sales_and_managers,revenue_and_sales,how='outer')

# Print merge_outer
print(merge_outer)

# Perform the third merge: merge_outer_on
merge_outer_on = pd.merge(sales_and_managers,revenue_and_sales,on=['city','state'],how = 'outer')

# Print merge_outer_on
print(merge_outer_on)

#ID09 - merge_ordered
# Perform the first ordered merge: tx_weather
tx_weather = pd.merge_ordered(austin,houston)

# Print tx_weather
print(tx_weather)

# Perform the second ordered merge: tx_weather_suff
tx_weather_suff = pd.merge_ordered(austin,houston,suffixes=['_aus','_hus'],on='date')

# Print tx_weather_suff
print(tx_weather_suff)

# Perform the third ordered merge: tx_weather_ffill
tx_weather_ffill = pd.merge_ordered(austin,houston,suffixes=['_aus','_hus'],on='date',fill_method='ffill')

# Print tx_weather_ffill
print(tx_weather_ffill)
# Merge auto and oil: merged
merged = pd.merge_asof(auto,oil,left_on='yr',right_on='Date')

# Print the tail of merged
print(merged.tail())

# Resample merged: yearly
yearly = merged.resample('A', on='Date')[['mpg','Price']].mean()

# Print yearly
print(yearly)

# print yearly.corr()
print(yearly.corr())

#ID10 - pd.read_csv(,sep = '\t'), df.devide(df2,axis='rows'), expanding().mean(), pct_change
#Import pandas
import pandas as pd

# Create file path: file_path
file_path = 'Summer Olympic medallists 1896 to 2008 - EDITIONS.tsv'

# Load DataFrame from file_path: editions
editions = pd.read_csv(file_path,sep = '\t')

# Extract the relevant columns: editions
editions = editions[['Edition','Grand Total','City','Country']]
# Print editions DataFrame
print(editions)

# Import pandas
import pandas as pd

# Create empty dictionary: medals_dict
medals_dict = {}

for year in editions['Edition']:

    # Create the file path: file_path
    file_path = 'summer_{:d}.csv'.format(year)
    
    # Load file_path into a DataFrame: medals_dict[year]
    medals_dict[year] = pd.read_csv(file_path)
    
    # Extract relevant columns: medals_dict[year]
    medals_dict[year] = medals_dict[year][['Athlete','NOC','Medal']]
    
    # Assign year to column 'Edition' of medals_dict
    medals_dict[year]['Edition'] = year
    
# Concatenate medals_dict: medals
medals = pd.concat(medals_dict,ignore_index=True)

# Print first and last 5 rows of medals
print(medals.head())
print(medals.tail())

# Set Index of editions: totals
totals = editions.set_index('Edition')

# Reassign totals['Grand Total']: totals
totals = totals['Grand Total']

# Divide medal_counts by totals: fractions
fractions = medal_counts.divide(totals,axis = 'rows')

# Print first & last 5 rows of fractions
print(fractions.head())
print(fractions.tail())

# Apply the expanding mean: mean_fractions
mean_fractions = fractions.expanding().mean()

# Compute the percentage change: fractions_change
fractions_change = mean_fractions.pct_change()*100

# Reset the index of fractions_change: fractions_change
fractions_change = fractions_change.reset_index('Edition')

# Print first & last 5 rows of fractions_change
print(fractions_change.head())
print(fractions_change.tail())

# Import pandas
import pandas as pd

# Left join editions and ioc_codes: hosts
hosts = pd.merge(editions,ioc_codes,how ='left')

# Extract relevant columns and set index: hosts
hosts = hosts[['Edition','NOC']].set_index('Edition')

# Fix missing 'NOC' values of hosts
print(hosts.loc[hosts.NOC.isnull()])
hosts.loc[1972, 'NOC'] = 'FRG'
hosts.loc[1980, 'NOC'] = 'URS'
hosts.loc[1988, 'NOC'] = 'KOR'

# Reset Index of hosts: hosts
hosts = hosts.reset_index()

# Print hosts
print(hosts)


# Import pandas
import pandas as pd

# Reshape fractions_change: reshaped
reshaped = pd.melt(fractions_change,id_vars='Edition',value_name='Change')

# Print reshaped.shape and fractions_change.shape
print(reshaped.shape, fractions_change.shape)

# Extract rows from reshaped where 'NOC' == 'CHN': chn
chn =reshaped.loc[reshaped.NOC == 'CHN']

# Print last 5 rows of chn with .tail()
print(chn.tail())

# Import pandas
import pandas as pd

# Merge reshaped and hosts: merged
merged = pd.merge(reshaped,hosts)

# Print first 5 rows of merged
print(merged.head())

# Set Index of merged and sort it: influence
influence = merged.set_index('Edition').sort_index()

# Print first 5 rows of influence
print(influence.head())


# Import pyplot
import matplotlib.pyplot as plt

# Extract influence['Change']: change
change = influence['Change']

# Make bar plot of change: ax
ax =  change.plot(kind='bar')

# Customize the plot to improve readability
ax.set_ylabel("% Change of Host Country Medal Count")
ax.set_title("Is there a Host Country Advantage?")
ax.set_xticklabels(editions['City'])

# Display the plot
plt.show()  