import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presensi/screen/home_page.dart';
import 'package:presensi/models/login_response.dart';
import 'package:presensi/screen/register_page.dart';
import 'package:presensi/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? emailError;
  String? passwordError;

  Future<String>? _name;
  Future<String>? _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken();
  }

  void checkToken() async {
    String tokenStr = await _token!;
    String nameStr = await _name!;
    if (tokenStr != "" && nameStr != "") {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }

  Future<void> login(String email, String password) async {
    try {
      var response = await ApiService.postLogin(email, password);

      if (response.statusCode == 401) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email atau password salah",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        LoginResponseModel loginResponseModel =
            LoginResponseModel.fromJson(json.decode(response.body));
        saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
      }
    } catch (e) {
      print('An error occurred: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveUser(String token, String name) async {
    try {
      final SharedPreferences pref = await _prefs;
      await pref.setString("name", name);
      await pref.setString("token", token);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (err) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 70,
                  ),
                ),
                const SizedBox(
                  height: 19.0,
                ),
                const Text(
                  "Selamat Datang!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    errorText: emailError,
                  ),
                  onChanged: (_) {
                    setState(() {
                      emailError = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(value)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    errorText: passwordError,
                  ),
                  onChanged: (_) {
                    setState(() {
                      passwordError = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal harus 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      emailError = null;
                      passwordError = null;
                    });

                    String email = emailController.text;
                    String password = passwordController.text;

                    if (email.isEmpty) {
                      setState(() {
                        emailError = 'Email tidak boleh kosong';
                      });
                      return;
                    }

                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(email)) {
                      setState(() {
                        emailError = 'Masukkan email yang valid';
                      });
                      return;
                    }

                    if (password.isEmpty) {
                      setState(() {
                        passwordError = 'Password tidak boleh kosong';
                      });
                      return;
                    }

                    if (password.length < 6) {
                      setState(() {
                        passwordError = 'Password minimal harus 6 karakter';
                      });
                      return;
                    }

                    login(email, password);
                  },
                  child: const Text("Masuk"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Tidak memiliki akun?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterPage()), // Ganti dengan nama halaman pendaftaran Anda
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
