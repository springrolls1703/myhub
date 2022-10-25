#ID01 - pd.read_csv
#ID02 - showing subplot
#ID03 - ARMA model - defining stationary time series or not\
#ID04 - Adfuller
$from statsmodels.tsa.stattools import adfuller
-0th element is test statistic
--More negative means more likely to be stationary
-1st element is p-value
--If p-value is small→reject null hypothesis. Reject non-stationary.
-4th element is the criticaltest statistics - giá trị tới hạn
#ID05 - Calculate the second difference of the time series
#ID06 - using np.log to calculate the differences
#ID07 - ARMA fit
#ID08 - summary
#ID09 - ARMAX
#ID10 - get_prediction()/predicted_mean/conf_int()
#ID11 - plot the backward predictions
#ID12 - dynamic forecast
#ID13 - SARIMAX


#ID01 - read csv
# Import modules
import matplotlib.pyplot as plt
import pandas as pd

# Load in the time series
candy = pd.read_csv('candy_production.csv', 
            index_col='date',
            parse_dates=True)

# Plot and show the time series on axis ax
fig, ax = plt.subplots()
candy.plot(ax=ax)
plt.show()

#ID02
# Split the data into a train and test set
candy_train = candy.loc[:'2006']
candy_test = candy.loc['2007':]

# Create an axis
fig, ax = plt.subplots()

# Plot the train and test sets on the axis ax
candy_train.plot(ax=ax)
candy_test.plot(ax=ax)
plt.show()

#ID04
# Import augmented dicky-fuller test function
from statsmodels.tsa.stattools import adfuller

# Run test
result = adfuller(earthquake['earthquakes_per_year'])

# Print test statistic
print(result[0])

# Print p-value
print(result[1])

# Print critical values
print(result[4]) 

#ID05 - Calculate the second difference of the time series
# Calculate the second difference of the time series
city_stationary = city.diff().diff().dropna()

# Run ADF test on the differenced time series
result = adfuller(city_stationary['city_population'])

# Plot the differenced time series
fig, ax = plt.subplots()
city_stationary.plot(ax=ax)
plt.show()

# Print the test statistic and the p-value
print('ADF Statistic:', result[0])
print('p-value:', result[1])

#ID06 - using np.log to calculate the differences
# Calculate the first difference and drop the nans
amazon_diff = amazon.diff().dropna()

# Run test and print
result_diff = adfuller(amazon_diff['close'])
print(result_diff)

# Calculate log-return and drop nans
amazon_log = np.log(amazon/amazon.shift(1)).dropna()

# Run test and print
result_log = adfuller(amazon_log['close'])
print(result_log)

Set the coefficients for an AR(2) model with AR lag-1 and lag-2 coefficients of 0.3 and 0.2 respectively.

# Import data generation function and set random seed
from statsmodels.tsa.arima_process import arma_generate_sample
np.random.seed(2)

# Set coefficients
ar_coefs = [1,-0.3,-0.2]
ma_coefs = [1]

# Generate data
y = arma_generate_sample(ar_coefs, ma_coefs, nsample=100, sigma=0.5, )

plt.plot(y)
plt.ylabel(r'$y_t$')
plt.xlabel(r'$t$')
plt.show()

#ID07 - ARMA fit
# Import the ARMA model
from statsmodels.tsa.arima_model import ARMA

# Instantiate the model
model = ARMA(y, order=(1,1))

# Fit the model
results = model.fit()

#ID08 - summary
# Instantiate the model
model = ARMA(sample.timeseries_1, order=(2,0))

# Fit the model
results = model.fit()

# Print summary
print(results.summary())

#ID09 - ARMAX
# Instantiate the model
model = ARMA(hospital.wait_times_hrs,order=(2,1),exog=hospital.nurse_count)

# Fit the model
results = model.fit()

# Print model fit summary
print(results.summary())

#ID10 - get_prediction()/predicted_mean/conf_int()
# Generate predictions
one_step_forecast = results.get_prediction(start=-30)

# Extract prediction mean
mean_forecast = one_step_forecast.predicted_mean

# Get confidence intervals of  predictions
confidence_intervals = one_step_forecast.conf_int()

# Select lower and upper confidence limits
lower_limits = confidence_intervals.loc[:,'lower close']
upper_limits = confidence_intervals.loc[:,'upper close']

# Print best estimate  predictions
print(mean_forecast)

#ID11 - plot the backward predictions
# plot the amazon data
plt.plot(amazon.index,amazon, label='observed')

# plot your mean predictions
plt.plot(mean_forecast.index,mean_forecast,  color='r', label='forecast')

# shade the area between your confidence limits
plt.fill_between(lower_limits.index,lower_limits, upper_limits,
		  color='pink')

# set labels, legends and show plot
plt.xlabel('Date')
plt.ylabel('Amazon Stock Price - Close USD')
plt.legend()
plt.show()

#ID12 - dynamic forecast

# Generate predictions
dynamic_forecast = results.get_prediction(start=-30, dynamic=True)

# Extract prediction mean
mean_forecast = dynamic_forecast.predicted_mean

# Get confidence intervals of predictions
confidence_intervals = dynamic_forecast.conf_int()

# Select lower and upper confidence limits
lower_limits = confidence_intervals.loc[:,'lower close']
upper_limits = confidence_intervals.loc[:,'upper close']

# Print best estimate predictions
print(mean_forecast)

# plot the amazon data
plt.plot(amazon.index, amazon, label='observed')

# plot your mean forecast
plt.plot(mean_forecast.index, mean_forecast, color='r', label='forecast')

# shade the area between your confidence limits
plt.fill_between(lower_limits.index, lower_limits, 
         upper_limits, color='pink')

# set labels, legends and show plot
plt.xlabel('Date')
plt.ylabel('Amazon Stock Price - Close USD')
plt.legend()
plt.show()

#ID13 - SARIMAX - take the diff
# Take the first difference of the data
amazon_diff = amazon.diff().dropna()

# Create ARMA(2,2) model
arma = SARIMAX(amazon_diff,order=(2,0,2))

# Fit model
arma_results = arma.fit()

# Print fit summary
print(arma_results.summary())

# Make arma forecast of next 10 differences
arma_diff_forecast = arma_results.get_forecast(steps=10).predicted_mean

     # Integrate the difference forecast
arma_int_forecast = np.cumsum(arma_diff_forecast)

# Make absolute value forecast
arma_value_forecast = arma_int_forecast + amazon.iloc[-1,0]

# Print forecast
print(arma_value_forecast)

#ID14 - SARIMAX contains
# Create ARIMA(2,1,2) model
arima = SARIMAX(amazon,order=(2,1,2))

# Fit ARIMA model
arima_results = arima.fit()

# Make ARIMA forecast of next 10 values
arima_value_forecast = arima_results.get_forecast(steps=10).predicted_mean

# Print forecast
print(arima_value_forecast)