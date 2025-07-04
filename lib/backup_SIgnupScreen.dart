import 'package:city_lens/SignInScreen.dart';
import 'package:city_lens/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'BottomNavBar.dart';
import 'utils/appbar.dart';
import 'utils/drawer.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  FirebaseAuth authn = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: CustomAppBar(title: 'City Lens'),
      endDrawer: CustomDrawer(),
      body: ListView(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Oops! you're not currently signed in.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue),
                    ),
                    SizedBox(height: 20),
                    // Username TextField
                    TextFormField(
                      cursorColor: Colors.lightBlue,
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Email TextFormField
                    TextFormField(
                      cursorColor: Colors.lightBlue,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        labelStyle: TextStyle(
                            color: Colors.black), // Changed label text color
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set border radius
                          borderSide: BorderSide(
                              color: Colors.black), // Set border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set border radius
                          borderSide: BorderSide(
                              color: Colors.black), // Set border color
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set border radius
                          borderSide:
                              BorderSide(color: Colors.red), // Set border color
                        ),
                      ),
                      style:
                          TextStyle(color: Colors.black), // Changed text color
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                                r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
                            .hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Password TextFormField
                    TextFormField(
                      cursorColor: Colors.lightBlue,

                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        labelStyle: TextStyle(
                            color: Colors.black), // Changed label text color
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set border radius
                          borderSide: BorderSide(
                              color: Colors.black), // Set border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set border radius
                          borderSide: BorderSide(
                              color: Colors.black), // Set border color
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set border radius
                          borderSide:
                              BorderSide(color: Colors.red), // Set border color
                        ),
                      ),
                      style:
                          TextStyle(color: Colors.black), // Changed text color
                      obscureText: true, // Hide password text
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Confirm Password TextFormField
                    SizedBox(height: 20),
                    // Sign In Button
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });

                              try {
                                // Firebase signup
                                UserCredential userCredential =
                                    await authn.createUserWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );

                                // Store the user's name in Firebase Auth profile
                                await userCredential.user?.updateProfile(
                                    displayName: _nameController.text.trim());

                                // Save user information in Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_emailController.text.trim())
                                    .set({
                                  'name': _nameController.text.trim(),
                                  'email': _emailController.text.trim(),
                                });

                                // Success message using Toast
                                ToastUtil.showToast("Successfully Registered");

                                // Navigate to the HomeScreen after successful signup
                                Get.to(Bottombar());

                                setState(() {
                                  loading = false;
                                });
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  loading = false;
                                });

                                if (e.code == 'email-already-in-use') {
                                  ToastUtil.showToast(
                                      "Email is already in use");
                                } else if (e.code == 'weak-password') {
                                  ToastUtil.showToast("Password is too weak");
                                } else {
                                  ToastUtil.showToast('Something went wrong');
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Sign Up')),
                    ),
                    SizedBox(height: 20),
                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Get.to(SignInScreen());
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
