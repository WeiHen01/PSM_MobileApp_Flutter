import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../../../Controller/MongoDBController.dart';
import '../../../../Model/GraphData.dart';
import '../../../../Model/Temperature.dart';

class TempDashboard extends StatefulWidget {
  final int? id;
  const TempDashboard({super.key, this.id});

  @override
  State<TempDashboard> createState() => _TempDashboardState();
}

class _TempDashboardState extends State<TempDashboard> {

  final List<bool> _selectedDays = <bool>[true, false, false];
  bool vertical = false;

  late List<Temperature> temperatures = [];
  // Prepare temperature data
  List<GraphData> temperatureData = [];

  String graphTitle = '';

  DateTime? selectedDate;

  DateTime? startRange, endRange;

  String? dateRange;


  DateTime today = DateTime.now();

  // List of month names
  final List<String> monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];


  // Function to format DateTime to string
  String formatDate(String date) {
    // Parse the date string
    final dateTime = DateTime.parse(date);
    // Format the DateTime into a desired string format
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  // Function to format Time to string in 12-hour system and convert to local time
  String formatTime(String time) {
    final dateTime = DateTime.parse(time).toLocal(); // Convert to local time
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0'); // Add leading zero if necessary
    final second = dateTime.second.toString().padLeft(2, '0'); // Add leading zero if necessary
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute:$second $period';
  }

  // get today records
  Future<void> getAllTempRecordsByToday() async {
    
    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);


    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var temp = await MongoDatabase().getByQuery("Temperature", 
        {
          "PatientID" : 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": today, //change to today
            "\$lt": today.add(Duration(days: 1)),
          }
        }
      );
      print("All Temperature: $temp");
      print("Total: ${temp.length}");
      
      if(temp.isNotEmpty){
        setState((){
          temperatures = temp.map((json) => Temperature.fromJson(json)).toList();
          temperatureData = temperatures.map((temp) =>
              GraphData(day: formatTime(temp.measureTime.toString()), value: temp.temperature.toDouble())
          ).toList();
        });
      }

    } catch (e, printStack) {
      print('Error fetching other doctors : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }


  /* // Get records for a specific date
  Future<void> getTempRecordsByDate(DateTime selectedDate) async {
    setState(() {
      graphTitle = "Records for ${selectedDate.day} ${monthNames[selectedDate.month - 1]} ${selectedDate.year}";
    });

    try {
      var tempRecords = await MongoDatabase().getByQuery(
        "Temperature",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
            "\$lt": DateTime(selectedDate.year, selectedDate.month, selectedDate.day).add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        temperatures = tempRecords.map((json) => Temperature.fromJson(json)).toList();
        temperatureData = temperatures.map((temp) => GraphData(day: formatTime(temp.measureTime.toString()), value: temp.temperature.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching temperature records for the specific date: $e');
      print(printStack);
    }
  } */

  String? avg, fahren;

  // Get records for a specific date and calculate the average temperature
  Future<void> getTempRecordsByDate(DateTime selectedDate) async {
    setState(() {
      graphTitle = "Records for ${selectedDate.day} ${monthNames[selectedDate.month - 1]} ${selectedDate.year}";
    });

    try {
      var tempRecords = await MongoDatabase().getByQuery(
        "Temperature",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
            "\$lt": DateTime(selectedDate.year, selectedDate.month, selectedDate.day).add(Duration(days: 1)),
          }
        },
      );

      if (tempRecords.isNotEmpty) {
        // Map records to Temperature objects
        temperatures = tempRecords.map((json) => Temperature.fromJson(json)).toList();

        // Calculate the average temperature
        double totalTemperature = temperatures.fold(0.0, (sum, temp) => sum + temp.temperature.toDouble());
        double averageTemperature = totalTemperature / temperatures.length;

        double avgFahrenheit = (averageTemperature * 9 / 5) + 32;

        // Update the graph data
        temperatureData = temperatures.map((temp) => 
          GraphData(day: formatTime(temp.measureTime.toString()), value: temp.temperature.toDouble())
        ).toList();

        print("Average Temperature: $averageTemperature");

        setState(() {
          // You can update the UI with the average temperature here if needed
          // For example, you could display it in a widget or add it to the graphTitle
          avg = "${averageTemperature.toStringAsFixed(2)}";
          fahren = "${avgFahrenheit.toStringAsFixed(2)}";

        });
      } else {
        print("No records found for the selected date.");
        // Handle the case where no records are found
      }
    } catch (e, printStack) {
      print('Error fetching temperature records for the specific date: $e');
      print(printStack);
    }
  }




  // get highest records for recent 5 days
  Future<void> getHighestTempRecordsForRecentDays() async {
    setState(() {
      graphTitle = "Highest temperature records for Recent 5 days";
    });
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime fiveDaysAgo = today.subtract(Duration(days: 5));

    try {
      var tempRecords = await MongoDatabase().getByQuery(
        "Temperature",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": fiveDaysAgo,
            "\$lt": today.add(Duration(days: 1)),
          }
        },
      );

      List<Temperature> temps = tempRecords.map((json) => Temperature.fromJson(json)).toList();
      Map<DateTime, Temperature> highestTemps = {};

      for (var temp in temps) {
        DateTime date = DateTime(temp.measureDate!.year, temp.measureDate!.month, temp.measureDate!.day);
        if (!highestTemps.containsKey(date) || highestTemps[date]!.temperature < temp.temperature) {
          highestTemps[date] = temp;

          print("Highest: ${highestTemps[date]}");
        }
      }

      setState(() {
        temperatures = highestTemps.values.toList();
        temperatureData = temperatures.map((temp) => GraphData(day: formatDate(temp.measureDate.toString()), value: temp.temperature.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching temperature records: $e');
      print(printStack);
    }
  }

  // get records based on certain date range selected
  Future<void> getTempRecordsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      var tempRecords = await MongoDatabase().getByQuery(
        "Temperature",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startDate,
            "\$lt": endDate.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        temperatures = tempRecords.map((json) => Temperature.fromJson(json)).toList();

        print("Records between ${startDate} and ${endDate}: ${temperatures}");
        temperatureData = temperatures.map((temp) => GraphData(day: "${formatDate(temp.measureDate.toString())} ${formatTime(temp.measureTime.toString())}", value: temp.temperature.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching temperature records: $e');
      print(printStack);
    }
  }

  // Get records for the week based on the specific date
  Future<void> getTempRecordsForWeek(DateTime selectedDate) async {
    

    DateTime startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    try {
      var tempRecords = await MongoDatabase().getByQuery(
        "Temperature",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startOfWeek,
            "\$lt": endOfWeek.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        temperatures = tempRecords.map((json) => Temperature.fromJson(json)).toList();
        temperatureData = temperatures.map((temp) => GraphData(day: formatDate(temp.measureDate.toString()), value: temp.temperature.toDouble())).toList();
        graphTitle = "Temperature Records for Week of ${formatDate(startOfWeek.toString())} to ${formatDate(endOfWeek.toString())}";
      });
    } catch (e, printStack) {
      print('Error fetching temperature records for the week: $e');
      print(printStack);
    }
  }

  // Get records for the month based on the specific date
  Future<void> getTempRecordsForMonth(DateTime selectedDate) async {
    setState(() {
      graphTitle = "Records for ${monthNames[selectedDate.month - 1]} ${selectedDate.year}";
    });

    DateTime startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1).subtract(Duration(days: 1));

    try {
      var tempRecords = await MongoDatabase().getByQuery(
        "Temperature",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startOfMonth,
            "\$lt": endOfMonth.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        temperatures = tempRecords.map((json) => Temperature.fromJson(json)).toList();
        temperatureData = temperatures.map((temp) => GraphData(day: formatDate(temp.measureDate.toString()), value: temp.temperature.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching temperature records for the month: $e');
      print(printStack);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize with today's date
    selectedDate = today;
    getAllTempRecordsByToday();
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),

        title: Text("Temperature", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        

      ),

      body: Container(
        decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        height: double.infinity,
        padding: EdgeInsets.all(10),
        child: RefreshIndicator(
          
          color: Colors.orange,
          onRefresh: ()async {
            // Simulate a time-consuming task
            await Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: ()async{
                      var date_result = await showCalendarDatePicker2Dialog(
                        context: context,
                        config: CalendarDatePicker2WithActionButtonsConfig(
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: today,
                          currentDate: today,
                          controlsTextStyle:  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                          weekdayLabelTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
                          lastMonthIcon: Icon(Icons.arrow_back_ios, color: Colors.black),
                          nextMonthIcon: Icon(Icons.arrow_forward_ios, color: Colors.black),

                          dayTextStyle: GoogleFonts.poppins(color: Colors.black),
                          monthTextStyle: GoogleFonts.poppins(color: Colors.black),
                          yearTextStyle: GoogleFonts.poppins(color: Colors.black),
                          okButtonTextStyle: GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold),
                          selectedMonthTextStyle: GoogleFonts.poppins(color: Colors.white),
                          selectedYearTextStyle: GoogleFonts.poppins(color: Colors.white),
                          selectedDayTextStyle: GoogleFonts.poppins(color: Colors.white),


                          cancelButtonTextStyle:  GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold),

                        ),
                        dialogSize: const Size(325, 400),
                        value: [selectedDate],
                        borderRadius: BorderRadius.circular(15),
                        
                      );

                      // If results are not null and contain at least one date, update the selected date
                      if (date_result != null) {
                        setState(() {
                          selectedDate = date_result.last; // Update selected date to the first (and only) selected date
                          getTempRecordsByDate(selectedDate!);
                          dateRange == null;
                        });
                        print("Selected Date: ${selectedDate.toString()}"); // Print the selected date
                        
                      }
                    },
                    child: Row(
                      children: [
                        Text("${selectedDate == today ? "Today" : "${selectedDate!.day.toString()} ${monthNames[selectedDate!.month - 1]} ${selectedDate!.year.toString()}"} ", style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0
                        ),),

                        Icon(Icons.arrow_drop_down_sharp, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                Container(
                  child: Row(
                    children: [
                      
                      Container(
                        padding: EdgeInsets.all(10),
                        height: MediaQuery.sizeOf(context).width / 3.5,
                        width: MediaQuery.sizeOf(context).width / 2.5,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        child: Column(
                          children: [
                            Text("Celsius °C", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0
                            ),),

                            Spacer(),

                            Text("${avg == null ? "-" : avg}", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 35.0
                            ),),
                          ],
                        ),
                      ),
          
                      
          
                      Spacer(),
                      
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        height: MediaQuery.sizeOf(context).width / 3.5,
                        width: MediaQuery.sizeOf(context).width / 2.5,
                        
                        child: Column(
                          children: [
                            Text("Fahrenheit °F", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0
                            ),),

                            Spacer(),

                            Text("${fahren == null ? "-" : fahren}", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 35.0
                            ),),

                            
                          ],
                        ),
                      ),
                    ],
                  )
                ),
          
                SizedBox(height: 20),
          
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      direction: vertical ? Axis.vertical : Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < _selectedDays.length; i++) {
                            _selectedDays[i] = i == index;
                            
                          }
                          if (_selectedDays[0]) {
                            getTempRecordsByDate(selectedDate!);
                          } else if (_selectedDays[1]) {
                            getTempRecordsForWeek(selectedDate!);
                          } else if (_selectedDays[2]) {
                            getTempRecordsForMonth(selectedDate!);
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderColor: Color(0xFFFFFFFF),
                      selectedColor: Colors.white,
                      selectedBorderColor: Color(0xFFFFFFFF),
                      fillColor: Color(0xFFFF7F50),
                      color: Colors.black,
                      constraints: BoxConstraints(
                        minHeight: 40.0,
                        minWidth: MediaQuery.sizeOf(context).width / 3.5,
                      ),
                      isSelected: _selectedDays,
                      children: [
                        Text('Day', style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15
                        ),),
                        Text('Week', style: GoogleFonts.poppins(
                        color: Colors.white,
                          fontSize: 15.0
                        ),),
                        Text('Month', style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15.0
                        ),),
                      ],
                    ),
                  ],
                ),
          
                SizedBox(height: 20),
          
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SfCartesianChart(
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(
                      // For days view
                      labelStyle: GoogleFonts.poppins(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.0),
                      /* title: AxisTitle(
                        text: 'Day',
                        textStyle: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0),
                      ), */
                    ),

                    primaryYAxis: NumericAxis(
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600,
                        fontSize: 15.0
                      ),
                      title: AxisTitle(
                        text: 'Celsius', // Set the label for X axis
                        textStyle:  GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600,
                          fontSize: 15.0
                        ),
                      ),
                    ),


                    title: ChartTitle(
                      text: '${graphTitle}',
                      textStyle:  GoogleFonts.poppins(
                        color: Colors.white,  fontWeight: FontWeight.w600,
                        fontSize: 15.0
                      ),
                    ),

                    series: <CartesianSeries>[

                      /*  
                        ColumnSeries: Displays data as vertical columns, with height representing the data value.
                        BarSeries: Similar to ColumnSeries, but the columns are horizontal.
                        AreaSeries: Displays data as a filled area, with the area under the curve filled with color.
                        SplineSeries: Similar to LineSeries, but the curve is smoothed out.
                        ScatterSeries: Represents individual data points as symbols without connecting them.
                        BubbleSeries: Represents data points as bubbles, with the size of the bubble representing the data value.
                        PieSeries: Displays data as slices of a pie, with each slice representing a category and its size representing the data value.
                        DoughnutSeries: Similar to PieSeries, but with a hole in the center. 
                      */

                       // Temperature Series
                      temperatureData.length > 1 

                      ? SplineSeries<GraphData, String>(
                        color: Color(0xFFFF5E00),
                        dataSource: temperatureData,
                        xValueMapper: (GraphData value, _) => value.day,
                        yValueMapper: (GraphData value, _) => value.value,
                        enableTooltip: true,
                        name: 'Temperature (°C)', // Name of the series
                        /* dataLabelSettings: DataLabelSettings(
                          isVisible: true, textStyle:  GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 8.0
                        ),) */
                      )

                      : ColumnSeries<GraphData, String>(
                        color: Color(0xFFFF5E00),
                        dataSource: temperatureData,
                        xValueMapper: (GraphData value, _) => value.day,
                        yValueMapper: (GraphData value, _) => value.value,
                        enableTooltip: true,
                        name: 'Temperature (°C)', // Name of the series
                        /* dataLabelSettings: DataLabelSettings(
                          isVisible: true, textStyle:  GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 8.0
                        ),) */
                      ),







                    ],
                    // Enable legend

                    // Custom legend position
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.auto, // Adjust the position here
                      textStyle:  GoogleFonts.poppins(
                        color: Color(0xFFFFFFFF),
                        fontSize: 10.0
                      ),
                    ),

                    // Enable zooming and panning
                    zoomPanBehavior: ZoomPanBehavior(
                      enableSelectionZooming: true,
                      enableMouseWheelZooming: true,
                      enablePanning: true,
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                    ),

                    // Add tooltip
                    tooltipBehavior: TooltipBehavior(
                      textStyle:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 8.0
                      ),
                      enable: true,

                    ),


                  ),
                ),

          
          
          
                SizedBox(height: 20),
          
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${dateRange == null ? "" : dateRange}", style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.0,
                  ), textAlign: TextAlign.center),
                ),
          
                Container(
                  alignment: Alignment.center,
                    height: 200,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("View mode", style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontSize: 17.0
                          ),),

                        
          
                        Row(
                         mainAxisAlignment: MainAxisAlignment.center, // Center the row's children
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
          
                            SizedBox(width: 5),
          
                            InkWell(
                              onTap: (){
                                getAllTempRecordsByToday();
                                setState(() {
                                  graphTitle = "Today Temperature";
                                  dateRange = null;
                                  selectedDate = DateTime.now();
                                });
                              }, 
                              child: Card(
                                elevation: 3,
                                child: Container(
                                 width: MediaQuery.sizeOf(context).width / 4,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.white,),
                                        
                                      Text("Today", style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10.0
                                      ),),
                                        
                                        
                                    ],
                                  ),
                                ),
                              )
                            ),
                        
                        
                            InkWell(
                              onTap: ()async{
                                var date_result = await showCalendarDatePicker2Dialog(
                                  context: context,
                                  config: CalendarDatePicker2WithActionButtonsConfig(
                                    lastDate: today,
                                    currentDate: today,
                                    firstDate: DateTime(2000, 1, 1),
                                    controlsTextStyle:  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                                    weekdayLabelTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
                                    lastMonthIcon: Icon(Icons.arrow_back_ios, color: Colors.black),
                                    nextMonthIcon: Icon(Icons.arrow_forward_ios, color: Colors.black),

                                    dayTextStyle: GoogleFonts.poppins(color: Colors.black),
                                    monthTextStyle: GoogleFonts.poppins(color: Color(0xFF000000)),
                                    yearTextStyle: GoogleFonts.poppins(color: Colors.black),
                                    okButtonTextStyle: GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold),
                                    selectedMonthTextStyle: GoogleFonts.poppins(color: Colors.white),
                                    selectedDayTextStyle: GoogleFonts.poppins(color: Colors.white),
                                    selectedYearTextStyle: GoogleFonts.poppins(color: Colors.white),
                                    calendarType: CalendarDatePicker2Type.range,
                                    cancelButtonTextStyle:  GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold),

                                  ),
                                  dialogSize: const Size(325, 400),
                                  value: [startRange, endRange],
                                  borderRadius: BorderRadius.circular(15),
                                  
                                );

                                // If results are not null and contain at least one date, update the selected date
                                if (date_result != null) {
                                  setState(() async{
                                    startRange = date_result.first; // Update selected date to the first (and only) selected date
                                    endRange = date_result.last;
                                    print("$startRange - $endRange");
                                    await getTempRecordsByDateRange(startRange!, endRange!);
                                    
                                    dateRange = "Date Selected: ${startRange!.day} ${monthNames[startRange!.month - 1]} ${startRange!.year} - ${endRange!.day} ${monthNames[endRange!.month - 1]} ${endRange!.year} ";
                                    graphTitle = "Temperature records between ${startRange!.day} ${monthNames[startRange!.month - 1]} ${startRange!.year} and ${endRange!.day} ${monthNames[endRange!.month - 1]} ${endRange!.year}";
                                  });

                                  
                                 
                                }
                              }, 
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width / 4,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_view_day_rounded, color: Colors.white,),
                                        
                                      Text("Select date range", style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ), textAlign: TextAlign.center),
                                        
                                        
                                    ],
                                  ),
                                ),
                              )
                            ),
                        
                        
                            InkWell(
                              onTap: (){
                                setState(() {
                                  graphTitle = "Highest pulse records for Recent 5 days";
                                  getHighestTempRecordsForRecentDays();
                                });
                              }, 
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width / 4,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.data_exploration, color: Colors.white,),
                                        
                                      Text("Highest records in recent 5 days", style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ), textAlign: TextAlign.center),
                                        
                                        
                                    ],
                                  ),
                                ),
                              )
                            )
                            
                          ],
                        ),
          
                        
                      ],
                    )
                  ),
          
                  SizedBox(height: 70),
                
              ],
            ),
          ),
        )
      )
    );
  }
}