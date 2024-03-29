import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialChatRoom extends StatefulWidget {
  const SocialChatRoom({super.key});

  @override
  State<SocialChatRoom> createState() => _SocialChatRoomState();
}

class _SocialChatRoomState extends State<SocialChatRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 8),

            Text('Username', style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
            
          ],
        ),

        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white,),
        ),

      ),

      body: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF301847), Color(0xFFC10214)
              ],
            )
        ),
        child: Column(
          children: [
            const Spacer(),

            const Divider(
              color: Colors.white,
            ),

            Container(
              child: Row(
                children: [
                  
                  Expanded(
                    child: TextField(
                      controller: SearchController(),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                        prefixIcon: Icon(Icons.message, color: Colors.white,),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        )
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.send, color: Colors.white,)
                  )
                ],
              ),
            )
          ],
        )

      ),

    


    );
  }
}