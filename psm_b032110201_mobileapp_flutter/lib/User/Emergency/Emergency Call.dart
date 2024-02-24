import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyCall extends StatefulWidget {
  const EmergencyCall({super.key});

  @override
  State<EmergencyCall> createState() => _EmergencyCallState();
}

class _EmergencyCallState extends State<EmergencyCall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Stack(
        children: [
          // Lowest layer
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Are you in emergency?", style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 25.0, 
                      fontWeight: FontWeight.bold
                    )
                ),
                  
                SizedBox(height: 20.0),
                  
                Text("Press the button below will reach you soon", style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 15.0, 
                    )
                ),
                  
                  
              ],
            ),
          ),
      
      
          // Top most layer
          Positioned(
            bottom: 50,
            left: 0,
            child: Card(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  children: [
                     /**
                       * User Profile Image
                       */
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 8.0),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Text("Your current address", style: GoogleFonts.poppins(
                            color: Colors.black, fontWeight: FontWeight.bold,
                            fontSize: 15.0, 
                          )
                        ),

                        Text("Location name", style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 15.0, 
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              )
            )
          )
        ],
      )
    );
  }
}