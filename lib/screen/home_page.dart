import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/models/home_response.dart';
import 'package:presensi/screen/login_page.dart';
import 'package:presensi/screen/simpan_page.dart';
import 'package:presensi/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String> _name, _token;

  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    super.initState();
    _token = SharedPreferences.getInstance().then((prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = SharedPreferences.getInstance().then((prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future<void> getData() async {
    String token = await _token;
    var response = await ApiService.getPresensi(token);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    for (var element in homeResponseModel!.data) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            color: Colors.red,
          ),
        ],
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: _name,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hallo ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Text("-",
                                style: TextStyle(fontSize: 18));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade500,
                            offset: const Offset(4.0, 4.0),
                            blurRadius: 15.0,
                            spreadRadius: 1.0,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-4.0, -4.0),
                            blurRadius: 15.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              hariIni?.tanggal ?? '-',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontFamily: 'NexaBold'),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(hariIni?.masuk ?? '-',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontFamily: 'NexaBold')),
                                    const Text("Masuk",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 110, 224, 114),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NexaLight'))
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(hariIni?.pulang ?? '-',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontFamily: 'NexaBold')),
                                    const Text(
                                      "Pulang",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 246, 159, 29),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NexaLight'),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Riwayat Presensi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (BuildContext context, int index) {
                        var element = riwayat[riwayat.length - index - 1];
                        return Card(
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tanggal: ${element.tanggal}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Masuk: ${element.masuk}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  "Pulang: ${element.pulang}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      reverse: false,
                    )),
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const SimpanPage()))
              .then((value) {
            setState(() {});
          });
        },
        child: const Icon(
          Icons.add_location_alt,
          color: Colors.white,
        ),
      ),
    );
  }
}
