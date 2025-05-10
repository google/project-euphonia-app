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

import '../generated/l10n/app_localizations.dart';
import '../repos/settings_repository.dart';

class SettingsView extends StatelessWidget {
  final TextEditingController transcriptionURLController;
  final String defaultTranscriptURL;
  final SettingsRepository settings;

  const SettingsView(
      {super.key,
      required this.transcriptionURLController,
      required this.defaultTranscriptURL,
      required this.settings});

  @override
  Widget build(BuildContext context) {
    final children = [
      const SizedBox(height: 36),
      ListTile(
          title: Text(AppLocalizations.of(context)!.trainModeTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.blue))),
      ListTile(
        title: Text(AppLocalizations.of(context)!.autoAdvanceSettingTitle,
            style: Theme.of(context).textTheme.headlineSmall),
        subtitle:
            Text(AppLocalizations.of(context)!.autoAdvanceSettingSubtitle),
        trailing: Switch(
            value: settings.autoAdvance,
            onChanged: (newValue) {
              settings.updateAutoAdvance(newValue);
            }),
      ),
      const SizedBox(height: 36),
      ListTile(
          title: Text(AppLocalizations.of(context)!.transcribeModeTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.blue))),
      ListTile(
          title: TextField(
        controller: transcriptionURLController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.cloudRunTextFieldLabel,
          hintText: 'https://project-euphoina.us-west2.run.app',
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        onChanged: (newValue) {
          Provider.of<SettingsRepository>(context, listen: false)
              .updateTranscribeEndpoint(newValue);
        },
      )),
      const SizedBox(height: 64)
    ];

    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        flexibleSpace: AppBar(
            centerTitle: false,
            title: Text(AppLocalizations.of(context)!.settingsMenuDrawerTitle)),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return children[index];
        }, childCount: children.length),
      )
    ]));
  }
}
