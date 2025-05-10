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

import '../repos/settings_repository.dart';
import 'settings_view.dart';

final class SettingsController extends StatefulWidget {
  const SettingsController({super.key});

  @override
  State<SettingsController> createState() => _SettingsControllerState();
}

class _SettingsControllerState extends State<SettingsController> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    final endpoint = Provider.of<SettingsRepository>(context, listen: false)
        .transcribeEndpoint;
    setState(() {
      controller.text = endpoint;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(builder: (context, settings, _) {
      return SettingsView(
        transcriptionURLController: controller,
        defaultTranscriptURL: settings.transcribeEndpoint,
        settings: settings,
      );
    });
  }
}
