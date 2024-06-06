import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PressureHistory extends StatefulWidget {
  const PressureHistory({super.key});

  @override
  State<PressureHistory> createState() => _PressureHistoryState();
}

class _PressureHistoryState extends State<PressureHistory> {
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

        title: Text("Blood Pressure", style: GoogleFonts.poppins(
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
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("History", style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black,
                  fontSize: 20.0
                ),),
              ),

              Expanded(
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 15); // Adjust the height as needed
                  },
                  itemCount: 5,
                  itemBuilder: (context, index){
                    return InkWell(
                      onLongPress: (){
                        
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            offset: Offset(2, 2),
                            spreadRadius: 1.0,
                            blurRadius: 2.0,
                          )
                        ]
                      ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Date Time", style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12.0
                                ),),
                      
                                Spacer(),
                      
                                Text("Location", style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12.0
                                ),),
                                            
                                
                              ],
                            ),
                      
                            SizedBox(height: 15),
                                            
                                            
                            Row(
                              children: [
                                Text("Pressure Record", style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, color: Colors.black,
                                  fontSize: 20.0
                                ),),
                                            
                                SizedBox(width: 10),
                                            
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("°C", style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold, color: Colors.black,
                                      fontSize: 10
                                    ),),
                                            
                                    Text("Degree Celsius", style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 10
                                    ),),
                                  ],
                                )
                              ],
                            ),
                                            
                            
                                            
                                            
                          ],
                        ),
                      ),
                    );
                  }
                
                ),
              ),
            ],
          )
        )
      )
    );
  }
}