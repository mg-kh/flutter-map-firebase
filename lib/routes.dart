import 'package:get/get.dart';
import 'package:map_note/screens/home.dart';
import 'package:map_note/screens/login.dart';

List<GetPage> routes = [
  GetPage(name: '/', page: () => const Home()),
  GetPage(name: '/login', page: () => Login()),
];