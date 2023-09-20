import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  String result = '';
  late ImagePicker imagePicker;

  late TextRecognizer textRecognizer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    textRecognizer = GoogleMlKit.vision.textRecognizer();

    //TODO initialize detector
  }

  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    File image = File(pickedFile!.path);
    setState(() {
      _image = image;
      if (_image != null) {
        doTextRecognition();
      }
    });
  }

  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      setState(() {
        _image = image;
        if (_image != null) {
          doTextRecognition();
        }
      });
    }
  }

  doTextRecognition() async {
    if (_image != null) {
      final inputImage = InputImage.fromFile(_image!);

      RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      result = '';

      for (TextBlock textBlock in recognizedText.blocks) {
        /* final Rect rect = textBlock.boundingBox;

        final List<Point<int>> cornerPoints = textBlock.cornerPoints;

        final String text = textBlock.text;

        final List<String> languages = textBlock.recognizedLanguages; */

        for (TextLine line in textBlock.lines) {
          for (TextElement element in line.elements) {
            result += '${element.text} ';
          }

          result += '\n';
        }
        result += '\n\n';
      }

      setState(() {
        result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg2.jpg'), fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              const SizedBox(
                width: 100,
              ),
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/notebook.png'),
                      fit: BoxFit.cover),
                ),
                height: 280,
                width: 250,
                margin: const EdgeInsets.only(top: 70),
                padding: const EdgeInsets.only(left: 28, bottom: 5, right: 18),
                child: SingleChildScrollView(
                    child: Text(
                  result,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 10),
                )),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, right: 140),
                child: Stack(children: <Widget>[
                  Center(
                    child: Image.asset(
                      'images/clipboard.png',
                      height: 240,
                      width: 240,
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _imgFromGallery,
                      onLongPress: _imgFromCamera,
                      style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          shadowColor: Colors.transparent),
                      child: Container(
                        margin: const EdgeInsets.only(top: 25),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                width: 140,
                                height: 192,
                                fit: BoxFit.fill,
                              )
                            : Container(
                                width: 140,
                                height: 150,
                                child: Icon(
                                  Icons.find_in_page,
                                  color: Colors.grey[800],
                                ),
                              ),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
