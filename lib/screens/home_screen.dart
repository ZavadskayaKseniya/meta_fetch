import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:exif/exif.dart';
import 'package:meta_fetch/screens/edit_screen.dart';
import 'package:meta_fetch/utils/styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pulp_flash/pulp_flash.dart';
import 'package:gallery_saver/gallery_saver.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  dynamic _mutableMeta;
  dynamic _immutableMeta;
  dynamic _attrs;
  dynamic _newImage;

  Future<void> _uploadImage(ImageSource source) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(source: source);
    } catch (e) {
      print(e);
    }

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage!.path);
        _newImage = null;
      });

      final exif = await Exif.fromPath(pickedImage.path);
      final attrs = await exif.getAttributes();
      

      final immMeta = await readExifFromFile(_imageFile!);
      
      setState(() {
        _mutableMeta = exif;
        _immutableMeta = {
            "Image Make": immMeta['Image Make'], 
            "Image Model": immMeta['Image Model'], 
            "Image Artist": immMeta['Image Artist'], 
            "Image DateTime": immMeta['Image DateTime'], 
            "GPS GPSLatitude": immMeta['GPS GPSLatitude'], 
            "GPS GPSLongitude": immMeta['GPS GPSLongitude'],
        };
        _attrs = attrs;
      });
    }
  }

  Future<void> _exportImage() async {
    if (_imageFile == null || _newImage == null) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('No Image'),
              content: const Text('Please upload an image first.  '),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
    try {
      final File? newFile = await _imageFile?.writeAsBytes(_newImage!);

      final exif = await Exif.fromPath(newFile!.path);
      final newFileAttrs = await exif.getAttributes();
      print('NEW FILE ATTRS > ${newFileAttrs?.keys.toList()}');

      final meta = await readExifFromFile(newFile);
      print("NEW FILE META > ${meta.toString()}");

      await GallerySaver.saveImage(newFile.path);

      PulpFlash.of(context).showMessage(
        context,
        inputMessage: Message(
            displayDuration: const Duration(seconds: 3),
            status: FlashStatus.successful,
            title: 'Image Saved'),
      );
    } catch (e) {
      print('ERROR > $e');
    }
  }

  void _editImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditScreen(
          attrs: _attrs,
          onRemoveAllPressed: _removeAllCallback,
          onSavePressed: _onSaveCallback,
        ),
      ),
    );
  }

  Future<void> _removeAllCallback() async {
    // Compress image and remove EXIF Metadata
    try {
      final res = await FlutterImageCompress.compressWithFile(_imageFile!.path);
      //create temporal file from res
      final tmpFile = await File('${Directory.systemTemp.path}/${Random().nextInt(10000)}.jpg').writeAsBytes(res as List<int>);

      final mutMeta = await Exif.fromPath(tmpFile.path);
      final attrs = await mutMeta.getAttributes();

      final immMeta = await readExifFromFile(tmpFile);

      // Read EXIF Metadata from compressed image
      setState(() {
        _newImage = res;
        _mutableMeta = mutMeta;
        _immutableMeta = {
            "Image Make": immMeta['Image Make'], 
            "Image Model": immMeta['Image Model'], 
            "Image Artist": immMeta['Image Artist'], 
            "Image DateTime": immMeta['Image DateTime'], 
            "GPS GPSLatitude": immMeta['GPS GPSLatitude'], 
            "GPS GPSLongitude": immMeta['GPS GPSLongitude'],
        };
        _attrs = attrs;
      });
      // ignore: use_build_context_synchronously
      PulpFlash.of(context).showMessage(context,
          inputMessage: Message(
              displayDuration: const Duration(seconds: 3),
              status: FlashStatus.successful,
              title: 'EXIF Metadata Removed'));
    } catch (e) {
      print('ERROR > $e');
    }
  }

  Future<void> _onSaveCallback(dynamic newAttrs) async {
    // Read EXIF Metadata from original image
    final exif = await Exif.fromPath(_imageFile!.path);

    // Mutate EXIF Metadata
    await exif.writeAttributes(newAttrs);

    // Compress image and keep EXIF Metadata
    final newImage = await FlutterImageCompress.compressWithFile(
      _imageFile!.path,
      keepExif: true
    );

    // Create temporal file from res
    final newExif = await Exif.fromPath(_imageFile!.path);
    final modifiedAttributes = await newExif.getAttributes();
    print('MODIFIED ATTRS > $modifiedAttributes');

    // Read EXIF Metadata from compressed image
    setState(() {
      _newImage = newImage;
      _attrs = modifiedAttributes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(_mutableMeta),
      backgroundColor: Colors.black,
    );
  }

  appBar() {
    return AppBar(
      title: const Text("Metadata Editor"),
      actions: [
        if (_imageFile != null)
          IconButton(
            onPressed: _editImage,
            icon: const Icon(Icons.edit),
          ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  uploadButton() {
    return FloatingActionButton.extended(
      label: const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.upload),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text('Select Image'),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text('Gallery'),
                  onPressed: () {
                    _uploadImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text('Camera'),
                  onPressed: () {
                    _uploadImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        );
      },
      tooltip: 'Upload Image',
    );
  }

  exportButton() {
    return FloatingActionButton(
      backgroundColor: _newImage != null ? Colors.purple : Colors.grey,
      onPressed: (_newImage != null)
          ? () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Export a new image?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _exportImage();
                      },
                      child: const Text('Export'),
                    ),
                  ],
                ),
              );
            }
          : null,
      tooltip: 'Upload Image',
      child: const Icon(Icons.save_alt_outlined),
    );
  }

  metaItem([String value = '']) {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  body(dynamic meta) {
    print('BODY > attrs > $_attrs');
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ListView(
          children: [
            if (_imageFile == null && _mutableMeta == null)
              Container(
                  height: 650,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image, size: 86, color: Colors.white),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'No Image Uploaded',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  )),
            if (_imageFile != null)
              Container(
                padding: const EdgeInsets.all(8),
                height: 500,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
            if (meta != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    for (var key in _immutableMeta.keys.toList())
                      Text(
                        '$key: ${_immutableMeta[key].toString()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                    for (var key in _attrs.keys.toList())
                      Text(
                        '$key: ${_attrs[key].toString()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                  ], 
                  
                    // Text(
                    //   'EXIF Data: ${_mutableMeta}',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    
                    // metaItem('Make: ${meta?['Image Make'].toString()}'),
                    // metaItem('Model: ${meta?['Image Model'].toString()}'),
                    // metaItem('Artist: ${meta?['Image Artist'].toString()}'),
                    // metaItem('DateTime: ${meta?['Image DateTime'].toString()}'),
                    // metaItem('GPS Lat: ${meta?['GPS GPSLatitude'].toString()}'),
                    // metaItem(
                    //     'GPS Long: ${meta?['GPS GPSLongitude'].toString()}'),
                  
                ),
              ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                uploadButton(),
                const SizedBox(width: 8),
                exportButton(),
              ],
            ))
      ],
    );
  }
}
