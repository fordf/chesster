import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatelessWidget {
  const ImageInput({
    super.key,
    required this.onChanged,
    required this.value,
  });

  final void Function(File image) onChanged;
  final File? value;

  void _addImage(ImageSource imageSource) async {
    final imagePicker = ImagePicker();
    final xFile = await imagePicker.pickImage(
      source: imageSource,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (xFile == null) return;
    final image = File(xFile.path);

    onChanged(image);
  }

  void _onEditProfilePic(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () {
                  _addImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                label: const Text('Choose photo'),
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
              const SizedBox(width: 20),
              TextButton.icon(
                onPressed: () {
                  _addImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
                label: const Text('Take a Photo'),
                icon: const Icon(Icons.photo_camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onEditProfilePic(context);
      },
      // borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        height: 116,
        width: 116,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              foregroundImage: value == null ? null : FileImage(value!),
            ),
            Positioned(
              bottom: 0,
              right: -25,
              child: InkWell(
                onTap: () {
                  _onEditProfilePic(context);
                },
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Colors.blue, // Background color of the circle
                  child: Icon(
                    Icons.edit,
                    color: Colors.white, // Color of the icon
                    size: 20, // Size of the icon
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   return Column(
  //     children: [
  // CircleAvatar(
  //   radius: 40,
  //   backgroundColor: Colors.grey,
  //   foregroundImage: value == null ? null : FileImage(value!),
  // ),
  // Row(
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   children: [
  //     IconButton(
  //       style: ButtonStyle(
  //         backgroundColor:
  //             WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
  //       ),
  //       onPressed: () {
  //         _addImage(ImageSource.gallery);
  //       },
  //       // label: const Text(''),
  //       icon: const Icon(Icons.add_photo_alternate_outlined),
  //     ),
  //     const SizedBox(width: 20),
  //     IconButton(
  //       style: ButtonStyle(
  //         backgroundColor:
  //             WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
  //       ),
  //       onPressed: () {
  //         _addImage(ImageSource.camera);
  //       },
  //       // label: const Text('Take a Photo'),
  //       icon: const Icon(Icons.photo_camera),
  //     ),
  //   ],
  // )
  //     ],
  //   );
  // }
}

  // @override
  // Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
  //   return Container(
  //     height: 250,
  //     width: double.infinity,
  //     alignment: Alignment.center,
  //     decoration: BoxDecoration(
  //       image: value == null
  //           ? null
  //           : DecorationImage(
  //               image: FileImage(value!),
  //               fit: BoxFit.cover,
  //             ),
  //       border: Border.all(
  //         color: colorScheme.primary.withOpacity(.2),
  //       ),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
          // ElevatedButton.icon(
          //   style: ButtonStyle(
          //     backgroundColor:
          //         WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
          //   ),
          //   onPressed: () {
          //     _addImage(ImageSource.gallery);
          //   },
          //   label: const Text('Choose an Image from your Gallery'),
          //   icon: const Icon(Icons.add_photo_alternate_outlined),
          // ),
          // const SizedBox(height: 20),
          // TextButton.icon(
          //   style: ButtonStyle(
          //     backgroundColor:
          //         WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
          //   ),
          //   onPressed: () {
          //     _addImage(ImageSource.camera);
          //   },
          //   label: const Text('Take a Photo'),
          //   icon: const Icon(Icons.camera),
          // ),
  //       ],
  //     ),
  //   );
  // }

