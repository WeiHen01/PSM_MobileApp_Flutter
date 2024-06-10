import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TempMeasure extends StatefulWidget {

  final int? id;
  const TempMeasure({super.key, this.id});

  @override
  State<TempMeasure> createState() => _TempMeasureState();
}

class _TempMeasureState extends State<TempMeasure> {

  final String nodeMCUIP = '192.168.101.226';

  Future<void> sendCommandToNodeMCU(String command) async {

    Map<String, dynamic> body = {'cmd': command, 'PatientID': 'P-${widget.id}' };
    
    try {
      final response = await http.get(Uri.http('$nodeMCUIP', '/command', body));
      // handle the response here
    } catch (e) {
      print('Error sending command to NodeMCU: $e');
    }
  }

  var tempReceived;

  Future<void> _getRecordedData() async {
    final url = 'http://$nodeMCUIP/command'; // Replace with the correct URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Parse the response body to extract the recorded data
      // For example, if the response body is a JSON string:
      final jsonData = jsonDecode(responseBody);
      final temp = jsonData['temperature'];

      // Update the UI with the recorded data
      setState(() {
        tempReceived = temp;
      });
    } else {
      print('Failed to retrieve recorded data');
    }
  }

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
          fontSize: 20.0
        ),),

        

      ),

      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 100, bottom: 100),
        color: Colors.grey.shade300,
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
                        value: 95, needleColor: Colors.black,
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

            SizedBox(height: 80),

            Text("Record", style: GoogleFonts.poppins(
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
            
            Spacer(),
            
            InkWell(
              onTap: (){
                sendCommandToNodeMCU("Temperature");
                _getRecordedData();
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.orangeAccent
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

          ],
        ),
      )

    );
  }
}