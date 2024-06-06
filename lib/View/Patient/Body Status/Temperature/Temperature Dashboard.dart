import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  late List<Temperature> temperatures = [];
  // Prepare temperature data
  List<GraphData> temperatureData = [];

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

  String graphTitle = '';

  Future<void> getAllTempRecordsByToday() async {
    setState(() {
      graphTitle = "Today records";
    });
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

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      // Customize color scheme
      
    );

    if (picked != null && picked.start != null && picked.end != null) {
      setState(() {
        graphTitle = "Temperature records between ${formatDate(picked.start.toString())} and ${formatDate(picked.end.toString())}";
      });
      getTempRecordsByDateRange(picked.start, picked.end);
    }
  }

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

  @override
  void initState() {
    super.initState();
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
      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: ()async {
          // Simulate a time-consuming task
          await Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SfCartesianChart(
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(
                      // For days view
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.black,
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
                        color: Colors.black, fontWeight: FontWeight.w600,
                        fontSize: 15.0
                      ),
                      /* title: AxisTitle(
                        text: 'Celsius', // Set the label for X axis
                        textStyle:  GoogleFonts.poppins(
                          color: Colors.black, fontWeight: FontWeight.w600,
                          fontSize: 15.0
                        ),
                      ), */
                    ),


                    title: ChartTitle(
                      text: '${graphTitle}',
                      textStyle:  GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.w600,
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
                      SplineSeries<GraphData, String>(
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
                        color: Colors.black,
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

                SizedBox(height: 15),


                Container(
                  height: 60,
                  child: ListView.separated(
                    separatorBuilder: (context, builder){
                      return SizedBox(width: 10);
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index){
                      if(index == 0){

                        return InkWell(
                          onTap: (){
                            getAllTempRecordsByToday();
                            setState(() {
                              graphTitle = "Today Temperature";
                            });
                          }, 
                          child: Card(
                            elevation:3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                              padding: EdgeInsets.all(15),
                              child: Text("Today", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0, color: Colors.white
                              ),),
                            ),
                          ),
                        );

                    

                      }
                      else if(index == 1){
                        return InkWell(
                          onTap: (){
                            _selectDateRange();
                            
                          }, 
                          child: Card(
                            elevation:3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                              padding: EdgeInsets.all(15),
                              child: Text("Select date", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0, color: Colors.white
                              ),),
                            ),
                          ),
                        );

                    
                      }
                      else {
                        return InkWell(
                          onTap: (){
                            getHighestTempRecordsForRecentDays();
                            setState(() {
                              graphTitle = "Highest temperature records for Recent 5 days";
                            });
                          }, 
                          child: Card(
                            elevation:3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                              padding: EdgeInsets.all(15),
                              child: Text("Highest records for Recent 5 days", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0, color: Colors.white
                              ),),
                            ),
                          ),
                        );
                      }
                    }
                  )
                )


                

                



              ],
            )
          ),
        )
      )
    );
  }
}

