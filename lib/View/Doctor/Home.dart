import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;

import '../../Controller/MongoDBController.dart';
import '../Login Menu.dart';
import 'AI Chatbot/Chat Page.dart';
import 'Social/Chat.dart';
import 'Google Login.dart';
import 'Profile/Profile.dart';
import 'Report/Report.dart';

class DoctorHomePage extends StatefulWidget {

  final int? id;
  final String? name;
  final String? email;

  const DoctorHomePage({Key? key, this.id, this.name, this.email});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {

  //String name = "", email = "";
  
  /* Future<void> getProfile () async {
    WebRequestController req = WebRequestController(
      path: "doctor/findDoctor/${widget.id}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          name = data["DoctorName"];
          email = data["DoctorEmail"];
        });
        
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  String name = "", email = "";
  Future<void> getProfile () async {
    
    MongoDatabase mongo = MongoDatabase();
    await mongo.open("Doctor");

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Doctor");
    var doctorData;
    for (var user in userList) {
      if (user['DoctorID'] == widget.id) {
        setState((){
          doctorData = user;
          name = doctorData["DoctorName"];
          email = doctorData["DoctorEmail"];
        });
        break;
      }
    }

  }

  String imageUrl = "images/Profile_2.png";
  late Uint8List? _images = Uint8List(0); // Default image URL

  // Default image URL
  Future<void> fetchProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8000/api/doctor/profileImage/${widget.id}')
    );

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
    fetchProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /**
       * SIDEBAR
       */
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF301847), Color(0xFFC10214)
              ],
            )
          ),
          padding:  const EdgeInsets.only(
            left: 10.0, top: 30
          ),
          child:  Column(
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Container(
                    // 50% of the screen
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: _images != null
                          ? DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(_images!)
                      )
                          : DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(imageUrl)
                      ),
                      shape: BoxShape.circle,
                      
                    ),
                  ),

                  const SizedBox(width: 5), 

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text(name, style: GoogleFonts.poppins(
                          fontSize: 15.0, fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),

                      Text(email, style: GoogleFonts.poppins(
                          fontSize: 12.0, color: Colors.white
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
                    builder: (context) => DoctorProfile(id: widget.id ?? 0)
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
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DoctorChat(id: widget.id,))
                  );
                },
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

              /* InkWell(
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
              ), */

              //const SizedBox(height: 15,),

              InkWell(
                onTap:(){
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => Report()
                    )
                  );
                },
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.book, size: 30, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("Report", style: GoogleFonts.poppins(
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

              const SizedBox(height: 10),

              InkWell(
                onTap:()async {
                  
                  ArtDialogResponse response = await ArtSweetAlert.show(
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                      
                      customColumns: [
                        GradientText(
                          "Logout Confirmation",
                          style: GoogleFonts.poppins(
                              fontSize: 22.0, fontWeight: FontWeight.bold
                          ),
                          colors: [
                              Color(0xFF301847), Color(0xFFC10214)
                          ],
                        ),

                        SizedBox(height: 10),

                        Text("Are you confirm to log out?", style: GoogleFonts.poppins(
                            fontSize: 16.0,
                          )
                        ),

                        SizedBox(height: 20),
                      ],
                      showCancelBtn: true,
                      cancelButtonText: "No",
                      confirmButtonText: "Yes",
                      confirmButtonColor: Colors.orange.shade400,
                      
                    ),
                  );



                  if(response.isTapConfirmButton) {
                    OneSignal.logout();
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('loggedUserId');
                    await prefs.remove('usertype');
                    
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => LoginMenu())
                    );

                    await GoogleLogin.logout();
                  }

                  if(response.isTapDenyButton) {
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.info,
                        title: "Changes are not saved!"
                      )
                    );
                    return;
                  }
                },
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [

                      const Icon(Icons.logout, size: 30, color: Colors.white,),

                      const SizedBox(width: 20,),
                      
                      Text("Log out", style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),

              const Spacer(),

              Image.asset(
                "images/logo.png", 
                height: 80, 
                width: MediaQuery.of(context).size.width * 0.4,
                color: Colors.white
              ),

              SizedBox(height: 50),
              
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
          height: 50, width: 120,
          color: Colors.white
        ),


        /**
         * Notification button
         */
        /* actions: [
          IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.notifications_outlined, color: Colors.white)
          )
        ], */

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

      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: ()async {
          // Simulate a time-consuming task
          await Future.delayed(Duration(seconds: 1));
          getProfile();
          fetchProfileImage();
        },
        child: Container(
          color: Colors.grey.shade300,
          height: double.maxFinite,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [

              InkWell(
                onTap: () => Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => DoctorProfile(id: widget.id ?? 0)
                  )
                ),
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
                    child: ListTile(
                      leading: Container(
                          // 50% of the screen
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.height * 0.15,
                          decoration: BoxDecoration(
                            image: _images != null
                                ? DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(_images!)
                            )
                                : DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(imageUrl)
                            ),
                            shape: BoxShape.circle,
                            
                          ),
                        ),

                        title: Text("Welcome!", style: GoogleFonts.poppins(
                            fontSize: 15.0,
                          )
                        ),
                    
                        subtitle: GradientText(
                            'Dr ${name}',
                            style: GoogleFonts.poppins(
                                fontSize: 18.0, fontWeight: FontWeight.bold
                            ),
                            colors: [
                                Color(0xFF301847), Color(0xFFC10214)
                            ],
                        ),
                      
                        trailing: GradientIcon(
                            offset: Offset(0, -2),
                            icon: Icons.local_hospital_outlined,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF301847), Color(0xFFC10214)
                              ],
                            ),
                            size: 50,
                          )
                        ),
                      ),
                    ),
                  ),

              
        
              SizedBox(height: 15),
        
              Expanded(
                child: GridView.count(
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  crossAxisCount: 2,
                  children: [
                    
                    /* InkWell(
                      onTap: (){
                        
                      },
                      child: Card(
                        elevation: 3,
                        child: Container(
                          decoration: BoxDecoration(
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
                            ),
                            gradient: LinearGradient(
                              colors: [
                                  Color(0xFFFF4081), Color(0xFFFFC5D8), 
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("images/Doctor.png", height: MediaQuery.of(context).size.width * 0.3),
                                  GradientText(
                                    "Body Status",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.0, fontWeight: FontWeight.w600
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ), */
        
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DoctorChat(id: widget.id,))
                        );
                      },
                      child: Card(
                        elevation: 3,
                        child: Container(
                          padding: const EdgeInsets.all(8),
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
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF4081), Color(0xFFFFC5D8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("images/Chat_2.png", height: MediaQuery.of(context).size.width * 0.25),
                                  GradientText(
                                    "Chat",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.0, fontWeight: FontWeight.w600
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (context) => Report()
                          )
                        );
                      },
                      child: Card(
                        elevation: 3,
                        child: Container(
                          padding: const EdgeInsets.all(8),
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
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF7F50), Color(0xFFFCCCBB)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("images/report.png", height: MediaQuery.of(context).size.width * 0.25),
                                  GradientText(
                                    "Report",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.0, fontWeight: FontWeight.w600
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => DocAIChatPage()
                        )
                      ),
                      child: Card(
                        elevation: 3,
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
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF7F50), Color(0xFFFCCCBB)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("images/Chat with bot.png", height: MediaQuery.of(context).size.width * 0.25),
                                  GradientText(
                                    "Chat with AI",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.0, fontWeight: FontWeight.w600
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        
                  ],
                ),
              ),
        
              SizedBox(height: 25),
        
              InkWell(
                onTap:() async {
                  
                  ArtDialogResponse response = await ArtSweetAlert.show(
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                      
                      customColumns: [
                        GradientText(
                          "Logout Confirmation",
                          style: GoogleFonts.poppins(
                              fontSize: 22.0, fontWeight: FontWeight.bold
                          ),
                          colors: [
                              Color(0xFF301847), Color(0xFFC10214)
                          ],
                        ),

                        SizedBox(height: 10),

                        Text("Are you confirm to log out?", style: GoogleFonts.poppins(
                            fontSize: 16.0,
                          )
                        ),

                        SizedBox(height: 20),
                      ],
                      showCancelBtn: true,
                      cancelButtonText: "No",
                      confirmButtonText: "Yes",
                      confirmButtonColor: Colors.orange.shade400,
                      
                    ),
                  );



                  if(response.isTapConfirmButton) {
                    OneSignal.logout();
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('loggedUserId');
                    await prefs.remove('usertype');
                     await GoogleLogin.logout();
                    
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => LoginMenu())
                    );

                    await GoogleLogin.logout();
                  }

                  if(response.isTapDenyButton) {
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.info,
                        title: "Changes are not saved!"
                      )
                    );
                    return;
                  }
                },
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

               const SizedBox(height: 60.0),
        

            ],
          )
        ),
      ),
    );
  }
}