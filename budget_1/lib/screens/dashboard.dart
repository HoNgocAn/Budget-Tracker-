import 'package:budget_tracker/screens/home_screen.dart';
import 'package:budget_tracker/screens/transaction_screen.dart';
import 'package:budget_tracker/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _State();
}

int currentIndex = 0;
var pageViewList =[
  const HomeScreen(),
  const TransactionScreen(),
];


class _State extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (int value){
            setState(() {
              currentIndex = value;
            });
          }),
      body: pageViewList[currentIndex],
    );
  }
}
