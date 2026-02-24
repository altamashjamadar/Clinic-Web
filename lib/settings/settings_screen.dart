// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'settings_controller.dart';

// class Setting extends StatelessWidget {
//   const Setting({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final settings = Get.find<SettingsController>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             'Appearance',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),

//           /// 🌗 Dark Mode
//           Card(
//             child: Obx(() {
//               return SwitchListTile(
//                 value: settings.isDark.value,
//                 onChanged: settings.toggleTheme,
//                 title: const Text('Dark Mode'),
//                 secondary: const Icon(Icons.dark_mode),
//               );
//             }),
//           ),

//           const SizedBox(height: 24),

//           const Text(
//             'Language',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),

//           /// 🌍 Language Switch
//           Card(
//             child: ListTile(
//               leading: const Icon(Icons.language),
//               title: const Text('Language'),
//               trailing: Obx(() {
//                 return DropdownButton<Locale>(
//                   value: settings.locale.value,
//                   underline: const SizedBox(),
//                   onChanged: (locale) {
//                     if (locale != null) {
//                       settings.changeLanguage(locale);
//                     }
//                   },
//                   items: const [
//                     DropdownMenuItem(
//                       value: Locale('en'),
//                       child: Text('English'),
//                     ),
//                     DropdownMenuItem(
//                       value: Locale('hi'),
//                       child: Text('हिंदी'),
//                     ),
//                     DropdownMenuItem(
//                       value: Locale('mr'),
//                       child: Text('मराठी'),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
