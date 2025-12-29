import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'core/theme/theme.dart';
import 'core/common_widgets/selections/radio.dart';
import 'core/common_widgets/inputs/text_field.dart';

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
      home: const MyHomePage(title: 'Learning Path'),
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
  int _score = 0;

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
            PixelRadioGroup(
            onSelected: (value) {
              setState(() {
                _score = value;
              });
            }
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
