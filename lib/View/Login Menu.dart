import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../main.dart';
import 'Doctor/Login.dart';
import 'Register Menu.dart';
import 'Patient/Login.dart'; 

class LoginMenu extends StatelessWidget {
  final Socket? socket; // Declare socket as a field
  const LoginMenu({super.key, this.socket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.maxFinite,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF301847), Color(0xFFC10214)
            ],
          )
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                
                Text("Choose Account Type", style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold
                )),
            
                const SizedBox(height: 25.0),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(
                          builder: (context) => PatientLogin()
                        )
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.3,
                        height: 180,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081),
                                  
                          borderRadius: const BorderRadius.all(
                           Radius.circular(10.0),
                          ),
            
                          border: Border.all(
                            width: 2,
                            color: Colors.white, // White border color
                          ),
            
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1f1f1f), // Shadow color
                              offset: Offset(0, 2), // Offset of the shadow
                              blurRadius: 4, // Spread of the shadow
                              spreadRadius: 0, // Spread radius of the shadow
                            ),
                          ],
                          
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/patient.png", height: 120, width: 120),
            
                            Spacer(),
            
                            Text("Patient", style: GoogleFonts.poppins(
                              color: Colors.black, fontSize: 18
                            )),
                          ],
                        )
                      ),
                    ),
            
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(
                          builder: (context) => DoctorLogin()
                        )
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.3,
                        height: 180,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081),
                                  
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
            
                          border: Border.all(
                            width: 2,
                            color: Colors.white, // White border color
                          ),
            
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1f1f1f), // Shadow color
                              offset: Offset(0, 2), // Offset of the shadow
                              blurRadius: 4, // Spread of the shadow
                              spreadRadius: 0, // Spread radius of the shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/Doctor_2.png", height: 120, width: 120),
            
                            Spacer(),
            
                            Text("Doctor", style: GoogleFonts.poppins(
                              color: Colors.black, fontSize: 18
                            )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
            
                const SizedBox(height: 30),
            
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(
                      builder: (context) => RegisterMenu()
                    )
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                              
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
            
                      border: GradientBoxBorder(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF301847), Color(0xFFC10214)
                          ]
                        ),
                        width: 4,
                      ),
            
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1f1f1f), // Shadow color
                          offset: Offset(0, 2), // Offset of the shadow
                          blurRadius: 4, // Spread of the shadow
                          spreadRadius: 0, // Spread radius of the shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: GradientText(
                          'Go to Register',
                          style: GoogleFonts.poppins(
                              fontSize: 20.0
                          ),
                          colors: [
                              Color(0xFF301847), Color(0xFFC10214)
                          ],
                      ),
                    
                    ),
                  ),
                ),
            
                const SizedBox(height: 15),
            
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => SplashScreen()
                      )
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF301847), Color(0xFFC10214)
                        ],
                      ),
                              
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
            
                      border: Border.all(
                        width: 2,
                        color: Colors.white, // White border color
                      ),
            
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1f1f1f), // Shadow color
                          offset: Offset(0, 2), // Offset of the shadow
                          blurRadius: 4, // Spread of the shadow
                          spreadRadius: 0, // Spread radius of the shadow
                        ),
                      ],
                    ),
                    child: Center(child: Text('Back', style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 18
                            ))),
                  ),
                ),
            
            
              ],
            ),
          ),
        )
      )
    );
  }
}