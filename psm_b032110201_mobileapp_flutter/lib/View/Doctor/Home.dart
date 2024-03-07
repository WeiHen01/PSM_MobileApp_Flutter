import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../User/Home.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
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
                    //backgroundImage
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
                onTap:(){},
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

              Spacer(),

              Image.asset(
                "images/logo.png", 
                height: 80, 
                width: MediaQuery.of(context).size.width * 0.4,
                color: Colors.white
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
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        ),

        title: Image.asset(
          "images/logo.png", 
          height: 50, width: 150,
          color: Colors.white
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            InkWell(
              onTap: null,
              child: Card(
                elevation: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    border: GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF301847), Color(0xFFC10214)
                        ]
                      ),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    )
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // 50% of the screen
                        width: MediaQuery.of(context).size.width * 0.14,
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
              
                          GradientText(
                              'NG WEI HEN',
                              style: GoogleFonts.poppins(
                                  fontSize: 25.0, fontWeight: FontWeight.bold
                              ),
                              colors: [
                                  Color(0xFF301847), Color(0xFFC10214)
                              ],
                          ),
                        ],
                      ),

                      const Spacer(),

                  
                    ],
                  ),
                ),
              ),
            ),

            InkWell(
              onTap:()=>Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => UserHomePage()
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
        )
      ),
    );
  }
}