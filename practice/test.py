import sys
sys.path.append('/opt/homebrew/lib/python2.7/site-packages') # Replace this with the place you installed facebookads using pip
sys.path.append('/opt/homebrew/lib/python2.7/site-packages/facebook_business-3.0.0-py2.7.egg-info') # same as above

from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.adaccount import AdAccount

my_app_id = '1345382539141977'
my_app_secret = '1e7614848c88ed5db10dbb287553c82f'
my_access_token = 'EAATHnkhVI1kBAO7ZCGz3pn8tlrfpSkOVA40amWeyZAmZAVWOl1VyZAZCRlhDFuAdbiYAEXkgbw1h7FLJTSVZBxN99kzAAn6FDEguR7dihK3Y77LpvNMfsf6IkZAWRhpgPAIrrN8S8Xqo1BWO7CcQZAXCxsFoaKy8mttdkLotETG6VeZBbkLEZA2jJZCZAGONuHCRvOMZD'
FacebookAdsApi.init(my_app_id, my_app_secret, my_access_token)
my_account = AdAccount('act_<196070987588536>')
campaigns = my_account.get_campaigns()
print(campaigns)
