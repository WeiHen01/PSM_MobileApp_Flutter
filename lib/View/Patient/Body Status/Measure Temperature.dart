import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../Controller/MongoDBController.dart';
import '../../../Controller/OneSignal Controller.dart';
import '../../../Model/Temperature.dart';
import '../../Widget/Patient/Custom Loading Popup.dart';

class TempMeasure extends StatefulWidget {

  final int? id;
  const TempMeasure({super.key, this.id});

  @override
  State<TempMeasure> createState() => _TempMeasureState();
}

class _TempMeasureState extends State<TempMeasure> {

  // IP here refer to IP connected to NodeMCU
  

  int latestTemperatureRecord = 0;
  late List<Temperature> temperatures = [];

  Future<void> sendCommandToNodeMCU(String command) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nodeMCUIP = await prefs.getString("nodeMCU");
    String? server = await prefs.getString("localhost");

    Map<String, dynamic> body = {'cmd': command, 'IP' : server, 'PatientID': 'P-${widget.id}' };
    
    try {
      LoadingScreen.show(context, "Loading, please wait");
      await http.get(Uri.http('$nodeMCUIP', '/command', body));
      Future.delayed(Duration(seconds: 5), () {
        // 5s over, navigate to a new page
        LoadingScreen.hide(context);
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
            latestTemperatureRecord = temperatures.last.temperature;
            tempReceived = latestTemperatureRecord;

            if(tempReceived < 20){
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: "LOW TEMPERATURE",
                  text: "The temperature is ${tempReceived}°C! It is cold now!",
                
                ),
              );

              Navigator.pop(context);

              String id = "P-${widget.id}";
              List<String> sendTo = [];

              sendTo.add(id);
              
              var title = "LOW TEMPERATURE";
              var desc = "The temperature is ${tempReceived}°C! It is cold now!";

              OneSignalController onesignal = OneSignalController();
              onesignal.SendNotification(title, desc, sendTo);
            }

            if(tempReceived > 20 && tempReceived < 33){
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: "NORMAL TEMPERATURE DATA",
                  text: "Your temperature data: ${tempReceived} is normal! ",
                
                  
                ),
              );

              Navigator.pop(context);

              String id = "P-${widget.id}";
              List<String> sendTo = [];

              sendTo.add(id);

              var title = "Normal Temperature data!";
              var desc = "Your temperature data: ${tempReceived} is normal!";

              OneSignalController onesignal = OneSignalController();
              onesignal.SendNotification(title, desc, sendTo);
            }

            if(tempReceived > 33){
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: "HIGH TEMPERATURE",
                  text: "The temperature is ${tempReceived}°C! It is hot now! Please be careful!",
                
                ),
              );

              Navigator.pop(context);

              String id = "P-${widget.id}";
              List<String> sendTo = [];

              sendTo.add(id);
              
              var title = "HIGH TEMPERATURE";
              var desc = "The temperature is ${tempReceived}°C! It is hot now! Please be careful!";

              OneSignalController onesignal = OneSignalController();
              onesignal.SendNotification(title, desc, sendTo);
            }
          });
        }
      

      } catch (e, printStack) {
        print('Error fetching other doctors : $e');
        print(printStack);
        // Handle the exception as needed, for example, show an error message to the user
      }
    } catch (e) {
      print('Error sending command to NodeMCU: $e');
    }
  }

  var tempReceived;
  

  String? temperature;


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

        title: Text("Measure Temperature", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 18.0
        ),),

        

      ),

      body:  RefreshIndicator(
        color: Colors.orange,
        onRefresh: ()async {
          // Simulate a time-consuming task
          await Future.delayed(Duration(seconds: 1));
        },
        child: Container(
          padding: EdgeInsets.only(top: 100, bottom: 100),
          color: Colors.grey.shade300,
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
            
                      ticksPosition: ElementsPosition.outside,
                      labelsPosition: ElementsPosition.outside,
                      minorTicksPerInterval: 5,
                      axisLineStyle: AxisLineStyle(
                        thicknessUnit: GaugeSizeUnit.factor,
                        thickness: 0.1,
                      ),
                      axisLabelStyle: GaugeTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      radiusFactor: 0.85,
                      majorTickStyle: MajorTickStyle(
                          length: 0.1,
                          thickness: 2,
            
                          lengthUnit: GaugeSizeUnit.factor),
                      minorTickStyle: MinorTickStyle(
                          length: 0.05,
                          thickness: 1.5,
            
                          lengthUnit: GaugeSizeUnit.factor),
                      minimum: -20,
                      maximum: 120,
                      interval: 20,
                      startAngle: 115,
                      endAngle: 65,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: -60,
                            endValue: 120,
                            startWidth: 0.1,
                            sizeUnit: GaugeSizeUnit.factor,
                            endWidth: 0.1,
                            gradient: SweepGradient(stops: <double>[
                              0.2,
                              0.5,
                              0.75
                            ], colors: <Color>[
                              Colors.green,
                              Colors.yellow,
                              Colors.red
                            ]))
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                            value: tempReceived?.toDouble() ?? 0, needleColor: Colors.black,
                            tailStyle: TailStyle(length: 0.18, width: 8,
                                color: Colors.black,
                                lengthUnit: GaugeSizeUnit.factor),
                            needleLength: 0.68,
                            needleStartWidth: 1,
                            needleEndWidth: 8,
                            knobStyle: KnobStyle(knobRadius: 0.07,
                                color: Colors.white, borderWidth: 0.05,
                                borderColor: Colors.black),
                            lengthUnit: GaugeSizeUnit.factor)
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Text(
                              '°C',
                              style:
                              GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            positionFactor: 0.8,
                            angle: 90)
                      ],
                    ),
                  ],
                ),
            
            
                Text("${tempReceived == null ? "" : '$tempReceived °C'} ", style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black,
                  fontSize: 30.0,  
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 139, 139, 139),
                      offset: Offset(1.0, 2.0),
                      blurRadius: 4.0,
                    ),
                  ],
                ),),
                
               
                Container(
                  height: 220,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    
                    color: Colors.black87,
                  ),
                  child: Column(children: [
                    Text("Temperature Measurement", style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white,
                      fontSize: 18.0,  
                      
                    ),),

                    SizedBox(height: 20),

                    Container(
                      child: SfLinearGauge(
                      minimum: 30,
                      maximum: 42.2,
                      interval: 1,
                      showTicks: false,
                      showLabels: true,
                      showAxisTrack: true,
                      minorTicksPerInterval: 4,
                      useRangeColorForAxis: true,
                      animateAxis: true,
                      axisTrackStyle: LinearAxisTrackStyle(thickness: 40),
                      axisLabelStyle: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 15,),
                      
                      ranges: <LinearGaugeRange>[
                        LinearGaugeRange(

                            startValue: 10,
                            endValue: 36,
                            startWidth: 40,
                            midWidth: 40,
                            endWidth: 40,
                            position: LinearElementPosition.cross,
                            color: Color(0xEDFFC400),
                            child: Center(
                              child: Container(
                                child: Text("Lower", style: GoogleFonts.poppins(
                                   color: Color(0xFF000000),
                                  fontSize: 13.0,
                                ), textAlign: TextAlign.center,),
                              ),
                            ),
                        ),
                        LinearGaugeRange(
                            startValue: 36,
                            endValue: 37,
                            startWidth: 40,
                            midWidth: 40,
                            endWidth: 40,
                            position: LinearElementPosition.cross,
                            color: Color(0xFF00EE3B),
                            child: Center(
                              child: Container(
                                child: Text("Normal", style: GoogleFonts.poppins(
                                   color: Colors.white,
                                 fontSize: 13.0,
                                ), textAlign: TextAlign.center,),
                              ),
                            ),
                        ),
                        LinearGaugeRange(
                            startValue: 37,
                            endValue: 38,
                            startWidth: 40,
                            midWidth: 40,
                            endWidth: 40,
                            position: LinearElementPosition.cross,
                            color: Color(0xFFFD7200),
                            child: Center(
                              child: Container(
                                child: Text("Higher", style: GoogleFonts.poppins(
                                   color: Colors.white,
                                  fontSize: 13.0,
                                ), textAlign: TextAlign.center,),
                              ),
                            ),
                        ),
                        LinearGaugeRange(
                            startValue: 38,
                            endValue: 42.2,
                            startWidth: 40,
                            midWidth: 40,
                            endWidth: 40,
                            position: LinearElementPosition.cross,
                            color: Color(0xFFFD0000),
                            child: Center(
                              child: Container(
                                child: Text("Danger", style: GoogleFonts.poppins(
                                   color: Colors.white,
                                  fontSize: 13.0,
                                ), textAlign: TextAlign.center,),
                              ),
                            ),
                        ),
                      ],
                    )
                  ),

                   

                  SizedBox(height: 20),


                  InkWell(
                    onTap: (){
                      sendCommandToNodeMCU("Temperature");
                    },
                    child: Card(
                      elevation: 3,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF301847), 
                              const Color(0xFFC10214).withOpacity(0.8)
                            ],
                            
                          ),
                          border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                        ),
                        child: Center(
                          child: Text("Measure Temperature", style: GoogleFonts.poppins(
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
                      ),
                    ),
                  ),

                      
                    
                  ],)
                )
            
              ],
            ),
          ),
        ),
      )

    );
  }
}