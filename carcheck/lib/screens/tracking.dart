// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceTrackingScreen extends StatefulWidget {
  const MaintenanceTrackingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaintenanceTrackingScreenState createState() =>
      _MaintenanceTrackingScreenState();
}

class _MaintenanceTrackingScreenState extends State<MaintenanceTrackingScreen> {
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  late File _image; // Переменная для хранения выбранной фотографии

  // Объекты для работы с базой данных Firestore и Storage
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отслеживание технического обслуживания'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _serviceTypeController,
              decoration: const InputDecoration(labelText: 'Тип обслуживания'),
            ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Дата обслуживания'),
              keyboardType: TextInputType.datetime,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  _dateController.text = pickedDate.toString();
                }
              },
            ),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                  labelText: 'Пробег на момент обслуживания'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Комментарии'),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            // ignore: unnecessary_null_comparison
            _image != null
                ? Image.file(
              _image,
              height: 100.0,
            )
                : const SizedBox(), // Отображение выбранной фотографии
            ElevatedButton(
              onPressed: () async {
                // Выбираем фотографию из галереи
                final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80); // Устанавливаем качество изображения

                setState(() {
                  if (pickedImage != null) {
                    _image = File(pickedImage.path);
                  } else {
                    print('No image selected.');
                  }
                });
              },
              child: const Text('Выбрать фотографию'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Получаем введенные данные
                String serviceType = _serviceTypeController.text;
                String date = _dateController.text;
                int? mileage = int.tryParse(_mileageController.text);
                String comment = _commentController.text;

                // Проверяем, чтобы все обязательные поля были заполнены
                if (serviceType.isNotEmpty &&
                    date.isNotEmpty &&
                    mileage != null) {
                  // Создаем новый документ в коллекции "maintenance" с информацией о техническом обслуживании
                  await _firestore.collection('maintenance').add({
                    'serviceType': serviceType,
                    'date': date,
                    'mileage': mileage,
                    'comment':
                    comment, // Добавляем комментарий к данным обслуживания
                    // ignore: unnecessary_null_comparison
                    'imageURL': _image != null
                        ? await uploadImage(
                        _image) // Загружаем изображение в Storage и получаем его URL
                        : null,
                  });

                  // После сохранения данных в базе данных можно вернуться на предыдущий экран
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  // Если не все поля заполнены, выводим сообщение об ошибке
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
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // ignore: unused_local_variable
    firebase_storage.Reference reference =
    _storage.ref().child('images/$fileName');

    return '';
  }
}
