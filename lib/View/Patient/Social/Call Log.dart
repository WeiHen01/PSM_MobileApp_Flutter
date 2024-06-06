import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallLog extends StatefulWidget {
  const CallLog({super.key});

  @override
  State<CallLog> createState() => _CallLogState();
}

class _CallLogState extends State<CallLog> {
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


        title: Text("Chat", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),

      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text("Call Log", style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15.0
            ),),
          ],
        ),
      ),
    );
  }
}