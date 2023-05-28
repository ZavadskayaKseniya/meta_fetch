import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulp_flash/pulp_flash.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({
    super.key,
    required this.meta,
    required this.onSavePressed,
    required this.onRemoveAllPressed,
  });

  final dynamic meta;
  final void Function(dynamic) onSavePressed;
  final void Function() onRemoveAllPressed;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final makeText = TextEditingController();
  final modelText = TextEditingController();
  final artistText = TextEditingController();
  final dateTimeText = TextEditingController();
  final latitudeText = TextEditingController();
  final longitudeText = TextEditingController();

  @override
  void initState() {
    super.initState();
    makeText.text = widget.meta['Image Make'].toString();
    modelText.text = widget.meta['Image Model'].toString();
    artistText.text = widget.meta['Image Artist'].toString();
    dateTimeText.text = widget.meta['Image DateTime'].toString();
    latitudeText.text = widget.meta['GPS GPSLatitude'].toString();
    longitudeText.text = widget.meta['GPS GPSLongitude'].toString();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.meta);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => {
              widget.onSavePressed(widget.meta),
              Navigator.of(context).pop()
            },
            icon: const Icon(Icons.save),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Edit Metadata"),
      ),
      body: _Body(),
      persistentFooterButtons: [
        CupertinoButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove All'),
                content: const Text(
                    'Are you sure you want to remove all image metadata?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () {
                      print("Remove All Pressed");
                      widget.onRemoveAllPressed();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Remove All',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          child: Row(children: const [
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Remove All',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  _Body() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: makeText,
              onChanged: (value) => widget.meta['Image Make'] = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Image Make',
                hintText: widget.meta['Image Make'].toString(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: modelText,
              onChanged: (value) =>
                  widget.meta['Image Model'] = value as IfdTag,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Image Model',
                hintText: widget.meta['Image Model'].toString(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: artistText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Image Artist',
                hintText: widget.meta['Image Artist'].toString(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dateTimeText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Image DateTime',
                hintText: widget.meta['Image DateTime'].toString(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: latitudeText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'GPS Latitude',
                hintText: widget.meta['GPS GPSLatitude'].toString(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: longitudeText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'GPS Longitude',
                hintText: widget.meta['GPS GPSLongitude'].toString(),
              ),
            ),
          ],
        ));
  }
}
