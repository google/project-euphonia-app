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
import 'phrase_view.dart';
import 'package:provider/provider.dart';

import '../generated/l10n/app_localizations.dart';
import '../repos/phrases_repository.dart';
import '../repos/phrase.dart';
import 'upload_status.dart';

class TrainModeView extends StatelessWidget {
  final int index;
  final List<Phrase> phrases;
  final void Function()? record;
  final void Function()? play;
  final void Function()? nextPhrase;
  final void Function()? previousPhrase;
  final bool isRecording;
  final bool isPlaying;
  final bool isRecorded;
  final UploadStatus uploadStatus;
  final PageController? controller;

  const TrainModeView(
      {super.key,
      required this.index,
      required this.phrases,
      required this.nextPhrase,
      required this.previousPhrase,
      required this.record,
      required this.play,
      required this.isRecording,
      required this.isPlaying,
      required this.isRecorded,
      required this.uploadStatus,
      this.controller});

  Icon get _uploadIcon {
    switch (uploadStatus) {
      case UploadStatus.notStarted:
        return const Icon(Icons.cloud_upload, color: Colors.transparent);
      case UploadStatus.started:
        return const Icon(Icons.cloud_upload, color: Colors.blue);
      case UploadStatus.completed:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case UploadStatus.interrupted:
        return const Icon(Icons.cloud_off, color: Colors.red);
    }
  }

  bool get _showUploadProgress {
    switch (uploadStatus) {
      case UploadStatus.notStarted:
        return false;
      case UploadStatus.started:
        return true;
      case UploadStatus.completed:
        return false;
      case UploadStatus.interrupted:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var sideLength = width;
    if (height < width) {
      sideLength = height;
    }
    return Column(
      children: [
        SizedBox(
            width: sideLength,
            height: sideLength,
            child: PageView.builder(
                controller: controller,
                itemBuilder: (context, index) {
                  return PhraseView(phrase: phrases[index]);
                },
                itemCount: phrases.length,
                onPageChanged: (index) =>
                    Provider.of<PhrasesRepository>(context, listen: false)
                        .jumpToPhrase(updatedPhraseIndex: index))),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              onPressed: previousPhrase,
              iconSize: 48,
              icon: const Icon(Icons.skip_previous),
            ),
            const SizedBox(width: 24),
            IconButton.outlined(
              onPressed: play,
              iconSize: 48,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(width: 24),
            IconButton.outlined(
              onPressed: nextPhrase,
              iconSize: 48,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
        const SizedBox(height: 40),
        MaterialButton(
          onPressed: record,
          minWidth: width - 48,
          color: isRecording
              ? Colors.teal
              : (isRecorded ? Colors.lightBlueAccent : Colors.blue),
          textColor: Colors.white,
          disabledColor: Colors.grey,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(80)),
          ),
          padding: const EdgeInsets.fromLTRB(80, 24, 80, 24),
          child: Text(
            isRecording
                ? AppLocalizations.of(context)!.stopRecordingButtonTitle
                : (isRecorded
                    ? AppLocalizations.of(context)!.reRecordButtonTitle
                    : AppLocalizations.of(context)!.recordButtonTitle),
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }
}
