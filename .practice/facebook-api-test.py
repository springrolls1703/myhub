# This program downloads all relevent Facebook traffic info as a csv file
# This program requires info from the Facebook Ads API: https://github.com/facebook/facebook-python-ads-sdk

# Import all the facebook mumbo jumbo
from facebookads.api import FacebookAdsApi
from facebookads.adobjects.adsinsights import AdsInsights
from facebookads.adobjects.adaccount import AdAccount
from facebookads.adobjects.business import Business

# Import th csv writer and the date/time function
import datetime
import csv
EAATHnkhVI1kBAO7ZCGz3pn8tlrfpSkOVA40amWeyZAmZAVWOl1VyZAZCRlhDFuAdbiYAEXkgbw1h7FLJTSVZBxN99kzAAn6FDEguR7dihK3Y77LpvNMfsf6IkZAWRhpgPAIrrN8S8Xqo1BWO7CcQZAXCxsFoaKy8mttdkLotETG6VeZBbkLEZA2jJZCZAGONuHCRvOMZD  
# Set the info to get connected to the API. Do NOT share this info
my_app_id = '1345382539141977'
my_app_secret = '1e7614848c88ed5db10dbb287553c82f'
my_access_token = 'EAATHnkhVI1kBAO7ZCGz3pn8tlrfpSkOVA40amWeyZAmZAVWOl1VyZAZCRlhDFuAdbiYAEXkgbw1h7FLJTSVZBxN99kzAAn6FDEguR7dihK3Y77LpvNMfsf6IkZAWRhpgPAIrrN8S8Xqo1BWO7CcQZAXCxsFoaKy8mttdkLotETG6VeZBbkLEZA2jJZCZAGONuHCRvOMZD'

# Start the connection to the facebook API
FacebookAdsApi.init(my_app_id, my_app_secret, my_access_token)
 
# Create a business object for the business account
business = Business('****')

# Get yesterday's date for the filename, and the csv data
yesterdaybad = datetime.datetime.now() - datetime.timedelta(days=1)
yesterdayslash = yesterdaybad.strftime('%m/%d/%Y')
yesterdayhyphen = yesterdaybad.strftime('%m-%d-%Y')

# Define the destination filename
filename = yesterdayhyphen + '_fb.csv'
filelocation = "/cron/downloads/"+ filename

# Get all ad accounts on the business account
accounts = business.get_owned_ad_accounts(fields=[AdAccount.Field.id])

# Open or create new file 
try:
    csvfile = open(filelocation , 'w+', 0777)
except:
    print ("Cannot open file.")


# To keep track of rows added to file
rows = 0

try:
    # Create file writer
    filewriter = csv.writer(csvfile, delimiter=',')
except Exception as err:
    print(err)

# Iterate through the adaccounts
for account in accounts:
    # Create an addaccount object from the adaccount id to make it possible to get insights
    tempaccount = AdAccount(account[AdAccount.Field.id])

    # Grab insight info for all ads in the adaccount
    ads = tempaccount.get_insights(params={'date_preset':'yesterday',
                                           'level':'ad'
                                          },
                                   fields=[AdsInsights.Field.account_id,
                       AdsInsights.Field.account_name,
                                           AdsInsights.Field.ad_id,
                                           AdsInsights.Field.ad_name,
                                           AdsInsights.Field.adset_id,
                                           AdsInsights.Field.adset_name,
                                           AdsInsights.Field.campaign_id,
                                           AdsInsights.Field.campaign_name,
                                           AdsInsights.Field.cost_per_outbound_click,
                                           AdsInsights.Field.outbound_clicks,
                                           AdsInsights.Field.spend
                                          ]
    );

    # Iterate through all accounts in the business account
    for ad in ads:
        # Set default values in case the insight info is empty
        date = yesterdayslash
        accountid = ad[AdsInsights.Field.account_id]
        accountname = ""
        adid = ""
        adname = ""
        adsetid = ""
        adsetname = ""
        campaignid = ""
        campaignname = ""
        costperoutboundclick = ""
        outboundclicks = ""
        spend = ""

        # Set values from insight data
        if ('account_id' in ad) :
            accountid = ad[AdsInsights.Field.account_id]
        if ('account_name' in ad) :
            accountname = ad[AdsInsights.Field.account_name]
        if ('ad_id' in ad) :
            adid = ad[AdsInsights.Field.ad_id]
        if ('ad_name' in ad) :
            adname = ad[AdsInsights.Field.ad_name]
        if ('adset_id' in ad) :
            adsetid = ad[AdsInsights.Field.adset_id]
        if ('adset_name' in ad) :
            adsetname = ad[AdsInsights.Field.adset_name]
        if ('campaign_id' in ad) :
            campaignid = ad[AdsInsights.Field.campaign_id]
        if ('campaign_name' in ad) :
            campaignname = ad[AdsInsights.Field.campaign_name]
        if ('cost_per_outbound_click' in ad) : # This is stored strangely, takes a few steps to break through the layers
            costperoutboundclicklist = ad[AdsInsights.Field.cost_per_outbound_click]
            costperoutboundclickdict = costperoutboundclicklist[0]
            costperoutboundclick = costperoutboundclickdict.get('value')
        if ('outbound_clicks' in ad) : # This is stored strangely, takes a few steps to break through the layers
            outboundclickslist = ad[AdsInsights.Field.outbound_clicks]
            outboundclicksdict = outboundclickslist[0]
            outboundclicks = outboundclicksdict.get('value')
        if ('spend' in ad) :
            spend = ad[AdsInsights.Field.spend]

        # Write all ad info to the file, and increment the number of rows that will display
        filewriter.writerow([date, accountid, accountname, adid, adname, adsetid, adsetname, campaignid, campaignname, costperoutboundclick, outboundclicks, spend])
        rows += 1


csvfile.close()

# Print report
print (str(rows) + " rows added to the file " + filename)