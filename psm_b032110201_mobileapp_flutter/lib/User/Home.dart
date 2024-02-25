import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Doctor/Home.dart';
import '../main.dart';
import 'Emergency/Emergency Call.dart';
import 'Profile/Profile.dart';
import 'Social/Social Home.dart';


class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /**
       * SIDEBAR
       */
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF301847), Color(0xFFC10214)
              ]
            )
          ),
          padding:  const EdgeInsets.only(
            left: 10.0, top: 60.0
          ),
          child:  Column(
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  const CircleAvatar(
                    radius: 25,
                    //backgroundImage: 
                  ),

                  const SizedBox(width: 15), 

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text("User Name", style: GoogleFonts.poppins(
                          fontSize: 20.0, fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),

                      Text("Email", style: GoogleFonts.poppins(
                          fontSize: 15.0, color: Colors.white
                        ),
                      ),

                    ],
                  )

                ],
              ),

              const SizedBox(height: 10),

              const Divider(
                thickness: 2.0,
                color: Colors.white,
                endIndent: 10,
              ),

              const SizedBox(height: 10),

              

              InkWell(
                onTap:() => Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => UserProfile()
                  )
                ),
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, size: 30, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("My Account", style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),

              

              const SizedBox(height: 10),

              const Divider(
                thickness: 1.0,
                color: Colors.white,
                endIndent: 10,
              ),

              const SizedBox(height: 15,),

              InkWell(
                onTap:(){},
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.stacked_line_chart, size: 30, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("Body Status", style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15,),

              InkWell(
                onTap:(){},
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.chat, size: 30, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("Chats", style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15,),

              InkWell(
                onTap:(){},
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.forum, size: 30, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("Social", style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15,),

              InkWell(
                onTap:(){},
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [

                      const FaIcon(FontAwesomeIcons.stethoscope, size: 28, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("Chat with Doctor", style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          )

        ),
      ),

      appBar: AppBar(

        /**
         * Application Logo
         */
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        ),



        title: Row(
          children: [
            Text("Epi", style: GoogleFonts.arbutus(
              color: Color.fromARGB(255, 255, 255, 255),    
             )
            ),

            Text("Health", style: GoogleFonts.arbutus(
              color: Color(0xff1000FF),    
             )
            ),
          ],
        ),


        /**
         * Notification button
         */
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.notifications_outlined, color: Colors.white)
          )
        ],

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: Colors.white,
            );
          }
        ),
      ),

      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [

            Card(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // 50% of the screen
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                
                    const SizedBox(width: 10.0,),
                
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back!", style: GoogleFonts.poppins(
                            fontSize: 15.0,
                          )
                        ),
                
                
                        Text("NG WEI HEN", style: GoogleFonts.poppins(
                            fontSize: 25.0, fontWeight: FontWeight.bold
                          )
                        ),
                      ],
                    ),
                
                  ],
                ),
              ),
            ),

            Divider(
              thickness: 2.0,
              color: Colors.black,
            ),

            SizedBox(height: 15.0),

            Expanded(
              child: GridView.count(
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                crossAxisCount: 2,
                children: [
                  
                  InkWell(
                    onTap: (){},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: const Text("Body Status"),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => SocialHome()
                      )
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[200],
                      child: const Text('Social'),
                    ),
                  ),

                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[300],
                      child: const Text('Chat with AI'),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => EmergencyCall()
                      )
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[400],
                      child: const Text('Emergency Call'),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[500],
                      child: const Text('Chat with Doctor!'),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => DoctorHomePage()
                      )
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[600],
                      child: const Text('Go to doctor page'),
                    ),
                  )
                  
                ],
              ),
            ),

            const SizedBox(height: 20.0),

            InkWell(
              onTap:()=>Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => SplashScreen()
                )
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color(0xFFCA0202),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white,),

                      const SizedBox(width: 5.0),

                      Text("Log out", style: GoogleFonts.poppins(
                         color: Colors.white,
                         fontSize: 20.0, 
                         fontWeight: FontWeight.bold
                       )
                      ),
                    ],
                  ),
                ),
              ),
            ),


          ],
        ),

      )
    );
  }
}
