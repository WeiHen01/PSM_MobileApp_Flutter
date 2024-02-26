import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Social Chat Room.dart';

class SocialChat extends StatefulWidget {
  const SocialChat({super.key});

  @override
  State<SocialChat> createState() => _SocialChatState();
}

class _SocialChatState extends State<SocialChat> {

  TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),

        title: Text("Chat", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        actions:[
          IconButton(
            onPressed: (){}, icon: Icon(Icons.more_vert, color: Colors.white)
          )
        ]

      ),

      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [

            TextField(
              controller: SearchController(),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
              ),
            ),

            const SizedBox(height: 10.0,),

            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap:()=>Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => SocialChatRoom()
                      )
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle
                        ),
                      ),
                      
                      title: Row(
                        children: [
                          
                          Text('Username ${index+1}', style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold
                          ),),
                          
                          const Spacer(),
                          
                          Text('Latest Time', style: GoogleFonts.poppins(
                            fontSize: 12
                          ),),
                    
                        ],
                      ),
                      
                      subtitle: Text('Message', style: GoogleFonts.poppins(
                        fontSize: 12
                      ),),
                    
                      
                    
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}