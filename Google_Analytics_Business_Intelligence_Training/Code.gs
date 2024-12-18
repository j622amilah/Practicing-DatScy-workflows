function onOpen() {
  var ui = SpreadsheetApp.getUi();
  ui.createMenu('extra functions')
      .addItem('cleanup: delete temp sheets', 'delete_temp_sheets')
      .addItem('GET request to deploy webapp & cleanup', 'doGet')
      .addToUi();
}



// Deploying using gs script only: https://developers.google.com/apps-script/reference/charts
// Deploying using gs and html script: https://developers.google.com/apps-script/guides/html/templates#index.html_3
function doGet() {

  // Create an Html output
  var htmlOutput = HtmlService.createHtmlOutput().setTitle('Dashboard about fictional Google Fiber data');

  // this specfies the entire current google sheet 
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  // OR
  // const ss = SpreadsheetApp.openByUrl('https://docs.google.com/spreadsheets/d/abc123456/edit');
  // OR
  // var ss = SpreadsheetApp.openById("abc1234567");
  // console.log(ss.getName());

  // Need to select the connected sheet

  // For a connected sheet
  // -----------------------------------
  var main_sheet = ss.getSheetByName("Sheet1");
  var datasource_sheet = ss.getSheetByName('repeat_call1');  // says that this is a sheet in the log, but it gives an error saying it is a DATASOURCE sheet
  // OR
  // var sheet = ss.getSheets()[0];
  // -----------------------------------
  
  Logger.log(datasource_sheet)

  // https://developers.google.com/apps-script/guides/sheets/connected-sheets


  // var sheet = datasource_sheet.asSheet()  // TypeError: datasource_sheet.asSheet is not a function
  // Logger.log(sheet)

  // -----------------------------------
  // Determine the name of the desired column OR determine the number of rows
  // -----------------------------------
  // var rows = datasource_sheet.getDataRange();  // Exception: The action is not supported for DATASOURCE sheet.
  // var numRows = rows.getNumRows();
  // OR
  // var numRows=datasource_sheet.getLastRow();  // Error : The action is not supported for DATASOURCE sheet
  // Logger.log(numRows)
  // OR
  // var values = SpreadsheetApp.getActiveSheet().getDataRange().getValues() // Exception: The action is not supported for DATASOURCE sheet
  // Logger.log(values)
  // OR
  // var names = datasource_sheet.DataSourceColumn.getName()  // TypeError: Cannot read properties of undefined (reading 'getName')
  // Logger.log(names)
  // OR
  // var range = datasource_sheet.getDataRange();  // Exception: The action is not supported for DATASOURCE sheet.
  // Logger.log(range.getValues())
  // OR
  // Functions for a DataSource and normal sheet
  // var range = SpreadsheetApp.getActiveRange();
  // Logger.log(range.getValues()) // [[Fiber optic]]  gets the first row value in the first column
  // var numRows = range.getValues().length;
  // Logger.log(numRows)
  // OR
  // Functions for a DataSource and normal sheet
  var startrow_num = 1;  //if 0, it starts on cell row 1
  var endrow_num = "";  // leave blank if you do not know the length of the column
  var startcol_letter = "A"
  var endcol_letter = "A"  
  var str_range = make_str_range(startrow_num, endrow_num, startcol_letter, endcol_letter)
  Logger.log(str_range)
  var data = datasource_sheet.getRange(str_range).getValues();
  Logger.log("data:")
  Logger.log(data)
  var numRows = data.length;
  Logger.log(numRows)
  // -----------------------------------


  // -----------------------------------
  // Get values from spreadsheet
  // -----------------------------------
  // const range = sheet.getRange('A1:D20');
  // OR
  // var sheet_start_num = 1;  //if 0, it starts on cell row 1
  // var sheet_end_num = 1;
  // var str_lettre = "A"
  // var end_lettre = "A"
  // var str_range = make_str_range(sheet_start_num, sheet_end_num, str_lettre, end_lettre)
  // var data = sheet.getRange(str_range).getValues(); 
  // OR
  // start_row, start_column, num_of_row to count down, num_of_columns)
  // var out = sheet.getRange(1,1,numRows-3,2).getValues();
  // OR
  // start_row, start_column, num_of_row to count down, num_of_columns)
  
  var market_city = datasource_sheet.getRange(1,1,numRows,1).getValues();
  Logger.log(market_city)
  
  var contract = datasource_sheet.getRange(1,2,numRows,1).getValues();
  Logger.log(contract)
  
  var acc_mang_probtype = datasource_sheet.getRange(1,5,numRows,1).getValues();
  Logger.log(acc_mang_probtype)
  
  var techtrob_probtype = datasource_sheet.getRange(1,6,numRows,1).getValues();
  Logger.log(techtrob_probtype)

  var acc_mang_probtype_call_freq = datasource_sheet.getRange(1,9,numRows,1).getValues();
  Logger.log(acc_mang_probtype_call_freq)
  
  var techtrob_probtype_call_freq = datasource_sheet.getRange(1,10,numRows,1).getValues();
  Logger.log(techtrob_probtype_call_freq)
  // -----------------------------------------
  

  // -----------------------------------------
  // First figure to the dashboard
  // -----------------------------------------
  // Aggregate the data values per category [SUM, AVG]
  var categorical_agg = removeDuplicatesWithSet(market_city)
  var agg_type = "SUM"
  var numerical_agg0 = aggregate_data2plot(market_city, acc_mang_probtype, agg_type)
  var numerical_agg1 = aggregate_data2plot(market_city, techtrob_probtype, agg_type)

  // print each column in the newsheet from left to right
  // var arr_of_cols = [market_city, acc_mang_probtype, techtrob_probtype];
  var arr_of_cols = [categorical_agg, numerical_agg0, numerical_agg1];
  var num_of_cols_2arrange = 3;
  var num_of_rows_per_col = categorical_agg.length;

  var sheetname = "tempsheet0";
  var tempsheet0 = pack_columns_2plot(ss, sheetname, num_of_cols_2arrange, num_of_rows_per_col, arr_of_cols);

  let title_text = 'Market and Problem Type of First Repeat Calls'
  let y_axis_text = 'Type of Internet Service (market_city)'
  let x_axis_text = 'Number of customers'
  var chart = add_bar_plot(tempsheet0, title_text, x_axis_text, y_axis_text)

  // Output the chart to the htmlservice
  var imageData = Utilities.base64Encode(chart.getAs('image/png').getBytes());
  var imageUrl = "data:image/png;base64," + encodeURI(imageData);
  htmlOutput.append("Dashboard about fictional Google Fiber data <br/>");
  htmlOutput.append("<img border=\"1\" src=\"" + imageUrl + "\">");
  // -----------------------------------------

  
  // -----------------------------------------
  // 2nd figure to the dashboard
  // -----------------------------------------
  // Aggregate the data values per category [SUM, AVG]
  var categorical_agg = removeDuplicatesWithSet(contract)
  var agg_type = "SUM"
  var numerical_agg0 = aggregate_data2plot(contract, acc_mang_probtype_call_freq, agg_type)
  var numerical_agg1 = aggregate_data2plot(contract, techtrob_probtype_call_freq, agg_type)

  // print each column in the newsheet from left to right
  var arr_of_cols = [categorical_agg, numerical_agg0, numerical_agg1];
  var num_of_cols_2arrange = 3;
  var num_of_rows_per_col = categorical_agg.length;

  var sheetname = "tempsheet1";
  var tempsheet1 = pack_columns_2plot(ss, sheetname, num_of_cols_2arrange, num_of_rows_per_col, arr_of_cols);

  title_text = 'Repeats by Contract length'
  y_axis_text = 'Contract'
  x_axis_text = 'Call frequency [number of tickets/Contract length]'
  var chart = add_bar_plot(tempsheet1, title_text, x_axis_text, y_axis_text)

  // Output the chart to the htmlservice
  var imageData = Utilities.base64Encode(chart.getAs('image/png').getBytes());
  var imageUrl = "data:image/png;base64," + encodeURI(imageData);
  htmlOutput.append("   ");
  htmlOutput.append("<img border=\"1\" src=\"" + imageUrl + "\">");
  // -----------------------------------------


  // -----------------------------------------
  // 3rd figure to the dashboard
  // -----------------------------------------
  // Aggregate the data values per category [SUM, AVG]
  var categorical_agg = removeDuplicatesWithSet(market_city)
  var agg_type = "SUM"
  var numerical_agg0 = aggregate_data2plot(market_city, acc_mang_probtype_call_freq, agg_type)
  var numerical_agg1 = aggregate_data2plot(market_city, techtrob_probtype_call_freq, agg_type)

  // print each column in the newsheet from left to right
  var arr_of_cols = [categorical_agg, numerical_agg0, numerical_agg1];
  var num_of_cols_2arrange = 3;
  var num_of_rows_per_col = categorical_agg.length;
  
  var sheetname = "tempsheet2";
  var tempsheet2 = pack_columns_2plot(ss, sheetname, num_of_cols_2arrange, num_of_rows_per_col, arr_of_cols);

  title_text = 'Calls by Market and Type'
  y_axis_text = 'Type of Internet Service (market_city)'
  x_axis_text = 'Call frequency [number of tickets/Contract length]'
  var chart = add_bar_plot(tempsheet2, title_text, x_axis_text, y_axis_text)

  // Output the chart to the htmlservice
  var imageData = Utilities.base64Encode(chart.getAs('image/png').getBytes());
  var imageUrl = "data:image/png;base64," + encodeURI(imageData);
  htmlOutput.append("<br/>");
  htmlOutput.append("<img border=\"1\" src=\"" + imageUrl + "\">");
  // -----------------------------------------

  delete_temp_sheets();

  return htmlOutput;

  
}


function make_str_range(start_num, end_num, str_lettre, end_lettre){ 
  return str_lettre.concat(start_num.toString(), ":", end_lettre, end_num.toString())
}


function pack_columns_2plot(ss, sheetname, num_of_cols_2arrange, num_of_rows_per_col, arr_of_cols){ 

  // make a new sheet
  var tempsheet = ss.insertSheet();
  tempsheet.setName(sheetname);

  for (var c=1; c<num_of_cols_2arrange+1; c++){
    selected_arr = arr_of_cols[c-1];
    Logger.log("selected_arr: ")
    Logger.log(selected_arr)

    for (var r=1; r<num_of_rows_per_col+1; r++){
      var range = tempsheet.getRange(r, c);
      range.setValue(selected_arr[r-1])
    }
  }
  
  return tempsheet
}



function convert_colnum_to_letter(numColumns){
  var letterlist = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
  var letterColumn;

  for (var i=1; i<letterlist.length+1; i++){
    if (i == numColumns){
      letterColumn = letterlist[i-1];
    }
  }
  return letterColumn
}



function aggregate_data2plot(categorical_col, numerical_col, agg_type){

  var uq_cat = removeDuplicatesWithSet(categorical_col)
  
  var tot_sum = [];
  var tot_avg = [];
  for (var i=1; i<uq_cat.length+1; i++){
    var tot_num = 0;
    //var count = 1;
    for (var j=1; j<categorical_col.length+1; j++){
      if (uq_cat[i-1] == categorical_col[j-1]){
        Logger.log("uq_cat[i-1]:")
        Logger.log(uq_cat[i-1])
        Logger.log("categorical_col[j-1]: ")
        Logger.log(categorical_col[j-1])
        tot_num = tot_num + Number(numerical_col[j-1]);
        Logger.log("tot_num:")
        Logger.log(tot_num)
        //count = count + 1;
        // Logger.log("count:")
        // Logger.log(count)
      }
    }
    tot_sum.push(tot_num);
    tot_avg.push(tot_num/categorical_col.length);
  }

  if (agg_type == "SUM"){
    return tot_sum
  } else if (agg_type == "AVG") {
    return tot_avg
  }

}



function add_bar_plot(tempsheet, title_text, x_axis_text, y_axis_text){
  
  // Add a row to the tempsheet 
  tempsheet.insertRowBefore(1);
  // var legend_text = ["", "acc_mang_probtype", "techtrob_probtype"];
  // var legend_text = [[""], ["acc_mang_probtype"], ["techtrob_probtype"]];
  // var range = tempsheet.getRange("A1:C1");
  // range.setValues(legend_text).setFontSize(14)
  // OR
  var range = tempsheet.getRange("B1:B1"); // start_row, start_column, num_of_row to count down, num_of_columns)
  range.setValue("acc_mang_probtype").setFontSize(12)
  var range = tempsheet.getRange("C1:C1"); // start_row, start_column, num_of_row to count down, num_of_columns)
  range.setValue("techtrob_probtype").setFontSize(12)


  // Find number of rows in tempsheet
  let numRows = tempsheet.getLastRow();

  // Find number of columns in tempsheet
  var numColumns = tempsheet.getLastColumn();

  // Get string interval to specify data range 
  var startrow_num = 1;  //if 0, it starts on cell row 1
  var endrow_num = numRows;
  var startcol_letter = "A"
  var endcol_letter = convert_colnum_to_letter(numColumns)
  var str_range = make_str_range(startrow_num, endrow_num, startcol_letter, endcol_letter)
  Logger.log(str_range)
  // OR
  // var startrow_num = 1;  //if 0, it starts on cell row 1
  // var endrow_num = numRows;
  // var startcol_letter = "A"
  // var endcol_letter = startcol_letter
  // var str_range0 = make_str_range(startrow_num, endrow_num, startcol_letter, endcol_letter)
  // Logger.log(str_range0)
  // var startrow_num = 1;  //if 0, it starts on cell row 1
  // var endrow_num = numRows;
  // var startcol_letter = "B"
  // var endcol_letter = startcol_letter
  // var str_range1 = make_str_range(startrow_num, endrow_num, startcol_letter, endcol_letter)
  // Logger.log(str_range1)
  // var startrow_num = 1;  //if 0, it starts on cell row 1
  // var endrow_num = numRows;
  // var startcol_letter = "C"
  // var endcol_letter = startcol_letter
  // var str_range2 = make_str_range(startrow_num, endrow_num, startcol_letter, endcol_letter)
  // Logger.log(str_range2)
  // var colA = tempsheet.getRange(str_range0);
  // var colB = tempsheet.getRange(str_range1);
  // var colC = tempsheet.getRange(str_range2);

  // Way 0: make a new temporary sheet - print the data of each column in the right order - select the range of this - delete the sheet after
  // https://developers.google.com/apps-script/reference/spreadsheet/embedded-chart-builder
  // https://developers.google.com/chart/interactive/docs/roles#stylerole
  // https://developers.google.com/apps-script/chart-configuration-options#bar-chart-configuration-options

  var chart = tempsheet.newChart()
        .setChartType(Charts.ChartType.BAR)
        .setOption('title', title_text)
        .setOption('vAxis.title', y_axis_text)
        .setOption('hAxis.title', x_axis_text)
        .setOption('hAxis.title', x_axis_text)
        .addRange(tempsheet.getRange(str_range))
        // OR
        //.addRange(colB)
        //.addRange(colC)
        //.addRange(colA)
        .setOption('useFirstColumnAsDomain', true) 
        //.setTransposeRowsAndColumns(true) // does not work
        .setPosition(2,4,0,0)
        //.setOption('legend', {position: 'top', textStyle: {color: 'blue', fontSize: 16}})
        .setNumHeaders(1)
        .build();

  // OR

  // Way 1: 
  // var market_city_range = datasource_sheet.getRange(1,1,numRows,1);
  // var acc_mang_probtype_range = datasource_sheet.getRange(1,5,numRows,1);
  // var techtrob_probtype_range = datasource_sheet.getRange(1,6,numRows,1);
  // var chart = datasource_sheet.newChart()
  //   .setChartType(Charts.ChartType.BAR)
  //   .setOption('title', 'Chart title')
  //   .setOption('hAxis.title', 'x-axis label')
  //   .setOption('vAxis.title', 'y-axis title')
  //   .setOption('vAxis.title', 'y-axis title')
  //   .addRange(market_city_range)
  //   .addRange(acc_mang_probtype_range)
  //   .addRange(techtrob_probtype_range)
  //   .setMergeStrategy(Charts.ChartMergeStrategy.MERGE_ROWS)
  //   .setPosition(5, 5, 0, 0)
  //   .build();
  // Gives error with chart after - Exception: Service Spreadsheets failed while accessing document with id 1Neu7eLHbdbceL2QHc5p85pEk-aVxn216MX80c8G_x10.
  // This error means that the merged data is deleted because the same error appears when I delete tempsheet

  // See results before deploying the dashboard
  tempsheet.insertChart(chart);

  return chart;

}


function sample3() {
  var sheet = SpreadsheetApp.getActiveSheet();
  var chart = sheet.getCharts()[0];
  var ranges = chart.getRanges();
  var c = chart.modify();
  ranges.forEach(r => c.removeRange(r));
  ranges.reverse().forEach(r => c.addRange(r));
  sheet.updateChart(c.build());
}


function newChart(range, sheet) {
  var chart = sheet.newChart()
    .setChartType(Charts.ChartType.LINE)
    .addRange(range)
    .setPosition(5, 5, 0, 0)
    .setOption("title", "Model run 1")
    .setOption("pointSize", 2)
    .setOption("lineWidth", 1)
    .build();
  sheet.insertChart(chart);
}



function removeDuplicatesWithSet(arr){
  // This is in list format
  var arr_list = arr.flat();
  // Logger.log(arr_list)

  var unique = Array.from(new Set(arr_list));
  // Logger.log(unique)
  // OR
  //let unique = [...new Set(arr_list)]  // prints same values
  return unique;
}


function removeDuplicates(arr) {
  // This is in list format
  var arr_list = arr.flat();
  // Logger.log(arr_list)
  
  let unique = [];
  arr_list.forEach(element => {
      if (!unique.includes(element)) {
          unique.push(element);
      }
  });
  return unique;
}


 
function removewithfilter(arr) {
  // This is in list format
  var arr_list = arr.flat();
  // Logger.log(arr_list)
  
  let outputArray = arr_list.filter(function (v, i, self) {
    // It returns the index of the first instance of each value
        return i == self.indexOf(v);
    });
 
    return outputArray;
}



function delete_temp_sheets() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  // Clean up temporary sheets
  var tempsheet0 = ss.getSheetByName("tempsheet0");
  ss.deleteSheet(tempsheet0);
  var tempsheet1 = ss.getSheetByName("tempsheet1");
  ss.deleteSheet(tempsheet1);
  var tempsheet2 = ss.getSheetByName("tempsheet2");
  ss.deleteSheet(tempsheet2);
}
