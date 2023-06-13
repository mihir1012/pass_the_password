import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _currPassword;
  List<String> _prevPasswords = List.empty(growable: true);

  int selectArray() {
    int i = Random().nextInt(1000) % 5;
    if (i == 0) {
      i++;
    }
    return i;
  }

  int getKey() {
    int key = Random().nextInt(1000) % 26;
    return key;
  }

  String generatePassword(String? currPass) {
    if (currPass != null && currPass.isNotEmpty) {
      setState(() {
        _prevPasswords.add(currPass);
        _prefs.then((prefs) {
          prefs.setStringList('prev_password', _prevPasswords);
        });
      });
    }
    String password = "";
    const String alphabet = "abcdefghijklmnopqrstuvwxyz";
    const String ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    String s_symbol = "!@#\$%&";
    String number = "0123456789";

    int key,
        count_alphabet = 0,
        count_ALPHABET = 0,
        count_number = 0,
        count_s_symbol = 0;

    int count = 0;
    while (count < 16) {
      // selectArray() function will return a number 1 to 4
      // and will use to select one of the above defined string
      //(i.e alphabet or ALPHABET or s_symbol or number )
      // 1 is for string alphabet
      // 2 is for string ALPHABET
      // 3 is for string number
      // and 4 is for string s_symbol

      int k = selectArray();

      //for the first character of password it is mentioned that,
      //it should be a letter
      //so the string that should be selected is either alphabet or
      //ALPHABET (i.e 1 or 2)
      //following if condition will take care of it.
      if (count == 0) {
        k = k % 3;
        if (k == 0) {
          k++;
        }
      }
      switch (k) {
        case 1:
          // following if condition will check if minimum requirement of alphabet
          // character has been fulfilled or not
          // in case it has been fulfilled and minimum requirements of other
          // characters is still left then it will break ;
          if ((count_alphabet == 2) &&
              (count_number == 0 ||
                  count_ALPHABET == 0 ||
                  count_ALPHABET == 1 ||
                  count_s_symbol == 0)) {
            break;
          }

          key = getKey();
          password = password + alphabet[key];
          count_alphabet++;
          count++;
          break;

        case 2:
          // following if condition will check if minimum requirement of
          // ALPHABET character has been fulfilled or not
          // in case it has been fulfilled and minimum requirements of
          // other characters is still left then it will break ;
          if ((count_ALPHABET == 2) &&
              (count_number == 0 ||
                  count_alphabet == 0 ||
                  count_alphabet == 1 ||
                  count_s_symbol == 0)) {
            break;
          }
          key = getKey();
          password = password + ALPHABET[key];
          count_ALPHABET++;
          count++;
          break;

        case 3:
          // following if condition will check if minimum requirement
          // of Numbers  has been fulfilled or not
          // in case it has been fulfilled and minimum requirements of
          // other characters is still left then it will break ;
          if ((count_number == 1) &&
              (count_alphabet == 0 ||
                  count_alphabet == 1 ||
                  count_ALPHABET == 1 ||
                  count_ALPHABET == 0 ||
                  count_s_symbol == 0)) {
            break;
          }

          key = getKey();
          key = key % 10;
          password = password + number[key];
          count_number++;
          count++;
          break;

        case 4:
          // following if condition will check if minimum requirement of
          // Special symbol character has been fulfilled or not
          // in case it has been fulfilled and minimum requirements of
          // other characters is still left then it will break ;
          if ((count_s_symbol == 1) &&
              (count_alphabet == 0 ||
                  count_alphabet == 1 ||
                  count_ALPHABET == 0 ||
                  count_ALPHABET == 1 ||
                  count_number == 0)) {
            break;
          }

          key = getKey();
          key = key % 6;
          password = password + s_symbol[key];
          count_s_symbol++;
          count++;
          break;
      }
    }
    if (_prevPasswords.contains(password)) {
      return generatePassword(null);
    }
    return password;
  }

  Future<void> _generatePassword() async {
    final SharedPreferences prefs = await _prefs;
    final String password = generatePassword(prefs.getString('password'));

    setState(() {
      _currPassword = prefs.setString('password', password).then((bool success) {
        return password;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _prevPasswords = prefs.getStringList('prev_password') ?? List.empty(growable: true);
      });
    });
    _currPassword = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('password') ?? generatePassword(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<String>(
                future: _currPassword,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          "Current Password: ${snapshot.data}",
                          style: const TextStyle(color: Colors.black),
                        );
                      }
                  }
                }),
            ElevatedButton(
                onPressed: _generatePassword, child: const Text("generate")),
            const Text("Previous Passwords:"),
            Expanded(
              child: ListView.builder(
                itemCount: _prevPasswords.length,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  return ListTile(title: Text(_prevPasswords[i]));
                },
              ),
            ),
          ]),
    );
  }
}
