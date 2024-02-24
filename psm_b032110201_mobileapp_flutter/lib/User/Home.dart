import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Emergency/Emergency Call.dart';
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
      drawer: Drawer(),
      appBar: AppBar(

        /**
         * Sidebar
         */
        leading: IconButton(
          onPressed: (){}, 
          icon: Icon(Icons.menu)
        ),

        

        /**
         * Application Logo
         */
        title: Row(
          children: [
            Text("Epi", style: GoogleFonts.arbutus(
              color: Color(0xffC12126),    
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
            icon: Icon(Icons.notifications_outlined)
          )
        ],
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
                    onTap: () {},
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
              onTap:(){},
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