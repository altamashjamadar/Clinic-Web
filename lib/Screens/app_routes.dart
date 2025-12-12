import 'package:get/get.dart';
import 'package:rns_herbals_app/Admin/admin_home.dart';
import 'package:rns_herbals_app/Admin/manage_camps.dart';
import 'package:rns_herbals_app/Admin/manage_products.dart';
import 'package:rns_herbals_app/Screens/ProductListScreen.dart';
import 'package:rns_herbals_app/Screens/camps_page.dart';
import 'package:rns_herbals_app/Screens/home_page.dart';
import 'package:rns_herbals_app/Screens/instagram_feed.dart';
import 'package:rns_herbals_app/Screens/book_appointment.dart';
import 'package:rns_herbals_app/Admin/admin_appointments.dart';
import 'package:rns_herbals_app/Screens/chatbot_screen.dart';
import 'package:rns_herbals_app/Screens/news_page.dart';
import 'package:rns_herbals_app/Screens/doctor_screen.dart';
import 'package:rns_herbals_app/Screens/login_screen.dart'; 
import 'package:rns_herbals_app/Screens/profile_screen.dart';
import 'package:rns_herbals_app/Screens/setting.dart';
import 'package:rns_herbals_app/Screens/signup.dart';
import 'package:rns_herbals_app/SplashScreen.dart';

class AppRoutes {
  static const String splash = '/SplashScreen';
  static const String home = '/home';
  static const String instagram = '/instagram';
  static const String bookAppointment = '/book-appointment';
  static const String adminHome = '/admin-home';
  static const String adminAppointments = '/admin-appointments';
  static const String chatbot = '/chatbot';
  static const String news = '/news';
  static const String doctor = '/doctor';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String product = '/product';
  static const String settings = '/settings';
  static const String manageCamps = '/manage-camps';
  static const String manageProducts = '/manage-products';
  static const String manageOrders = '/manage-orders';
  static const String manageUsers = '/manage-users';
  static const String introSlider = '/intro-slider';
  static const String camps = '/camps';
  static const String profile = '/profile';
  

static final List<GetPage> pages=[
  GetPage(name: AppRoutes.splash, page: () =>SplashScreen()),
  GetPage(name: AppRoutes.home, page: () => HomePage()),
  GetPage(name: AppRoutes.instagram, page: () => InstagramFeed()),
  GetPage(name: AppRoutes.bookAppointment, page: () => BookAppointment()),
  GetPage(name: AppRoutes.adminHome, page: () =>  AdminHome()),
  GetPage(name: AppRoutes.adminAppointments, page: () =>  AdminAppointments()),
  GetPage(name: AppRoutes.chatbot, page: () => ChatbotScreen()),
  GetPage(name: AppRoutes.news, page: () => NewsPage()),
  GetPage(name: AppRoutes.doctor, page: () => DoctorScreen()),
  GetPage(name: AppRoutes.login, page: () => LoginScreen()),
  GetPage(name: AppRoutes.signup, page: () => SignupPage()),
  GetPage(name: AppRoutes.product, page: () =>  ProductListScreen()),
  GetPage(name: AppRoutes.settings, page: () => Setting()),
  GetPage(name: AppRoutes.manageCamps, page: () => ManageCamps()),
  GetPage(name: AppRoutes.manageProducts, page: () => AdminProductManagement()),
  GetPage(name: AppRoutes.camps, page: () => CampsPage()),
  GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
 
];
}