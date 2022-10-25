import requests

url = "https://api.kilo.vn/back-office/utils/adjust-cashback-balance"
TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTE3MTgsInBsYXRmb3JtIjoiU0VMTEVSX1dFQiIsImlhdCI6MTY1OTc1NzMzNSwiZXhwIjoxNjU5ODQzNzM1fQ.keSJTdDAKMsK7KDqo10ovW61VsBroJGIfR588Ipame0'

import json
payload = json.dumps({
    'retailerIds': [27418],
    'action': 'PUSH_IN',
	'points': 53815
})
headers = {
    'Api-version': '2',
    'Authorization': f"Bearer {TOKEN}",
    'Content-Type': "application/json",
    'admintoken': TOKEN
    }

response = requests.request("PUT", url, data=payload, headers=headers)

print(response.text)
