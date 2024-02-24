import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psm_b032110201_mobileapp_flutter/User/Home.dart';
import 'package:psm_b032110201_mobileapp_flutter/main.dart';

class LoginMenu extends StatelessWidget {
  const LoginMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red, Colors.indigo.shade400
            ]
          )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Are you a?", style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 25
              )),
          
              const SizedBox(height: 15.0),
          
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(
                          builder: (context) => UserHomePage()
                        )
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.teal[100],
                        child: const Text("Go to Home Page"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(
                          builder: (context) => SplashScreen()
                        )
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.teal[200],
                        child: const Text('Back'),
                      ),
                    ),
                  ]
                ),
              )
          
            ],
          ),
        )
      )
    );
  }
}