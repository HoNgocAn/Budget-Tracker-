import 'package:budget_tracker/screens/dashboard.dart';
import 'package:budget_tracker/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return const LoginView();
          }
          return const Dashboard();
        }
    );
  }
}
