import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../Controller/MongoDBController.dart';
import '../../../../Model/GraphData.dart';
import '../../../../Model/Heart Pulse.dart';


class PulseDashboard extends StatefulWidget {
  final int? id;
  const PulseDashboard({super.key, this.id});

  @override
  State<PulseDashboard> createState() => _PulseDashboardState();
}

class _PulseDashboardState extends State<PulseDashboard> {

  late List<Pulse> pulses = [];
  // Prepare temperature data
  List<GraphData> pulsesData = [];

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

  Future<void> getAllPulseRecordsByToday() async {
    setState(() {
      graphTitle = "Today records";
    });
    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);


    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var pulseRecord = await MongoDatabase().getByQuery("Heart_Pulse", 
        {
          "PatientID" : 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": today, //change to today
            "\$lt": today.add(Duration(days: 1)),
          }
        }
      );
      print("All Temperature: $pulseRecord");
      print("Total: ${pulseRecord.length}");
      
      if(pulseRecord.isNotEmpty){
        setState((){
          pulses = pulseRecord.map((json) => Pulse.fromJson(json)).toList();
          pulsesData = pulses.map((rate) =>
              GraphData(day: formatTime(rate.MeasureTime.toString()), value: rate.pulseRate.toDouble())
          ).toList();
        });
      }
      else{
        setState((){
          pulses = pulseRecord.map((json) => Pulse.fromJson(json)).toList();
          pulsesData = pulses.map((rate) =>
              GraphData(day: formatTime(rate.MeasureTime.toString()), value: rate.pulseRate.toDouble())
          ).toList();
        });
      }

    } catch (e, printStack) {
      print('Error fetching other doctors : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }


  Future<void> getHighestPulseRecordsForRecentDays() async {
    setState(() {
      graphTitle = "Highest Pulse records for Recent 5 days";
    });
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime fiveDaysAgo = today.subtract(Duration(days: 5));

    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": fiveDaysAgo,
            "\$lt": today.add(Duration(days: 1)),
          }
        },
      );

      List<Pulse> rates = pulseRecords.map((json) => Pulse.fromJson(json)).toList();
      Map<DateTime, Pulse> highestRates = {};

      for (var rate in rates) {
        DateTime date = DateTime(rate.MeasureDate!.year, rate.MeasureDate!.month, rate.MeasureDate!.day);
        if (!highestRates.containsKey(date) || highestRates[date]!.pulseRate < rate.pulseRate) {
          highestRates[date] = rate;

          print("Highest: ${highestRates[date]}");
        }
      }

      setState(() {
        pulses = highestRates.values.toList();
        pulsesData = pulses.map((rate) => GraphData(day: formatDate(rate.MeasureDate.toString()), value: rate.pulseRate.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching temperature records: $e');
      print(printStack);
    }
  }

  void _selectDateRange() async {
    final ThemeData customTheme = ThemeData(
      colorScheme: ColorScheme.light(
        primary: Color.fromARGB(255, 255, 123, 0), // Change the primary color
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0400FF)
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 13.0,
          color: Color(0xFF0400FF)
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5900FF),
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 16.0,
          color: Color(0xFF00FFEA),
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 12.0,
          color: Color(0xFFFF0000),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 18.0,
          color: Color(0xFF000000),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 18.0,
          color: Color(0xFFFF006A),
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 16.0,
          color: Color(0xFFFC8600),
        ),
      ),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      barrierColor: Color(0xFFFF0000).withOpacity(0.5), // Change the background color of the dialog
      /* initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 7)),
        end: DateTime.now(),
      ), */
      
      builder: (context, child) {
        return Theme(
          data: customTheme,
          child: child!,
        );
      },
    );

    if (picked != null && picked.start != null && picked.end != null) {
      setState(() {
        graphTitle = "Pulse records between ${formatDate(picked.start.toString())} and ${formatDate(picked.end.toString())}";
      });
      getPulseRecordsByDateRange(picked.start, picked.end);
    }
  }

  Future<void> getPulseRecordsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startDate,
            "\$lt": endDate.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        pulses = pulseRecords.map((json) => Pulse.fromJson(json)).toList();

        print("Records between ${startDate} and ${endDate}: ${pulses}");
        pulsesData = pulses.map((rate) => GraphData(day: "${formatDate(rate.MeasureDate.toString())} ${formatTime(rate.MeasureTime.toString())}", value: rate.pulseRate.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching pulse records: $e');
      print(printStack);
    }
  }

  @override
  void initState() {
    super.initState();
    getAllPulseRecordsByToday();
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

        title: Text("Heart Pulse", style: GoogleFonts.poppins(
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

                SafeArea(
                  child: Padding(
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
                          dataSource: pulsesData,
                          xValueMapper: (GraphData value, _) => value.day,
                          yValueMapper: (GraphData value, _) => value.value,
                          enableTooltip: true,
                          name: 'Heart rate (BPM)', // Name of the series
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
                ),
                

                Padding(
                  padding: EdgeInsets.only(left: 15, bottom: 5),
                  child: Text("View Mode", style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0
                  ),),
                ),


                Container(
                  height: MediaQuery.sizeOf(context).width / 3,
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    separatorBuilder: (context, builder){
                      return SizedBox(width: 5);
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index){
                      if(index == 0){
                        return InkWell(
                          onTap: (){
                            getAllPulseRecordsByToday();
                            setState(() {
                              graphTitle = "Today Pulse";
                            });
                          }, 
                          child: Card(
                            elevation: 3,
                            child: Container(
                              width: MediaQuery.sizeOf(context).width / 3.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                  ],
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
                        );
                      }
                      else if(index == 1){
                        return InkWell(
                          onTap: (){
                            _selectDateRange();
                          }, 
                          child: Card(
                            elevation: 3,
                            child: Container(
                              width:  MediaQuery.sizeOf(context).width / 3.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_view_day_rounded, color: Colors.white,),

                                  Text("Range of date", style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                  ), textAlign: TextAlign.center),


                                ],
                              ),
                            ),
                          )
                        );
                      }
                      else{
                        return InkWell(
                          onTap: (){
                            getHighestPulseRecordsForRecentDays();
                            setState(() {
                              graphTitle = "Highest pulse records for Recent 5 days";
                            });
                          }, 
                          child: Card(
                            elevation: 3,
                            child: Container(
                              width:  MediaQuery.sizeOf(context).width / 3.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                  ],
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
