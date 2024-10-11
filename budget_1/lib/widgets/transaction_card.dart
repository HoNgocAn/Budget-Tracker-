import 'package:budget_tracker/utils/icons_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Text(
                "Recent Transaction",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        RecentTransactionList(),
      ],
    );
  }
}

class RecentTransactionList extends StatelessWidget {
  RecentTransactionList({
    super.key,
  });

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("transactions")
          .orderBy("timestamp", descending: true)
          .limit(20)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No transactions found"));
        }

        var data = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length, // Hiển thị 4 phần tử
          itemBuilder: (context, index) {
            var cardData = data[index];
            return TransactionItem(
              data: cardData,
            ); // Item giao dịch
          },
        );
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  TransactionItem({
    super.key,
    required this.data,
  });

  final dynamic data;

  final appIcon = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data["timestamp"]);
    String formatedDate = DateFormat("d MMM hh:mma").format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 10),
              color: Colors.grey.withOpacity(0.09),
              blurRadius: 10.0,
              spreadRadius: 4.0,
            )
          ],
        ),
        child: ListTile(
          minVerticalPadding: 8,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          leading: Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: data["type"] == "credit"
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
            ),
            child: Center(
                child: FaIcon(
                    appIcon.getExpenseCategoryIcons("${data["category"]}"),
                    color:
                        data["type"] == "credit" ? Colors.green : Colors.red)),
          ),
          title: Row(
            children: [
              Expanded(child: Text("${data["title"]}")),
              Spacer(),
              Text(
                "${data["type"] == "credit" ? "+" : "-"} £ ${data["amount"]}",
                style: TextStyle(color:  data["type"] == "credit" ? Colors.green : Colors.red),
              ),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Balance",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Spacer(),
                  Text("${data["remainingAmount"]}",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Text(formatedDate, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
