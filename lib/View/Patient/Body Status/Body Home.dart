import 'dart:convert'; //json encode/decode
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../Controller/MongoDBController.dart';
import '../../../Model/GraphData.dart';
import '../../../Model/Heart Pulse.dart';
import '../../../Model/Temperature.dart';
import '../../Widget/Patient/Measure Body NavBar.dart';
import '../../Widget/Patient/Pulse NavBar.dart';
import '../../Widget/Patient/Temperature NavBar.dart';

class BodyHome extends StatefulWidget {

  final Socket? socket;
  final int? id;
  const BodyHome({super.key, this.socket, this.id});

  @override
  State<BodyHome> createState() => _BodyHomeState();
}

class _BodyHomeState extends State<BodyHome> {

  // several
  /**
   * Services
   * 1. Get today latest temperature records
   * 2. Get today latest pulse records
   */
  int latestTemperatureRecord = 0;
  int latestPulseRecord = 0;

  late List<Temperature> temperatures = [];
  late List<Pulse> pulses = [];

  // Prepare temperature data
  List<GraphData> temperatureData = [];

  // Prepare pulse data
  List<GraphData> pulseData = [];

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
          latestTemperatureRecord = temperatures.last.temperature;
          temperatureData = temperatures.map((temp) =>
              GraphData(day: formatTime(temp.measureTime.toString()), value2: temp.temperature)
          ).toList();
        });
      }

    } catch (e, printStack) {
      print('Error fetching other doctors : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }


  
  Future<void> getAllPulseRecordsByToday() async {

    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);


    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var pulse = await MongoDatabase().getByQuery("Heart_Pulse", 
        {
          "PatientID" : 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": today, //change to today
            "\$lt": today.add(Duration(days: 1)),
          }
        }
      );
      print("All Pulse: $pulse");
      print("Total: ${pulse.length}");
      
      if(pulse.isNotEmpty){
        setState((){
          pulses = pulse.map((json) => Pulse.fromJson(json)).toList();
          latestPulseRecord = pulses.last.pulseRate;
          pulseData = pulses.map((pulse) =>
              GraphData(day: formatTime(pulse.MeasureTime.toString()), value2: pulse.pulseRate)
          ).toList();
        });
      }

    } catch (e, printStack) {
      print('Error fetching other pulses : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }
  
  Future<void> sendCommandToNodeMCU(String command) async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? server = await prefs.getString("localhost");

    
    String? nodeMCUIP = await prefs.getString("nodeMCU");

    Map<String, dynamic> body = {'cmd': command, 'IP' : server, 'PatientID': 'P-${widget.id}' };
    
    try {
      final response = await http.get(Uri.http('$nodeMCUIP', '/command', body));
      // handle the response here
    } catch (e) {
      print('Error sending command to NodeMCU: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    print("ID: ${widget.id}");
    getAllTempRecordsByToday();
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

        title: Text("Body Status", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        

      ),
      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: ()async {
          // Simulate a time-consuming task
          await Future.delayed(Duration(seconds: 1));
          
          getAllTempRecordsByToday();
          getAllPulseRecordsByToday();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
             color: Colors.grey.shade300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today", style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.black,
                          fontSize: 22.0, 
                          shadows: [
                            Shadow(
                              color: Color.fromARGB(255, 139, 139, 139),
                              offset: Offset(1.0, 2.0),
                              blurRadius: 4.0,
                            ),
                          ],
                        ),),
                    
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Color(0xFFB1B1B1),
                          ),
                          
                          padding: EdgeInsets.all(10.0),
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Card(
                                    elevation: 4,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.35,
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                          ],
                                        )
                                      ),
                                      child: Column(
                                        children: [
                                          Text("Latest Temperature", style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 15.0, 
                                          ),),
                                                            
                                          Text("${latestTemperatureRecord} °C", style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold, color: Colors.white,
                                            fontSize: 20.0,
                                            shadows: [
                                              Shadow(
                                                color: Color.fromARGB(255, 139, 139, 139),
                                                offset: Offset(1.0, 2.0),
                                                blurRadius: 4.0,
                                              ),
                                            ],
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ),
                          
                                  Card(
                                    elevation: 4,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.35,
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                         gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                          ],
                                        )
                                      ),
                                      child: Column(
                                        children: [
                                          Text("Latest Heart Pulse", style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 15.0, 
                                          ),),
                                                            
                                          Text("${latestPulseRecord} BPM", style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold, 
                                            color: Colors.white,
                                            fontSize: 20.0, 
                                            shadows: [
                                              Shadow(
                                                color: Color.fromARGB(255, 139, 139, 139),
                                                offset: Offset(1.0, 2.0),
                                                blurRadius: 4.0,
                                              ),
                                            ],
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SfCartesianChart(
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(
                      // For days view
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0),
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
                      text: 'Temperature today',
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
                      ColumnSeries<GraphData, String>(
                        color: Color(0xFFFF0019),
                        dataSource: temperatureData,
                        xValueMapper: (GraphData value, _) => value.day,
                        yValueMapper: (GraphData value, _) => value.value2,
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


                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SfCartesianChart(
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(
                      // For days view
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0),
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
                      text: 'Heart Pulse today',
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



                      // Heart Pulse Series
                      LineSeries<GraphData, String>(
                        color: Color(0xFF0400FF),
                        dataSource: pulseData,
                        xValueMapper: (GraphData data, _) => data.day!,
                        yValueMapper: (GraphData data, _) => data.value2!.toDouble(),
                        enableTooltip: true,


                        name: 'Heart Pulse (bpm)', // Name of the series
                        /* dataLabelSettings: DataLabelSettings(isVisible: true, 
                        textStyle:  GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 8.0
                        ),) */
                      ),

                      // Pie Series







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


                


                Divider(
                  color: Colors.grey,
                ),

                SizedBox(height: 15.0),

                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("View More", style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.black,
                    fontSize: 20.0, 
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(255, 139, 139, 139),
                        offset: Offset(1.0, 2.0),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),),
                ),

                SizedBox(height: 10),

                InkWell(
                  onTap: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    //IP based on NodeMCU
                    await prefs.setString("nodeMCU", "192.168.115.102");
                    sendCommandToNodeMCU("Start");
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => MeasureNav(tabIndexes: 0, id: widget.id)
                      )
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 180,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage("https://img.freepik.com/free-vector/doctor-smartwatch-with-heart-medical-icons-smartwatch-health-tracker-health-monitor-activity-tracking-concept-pinkish-coral-bluevector-isolated-illustration_335657-2303.jpg")
                            )
                          ),
                        ),
                
                        Center(
                          child: Text("Measure your body", style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, color: Colors.white,
                            fontSize: 15.0,  
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(255, 139, 139, 139),
                                offset: Offset(1.0, 2.0),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => TempNav(tabIndexes: 0, id: widget.id),
                        )
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage("https://static.vecteezy.com/system/resources/previews/002/390/681/non_2x/thermometer-icon-object-for-measure-temperature-illustration-free-vector.jpg")
                                )
                              ),
                            ),
                    
                            Center(
                              child: Text("Temperature", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, color: Colors.white,
                                fontSize: 15.0,  
                                shadows: [
                                  Shadow(
                                    color: Color.fromARGB(255, 139, 139, 139),
                                    offset: Offset(1.0, 2.0),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /* InkWell(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => PressureNav(tabIndexes: 0,),
                        )
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 2.5,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage("https://p4.img.cctvpic.com/photoworkspace/contentimg/2023/10/08/2023100808581672808.jpg")
                                )
                              ),
                            ),

                            Center(
                              child: Text("Blood Pressure", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, color: Colors.white,
                                fontSize: 15.0, 
                                shadows: [
                                  Shadow(
                                    color: Color.fromARGB(255, 139, 139, 139),
                                    offset: Offset(1.0, 2.0),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),),
                            ),
                          ],
                        ),
                      ),
                    ), */

                    InkWell(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => PulseNav(tabIndexes: 0, id: widget.id),
                        )
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage("https://cdni.iconscout.com/illustration/premium/thumb/doctor-checking-to-heartrate-monitor-4704802-3919128.png?f=webp")
                                )
                              ),
                            ),

                            Center(
                              child: Text("Heart Pulse", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, color: Colors.white,
                                fontSize: 15.0, 
                                shadows: [
                                  Shadow(
                                    color: Color.fromARGB(255, 139, 139, 139),
                                    offset: Offset(1.0, 2.0),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),),
                            ),
                          ],
                        ),
                      ),
                    ),




                  ],
                ),

                SizedBox(height: 60),

                SizedBox(height: 30),

                
              ]
            ),
          ),
        ),
      ),
    );
  }
}