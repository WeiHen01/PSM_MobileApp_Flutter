import 'dart:io';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;

import '../../Controller/Request Controller.dart';
import '../../Controller/MongoDBController.dart';
import '../Doctor/Google Login.dart';
import '../Login Menu.dart';
import '../Widget/Patient/Chat NavBar.dart';
import '../Widget/Patient/Emergency Call NavBar.dart';
import 'Body Status/Body Home.dart';
import 'ChatGPT bot/Chat Page.dart';
import 'Emergency/Emergency Call.dart';
import 'Profile/Profile.dart';


class PatientHomePage extends StatefulWidget {

  final int? id;
  final Socket? socket;

  PatientHomePage({Key? key, this.id, this.socket});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {

  String name = "", email = "";
  
  Future<void> getProfile() async {
    MongoDatabase mongo = MongoDatabase();
    await mongo.open("Patient");

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Patient");
    var patientData;
    for (var user in userList) {
      if (user['PatientID'] == widget.id) {
        setState((){
          patientData = user;
          name = patientData["PatientName"];
          email = patientData["PatientEmail"];
        });
        break;
      }
    }

  }


  /* String name = "", email = "";
  
  Future<void> getProfile () async {
    WebRequestController req = WebRequestController(
      path: "patient/findPatient/${widget.id}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          name = data["PatientName"];
          email = data["PatientEmail"];
        });
        
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
    fetchProfileImage();
  }

  String imageUrl = "images/Profile_2.png";
  late Uint8List? _images = Uint8List(0); // Default image URL

  // Default image URL
  Future<void> fetchProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8000/api/patient/profileImage/${widget.id}')
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
  Widget build(BuildContext context) {
    return Scaffold(

      /**
       * SIDEBAR
       */
      drawer: Drawer(
        child: Container(
          decoration:  BoxDecoration(
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
            mainAxisAlignment: MainAxisAlignment.start,
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
                  

                  const SizedBox(width: 15), 

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
                onTap: () => Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => PatientProfile(id: widget.id ?? 0),
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
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => BodyHome(socket: widget.socket, id: widget.id),
                    )
                  );
                },
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
                onTap:() => Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => ChatNav(tabIndexes: 0, patientID: widget.id,)
                  )
                ),
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
                onTap:(){
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => ChatNav(tabIndexes: 1, patientID: widget.id,)
                    )
                  );
                },
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

              const SizedBox(height: 15,),

              

              const Divider(
                thickness: 1.0,
                color: Colors.white,
                endIndent: 10,
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap:()async{

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

              Spacer(),

              Image.asset(
                "images/logo.png", 
                height: 70, 
                width: MediaQuery.of(context).size.width * 0.3,
                color: Colors.white
              ),

              SizedBox(height: 50),
            ],
          )

        ),
      ),
      extendBody: true,
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



        title: Image.asset(
          "images/logo.png", 
          height: 50, width: 120,
          color: Colors.white
        ),


        /* /**
         * Notification button
         */
        actions: [
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
          padding: EdgeInsets.all(15.0),
          color: Colors.grey.shade300,
          height: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              InkWell(
                onTap: () => Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => PatientProfile(id: widget.id ?? 0),
                  )
                ),
                child: Card(
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                          name,
                          style: GoogleFonts.poppins(
                              fontSize: 25.0, fontWeight: FontWeight.bold
                          ),
                          colors: [
                              Color(0xFF301847), Color(0xFFC10214)
                          ],
                      ),
                    
                      trailing: const GradientIcon(
                        offset: Offset(0, -2),
                        icon:Icons.person,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF301847), Color(0xFFC10214)
                          ],
                        ),
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
        
              
        
              Divider(
                thickness: 2.0,
                color: Colors.black,
              ),
        
              SizedBox(height: 15.0),
        
              Expanded(
                child: GridView.count(// Set shrinkWrap to true
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  crossAxisCount: 2,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    
                    InkWell(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => BodyHome(socket: widget.socket, id: widget.id),
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
                                  Image.asset("images/Patient_02.png", height: MediaQuery.of(context).size.width * 0.25),
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
                    ),
                        
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => ChatNav(tabIndexes: 0, patientID: widget.id,)
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
                                  Image.asset("images/Social_2.png", height: MediaQuery.of(context).size.width * 0.25),
                                  GradientText(
                                    "Social Chat",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.0, fontWeight: FontWeight.w600
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214),
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
                          builder: (context) => AIChatPage()
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
                        
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => EmergencyNav(patientID: widget.id, tabIndexes: 0,)
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
                                  Image.asset("images/call.png", height: MediaQuery.of(context).size.width * 0.25),
                                  GradientText(
                                    "Emergency",
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
        
              const SizedBox(height: 20.0),
        
              InkWell(
                onTap:() async{

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
          ),
        
        ),
      )
    );
  }
}
