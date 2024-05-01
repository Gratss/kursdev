import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_car_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> userCars = [];
  List<Map<String, dynamic>> addresses = [];
  List<Map<String, dynamic>> tehosmotrRecords = [];

  @override
  void initState() {
    super.initState();
    fetchUserCars();
    fetchAddresses();
    fetchTehosmotrRecords();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> fetchUserCars() async {
    final userCarsSnapshot = await FirebaseFirestore.instance
        .collection('cars')
        .where('userEmail', isEqualTo: user!.email)
        .get();

    setState(() {
      userCars = userCarsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> fetchAddresses() async {
    final addressesSnapshot =
    await FirebaseFirestore.instance.collection('adresa').get();

    setState(() {
      addresses = addressesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> fetchTehosmotrRecords() async {
    try {
      final tehosmotrSnapshot = await FirebaseFirestore.instance
          .collection('tehosmotr')
          .where('userEmail', isEqualTo: user!.email)
          .get();

      setState(() {
        tehosmotrRecords = tehosmotrSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Ошибка при получении записей ТО: $e');
    }
  }

  Future<void> deleteCar(String vin) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('cars')
          .where('vin', isEqualTo: vin)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final carId = querySnapshot.docs[0].id;
        await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Машина успешно удалена'),
            duration: Duration(seconds: 2),
          ),
        );
        fetchUserCars();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Машина с указанным VIN не найдена'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении машины: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Image> decodeImages(List<String> encodedImages) {
    return encodedImages.map((encodedImage) {
      final bytes = base64Decode(encodedImage);
      return Image.memory(bytes);
    }).toList();
  }

  bool isTimeForService(int lastServiceMileage, int mileage) {
    return mileage - lastServiceMileage > 10000;
  }

  void showServiceModal(String carVin) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return ListTile(
              title: Text(
                'Город: ${address['city']}, Улица: ${address['street']}, Номер: ${address['number']}',
              ),
              onTap: () {
                confirmBooking(carVin, address);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> confirmBooking(String carVin, Map<String, dynamic> address) async {
    try {
      await FirebaseFirestore.instance.collection('tehosmotr').add({
        'userEmail': user!.email,
        'carVin': carVin,
        'address': address,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бронь на ТО успешно оформлена'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при бронировании ТО: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCarInfoScreen(),
                  ),
                ).then((value) {
                  if (value != null && value is Map<String, dynamic>) {
                    fetchUserCars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Машина успешно добавлена'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.directions_car),
              label: const Text('Добавить машину'),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Ваши машины:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userCars.length,
                itemBuilder: (context, index) {
                  final car = userCars[index];
                  final List<String> images = List<String>.from(car['images'] ?? []);
                  final List<Image> decodedImages = decodeImages(images);
                  final int mileage = car['mileage'] ?? 0;
                  final int lastServiceMileage = car['lastServiceMileage'] ?? 0;
                  final bool timeForService = isTimeForService(lastServiceMileage, mileage);
                  final carVin = car['vin'];
                  final tehosmotrRecord = tehosmotrRecords.firstWhere(
                        (record) => record['carVin'] == carVin,
                    orElse: () => <String, dynamic>{},
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Марка: ${car['brand']}, Модель: ${car['model']}'),
                            Text('Пробег: $mileage км'),
                            Text('Пробег с последнего ТО: ${mileage - lastServiceMileage} км'),
                            if (timeForService) ...[
                              const Text(
                                'Рекомендуем записаться на ТО',
                                style: TextStyle(color: Colors.red),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showServiceModal(carVin);
                                },
                                icon: const Icon(Icons.event_available),
                                label: const Text('Записаться на ТО'),
                              ),
                            ],
                            if (tehosmotrRecord.isNotEmpty) ...[
                              Text('Запись на ТО: ${tehosmotrRecord['address']['city']}, ${tehosmotrRecord['address']['street']}'),
                            ],
                            SizedBox(
                              height: 200,
                              child: PageView(
                                children: decodedImages,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteCar(car['vin']),
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
