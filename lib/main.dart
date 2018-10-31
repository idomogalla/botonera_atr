import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:botonera_atr/model/audios.dart';

void main() => runApp(new BotoneraApp());

class BotoneraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Botonera ATR',
      theme: new ThemeData(
        brightness: Brightness.light,
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
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.help),
              color: new Color(0xFFFFFFFF),
              onPressed: () async { await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new SimpleDialog(
                    title: const Text(
                      'Compartir',
                      textAlign: TextAlign.center
                    ),                 
                    children: <Widget>[
                      const Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: const Text(
                          'Para compartir un audio se debe mantener presionado el audio deseado hasta que ' +
                          'salga el menú contextual de compartir.',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16.5,                            
                          ),
                          )
                      )
                    ]
                  );
                },
              ); },
            ),
          ],
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
        // Creo el botón
        crossAxisCount: 3,
        childAspectRatio: 1.65,
        // Mapeo todos los audios y voy cargando uno a uno a través de audio (Ver model/audios.dart)
        children: _audios.map((audio) {
          return new GestureDetector( // Detector de gestos para compartir
            onLongPress: () { _shareFile(audio.nombreArchivo.toString()); },
            child: new Container( // Configuración del botón
              margin: new EdgeInsets.all(1.0),
              child: new RaisedButton(
                color: new Color(0xFFF9A825),
                onPressed: (){ _playFile(audio.nombreArchivo.toString()); }, // Al presionar se activa el reproductor
                elevation: 4.0,
                splashColor: Colors.red,
                animationDuration: new Duration(seconds: 2),
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
      // Guardo el archivo que está en la carpeta audios en la carpeta temporal y lo reproduzco
      final file = new File('${(await getTemporaryDirectory()).path}/audio.mp3');
      file.writeAsBytesSync((await rootBundle.load('audios/'+nombrearchivo.toString()+'.mp3')).buffer.asUint8List());
      audioPlayer.play(file.path, isLocal: true);
    } catch (e) {
      print('Player error: $e');
    }
  }
}