import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class DocAIChatPage extends StatefulWidget {
  const DocAIChatPage({super.key});

  @override
  State<DocAIChatPage> createState() => _DocAIChatPageState();
}

class _DocAIChatPageState extends State<DocAIChatPage> {


  
  TextEditingController chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;

  @override
  void initState() {
    _model = GenerativeModel(
    model: 'gemini-pro', apiKey: 'AIzaSyAAj-gKvAv7lPRTiUYl4Sgr0ChYNdeY1HQ');
    _visionModel = GenerativeModel(
    model: 'gemini-pro-vision', apiKey: 'AIzaSyAAj-gKvAv7lPRTiUYl4Sgr0ChYNdeY1HQ');
    _chat = _model.startChat();
    super.initState();
  }

   void getAnswer(text) async {
    late final response;
    var content = Content.text(text.toString());
    response = await _chat.sendMessage(content);
    setState(() {
      _chatHistory.add({
        "time": DateTime.now(),
        "message": response.text,
        "isSender": false,
        "isImage": false
      });
    });

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  final _formKey = GlobalKey<FormState>();

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

        title: Text("Chat with AI", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        /* actions:[
          IconButton(
            onPressed: (){}, icon: Icon(Icons.more_vert, color: Colors.white)
          )
        ] */

      ),

      body: Stack(
        children: [
          Container(
            //get max height
            height: MediaQuery.of(context).size.height - 160,
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
            
            
                Expanded(
                  child: Container(
                    height: double.infinity,
                    child: ListView.builder(
                      itemCount: _chatHistory.length,
                      shrinkWrap: false,
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        
                        return Container(
                          
                          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                          child: Align(
                            alignment: (_chatHistory[index]["isSender"]
                            ? Alignment.topRight : Alignment.topLeft),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                color: (_chatHistory[index]["isSender"]?Color(0xFFFF7F50):Colors.white),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Text(_chatHistory[index]["message"], style: GoogleFonts.poppins(fontSize: 15, color: _chatHistory[index]["isSender"]?Colors.white:Colors.black)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            
            
            
            
            
            
              ],
            )

          ),

          

          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF301847), Color(0xFFC10214)
                      ],
                    )
                ),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: chatController,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Empty message to be sent';
                            }
                            else if(value.length > 300){
                              return 'The message can be only within 300 characters';
                            }
                            return null;
                          },
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
                          style: GoogleFonts.poppins(
                            color: Colors.white
                          ),
                        ),
                      ),
                      
                      IconButton(
                        onPressed: (){
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              if(chatController.text.isNotEmpty){
                                _chatHistory.add({
                                  "time": DateTime.now(),
                                  "message": chatController.text,
                                  "isSender": true,
                                });
                              
                        
                              }
                            });
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                        
                            getAnswer(chatController.text);
                            chatController.clear();
                          }
                          
                        },
                        icon: Icon(Icons.send, color: Colors.white,)
                      )
                              
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

