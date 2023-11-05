import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:presensi/models/save_presensi_response.dart';
import 'package:presensi/screen/chat_page.dart';
import 'package:presensi/screen/home_page.dart';
import 'package:presensi/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import 'package:page_transition/page_transition.dart';

class SimpanPage extends StatefulWidget {
  const SimpanPage({Key? key}) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
  }

  Future<LocationData?> _currenctLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = Location();

    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  void _onSimpanPressed(double latitude, double longitude) async {
    final SharedPreferences prefs = await _prefs;
    final String token = prefs.getString("token") ?? "";

    final response = await ApiService.savePresensi(
      latitude.toString(),
      longitude.toString(),
      token,
    );

    if (response.statusCode == 200) {
      final savePresensiResponseModel =
          SavePresensiResponseModel.fromJson(json.decode(response.body));

      if (savePresensiResponseModel.success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sukses simpan Presensi')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal simpan Presensi')),
        );
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }

  bool isFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Presensi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<LocationData?>(
        future: _currenctLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final LocationData currentLocation = snapshot.data;
            return SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          initialFocalLatLng: MapLatLng(
                              currentLocation.latitude!,
                              currentLocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: currentLocation.latitude!,
                              longitude: currentLocation.longitude!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 25),
                    child: SwipeableButtonView(
                      buttonText: "SIMPAN PRESENSI",
                      buttonWidget: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey,
                      ),
                      activeColor: const Color.fromARGB(255, 30, 126, 209),
                      isFinished: isFinished,
                      onWaitingProcess: () {
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            isFinished = true;
                            _onSimpanPressed(
                              currentLocation.latitude!,
                              currentLocation.longitude!,
                            );
                          });
                        });
                      },
                      onFinish: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const HomePage(),
                          ),
                        );

                        setState(() {
                          isFinished = false;
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 146, 143, 143),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const ChatGPTScreen()))
              .then((value) {
            setState(() {});
          });
        },
        child: const Icon(
          Icons.chat,
          color: Color.fromARGB(255, 43, 41, 41),
        ),
      ),
    );
  }
}
