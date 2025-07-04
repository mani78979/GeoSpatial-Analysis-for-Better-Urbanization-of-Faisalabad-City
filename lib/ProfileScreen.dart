import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_lens/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'SignInScreen.dart';
import 'utils/appbar.dart';
import 'utils/drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  String userName = '';
  String userEmail = '';
  List<Map<String, dynamic>> history = [];
  bool isRefreshing = false;
  bool isClearingHistory = false;
  Future<void> clearHistory() async {
    if (user == null || user!.email == null) {
      print("User is not logged in.");
      return;
    }

    setState(() {
      isClearingHistory = true;
    });

    try {
      var historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email)
          .collection('history')
          .get();

      for (var doc in historySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        history.clear();
        isClearingHistory = false;
      });
      ToastUtil.showToast('History cleared Successfully');
      print("History cleared successfully.");
    } catch (e) {
      setState(() {
        isClearingHistory = false;
      });
      print("Error clearing history: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    fetchHistory();
  }

  Future<void> getUserDetails() async {
    user = _auth.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email)
          .get();
      setState(() {
        userName = userDoc['name'];
        userEmail = userDoc['email'];
      });
    }
  }

  Future<void> fetchHistory() async {
    if (user == null || user!.email == null) {
      print("User is not logged in.");
      return;
    }

    try {
      var historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        history = historySnapshot.docs.map((doc) => doc.data()).toList();
      });

      print("History fetched successfully: ${history.length} items.");
    } catch (e) {
      print("Error fetching history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: CustomAppBar(title: 'City Lens'),
      endDrawer: CustomDrawer(),
      body: userEmail.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue))
          : RefreshIndicator(
              color: Colors.lightBlue,
              onRefresh: () async {
                setState(() {
                  isRefreshing = true;
                });
                await fetchHistory();
                setState(() {
                  isRefreshing = false;
                });
              },
              child: Column(
                children: [

                  SizedBox(height: 10),

                  // Profile Section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.black),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.email, color: Colors.black),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    userEmail,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: (){
                              FirebaseAuth.instance.signOut();
                              Get.off(() => SignInScreen());
                              ToastUtil.showToast('Loged Out');
                            },
                            child: Container(
                              height: 35,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(child: Text('Logout',style: TextStyle(color: Colors.white),)),
                            ),
                          ),
                          SizedBox(height: 10),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // History Section
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(left:8,right: 8,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off_sharp,
                                color: Colors.lightBlue,
                                size: 24,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'History',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.lightBlue),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              await clearHistory(); // Clear history when tapped
                            },
                            child: isClearingHistory
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              'Clear History',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  history.isEmpty
                      ? Center(
                          child: Text(
                            'No history available',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 0),
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                var item = history[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.lightBlue),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Snapshot Image
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: item['snapshotUrl'],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 150,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .blue, // Blue loader background
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Colors
                                                    .white, // White loader color
                                                strokeWidth:
                                                    2.0, // Customize loader thickness
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 150,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.red
                                                  .shade100, // Light red for error indication
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.error,
                                                color:
                                                    Colors.red), // Error icon
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      // Prediction Labels
                                      Text(
                                        'Land Type: ${item['landType']}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Population Density: ${item['populationDensity']}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Land Value: Increasing',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Development Sprawl: ${item['developmentSprawl']}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                ],
              ),
            ),
    );
  }
}



