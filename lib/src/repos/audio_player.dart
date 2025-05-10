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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'phrase.dart';

final class AudioPlayer extends ChangeNotifier {
  VideoPlayerController? _playerController;
  String? _audioPath;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  bool get canPlay => _audioPath != null && File(_audioPath!).existsSync();

  void loadPhrase(Phrase? phrase) {
    if (phrase == null) {
      return;
    }
    phrase.localRecordingPath.then((audioPath) {
      load(audioPath: audioPath);
    });
  }

  void load({required String? audioPath}) async {
    _playerController?.pause();
    _audioPath = audioPath;
    if (!canPlay) {
      _playerController?.dispose();
      _playerController = null;
      notifyListeners();
      return;
    }
    await _updatePath();
    notifyListeners();
  }

  Future<void> _updatePath() async {
    _playerController = VideoPlayerController.file(File(_audioPath!));
    await _playerController?.initialize();
    _playerController?.addListener(() {
      var newValue = _playerController?.value.isPlaying ?? false;
      if (_isPlaying != newValue) {
        _isPlaying = newValue;
        notifyListeners();
      }
    });
  }

  Future<void> play() async {
    _isPlaying = true;
    if (_playerController == null) {
      _updatePath();
    }
    await _playerController?.play();
    notifyListeners();
  }

  void pause() {
    _playerController?.pause();
    _playerController?.seekTo(const Duration(seconds: 0));
    _isPlaying = false;
    notifyListeners();
  }
}
