import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PulseDashboard extends StatefulWidget {
  final int? id;
  const PulseDashboard({super.key, this.id});

  @override
  State<PulseDashboard> createState() => _PulseDashboardState();
}

class _PulseDashboardState extends State<PulseDashboard> {
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
    );
  }
}