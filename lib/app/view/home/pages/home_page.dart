import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/controller/home/home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Initialize the controller
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() => controller.pages[controller.selectedIndex.value]),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.format_quote),
              label: 'Quotes',
            ),
            
            BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes'),
            
            // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
