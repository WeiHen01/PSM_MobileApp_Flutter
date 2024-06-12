import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import './View/Widget/Onboarding%20Screen/Onboarding.dart';
import 'Controller/MongoDBController.dart';
import 'View/Doctor/Home.dart';
import 'View/Login%20Menu.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'View/Patient/Home.dart';
import 'View/Register Menu.dart';

void main(){
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("ae3fc8cd-0f1e-4568-a8cc-7172abe05ae3");

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.white, // Background color of the status bar
      statusBarIconBrightness: Brightness.dark, // Brightness of status bar icons
    ));
    return MaterialApp(
      title: 'EpiHealth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange, backgroundColor: Colors.white,
          accentColor: Colors.white,
          errorColor: Colors.red
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {

  final Socket? socket; 

  const SplashScreen({super.key, this.socket});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  MongoDatabase mongo = MongoDatabase();

  Future<void> openDatabase(String collection) async {
    try {
      await mongo.open(collection);
      // Perform any other initialization after opening the database
    } catch (e) {
      // Handle any errors
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(Duration(seconds: 3), () async
    {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // 10.131.78.79
      // 192.168.109.212
      // 192.168.101.212
      // 10.0.2.2
      // 192.168.8.119
      await prefs.setString("localhost", "192.168.171.212");
      int? userID = await prefs.getInt("loggedUserId");
      String? usertype = await prefs.getString("usertype");

      print('$userID ,  $usertype');

      if(usertype == "Patient"){
        openDatabase("Patient");
        Navigator.push(context, 
          MaterialPageRoute(builder: (context) => PatientHomePage(id: userID, socket: widget.socket,))
        );
      }
      else if(usertype == "Doctor"){
        openDatabase("Doctor");
        Navigator.push(context, 
          MaterialPageRoute(builder: (context)=> DoctorHomePage(id: userID))
        );
      }
      else {
        Navigator.push(context, 
          MaterialPageRoute(builder: (context)=> OnBoardingScreen(socket: widget.socket,))
        );
      }
      
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.maxFinite,
        padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            // Linear gradient for background
            gradient: LinearGradient(
              //determine the direction and angle of each color stop in gradient
              begin: Alignment.topRight,
              end: Alignment.bottomRight,

              //0xFF is needed to convert RGB Hex code to int value
              // Hex code here is 29539B and 1E3B70
              // Gradient Name: Unloved Teen
              colors: [
                Color(0xFF301847).withOpacity(0.5), Color(0xFFC10214).withOpacity(0.5)
              ],
            )
          ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            
                Image.asset(
                    'images/blood.png'),
               
                Text("A healthy outside starts from the inside. - Robert Urich",
                style: GoogleFonts.poppins(
                    fontSize: 23, fontWeight: FontWeight.w500,
                    color: Colors.white,)
                ),

            
                SizedBox(height: 150),
            
                Container(
                  width: 60.0, // Adjust width as needed
                  height: 60.0, // Adjust height as needed
                  child: CircularProgressIndicator(
                    color: const Color(0xFFFF4081),
                    strokeWidth: 10.0,
                  ),
                ),

                SizedBox(height: 30),
            
            
            
                // Add a fixed space if needed
            
            
              ],
            ),
          ),
        ),
      ),
    );
  }
}





class OnBoardingScreen extends StatefulWidget {

  final Socket? socket;
  const OnBoardingScreen({super.key, this.socket});

  @override
  State<OnBoardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnBoardingScreen> {
  
  final controller = OnboardingData();
  final pageController = PageController();
  int currentIndex = 0;

  Socket? passSocket;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    setState(() {
      passSocket = widget.socket;
    });
  }

  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/Splash_screen_blank.png"),
            fit: BoxFit.cover,
          )
        ),
        child: Column(
          children: [
            body(),
            buildDots(),
            button(),
          ],
        ),
      )

      
    );
  }

  //Body
  Widget body(){
    return Expanded(
      child: Center(
        child: PageView.builder(
            onPageChanged: (value){
              setState(() {
                currentIndex = value;
              });
            },
            itemCount: controller.items.length,
            itemBuilder: (context,index){
             return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
               child: Center(
                 child: SingleChildScrollView(
                   child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                      
                       //Images
                       Image.asset(controller.items[currentIndex].image),
                   
                       const SizedBox(height: 15),
                       //Titles
                       Text(controller.items[currentIndex].title,
                         style: GoogleFonts.poppins(
                          fontSize: 30, color: Color(0xFFFF7F50),
                          fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                   
                       //Description
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                         child: Text(controller.items[currentIndex].description,
                           style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 18),
                            textAlign: TextAlign.justify,
                          ),
                       ),
                   
                     ],
                   ),
                 ),
               ),
             );
        }),
      ),
    );
  }

  //Dots
  Widget buildDots(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.items.length, (index) => AnimatedContainer(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration:   BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: currentIndex == index? Color(0xFFFF7F50) : Colors.white,
          ),
          height: 15,
          width: currentIndex == index? 60 : 15,
          duration: const Duration(milliseconds: 700))),
    );
  }

   //Button
  Widget button(){
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15, bottom: 5),
          width: MediaQuery.of(context).size.width *.9,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFFFF7F50)
          ),
        
          child: TextButton(
            onPressed: (){
              setState(() {
                currentIndex != controller.items.length -1
                ? currentIndex++ 
                : Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => const RegisterMenu(),
                    )
                  );
              });
            },
            child: Text(currentIndex == controller.items.length -1? "Get started" : "Continue",
              style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 20,
                fontWeight: currentIndex == controller.items.length -1 ? FontWeight.bold : FontWeight.normal
              )
            ),
          ),
        ),

        Visibility(
          visible: currentIndex == controller.items.length - 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already Have an Account?",
                style: GoogleFonts.poppins(
                  color: Color(0xFFFF7F50),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          
              TextButton(
                onPressed: () {
                  // Navigate to the login screen
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => LoginMenu(socket: passSocket,),
                    )
                  );
                },
                child: Text(
                  "Login here",
                  style: GoogleFonts.poppins(
                    color: Color(0xFFFF7F50),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),


        SizedBox(height: 50),
      ],
    );
  }


}

