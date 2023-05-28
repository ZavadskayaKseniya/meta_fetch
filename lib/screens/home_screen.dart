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

      setState(() async {
        _meta = await readExifFromFile(_imageFile!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(),
      body: _Body(_meta),
      backgroundColor: Colors.black,
    );
  }

  _AppBar() {
    return AppBar(
      title: const Text("Metadata Editor"),
      actions: [
        if (_imageFile != null)
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                    meta: _meta,
                    onRemoveAllPressed: () async {
                      // Compress image and remove EXIF Metadata
                      try {
                        final res = await FlutterImageCompress.compressWithFile(
                            _imageFile!.path);
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
                    },
                    onSavePressed: (dynamic newMetadata) {
                      print('NEW META > $newMetadata');
                      setState(() {
                        _meta = newMetadata;
                      });
                    },
                  ),
                ),
              );
            },
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

  _UploadButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Image Source'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadImage(ImageSource.gallery);
                },
                child: const Text('Gallery'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadImage(ImageSource.camera);
                },
                child: const Text('Camera'),
              ),
            ],
          ),
        );
      },
      tooltip: 'Upload Image',
      child: const Icon(Icons.upload),
    );
  }

  _ExportButton() {
    return FloatingActionButton(
      backgroundColor: _newImage != null ? Colors.purple : Colors.grey,
      onPressed: (_newImage != null)
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Export a new image?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //TODO: Save image
                        if (_imageFile == null || _newImage == null) {
                          showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text('No Image'),
                                  content: const Text(
                                      'Please upload an image first.  '),
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
                        _imageFile?.writeAsBytes(_newImage!).then((value) {
                          PulpFlash.of(context).showMessage(context,
                              inputMessage: Message(
                                  displayDuration: const Duration(seconds: 3),
                                  status: FlashStatus.successful,
                                  title: 'Image Saved'));
                        }).catchError((e) {
                          print('ERROR > $e');
                        });
                      },
                      child: const Text('Save'),
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

  _Body(dynamic meta) {
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
                    Text(
                      'Image Make: ${meta?['Image Make']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Image Model: ${meta?['Image Model']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Image Artist: ${meta?['Image Artist']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Image DateTime: ${meta?['Image DateTime']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'GPSLatitude: ${meta?['GPS GPSLatitude']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'GPSLongitude: ${meta?['GPS GPSLongitude']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
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
                _UploadButton(),
                const SizedBox(width: 8),
                _ExportButton(),
              ],
            ))
      ],
    );
  }
}