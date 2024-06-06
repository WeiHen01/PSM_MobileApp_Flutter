import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAboutMe extends StatelessWidget {
  const UserAboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("About Me", style: GoogleFonts.poppins(
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(25),
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
            )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100),
          
              Container(
                
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Write about your description:", style: GoogleFonts.poppins(
                        fontSize: 15.0, color: Colors.black,
                      )
                    ),

                    SizedBox(height: 10),
          
                    // Add TextFormFields and ElevatedButton here.
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: GoogleFonts.poppins(),
                        prefixIcon: Icon(Icons.description),
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        counterStyle: GoogleFonts.poppins(
                          fontSize: 15.0, color: Colors.black,
                        )
                      ),
                      maxLength: 1000,
                      maxLines: null,
                      style: GoogleFonts.poppins(
                          fontSize: 15
                      ),
                    ),

                    InkWell(
                      onTap: (){
                        
                      },
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF301847), Color(0xFFC10214)
                              ],
                            ),
                        
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Save", style: GoogleFonts.poppins(
                                  fontSize: 16.0, color: Colors.white,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              ),
          
          
            ],
          ),
        )
        
      ),
    );
  }
}