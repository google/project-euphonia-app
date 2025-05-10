// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'generated/l10n/app_localizations.dart';
import 'modes/train_mode_controller.dart';
import 'modes/transcribe_mode_controller.dart';
import 'repos/phrases_repository.dart';
import 'repos/settings_repository.dart';
import 'repos/uploader.dart';
import 'settings/settings_controller.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const TrainModeController(),
    const TranscribeModeController(),
    const Center(
      child: IconButton(
        icon: Icon(Icons.construction),
        iconSize: 80,
        onPressed: null,
      ),
    ),
  ];

  @override
  void initState() {
    Provider.of<PhrasesRepository>(context, listen: false).initFromAssetFile();
    Provider.of<SettingsRepository>(context, listen: false)
        .initFromPreferences();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            Consumer<Uploader>(
                builder: (context, uploader, _) => Stack(children: [
                      Visibility(
                          visible: uploader.showProgressIndicator,
                          child: const CircularProgressIndicator(
                              color: Colors.blue)),
                      Visibility(
                          visible: uploader.showUploadProgressIcon,
                          child: Container(
                              padding: const EdgeInsets.all(6),
                              child: uploader.uploadIcon))
                    ])),
            const SizedBox(width: 24)
          ]),
      body: _widgetOptions[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_sharp),
              title:
                  Text(AppLocalizations.of(context)!.settingsMenuDrawerTitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsController(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.mic),
              label: AppLocalizations.of(context)!.trainModeTitle),
          BottomNavigationBarItem(
            icon: const Icon(Icons.hearing),
            label: AppLocalizations.of(context)!.transcribeModeTitle,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
