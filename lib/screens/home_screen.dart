import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:exif/exif.dart';
import 'package:meta_fetch/screens/edit_screen.dart';
import 'package:meta_fetch/utils/styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
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
  dynamic _meta;
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
      // final attrs = await exif.getAttributes();
      // print(attrs?.keys.toList());

      final res = await readExifFromFile(_imageFile!);
      setState(() {
        _meta = res;
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
          meta: _meta,
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
      final exifRes = await readExifFromBytes(res!);
      // Read EXIF Metadata from compressed image
      setState(() {
        _newImage = res;
        _meta = exifRes;
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

  Future<void> _onSaveCallback(dynamic newMeta) async {
    print('NEW META > $newMeta');
    final file = await Exif.fromPath(_imageFile!.path);
    final attrs = await file.getAttributes();
    if (newMeta['dateTime'] != '') {
      await file.writeAttribute('DateTimeOriginal', newMeta['dateTime']);
      await file.writeAttribute('DateTimeDigitized', newMeta['dateTime']);
    }
    if (newMeta['latitude'] != '') {
      await file.writeAttribute('GPSLatitude', newMeta['latitude']);
    }
    if (newMeta['longitude'] != '') {
      await file.writeAttribute('GPSLongitude', newMeta['longitude']);
    }

    final res = await file.getAttribute('DateTimeOriginal');
    print('ON SAVE > Image DateTime: ${res}');
    await file.close();

    final exifRes = await readExifFromFile(_imageFile!);
    final newImage = await FlutterImageCompress.compressWithFile(
        _imageFile!.path,
        keepExif: true);
    setState(() {
      _newImage = newImage;
      _meta = exifRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(_meta),
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
    return FloatingActionButton(
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
      child: const Icon(Icons.upload),
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
    print('BODY > META > $meta');
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ListView(
          children: [
            if (_imageFile == null && _meta == null)
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
                    // Text(
                    //   'EXIF Data: ${_meta}',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    metaItem('Make: ${meta?['Image Make'].toString()}'),
                    metaItem('Model: ${meta?['Image Model'].toString()}'),
                    metaItem('Artist: ${meta?['Image Artist'].toString()}'),
                    metaItem('DateTime: ${meta?['Image DateTime'].toString()}'),
                    metaItem('GPS Lat: ${meta?['GPS GPSLatitude'].toString()}'),
                    metaItem(
                        'GPS Long: ${meta?['GPS GPSLongitude'].toString()}'),
                  ],
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
