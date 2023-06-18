import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tubes_iot/result_page.dart';

class NoiseApp extends StatefulWidget {
  const NoiseApp({super.key});

  @override
  NoiseAppState createState() => NoiseAppState();
}

class NoiseAppState extends State<NoiseApp> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  double maxDB = 0;
  double highestDB = 0;
  double meanDB = 0;
  List<ChartData> chartData = <ChartData>[];
  late int previousMillis;
  late DateTime currTime;
  Stopwatch duration = Stopwatch();
  int currDuration = 0;
  List<List<dynamic>> listDecibel = [];

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (_isRecording) {
        maxDB = noiseReading.maxDecibel;
        meanDB = noiseReading.meanDecibel;

        currTime = DateTime.now();

        if (currDuration < duration.elapsed.inSeconds) {
          currDuration = duration.elapsed.inSeconds;
          if (highestDB < maxDB) highestDB = maxDB;
          listDecibel.add([currDuration, maxDB]);
          chartData.add(
            ChartData(
              maxDB,
              meanDB,
              currDuration.toDouble(),
            ),
          );
        }
      }
    });
  }

  void onError(Object e) {
    _isRecording = false;
  }

  void start() async {
    listDecibel = [
      ["Second", "dB(A)"]
    ];
    currDuration = 0;
    currTime = DateTime.now();
    duration.reset();
    previousMillis = 0;
    maxDB = 0;
    highestDB = 0;
    chartData.clear();
    previousMillis = DateTime.now().millisecondsSinceEpoch;
    currTime = DateTime.now();
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      Future.delayed(const Duration(seconds: 1)).then((value) {
        setState(() {
          if (!_isRecording) _isRecording = true;
          duration.start();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void stop() async {
    try {
      _noiseSubscription!.cancel();
      _noiseSubscription = null;
      duration.stop();

      setState(() => _isRecording = false);
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => ResultPage(
                    chartData: chartData,
                    currTime: currTime,
                    listDecibel: listDecibel,
                    maxDB: highestDB,
                    meanDB: meanDB,
                    duration: currDuration,
                  ))));
    } catch (e) {
      print('stopRecorder error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: const Text(
          'Noise Meter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(_isRecording ? 'Stop' : 'Start'),
        onPressed: _isRecording ? stop : start,
        icon: !_isRecording ? const Icon(Icons.circle) : null,
        backgroundColor: _isRecording ? Colors.red : Colors.green,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  RadialGauge(
                    track: const RadialTrack(
                        start: 0,
                        end: 100,
                        color: Colors.white,
                        thickness: 20,
                        hideLabels: true,
                        trackStyle: TrackStyle(
                          secondaryRulerColor: Colors.blue,
                          primaryRulerColor: Colors.white,
                        ),
                        steps: 20),
                    valueBar: [
                      RadialValueBar(
                        value: maxDB,
                        valueBarThickness: 20,
                        gradient: const LinearGradient(
                            colors: [Colors.green, Colors.red]),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        maxDB.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: maxDB > 55 ? Colors.red : Colors.green[500]),
                      ),
                      const Text(
                        'dB (A)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
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
                      children: [
                        const Text(
                          "Duration",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          duration.elapsed.inSeconds.toString(),
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
                          highestDB.toStringAsFixed(1),
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
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: SfCartesianChart(
                backgroundColor: Colors.white,
                series: <LineSeries<ChartData, double>>[
                  LineSeries<ChartData, double>(
                      dataSource: chartData,
                      xAxisName: 'Time',
                      yAxisName: 'dB',
                      name: 'dB values over time',
                      enableTooltip: true,
                      xValueMapper: (ChartData value, _) => value.frames,
                      yValueMapper: (ChartData value, _) => value.maxDB,
                      animationDuration: 0),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 68,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final double? maxDB;
  final double? meanDB;
  final double frames;

  ChartData(this.maxDB, this.meanDB, this.frames);
}
