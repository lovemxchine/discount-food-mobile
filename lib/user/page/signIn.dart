import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/user/service/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String email = '';
  String password = '';
  var pathAPI = '';
  bool loginLoading = false;

  Map<String, dynamic>? userProfileData;

  Future<void> fetchUserProfile(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      loginLoading = true;
    });
    try {
      final url = Uri.parse("$pathAPI/customer/profileDetail?uid=$uid");
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          userProfileData = responseData['data'];
          loginLoading = false;
        });
        // Access username and lastname
        String? username = userProfileData?['fname'];
        String? lastname = userProfileData?['lname'];
        prefs.setString('username', username ?? '');
        prefs.setString('lastname', lastname ?? '');
        print('Username: $username, Lastname: $lastname');
        // You can also navigate to another page or perform other actions here
      } else {
        setState(() {
          loginLoading = false;
        });
        print('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loginLoading = false;
      });
      print('Error fetching profile: $e');
    }
  }

  Future<void> storeUID(String uid, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await fetchUserProfile(uid);
    await prefs.setString('user_uid', uid);
    await prefs.setString('user_role', role);
  }

  Future<void> signInFunc() async {
    await fetchUrl();
    _signIn();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  @override
  void initState() {
    super.initState();
    // initFetch();
    _signOutUser();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => {
                        setState(() {
                          emailController.text = "test@example.com";
                          passwordController.text = "123456";
                        })
                      },
                      child: Text('เข้าสู่ระบบ',
                          style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFFFF6838),
                              fontFamily: GoogleFonts.mitr().fontFamily)),
                    ),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          emailController.text = "pppp@gmail.com";
                          passwordController.text = "123456";
                        })
                      },
                      child: SizedBox(
                        child: Text("         "),
                        height: 30,
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      onSubmitted: (String value) {
                        setState(() {
                          email = emailController.text;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon:
                            Icon(Icons.person, color: Color(0xFFFF6838)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFFF6838), width: 2.0)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6838), // Custom border color
                            width: 2.0, // Custom border width
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: passwordController,
                      onSubmitted: (String value) {
                        setState(() {
                          password = passwordController.text;
                        });
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6838)),
                        hintText: 'Password',
                        // labelText: 'Password',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFFF6838), width: 2.0)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6838), // Custom border color
                            width: 2.0, // Custom border width
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                            text: 'เข้าสู่ระบบเป็น ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFF6838),
                                fontFamily: GoogleFonts.mitr().fontFamily),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'ผู้ชม',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: GoogleFonts.mitr().fontFamily,
                                      color: Color(0xFFFF6838),
                                      fontSize: 16,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/guest');
                                    })
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signInFunc();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6838), // Button color
                        minimumSize: Size(600, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15.0), // Rounded corners
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('เข้าสู่ระบบ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.mitr().fontFamily)),
                          const SizedBox(width: 10),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    RichText(
                        text: TextSpan(
                            text: 'ยังไม่มีบัญชีผู้ใช้ ? ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: GoogleFonts.mitr().fontFamily),
                            children: <TextSpan>[
                          TextSpan(
                              text: 'สมัครผู้ใช้',
                              style: TextStyle(
                                  color: Color(0xFFFF6838),
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.mitr().fontFamily,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/registerRole');
                                })
                        ])),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            title: Text(
                              'ติดต่อผู้ดูแลระบบ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: GoogleFonts.mitr().fontFamily),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'หากมีปัญหาในการเข้าสู่ระบบ กรุณาติดต่อผู้ดูแลระบบที่เบอร์',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.mitr().fontFamily,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                SelectableText(
                                  '099-999-9999',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    fontFamily: GoogleFonts.mitr().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('ปิด'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'ติดต่อผู้ดูแลระบบ',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color.fromARGB(255, 16, 16, 16),
                          fontFamily: GoogleFonts.mitr().fontFamily,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
        if (loginLoading)
          Container(
            color: Colors.black.withOpacity(0.3), // สีดำโปร่งบาง
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // ให้สีวงกลมเป็นขาว
              ),
            ),
          ),
      ]),
    );
  }

  void _signIn() async {
    String email = emailController.text;
    String password = passwordController.text;
    setState(() {
      loginLoading = true;
    });
    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);
      print("user");
      if (user != null) {
        print("This Email is registered");
        final url = Uri.parse("$pathAPI/authentication/signIn");
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'checkUID': user.uid,
          }),
        );
        print('User UID: ${user.uid}');
        print('Response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            loginLoading = false;
          });
          if (responseData['userStatus'] == 'success') {
            await storeUID(user.uid, responseData['role']);
            switch (responseData['role']) {
              case 'customer':
                Navigator.pushNamed(context, '/customer');
                break;
              case 'shopkeeper':
                Navigator.pushNamed(context, '/shop');
                break;
              default:
                await _auth.signOut();
                break;
            }
            print('regis');
          } else if (responseData['userStatus'] == 'registerShop') {
            setState(() {
              loginLoading = false;
            });
            await _auth.signOut();
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Text(
                        'รอการอนุมัติ',
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: GoogleFonts.mitr().fontFamily),
                      ),
                      content:
                          const Text('อยู่ในขั้นตอนรอการอนุมัติจากผู้ดูแลระบบ'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Navigator.pushNamed(context, '/registerRole/shopkeeper');
                            Navigator.pop(context);
                          },
                          child: const Text('ยืนยัน'),
                        ),
                      ],
                    ));
          }
        } else {
          setState(() {
            loginLoading = false;
          });
          print('Request failed with status: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sign in. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loginLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Sign-in failed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signOutUser() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
