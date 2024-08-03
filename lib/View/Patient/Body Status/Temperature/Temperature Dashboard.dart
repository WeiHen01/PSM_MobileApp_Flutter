import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TempDashboard extends StatefulWidget {
  final int? id;
  const TempDashboard({super.key, this.id});

  @override
  State<TempDashboard> createState() => _TempDashboardState();
}

class _TempDashboardState extends State<TempDashboard> {

  final List<bool> _selectedDays = <bool>[true, false, false];
  bool vertical = false;
  
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

              SizedBox(height: 30),

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
                          Text("Celsius", style: GoogleFonts.poppins(
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
                      height: MediaQuery.sizeOf(context).width / 3.5,
                      width: MediaQuery.sizeOf(context).width / 2.5,
                      
                      child: Column(
                        children: [
                          Text("Fahrenheit", style: GoogleFonts.poppins(
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

              

          
              
            ],
          ),
        )
      )
    );
  }
}