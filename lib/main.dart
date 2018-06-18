import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';

import 'package:botonera_atr/model/audios.dart';

void main() => runApp(new BotoneraApp());

class BotoneraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Botonera ATR',
      theme: new ThemeData(
        primaryColor: Colors.lightGreen[600],
        accentColor: Colors.amber,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(
            'Botonera ATR',
            style: new TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 1.5,
        ),
      body: new HomePageBody(kAudios),
    );
  }
}

class HomePageBody extends StatelessWidget {
  final List<Audios> _audios;
  HomePageBody(this._audios);

  @override
    Widget build(BuildContext context) {
      return new GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.65,
        children: _audios.map((audio) {
          return new GestureDetector(
            onLongPress: () { _shareFile(audio.nombreArchivo.toString()); },
            child: new Container(
              margin: new EdgeInsets.all(1.0),
              child: new RaisedButton(
                color: new Color(0xFFF9A825),
                onPressed: (){ _playFile(audio.nombreArchivo.toString()); },
                elevation: 3.0,
                child: new Text(
                      audio.nombre.toString(),
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white
                        ),
                      ),
              ),
            ),
          );
        }).toList(),
      );
    } 

  _shareFile(nombreArchivo) async {
    try {
      final ByteData bytes = await rootBundle.load('audios/'+nombreArchivo.toString()+'.mp3');
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/audio.mp3').create();
      file.writeAsBytesSync(list);

      final channel = const MethodChannel('channel:me.albie.share/share');
      channel.invokeMethod('shareFile', 'audio.mp3');

    } catch (e) {
      print('Share error: $e');
    }
  }

  _playFile(nombrearchivo) async {
    try {
      AudioPlayer audioPlayer = new AudioPlayer();
      final file = new File('${(await getTemporaryDirectory()).path}/audio.mp3');
      file.writeAsBytesSync((await rootBundle.load('audios/'+nombrearchivo.toString()+'.mp3')).buffer.asUint8List());
      audioPlayer.play(file.path, isLocal: true);
    } catch (e) {
      print('Player error: $e');
    }
  }
}