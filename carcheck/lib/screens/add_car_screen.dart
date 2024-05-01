import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class AddCarInfoScreen extends StatefulWidget {
  const AddCarInfoScreen({Key? key}) : super(key: key);

  @override
  _AddCarInfoScreenState createState() => _AddCarInfoScreenState();
}

class _AddCarInfoScreenState extends State<AddCarInfoScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _lastServiceMileageController = TextEditingController();

  List<File> _imageFiles = [];
  final picker = ImagePicker();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить информацию об автомобиле'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Марка'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
              value!.isNullOrBlank ? 'Марка не может быть пустой' : null,
            ),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Модель'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
              value!.isNullOrBlank ? 'Модель не может быть пустой' : null,
            ),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Год выпуска'),
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isNullOrBlank) {
                  return 'Год выпуска не может быть пустым';
                } else if (int.tryParse(value) == null) {
                  return 'Введите корректный год';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(labelText: 'Номер VIN'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
              value!.isNullOrBlank ? 'Номер VIN не может быть пустым' : null,
            ),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(labelText: 'Пробег (км)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _lastServiceMileageController,
              decoration: const InputDecoration(labelText: 'Пробег на последнем ТО (км)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () => saveCarInfo(),
              icon: Icon(Icons.save),
              label: Text('Сохранить'),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Фотографии машины:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _imageFiles.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    _imageFiles[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () => getImage(),
              icon: Icon(Icons.add_a_photo),
              label: Text('Добавить фотографию'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> saveCarInfo() async {
    String brand = _brandController.text;
    String model = _modelController.text;
    int? year = int.tryParse(_yearController.text);
    String vin = _vinController.text;
    int? mileage = int.tryParse(_mileageController.text);
    int? lastServiceMileage = int.tryParse(_lastServiceMileageController.text);

    if (brand.isNullOrBlank ||
        model.isNullOrBlank ||
        year == null ||
        vin.isNullOrBlank ||
        mileage == null ||
        lastServiceMileage == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: const Text('Пожалуйста, заполните все поля'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final user = _auth.currentUser;
      if (user != null) {
        final userEmail = user.email;

        List<String> imageBase64List = [];
        for (var file in _imageFiles) {
          List<int> imageBytes = await file.readAsBytes();
          String imageBase64 = base64Encode(imageBytes);
          imageBase64List.add(imageBase64);
        }

        DocumentReference docRef =
        await _firestore.collection('cars').add({
          'brand': brand,
          'model': model,
          'year': year,
          'vin': vin,
          'userEmail': userEmail,
          'images': imageBase64List,
          'mileage': mileage,
          'lastServiceMileage': lastServiceMileage,
        });

        Navigator.pop(context, {
          'addedCar': {
            'brand': brand,
            'model': model,
          },
          'showSuccessMessage': true,
        });
      }
    }
  }
}

extension StringExtension on String? {
  bool get isNullOrBlank {
    return this == null || this!.trim().isEmpty;
  }
}
