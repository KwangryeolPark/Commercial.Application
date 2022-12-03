import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowerpot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference control = FirebaseDatabase.instance.ref("control");
  DatabaseReference current = FirebaseDatabase.instance.ref("current");
  DatabaseReference data = FirebaseDatabase.instance.ref("data");

  int watering = 0;
  int n = -1;
  double humi = -1;
  double level = -1;
  Map<String, dynamic> report = Map();
  List<Text> listTiles = [];

  @override
  void initState() {
    super.initState();
    control.child('watering').get().then((snapshot) {
      setState(() {
        watering = snapshot.value as int;
      });
    });
    current.child('humi').get().then((snapshot) {
      var humi = snapshot.value as double;
      setState(() {
        this.humi = humi.toDouble()*100;
      });
    });
    current.child('level').get().then((snapshot) {
      var level = snapshot.value as double;
      setState(() {
        this.level = level.toDouble();
      });
    });
    data.get().then((snapshot) {
      report = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
      n = report["n"] as int;
      List<String> date = report.keys.toList();
      DateTime now = DateTime.now();

      date.remove("n");
      date.sort();
      setState(() {
        for(int i = 0; i < date.length; i++) {
          var time = int.tryParse(date[i]);
          if (time is int) {
            time = (time) * 1000;
            DateTime reportDateTime = DateTime.fromMillisecondsSinceEpoch(time);
            Duration diff = now.difference(reportDateTime);
            if ((diff.inDays).abs() <= 7) {
              Map<String, dynamic> data = report[date[i]];
              int pump = data["pump"] as int;
              String pumpState = (pump == 0) ? 'off' : 'on';
              if ((diff.inDays).abs() == 0) {
                listTiles.add(Text('오늘, ${reportDateTime.hour}:${reportDateTime.minute}:${reportDateTime.second} Humi: ${(data["humi"]*100).toInt()}% Pump: $pumpState', style: const TextStyle(fontSize: 15), textAlign: TextAlign.center));
              } else if ((diff.inDays).abs() == 1) {
                listTiles.add(Text('어제, ${reportDateTime
                    .hour}:${reportDateTime.minute}:${reportDateTime
                    .second} Humi: ${(data["humi"]*100).toInt()}% Pump: $pumpState',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center));
              } else {
                listTiles.add(Text('${(diff.inDays).abs()}일 전, ${reportDateTime
                    .hour}:${reportDateTime.minute}:${reportDateTime
                    .second} Humi: ${(data["humi"]*100).toInt()}% Pump: $pumpState',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center));
              }
            }
          }
        }
      });
    });


    control.onValue.listen((DatabaseEvent event) {
      final control = event.snapshot.value as Map;
      setState(() {
        watering = control["watering"] as int;
      });
    });
    current.onValue.listen((DatabaseEvent event) {
      final current = event.snapshot.value as Map;
      var humi = current["humi"];
      var level = current["level"];
      setState(() {
        this.humi = humi.toDouble()*100;
        this.level = level.toDouble();
      });
    });
    data.onValue.listen((DatabaseEvent event) {
      report = jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
      n = report["n"] as int;
      List<String> date = report.keys.toList();
      DateTime now = DateTime.now();

      date.remove("n");
      listTiles.clear();
      date.sort();
      setState(() {
        for(int i = 0; i < date.length; i++) {
          var time = int.tryParse(date[i]);
          if (time is int) {
            time = (time) * 1000;
            DateTime reportDateTime = DateTime.fromMillisecondsSinceEpoch(time);
            Duration diff = now.difference(reportDateTime);
            if ((diff.inDays).abs() <= 7) {
              Map<String, dynamic> data = report[date[i]];
              int pump = data["pump"] as int;
              String pumpState = (pump == 0) ? 'off' : 'on';
              if ((diff.inDays).abs() == 0) {
                listTiles.add(Text('오늘, ${reportDateTime.hour}:${reportDateTime.minute}:${reportDateTime.second} Humi: ${(data["humi"]*100).toInt()}% Pump: $pumpState', style: const TextStyle(fontSize: 15), textAlign: TextAlign.center));
              } else if ((diff.inDays).abs() == 1) {
                listTiles.add(Text('어제, ${reportDateTime
                    .hour}:${reportDateTime.minute}:${reportDateTime
                    .second} Humi: ${(data["humi"]*100).toInt()}% Pump: $pumpState',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center));
              } else {
                listTiles.add(Text('${(diff.inDays).abs()}일 전, ${reportDateTime
                    .hour}:${reportDateTime.minute}:${reportDateTime
                    .second} Humi: ${(data["humi"]*100).toInt()}% Pump: $pumpState',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center));
              }
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flowerpot"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Humidity: ${humi.toInt()}%, Water level: $level", style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 20,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3 * 2,
            child:
            ListView.builder(physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: listTiles.length,
              itemBuilder: (BuildContext context, int index) {
                return listTiles[index];
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
            ((watering != 0) ? Icons.water_drop : Icons.water_drop_outlined)
        ),
        onPressed: () {
          control.update({
            "watering": (watering == 1) ? 0 : 1
          });
        },
      ),
    );
  }
}
