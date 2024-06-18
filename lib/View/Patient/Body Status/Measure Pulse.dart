import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../Controller/MongoDBController.dart';
import '../../../Model/Heart Pulse.dart';
import '../../Widget/Patient/Custom Loading Popup.dart';

class PulseMeasure extends StatefulWidget {
  
  final int? id;
  const PulseMeasure({super.key, this.id});

  @override
  State<PulseMeasure> createState() => _PulseMeasureState();
}

class _PulseMeasureState extends State<PulseMeasure> {

  //IP based on NodeMCU
  //final String nodeMCUIP = '192.168.115.102';

  int latestPulseRecord = 0;
  late List<Pulse> pulses = [];

  Future<void> sendCommandToNodeMCU(String command) async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? server = await prefs.getString("localhost");

    
    String? nodeMCUIP = await prefs.getString("nodeMCU");

    Map<String, dynamic> body = {'cmd': command, 'IP' : server, 'PatientID': 'P-${widget.id}' };
    
    try {
      LoadingScreen.show(context, "Please place your finger while measuring..");
      Future.delayed(Duration(seconds: 10), () {
        // 5s over, navigate to a new page
        LoadingScreen.hide(context);
      });

      final response = await http.get(Uri.http('$nodeMCUIP', '/command', body));

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
            pulseReceived = latestPulseRecord;
          });
        }

      } catch (e, printStack) {
        print('Error fetching other pulses : $e');
        print(printStack);
        // Handle the exception as needed, for example, show an error message to the user
      }

      // handle the response here
    } catch (e) {
      print('Error sending command to NodeMCU: $e');
    }
  }

  var pulseReceived;

  

  String? pulse;


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

        title: Text("Measure Pulse", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 18.0
        ),),

      
      ),

      body: RefreshIndicator(
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
                      minimum: 0,
                      maximum: 200,
                      interval: 10,
                      startAngle: 115,
                      endAngle: 65,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: 200,
                            startWidth: 0.1,
                            sizeUnit: GaugeSizeUnit.factor,
                            endWidth: 0.1,
                            gradient: SweepGradient(stops: <double>[
                              0.2,
                              0.5,
                              0.95
                            ], colors: <Color>[
                              Colors.green,
                              Colors.yellow,
                              Colors.red
                            ]))
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                            value: pulseReceived?.toDouble() ?? 0, needleColor: Colors.black,
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
                              'BPM',
                              style:
                              GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            positionFactor: 0.6,
                            angle: 90)
                      ],
                    ),
                  ],
                ),
            
            
                Text("${pulseReceived == null ? "" : '$pulseReceived BPM'}", style: GoogleFonts.poppins(
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
            
                InkWell(
                  onTap: (){
                    sendCommandToNodeMCU("Pulse");
                    //_getRecordedData();
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
                      ),
                      child: Center(
                        child: Text("Measure", style: GoogleFonts.poppins(
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
            
                    
                
              ],
            ),
          ),
        ),
      )

    );
  }
}