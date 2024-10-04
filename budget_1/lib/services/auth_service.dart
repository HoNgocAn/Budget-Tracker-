import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<bool> createUser(data, context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data["email"],
        password: data["password"],
      );
      // Trả về true khi tạo tài khoản thành công
      return true;
    } catch (e) {
      // In ra lỗi để kiểm tra
      print(e);
      // Trả về false khi có lỗi
      return false;
    }
  }
}
