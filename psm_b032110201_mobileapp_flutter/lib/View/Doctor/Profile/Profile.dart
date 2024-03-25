import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../../Controller/Request Controller.dart';


class DoctorProfile extends StatefulWidget {

  final int? id;
  final String? name;

  DoctorProfile({Key? key, this.id, this.name});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {

   String email = "";

  Future<void> getProfile () async {
    WebRequestController req = WebRequestController(
      server: "http://10.0.2.2:8080/api/", path: "doctor/findDoctor/${widget.id}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          email = data["DoctorEmail"];
        });
        
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Your Profile", style: GoogleFonts.poppins(
            fontSize: 20.0, color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                    alignment: Alignment.topCenter,
                    fit: BoxFit.cover,
                  )
              ),
            ),
        
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
                child: Column(
        
                  children: [
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                              )
                            ),
                            child: Column(
                              children: [
                                              
                                const SizedBox(height: 40.0),
                                

                                GradientText(
                                    widget.name ?? '',
                                    style: GoogleFonts.poppins(
                                        fontSize: 25.0, fontWeight: FontWeight.bold
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                ),
                                              
                                Text(email, style: GoogleFonts.poppins(
                                    fontSize: 15.0,
                                  )
                                ),
                                              
                                const Divider(),
                                              
                                Row(
                                  children: [
                                    Text("Description", style: GoogleFonts.poppins(
                                        fontSize: 16.0,
                                      )
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20.0),
                                          
                                              
                                InkWell(
                                  onTap: null,
                                  child: Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)
                                        ),
                                              
                                        border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF301847), Color(0xFFC10214)
                                            ]
                                          ),
                                          width: 4,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.edit),

                                          const SizedBox(width: 5.0),

                                          Text("Edit This Profile", style: GoogleFonts.poppins(
                                              fontSize: 16.0, color: Colors.black,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                        ],
                                      )
                                    ),
                                  )
                                ),
                                              
                                
                                              
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
              
                    const SizedBox(height: 20.0),
              
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          ),
                          color: Colors.white
                        ),
                        child: InkWell(
                          onTap: null,
                          child: Row(
                            children: [
        
                              const Icon(Icons.person), 
        
                              const SizedBox(width: 10),
        
                              Text("About Me", style: GoogleFonts.poppins(
                                  fontSize: 18.0
                                )
                              ),
                          
                              const Spacer(),
                          
                              const Icon(Icons.arrow_forward_ios_outlined)
                              
                            ],
                          ),
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 10.0),
        
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          ),
                          color: Colors.white
                        ),
                        child: InkWell(
                          onTap: null,
                          child: Row(
                            children: [
                              const Icon(Icons.lock),
        
                              const SizedBox(width: 10),
        
                              Text("Change Password", style: GoogleFonts.poppins(
                                  fontSize: 18.0
                                )
                              ),
                          
                              const Spacer(),
                          
                              const Icon(Icons.arrow_forward_ios_outlined)
                              
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          ),
                          color: Color(0xFFFF1100)
                        ),
                        child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete, color: Colors.white,),
        
                              const SizedBox(width: 10),
        
                              Text("Delete this account", style: GoogleFonts.poppins(
                                  fontSize: 18.0, color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                          
                          
                            ],
                          ),
                        ),
                      ),
                    ),
        
        
        
        
        
                  ],
                ),
              ),
            ),
        
            Positioned(
              child: Container(
                margin: const EdgeInsets.only(bottom: 100),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 100),
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(
                            color: Colors.white,
                            width: 4.0,
        
                          )
                          
                        ),
                      ),
                              
                      
                              
                    ],
                  ),
                ),
              ),
            )
        
        
          ],
        ),
      )
    );
  }
}