import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psm_b032110201_mobileapp_flutter/View/Doctor/Register.dart';
import 'package:psm_b032110201_mobileapp_flutter/View/User/Register.dart';

import 'Login Menu.dart';

class RegisterMenu extends StatelessWidget {
  const RegisterMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF301847), Color(0xFFC10214)
            ],
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Register as?", style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 25
            )),
        
            const SizedBox(height: 15.0),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(
                      builder: (context) => UserRegister()
                    )
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    height: MediaQuery.of(context).size.width / 2.3,
                    padding: EdgeInsets.all(15),
                    color: Colors.teal[200],
                    child: const Text('Sign Up as User'),
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(
                      builder: (context) => DoctorRegister()
                    )
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    height: MediaQuery.of(context).size.width / 2.3,
                    padding: EdgeInsets.all(15),
                    color: Colors.teal[200],
                    child: const Text('Sign Up as Doctor'),
                  ),
                )
              ],
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(
                  builder: (context) => LoginMenu()
                )
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                padding: EdgeInsets.all(15),
                color: Colors.teal[200],
                child: const Text('Go to Login'),
              ),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                padding: EdgeInsets.all(15),
                color: Colors.teal[200],
                child: const Text('Back'),
              ),
            ),

        
          ],
        )
      )
    );
  }
}