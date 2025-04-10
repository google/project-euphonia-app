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

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

final class Phrase {
  final int index;
  final String text;

  Phrase({required this.index, required this.text});

  Future<bool> get isRecordingAvailableLocally =>
      localRecordingPath.then((x) => File(x).existsSync());

  Future<String> get localRecordingPath =>
      getApplicationDocumentsDirectory().then(
        (value) => '${value.path}/prompt$index.wav',
      );

  Future<String> get localTempPath => getApplicationDocumentsDirectory().then(
        (value) => '${value.path}/prompt_temp_$index.wav',
      );

  Future<void> downloadRecording() async {
    final storageRef = FirebaseStorage.instance.ref();
    final audioRef = storageRef.child('data/$index/recording.wav');
    final localAudioFile = File(await localRecordingPath);
    final remoteData = await audioRef.getData();
    if (remoteData == null || remoteData.isEmpty) {
      throw FileSystemException('File doesn\'t exist', audioRef.fullPath);
    }
    final List<int> data = (await audioRef.getData()) as List<int>;
    localAudioFile.writeAsBytesSync(data);
  }

  Future<void> uploadRecording() async {
    final storage = FirebaseStorage.instance;
    storage.setMaxUploadRetryTime(const Duration(seconds: 5));
    final storageRef = storage.ref();
    final phraseRef = storageRef.child('data/$index/phrase.txt');
    final audioRef = storageRef.child('data/$index/recording.wav');
    final audioPath = await localRecordingPath;
    final localAudioFile = File(audioPath);
    if (!localAudioFile.existsSync()) {
      throw FileSystemException('File doesn\'t exist', audioPath);
    }
    await Future.wait([
      phraseRef.putString(text),
      audioRef.putFile(localAudioFile),
    ]);
  }
}
