import 'package:budget_tracker/widgets/category_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../utils/appvalidator.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var type = "credit";

  var category = "Others";

  var isLoader = false;

  final appValidator = AppValidator();

  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  var uid = const Uuid();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true; // Bắt đầu hiển thị loader
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        var amount = int.parse(amountEditController.text);
        DateTime date = DateTime.now();

        var id = uid.v4();
        String monthYear = DateFormat("MMM y").format(date);

        // Lấy dữ liệu user từ Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get();

        int remainingAmount = userDoc["remainingAmount"];
        int totalCredit = userDoc["totalCredit"];
        int totalDebit = userDoc["totalDebit"];

        // Cập nhật số dư dựa trên loại giao dịch (credit hoặc debit)
        if (type == "credit") {
          remainingAmount += amount;
          totalCredit += amount;
        } else {
          remainingAmount -= amount;
          totalDebit += amount;
        }

        // Cập nhật dữ liệu người dùng
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .update({
          "remainingAmount": remainingAmount,
          "totalCredit": totalCredit,
          "totalDebit": totalDebit,
          "updateAt": timestamp,
        });

        // Thêm giao dịch vào collection "transactions"
        var data = {
          "id": id,
          "title": titleEditController.text,
          "amount": amount,
          "type": type,
          "timestamp": timestamp,
          "totalCredit": totalCredit,
          "totalDebit": totalDebit,
          "remainingAmount": remainingAmount,
          "monthYear": monthYear,
          "category": category
        };

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("transactions")
            .doc(id)
            .set(data);

        // Đóng form sau khi thêm thành công
        Navigator.pop(context);
      } catch (e) {
        // Xử lý lỗi nếu có
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      } finally {
        setState(() {
          isLoader = false; // Ẩn loader sau khi hoàn tất hoặc gặp lỗi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              CategoryDropdown(
                  cattype: category,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        category = value;
                      });
                    }
                  }),
              DropdownButtonFormField(
                  items: const [
                    DropdownMenuItem(value: "credit", child: Text("Credit")),
                    DropdownMenuItem(
                      value: "debit",
                      child: Text("Debit"),
                    )
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        type = value;
                      });
                    }
                  }),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (isLoader == false) {
                      _submitForm();
                    }
                  },
                  child: isLoader
                      ? const Center(child: CircularProgressIndicator())
                      : const Text("Add Transaction"))
            ],
          )),
    );
  }
}
