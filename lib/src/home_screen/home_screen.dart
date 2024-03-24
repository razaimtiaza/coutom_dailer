import 'package:dialer/src/tabs/contacts_tab.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import '../tabs/call_log.dart';
import '../tabs/dialer_tab.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visually Impaired Dialer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              // Tab(
              //   icon: Icon(Icons.pin),
              //   text: 'Dialer',
              // ),
              Tab(
                icon: Icon(Icons.call),
                text: 'Call Logs',
              ),
              Tab(
                icon: Icon(Icons.group),
                text: 'Contacts',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // SafeArea(child: DialerTab()),
            Center(
              child: SafeArea(child: CallLogScreen()),
            ),
            // Contacts Tab
            Center(child: SafeArea(child: ContactsTab())),
          ],
        ),
      ),
    );
  }
}
