import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: VecchiaFattoria(),
    debugShowCheckedModeBanner: false,
  ));
}

class VecchiaFattoria extends StatefulWidget {
  @override
  _VecchiaFattoriaState createState() => _VecchiaFattoriaState();
}

class _VecchiaFattoriaState extends State<VecchiaFattoria> {
  bool _caricamento;
  File _img;
  List _output;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _caricamento = true;
    modello().then((value) {
      setState(() {
        _caricamento = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text('Test TFLite su android'),
        centerTitle: true,
      ),


      body: _caricamento ?
       Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator()) 
        :
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _img == null ? Container():Image.file(_img),
              SizedBox(height: 20),
              _output != null ? Container(child: Column(children:<Widget> [
                Text('Precisione ${ _output[0]['confidence']*100}'),
                Text('Classe ${ _output[0]['label']}')]))  : Container()
            ],
          ),
        ),
    


      floatingActionButton: 
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [ 
        FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () {
          scattaImage();
        },
      ),
      SizedBox(width: 30),
       FloatingActionButton(
        child: Icon(Icons.image),
        onPressed: () {
          scegliImage();
        },
      ),],)
    ));
  }

  scegliImage() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _caricamento = true;
      _img = image;
    });
    inferenzaImg(image);
  }

  scattaImage() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _caricamento = true;
      _img = image;
    });
    inferenzaImg(image);
  }

  inferenzaImg(File image) async {
    var out = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 3,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _caricamento = false;
      _output = out;
    });
  }

  modello() async {
    await Tflite.loadModel(
        model: "asset/model_unquant.tflite", labels: "asset/labels.txt");
  }
}
