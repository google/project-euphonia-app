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

import '../repos/audio_player.dart';
import '../repos/audio_recorder.dart';
import '../repos/phrase.dart';
import '../repos/phrases_repository.dart';
import '../repos/settings_repository.dart';
import '../repos/uploader.dart';
import 'train_mode_view.dart';
import 'upload_status.dart';

class TrainModeController extends StatefulWidget {
  const TrainModeController({super.key});

  @override
  State<TrainModeController> createState() => _TrainModeControllerState();
}

class _TrainModeControllerState extends State<TrainModeController> {
  var _uploadStatus = UploadStatus.notStarted;
  final Key _key = GlobalKey();
  final _pageController = PageController(initialPage: 0, viewportFraction: 0.8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(milliseconds: 100));
      Provider.of<PhrasesRepository>(context, listen: false)
          .getLastRecordedPhraseIndex()
          .then((lastRecordedPhraseIndex) => setState(() {
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(lastRecordedPhraseIndex);
                }
              }));
    });
  }

  void _previousPhrase() async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    phrasesRepoProvider.moveToPreviousPhrase();
    setState(() {
      _pageController.animateToPage(phrasesRepoProvider.currentPhraseIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  void _nextPhrase() async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    phrasesRepoProvider.moveToNextPhrase();
    setState(() {
      _pageController.animateToPage(phrasesRepoProvider.currentPhraseIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  void _stopRecordingAndUpload(
      AudioRecorder recorder, Phrase phrase, AudioPlayer player) async {
    if (!recorder.isRecording) {
      recorder.start();
      return;
    }
    await recorder.stop();
    Provider.of<Uploader>(context, listen: false)
        .updateStatus(status: UploadStatus.started);
    phrase.uploadRecording().then((_) {
      Provider.of<Uploader>(context, listen: false)
          .updateStatus(status: UploadStatus.completed);
    }, onError: (_) {
      Provider.of<Uploader>(context, listen: false)
          .updateStatus(status: UploadStatus.interrupted);
    });
    if (Provider.of<SettingsRepository>(context, listen: false).autoAdvance) {
      _nextPhrase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PhrasesRepository, AudioPlayer, AudioRecorder>(
        builder: (_, repo, player, recorder, __) {
      if (repo.phrases.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return TrainModeView(
        index: repo.currentPhraseIndex,
        pageStorageKey: _key,
        phrases: repo.phrases,
        previousPhrase: repo.currentPhraseIndex == 0 ? null : _previousPhrase,
        nextPhrase: repo.currentPhraseIndex == repo.phrases.length - 1
            ? null
            : _nextPhrase,
        record: player.isPlaying
            ? null
            : () {
                _stopRecordingAndUpload(recorder, repo.currentPhrase!, player);
              },
        isRecording: recorder.isRecording,
        play: player.canPlay && !recorder.isRecording
            ? (player.isPlaying ? player.pause : player.play)
            : null,
        isPlaying: player.isPlaying,
        isRecorded: player.canPlay,
        uploadStatus: _uploadStatus,
        controller: _pageController,
      );
    });
  }
}
