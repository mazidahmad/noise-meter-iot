import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tubes_iot/app.dart';

class ResultPage extends StatelessWidget {
  const ResultPage(
      {required this.maxDB,
      required this.meanDB,
      required this.chartData,
      required this.currTime,
      required this.listDecibel,
      required this.duration,
      super.key});

  final double maxDB;
  final double meanDB;
  final List<ChartData> chartData;
  final DateTime currTime;
  final List<List<dynamic>> listDecibel;
  final int duration;

  void getCsv() async {
    if (await Permission.storage.request().isGranted) {
      String dir =
          "${(await getExternalStorageDirectory())!.path}/${currTime.toString()}.csv";

      File f = File(dir);

      String csv = const ListToCsvConverter().convert(listDecibel);
      f.writeAsString(csv);
      OpenFile.open(dir);
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        title: const Text(
          "Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () => getCsv(), icon: const Icon(Icons.save)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Environment Status",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Image.asset(
                    meanDB > 55 ? "assets/noisy.png" : "assets/study.png",
                    height: 150,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: meanDB > 55 ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      meanDB > 55 ? "NOISY" : "STUDIABLE",
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 5),
                              )
                            ]),
                        child: Column(
                          children: const [
                            Text(
                              "Duration (s)",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '3600',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 5),
                              )
                            ]),
                        child: Column(
                          children: [
                            const Text(
                              "Avg",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              meanDB.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 5),
                              )
                            ]),
                        child: Column(
                          children: [
                            const Text(
                              "Max",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              maxDB.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Decree of the State Minister for the Environment No. 48 of 1996 concerning"
                      " noise quality standards, in an activity environment, especially schools or"
                      " the like, the allowed noise level is only 55 dB(A).",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
