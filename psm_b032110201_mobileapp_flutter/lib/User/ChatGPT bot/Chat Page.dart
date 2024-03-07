import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
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

        title: Text("Chat with ChatGPT", style: GoogleFonts.poppins(
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