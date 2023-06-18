import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({
    super.key,
    required this.attrs,
    required this.onSavePressed,
    required this.onRemoveAllPressed,
  });

  final dynamic attrs;
  final void Function(dynamic) onSavePressed;
  final void Function() onRemoveAllPressed;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  dynamic keys;

  @override
  void initState() {
    super.initState();   
    keys = widget.attrs.keys.toList();
  }


  void _onSave() {
    widget.onSavePressed(widget.attrs);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _onSave,
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
          child: const Row(children: [
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
    print("BODY > ");
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: keys != null ? ListView.builder(
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final value = widget.attrs[keys[index]];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                onChanged: (value) => widget.attrs[keys[index]] = value,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: keys[index],
                  hintText: value.toString(),
                ),
              ),
            );
          },
        ) : const Center(child: CircularProgressIndicator()));
  }
}
