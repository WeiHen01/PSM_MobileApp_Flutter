import 'package:flutter/material.dart';

class UserAboutMe extends StatelessWidget {
  const UserAboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
    );
  }
}