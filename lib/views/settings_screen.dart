import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return Center(
      child: SwitchListTile(
        title: Text("Dark Mode"),
        value: themeController.isDarkMode,
        onChanged: (value) {
          themeController.toggleTheme();
        },
      ),
    );
  }
}
