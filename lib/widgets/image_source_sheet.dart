import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {

  final Function(File) onImageSelected;

  ImageSourceSheet({this.onImageSelected});

  void imageSelected(File image) async {
    onImageSelected(image);
    /*
    if(image != null){
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path, ratioX: 1.0, ratioY: 1.0,
        toolbarTitle: 'Edite sua foto',
      );
      onImageSelected(croppedImage);
    }
     */
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              File image = await ImagePicker.pickImage(source: ImageSource.camera);
              imageSelected(image);
            },
            icon: Icon(Icons.camera_alt),
            label: Text('Tirar uma foto'),
          ),
          FlatButton.icon(
            onPressed: () async {
              File image = await ImagePicker.pickImage(source: ImageSource.gallery);
              imageSelected(image);
            },
            icon: Icon(Icons.photo_library),
            label: Text('Buscar na galeria'),
          ),
        ],
      ),
    );
  }
}
