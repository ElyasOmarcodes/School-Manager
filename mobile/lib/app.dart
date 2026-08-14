import 'package:flutter/material.dart';

import 'core/design.dart';
import 'core/strings.dart';
import 'features/home_shell.dart';
import 'features/pairing_page.dart';

class SchoolManagerMobile extends StatefulWidget {
  const SchoolManagerMobile({super.key});

  @override
  State<SchoolManagerMobile> createState() => _SchoolManagerMobileState();
}

class _SchoolManagerMobileState extends State<SchoolManagerMobile> {
  MLocale _locale = MLocale.ps;
  AppRole? _role;
  bool _demo = false;

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      locale: _locale,
      setLocale: (l) => setState(() => _locale = l),
      child: MaterialApp(
        title: 'School Manager',
        debugShowCheckedModeBanner: false,
        theme: buildMobileTheme(Brightness.light),
        darkTheme: buildMobileTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        builder: (context, child) =>
            Directionality(textDirection: _locale.direction, child: child!),
        home: _role == null
            ? PairingPage(
                onConnected: (role, {required demo}) => setState(() {
                  _role = role;
                  _demo = demo;
                }),
              )
            : HomeShell(
                role: _role!,
                demo: _demo,
                onDisconnect: () => setState(() => _role = null),
              ),
      ),
    );
  }
}
