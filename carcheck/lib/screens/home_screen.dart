import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carcheck/screens/account_screen.dart';
import 'package:carcheck/screens/login_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добро пожаловать'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  'https://yt3.googleusercontent.com/z0G-ZD634jSYELPCZx8qqQ7f7613iAWVJN5cW1xlz56tGibvH_FsGbpEwLhHSPK_eJ8ao-GSn4E=s900-c-k-c0x00ffffff-no-rj',
                  fit: BoxFit.contain,
                  width: 450,
                  height: 450,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Добро пожаловать в приложение CarCheck!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Мы поможем вам контролировать и отслеживать техническое состояние вашего автомобиля.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Перейти на экран входа
                Navigator.pushNamed(context, '/login');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login),
                  const SizedBox(width: 10),
                  const Text('Войти'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Перейти на экран регистрации
                Navigator.pushNamed(context, '/signup');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add),
                  const SizedBox(width: 10),
                  const Text('Зарегистрироваться'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
