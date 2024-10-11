import 'package:budget_tracker/widgets/add_transaction_form.dart';
import 'package:budget_tracker/widgets/transaction_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/hero_card.dart';


import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

logOut(context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginView()),
  );
}

final userId = FirebaseAuth.instance.currentUser!.uid;

_dialogBuilder (BuildContext context){
  return showDialog(
      context: context,
      builder: (context){
        return const AlertDialog(
          content: AddTransactionForm(),
        );
      });
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue.shade900,
          onPressed: ((){
            _dialogBuilder(context);
          }),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ) ,
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          "Hello",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Tooltip(
            message: 'Logout', // Chữ sẽ hiện ra khi hover hoặc nhấn giữ
            child: IconButton(
              onPressed: () {
                logOut(context);
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeroCard(userId: userId),
              TransactionCard()
            ],
          ),
        ),
      ),
    );
  }
}
