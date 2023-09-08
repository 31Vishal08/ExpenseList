import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_status_code/http_status_code.dart';
void main() {
  Get.put(StorageController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class StorageController extends GetxController {
  final _box = GetStorage();

  void saveResponse(Map<String, dynamic> response) {
    _box.write("userResponse", response);
  }

  Map<String, dynamic> get savedResponse {
    return _box.read("userResponse") ?? {};
  }
}

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();

  void _login() async {
    final email = emailController.text;
    print(email);

    if (email!=null) {
      try {
        final response = await loginUser(email);



        if (email==email) {
          Get.find<StorageController>().saveResponse(response);
          Get.off(()=>ExpensesPage());
        } else {

          Get.snackbar("Login Error", "Failed to login.");
        }
      } catch (e) {

        Get.snackbar("Network Error", "Failed to connect to the server.");
      }
    } else {

      Get.snackbar("Input Error", "Email field cannot be empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: emailController,

                  decoration: const InputDecoration(

                    labelText: "Email",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                "LOGIN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )


          ],
        ),
      ),
    );
  }
}

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final storageController = Get.find<StorageController>();
  get response => storageController.savedResponse;
  get expenseList => response["expenseList"] as List<dynamic>;
  final TextEditingController searchController = TextEditingController();
  List<dynamic> filteredExpenseList = [];

  @override
  void initState() {
    super.initState();

    filteredExpenseList = expenseList;
  }

  void filterExpenses(String query) {
    setState(() {
      if (query.isEmpty) {

        filteredExpenseList = expenseList;
      } else {

        filteredExpenseList = expenseList.where((expense) {
          final expenseName = expense["expenseName"].toString().toLowerCase();
          return expenseName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 60,left: 8,right: MediaQuery.of(context).size.width / 2),
            child: Container(

              width: MediaQuery.of(context).size.width / 2,
              height: 100,
              color: Colors.white,
              child: const Center(
                child: Text(
                  "Expenses List",
                  style: TextStyle(
                    fontSize: 24.0, // Adjust the font size as needed
                    fontWeight: FontWeight.bold, // Adjust the font weight as needed
                  ),
                ),
              ),
            ),
          ),





          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0), // Adjust the radius for oval shape
                  border: Border.all(
                    color: Colors.blue, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterExpenses,
                    decoration: InputDecoration(
                      labelText: "Search Expenses",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredExpenseList.length,
              itemBuilder: (context, index) {
                final expense = filteredExpenseList[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue, // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8.0), // Adjust the border radius
                  ),
                  margin: EdgeInsets.all(8.0), // Adjust the margin as needed
                  child: ListTile(
                    title: Text(expense["expenseName"]),
                    // subtitle: Text(expense["description"]),
                    // You can add more details here
                  ),
                );
              },
            ),
          ),



        ],
      ),
    );
  }
}


Future<Map<String, dynamic>> loginUser(String email) async {
  try {
    final response = await Dio().post(
      "https://staging.thenotary.app/doLogin",
      data: {"email": email},
    );
    return response.data;
  } catch (error) {
    throw Exception("Failed to login: $error");
  }
}
