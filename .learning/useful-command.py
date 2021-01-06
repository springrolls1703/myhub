# command to export jupyter to html without having code
jupyter nbconvert yourNotebook.ipynb --no-input

df_organic['Partner'] = df_organic['Partner'].astype(str)
df_organic['Media Source'] = df_organic['Media Source'].astype(str)
def get_agency(row):
  if row["Partner"] != "nan":
    return row["Partner"]
  else:
    return row["Media Source"]
df_organic['Agency'] = df_organic.apply(lambda row: get_agency(row), axis=1)
import re
db_organic = df_organic[["Install Time","Event Time","Agency", "Site ID","Country Code", "Event Name","Event Value"]]
db_organic["Event Time"] = pd.to_datetime(db_organic["Event Time"])
db_organic["Install Time"] = pd.to_datetime(db_organic["Install Time"])

email = re.compile('".*".*"(.*@\w+\.[a-z]{3})')
def getEmail(row):
    s = "".join(email.findall(row['Event Value']))
    if len(s) > 0: 
      return s
    else:
      return "guest"

def timeDiff(row):
  diff = row["Event Time"] - row["Install Time"]
  return diff.total_seconds()

db_organic["Email"] = db_organic.apply(lambda row: getEmail(row), axis=1)
db_organic["time diff"] = db_organic.apply(lambda row: timeDiff(row),axis=1)