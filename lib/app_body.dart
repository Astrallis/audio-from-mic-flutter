import 'dart:io' as io;
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:audioplayers/audioplayers.dart';

class AppBody extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  AppBody({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => new AppBodyState();
}

class AppBodyState extends State<AppBody> {
  Recording _recording = new Recording();
  String pathFile;
  bool _isRecording = false;
  bool _isPlaying = false;
  TextEditingController _controller = new TextEditingController();
  AudioPlayer audioPlayer = new AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  playAudioFromLocalStorage(path) async {
    int response = await audioPlayer.play(path, isLocal: true);
    if (response == 1) {
      setState(() {
        _isPlaying = true;
      });
    } else {
      print('Some error occured in playing from storage!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_isRecording ? "Is Recording" : "Not Recording"),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      onPressed: _isRecording ? _stop : _start,
                      icon: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
                  IconButton(
                    onPressed: () {
                      playAudioFromLocalStorage(pathFile);
                    },
                    icon: Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () {
                      audioPlayer.pause();
                      setState(() {
                        _isPlaying = false;
                      });
                    },
                    icon: Icon(Icons.pause),
                  ),
                ]),
            Text(_isPlaying ? "Is Playing" : "Is paused"),
          ],
        ),
      ),
    );
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        if (_controller.text != null && _controller.text != "") {
          String path = _controller.text;
          if (!_controller.text.contains('/')) {
            io.Directory appDocDirectory =
                await getApplicationDocumentsDirectory();
            path = appDocDirectory.path + '/soundRecord';
          }
          print("Start recording: $path");
          await AudioRecorder.start(
              path: path, audioOutputFormat: AudioOutputFormat.AAC);
        } else {
          await AudioRecorder.start();
        }
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    setState(() {
      pathFile = recording.path;
    });
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
    _controller.text = recording.path;
  }
}
