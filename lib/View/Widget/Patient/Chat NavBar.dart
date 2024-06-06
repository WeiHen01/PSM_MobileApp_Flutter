import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

import '../../../Controller/MongoDBController.dart';
import '../../Patient/Social/Call Log.dart';
import '../../Patient/Social/Chat with Doctor.dart';
import '../../Patient/Social/Social Chat.dart';


class ChatNav extends StatefulWidget {

  final int tabIndexes;
  final int? patientID;

  const ChatNav({Key? key, required this.tabIndexes, this.patientID});

  @override
  State<ChatNav> createState() => _ChatNavState();
}

class _ChatNavState extends State<ChatNav> {

  // set the default initial page
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }
  
  // controller for Page view
  late PageController pageController;

  @override
  void initState() {

    // change the default page here
    _tabIndex = widget.tabIndexes;
    super.initState();
    /**
     * WidgetsBinding.instance?.addPostFrameCallback
     * -------------------------------------------------------
     * This code schedules a callback function to be executed
     * after the end of the frame.
     * -------------------------------------------------------
     */

    MongoDatabase db = MongoDatabase();
    db.open("Chat");
    

    // to set the default page to be initiated based on tab index
    pageController = PageController(initialPage: _tabIndex);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      /**
       * Using CircleNavBar as packages
       * setting up in pubspec.yaml for dependencies
       *
       * This will enable to be used as navigation bar
       * which is more dynamic
       */
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          /**
           * icons on navigation bar
           * will be appeared when user is at current page
           */
          Icon(Icons.people_alt, color: Colors.white, size: 35,),
          Icon(Icons.local_hospital, color: Colors.white, size: 35,),
          //Icon(Icons.call, color: Colors.white, size: 35,),
        ],

        /**
         * when the other pages are not active
         * the tab will be displayed as text
         */
        inactiveIcons:  [
          Text("Patients", style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold
          ),),
          Text("Doctor", style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold
          ),),
          /* Text("Calls", style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold
          ),), */
         
        ],
        color: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        // the rounded corner for the navigation bar
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Colors.blueGrey,
        elevation: 10,
        /**
         * Background color of the bar
         */
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF301847), Color(0xFFC10214), 
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          /**
           * when the user switch the page
           * the index of current page will be assigned to the tabIndex
           */
          tabIndex = v;
        },
        children: [
          /**
           * Here will import the screens
           * based on the navigation bar in sequence
           *
           * The index of the screen starts from 0 in sequence
           * which is related to variable tabIndex later on
           */
          SocialChat(id: widget.patientID,),
          ChatWithDoctor(id: widget.patientID,),
          

        ],
      )
    );
  }
}
