import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'View/Login%20Menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15.0),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/Splash_screen_1.png'),
            fit: BoxFit.cover, // Adjust this based on your needs
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello", style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 30,
              fontWeight: FontWeight.bold,
            ),),

            const SizedBox(height: 10.0),

            ElevatedButton(
              child: Text("Go to Login",),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => LoginMenu()
                )
              )
            ),


            
          ],
        ),
      ),
    );
  }
}

