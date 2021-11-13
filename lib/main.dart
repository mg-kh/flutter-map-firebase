import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_note/routes.dart';
import 'package:map_note/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: routes,
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (_, snapshot) {
          if(snapshot.hasData){
            return  const Home();
          }else if(snapshot.hasError){
            return const Scaffold(
              body: Center(
                child: Text('Error occur!'),
              ),
            );
          }else{
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
