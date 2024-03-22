import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psm_b032110201_mobileapp_flutter/View/Widget/Onboarding%20Screen/Onboarding.dart';
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


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  final controller = OnboardingData();
  final pageController = PageController();
  int currentIndex = 0;
 
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
               padding: const EdgeInsets.symmetric(horizontal: 5),
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
            color: currentIndex == index? Colors.orange : Colors.grey,
          ),
          height: 15,
          width: currentIndex == index? 65 : 15,
          duration: const Duration(milliseconds: 700))),
    );
  }

   //Button
  Widget button(){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width *.9,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange
      ),

      child: TextButton(
        onPressed: (){
          setState(() {
            currentIndex != controller.items.length -1
            ? currentIndex++ 
            : Navigator.push(context, MaterialPageRoute(
                builder: (context) => const LoginMenu(),
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
    );
  }


}


