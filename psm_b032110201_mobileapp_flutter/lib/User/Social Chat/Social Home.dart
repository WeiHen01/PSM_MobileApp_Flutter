import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psm_b032110201_mobileapp_flutter/User/Social%20Chat/Other%20User%20Profile.dart';

// Social Homepage

class SocialHome extends StatefulWidget {
  const SocialHome({super.key});

  @override
  State<SocialHome> createState() => _SocialHomeState();
}

class _SocialHomeState extends State<SocialHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text("Social", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, 
          fontSize: 20.0
        ),),

        actions: [

          // Notifications
          IconButton(
            onPressed: (){}, 
            icon: const Icon(Icons.notifications)
          ),

          // Chat button
          IconButton(
            onPressed: (){}, 
            icon: const Icon(Icons.chat_rounded)
          ),
        ],

      ),

      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            /**
             * User Story Start
             */
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),

                    Text("Username", style: GoogleFonts.poppins(
                      fontSize: 16.0
                    ),),
                  ],
                ),

                const SizedBox(width: 5.0),

                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),

                    Text("Username", style: GoogleFonts.poppins(
                      fontSize: 16.0
                    ),),
                  ],
                ),

                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),

                    Text("Username", style: GoogleFonts.poppins(
                      fontSize: 16.0
                    ),),
                  ],
                ),
              ],
            ),

            // User Story Ends

            const Divider(),

            /**
             * USER POST
             */
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                  
                      /**
                       * User Profile Image
                       */
                  
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                  
                      const SizedBox(width: 5.0),
                  
                      /**
                       * Username with post upload timestamp
                       */
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context, MaterialPageRoute(
                                  builder: (context) => const OtherUserProfile()
                                )
                              );
                            },
                            child: Text("Username", style: GoogleFonts.poppins(
                                fontSize: 16.0, fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                          ),
                  
                          Text("25 minutes ago", style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: Colors.black
                            ),
                          ),
                  
                  
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  /**
                   * User Post Description
                   */
                  Text("25 minutes ago", style: GoogleFonts.poppins(
                      fontSize: 20.0,
                      color: Colors.black
                    ), textAlign: TextAlign.justify,
                  ),
                  // User Post Image Ends

                  const SizedBox(height: 10.0),

                  /**
                   * User Post Image
                   */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.blue,
                    ),
                  ),
                  // User Post Image Ends


                  /**
                   * Like, Comment and Share Button
                   */
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    color: Color.fromARGB(255, 233, 233, 233),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        
                        GestureDetector(
                          onTap: (){}, 
                          child: Row(
                            children: [
                              const Icon(Icons.thumb_up_outlined),
                    
                              const SizedBox(width: 5.0),
                    
                              Text("Like", style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ), textAlign: TextAlign.justify,
                              ),
                    
                            ],
                          )
                        ),

                        const VerticalDivider(
                          color: Color(0xFF555555),
                        ),
                    
                        GestureDetector(
                          onTap: (){}, 
                          child: Row(
                            children: [
                              const Icon(Icons.comment_outlined),
                    
                              const SizedBox(width: 5.0),
                    
                              Text("Comment", style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ), textAlign: TextAlign.justify,
                              ),
                    
                            ],
                          )
                        ),

                        const VerticalDivider(
                          color: Color(0xFF555555),
                        ),
                    
                        GestureDetector(
                          onTap: (){}, 
                          child: Row(
                            children: [
                              const Icon(Icons.ios_share),
                    
                              const SizedBox(width: 5.0),
                    
                              Text("Share", style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ), textAlign: TextAlign.justify,
                              ),
                    
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  // Like, Comment and Share Button Ends


                ],
              ),
            )


          ],

        ),
      ),
    );
  }
}