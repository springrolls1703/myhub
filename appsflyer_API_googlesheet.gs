//-----------------------------------------------------------------------

function update_inapp_af() {
  var as = SpreadsheetApp.getActiveSpreadsheet();
  var sheet_Raw_Inapp = as.getSheetByName('Raw_Inapp');

  
  var options = {muteHttpExceptions: true};
  var url = "https://hq.appsflyer.com/export/com.tpb.mb.gprsandroid/in_app_events_report/v5?api_token=d4f97c86-3eea-4248-92db-601456620c38&from=2021-05-20&to=2021-06-12&event_name=register_lv1"; 
  var response = UrlFetchApp.fetch(url,options);
  var Dataraw = response.getContentText();
  var csvData = Utilities.parseCsv(Dataraw);
  
  sheet_Raw_Inapp.getRange(1, 1, csvData.length, csvData[0].length).setValues(csvData);
  Logger.log("-----------Function2: Done-----------")
}

