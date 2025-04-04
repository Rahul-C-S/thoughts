import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/view/note/pages/notes_page.dart';
import 'package:thoughts/app/view/quote/pages/quote_page.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  
  late List<Widget> pages = [
    QuotesPage(),
    NotesPage(),
    
  ];
  
  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
