

import 'dart:io';

import 'package:app4/db/db.dart';
import 'package:image_picker/image_picker.dart';

/// Get from camera
Future<File?> getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
    );
    if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await PrincipalDB.saveProfilePicturePath(pickedFile.path);
        return imageFile;
    }
    return null;
}

Future<File?> getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
    );
    if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await PrincipalDB.saveProfilePicturePath(pickedFile.path);
        return imageFile;
    }
    return null;
}