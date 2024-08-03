import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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



  final List<bool> _selectedDays = <bool>[true, false, false];
  bool vertical = false;

  late List<Pulse> pulses = [];
  List<GraphData> pulsesData = [];
  String graphTitle = '';

  String formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time).toLocal();
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute:$second $period';
  }

  Future<void> getAllPulseRecordsByToday() async {
    setState(() {
      graphTitle = "Today records";
    });
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    try {
      var pulseRecord = await MongoDatabase().getByQuery("Heart_Pulse", {
        "PatientID": 'P-${widget.id}',
        "MeasureDate": {
          "\$gte": today,
          "\$lt": today.add(Duration(days: 1)),
        }
      });

      if (pulseRecord.isNotEmpty) {
        setState(() {
          pulses = pulseRecord.map((json) => Pulse.fromJson(json)).toList();
          pulsesData = pulses.map((rate) =>
              GraphData(day: formatTime(rate.MeasureTime.toString()), value: rate.pulseRate.toDouble())
          ).toList();
        });
      } else {
        setState(() {
          pulses = [];
          pulsesData = [];
        });
      }
    } catch (e, printStack) {
      print('Error fetching pulse records: $e');
      print(printStack);
    }
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

      body: Container(
        decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        height: MediaQuery.sizeOf(context).height,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Today", style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
                ),),
              ),

              SizedBox(height: 10),

              Container(
                child: Row(
                  children: [
                    
                    Container(
                      padding: EdgeInsets.all(10),
                      height: MediaQuery.sizeOf(context).width / 4,
                      width: MediaQuery.sizeOf(context).width / 4,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Column(
                        children: [
                          Text("Average", style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0
                          ),),
                        ],
                      ),
                    ),

                    Spacer(),

                    Container(
                      padding: EdgeInsets.all(10),
                      height: MediaQuery.sizeOf(context).width / 4,
                      width: MediaQuery.sizeOf(context).width / 4,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Column(
                        children: [
                          Text("Minimum", style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0
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
                      height: MediaQuery.sizeOf(context).width / 4,
                      width: MediaQuery.sizeOf(context).width / 4,
                      
                      child: Column(
                        children: [
                          Text("Maximum", style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0
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
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderColor: Color(0xFFFFFFFF),
                    selectedColor: Colors.white,
                    selectedBorderColor: Color(0xFFFFFFFF),
                    fillColor:  Color(0xFFFF4081),
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

              SizedBox(height: 40),

              Container(
                height: 200,
                child: SfCartesianChart(
                      // Initialize category axis
                      plotAreaBorderWidth: 0.0,
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
                          color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600,
                          fontSize: 15.0
                        ),
                        title: AxisTitle(
                          text: 'Pulse(BPM)', // Set the label for X axis
                          textStyle:  GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600,
                            fontSize: 15.0
                          ),
                        ),
                        /* title: AxisTitle(
                          text: 'Celsius', // Set the label for X axis
                          textStyle:  GoogleFonts.poppins(
                            color: Colors.black, fontWeight: FontWeight.w600,
                            fontSize: 15.0
                          ),
                        ), */
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
                  
                        pulsesData.length > 1
                        // Temperature Series
                        ? SplineSeries<GraphData, String>(
                          xAxisName: "BPM",
                          yAxisName: "Month",
                          color: Color(0xFFFFFFFF),
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
                        )
                        
                        : ColumnSeries<GraphData, String>(
                          
                          color: Color(0xFFFFFFFF),
                          dataSource: pulsesData,
                          xValueMapper: (GraphData value, _) => value.day,
                          yValueMapper: (GraphData value, _) => value.value,
                          enableTooltip: true,
                          name: 'Heart rate (BPM)', // Name of the series
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true, textStyle:  GoogleFonts.poppins(
                            color: Color(0xFFFFFFFF),
                            fontSize: 8.0
                          ),)
                        ),
                  
                  
                  
                  
                  
                  
                  
                      ],
                      // Enable legend
                  
                      // Custom legend position
                      legend: Legend(
                        isVisible: false,
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

             

              Container(
                alignment: Alignment.center,
                  height: 130,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                       

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the row's children
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("View mode", style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontSize: 17.0
                          ),),

                          SizedBox(width: 5),

                          InkWell(
                            onTap: (){
                              getAllPulseRecordsByToday();
                              setState(() {
                                graphTitle = "Today Pulse";
                              });
                            }, 
                            child: Card(
                              elevation: 3,
                              child: Container(
                                width: MediaQuery.sizeOf(context).width / 4,
                                height: 80,
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
                            onTap: (){
                                      
                            }, 
                            child: Card(
                              elevation: 3,
                              child: Container(
                                width:  MediaQuery.sizeOf(context).width / 4,
                                 height: 80,
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
                              });
                            }, 
                            child: Card(
                              elevation: 3,
                              child: Container(
                                width:  MediaQuery.sizeOf(context).width / 4,
                                 height: 80,
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
        )
      )
    );
  }
}