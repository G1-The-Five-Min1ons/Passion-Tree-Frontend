import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';

import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/reflection_tree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Learning Path",
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              'TEST',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 20,
              ),
            ),

            // ===== Pixel Button =====
            //text only 
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Text',
              onPressed: () {
                debugPrint('Submit pressed');
              },
            ),

            //textWithIcon
            AppButton(
              variant: AppButtonVariant.textWithIcon,
              text: 'Like',
              icon: const PixelIcon('assets/icons/Pixel_heart.png'),
              onPressed: () {},
            ),

            //icon only
            AppButton(
              variant: AppButtonVariant.iconOnly,
              icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
              onPressed: () {},
            ),

            // ===== ปุ่มไปหน้า Reflection =====
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Go to Reflection',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReflectionTreePage(),
                  ),
                );
              },
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30), // กันขอบกล่องติดขอบจอเกินไป
              child: PixelTextField(
                label: 'เทส',
                hintText: 'Summary',
                height: 46,
                //borderColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
