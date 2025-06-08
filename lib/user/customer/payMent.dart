import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/textFieldComponent.dart';
import 'package:mobile/provider/cart_model.dart';
import 'package:mobile/user/customer/submitPayment.dart';
import 'package:provider/provider.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  File? _image;
  final ImagePicker picker = ImagePicker();

  void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  openCamera(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'ปรับแต่งรูปภาพ',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.white,
            activeControlsWidgetColor: Colors.green,
            dimmedLayerColor: Colors.black.withOpacity(0.5),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            statusBarColor: Colors.green,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      print('Error cropping image: $e');
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to crop image. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    return null;
  }

  Future<void> processImage(ImageSource source, bool isGemini) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        final File? croppedImage = await cropImage(pickedFile.path);
        if (croppedImage != null && mounted) {
          print("_image $croppedImage");
          setState(() {
            _image = croppedImage;
          });
        }
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to process image. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future getImage() async {
    await processImage(ImageSource.gallery, false);
  }

  Future<void> openCamera(BuildContext context) async {
    await processImage(ImageSource.camera, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 8),
            Text(
              'ชำระเงิน',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _image != null
                                  ? Image.file(
                                      _image!,
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/alt.png',
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            "ชื่อบัญชี",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " : ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Tops market",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            "บัญชี",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " : ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "ธนาคารกสิกรไทย",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            "เลขบัญชี",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " : ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "xxx-x-x1041-x",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "ราคารวมทั้งหมด",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        Text(
                                          "${Provider.of<CartModel>(context, listen: true).total} บาท",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            showPicker(context);
                                          },
                                          icon: Icon(
                                            Icons.file_upload_outlined,
                                            color: Colors.black,
                                          ),
                                          label: Text(
                                            "ส่งสลิปหลักฐานการจ่ายเงิน",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey[400],
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Submitpayment(),
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ชำระเงิน",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Submitpayment extends StatefulWidget {
  const Submitpayment({super.key});

  @override
  State<Submitpayment> createState() => _SubmitpaymentState();
}

class _SubmitpaymentState extends State<Submitpayment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ยืนยันการชำระเงินเรียบร้อย",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "กรุณารอการยืนยันจากร้านค้า...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.grey, width: 1),
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                "ยืนยัน",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
