import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen {
  LoadingScreen._();

  static show(BuildContext context, String text) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _customDialog(context, text),
          );
        });
  }

  static hide(BuildContext context) {
    Navigator.pop(context);
  }

  static _customDialog(BuildContext context, String text) {
    return Container(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              ),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation(const Color.fromARGB(255, 255, 255, 255)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                ),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}