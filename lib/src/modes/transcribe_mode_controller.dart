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

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../repos/settings_repository.dart';
import 'transcribe_mode_view.dart';

class TranscribeModeController extends StatefulWidget {
  const TranscribeModeController({super.key});

  @override
  State<TranscribeModeController> createState() =>
      _TranscribeModeControllerState();
}

class _TranscribeModeControllerState extends State<TranscribeModeController> {
  final storage = FirebaseStorage.instance;
  final record = AudioRecorder();
  late VideoPlayerController _playerController;
  var _phrase = '';
  var _isRecording = false;
  var _isPlaying = false;
  var _canPlay = false;
  var _uploadStatus = UploadStatus.notStarted;

  @override
  void initState() {
    super.initState();
  }

  void _manageRecording() async {
    if (_isRecording) {
      await _stopRecording();
      setState(() {
        _isRecording = false;
      });
    } else {
      await _startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<String> _getRecordingPath() {
    return getApplicationDocumentsDirectory().then(
      (value) => '${value.path}/recording.wav',
    );
  }

  Future<void> _startRecording() async {
    var path = await _getRecordingPath();
    if (await record.hasPermission()) {
      await record.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );
    }
  }

  Future<void> _preparePlayerForFile({required File audioFile}) async {
    _playerController = VideoPlayerController.file(audioFile);
    _playerController.initialize().then((_) {});
    _playerController.addListener(() {
      setState(() {
        _isPlaying = _playerController.value.isPlaying;
      });
    });
  }

  Future<void> _transcribe({required File audioFile}) async {
    setState(() {
      _uploadStatus = UploadStatus.started;
    });
    try {
      var transcribeEndpoint =
          Provider.of<SettingsRepository>(context, listen: false)
              .transcribeEndpoint;
      if (transcribeEndpoint.isEmpty) {
        return;
      }
      final uri = Uri.parse('$transcribeEndpoint/transcribe');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('wav', audioFile.path),
      );
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        setState(() {
          _phrase = result['transcript'] ?? 'ERROR: TRANSCRIPT NOT FOUND!';
          _uploadStatus = UploadStatus.completed;
        });
      } else {
        setState(() {
          _phrase = 'ERROR: SOMETHING WENT WRONG (${response.statusCode})!';
          _uploadStatus = UploadStatus.completed;
        });
      }
    } on http.ClientException catch (error) {
      developer.log(error.message);
      setState(() {
        _phrase = 'ERROR: ${error.message}';
        _uploadStatus = UploadStatus.interrupted;
      });
    }
  }

  void _playRecording() async {
    if (_isPlaying) {
      _playerController.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _playerController.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<bool> _checkIfRecordingFileIsAvailable() async {
    var recordingFile = File(await _getRecordingPath());
    setState(() {
      _canPlay = recordingFile.existsSync();
    });
    return _canPlay;
  }

  Future<void> _stopRecording() async {
    var _ = await record.stop();
    Future.wait([_checkIfRecordingFileIsAvailable(), _getRecordingPath()]).then(
      (results) {
        final bool fileExists = results[0] as bool;
        final String filePath = results[1] as String;
        if (fileExists) {
          _preparePlayerForFile(audioFile: File(filePath));
          _transcribe(audioFile: File(filePath));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
        builder: (context, settings, _) => TranscribeModeView(
              phrase: _phrase,
              transcriptUrl: settings.transcribeEndpoint,
              record: _isPlaying ? null : _manageRecording,
              isRecording: _isRecording,
              play: _canPlay && !_isRecording ? _playRecording : null,
              isPlaying: _isPlaying,
              isRecorded: _canPlay,
              uploadStatus: _uploadStatus,
            ));
  }
}
