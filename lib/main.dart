import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  bool isConnected = false;
  String message = 'No data received';

  @override
  void initState() {
    super.initState();
    connectToHC05();
  }

  Future<void> connectToHC05() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    BluetoothDevice? hc05Device;

    for (var device in devices) {
      if (device.name == 'HC-05') {
        hc05Device = device;
        break;
      }
    }

    if (hc05Device != null) {
      await BluetoothConnection.toAddress(hc05Device.address).then((_connection) {
        connection = _connection;
        isConnected = true;
        setState(() {});

        // Listen for incoming data
        connection!.input!.listen((Uint8List data) {
          String incomingData = String.fromCharCodes(data).trim();
          setState(() {
            message = incomingData;
          });
          print('Received: $incomingData');  // Print received data to console
        }).onDone(() {
          // This will be triggered when the connection is disconnected
          print('Disconnected by remote or connection lost');
          disconnect();
        });
      }).catchError((error) {
        print('Cannot connect, exception occurred: $error');
        disconnect();  // Update the UI and state to reflect disconnection
      });
    }
  }

  void disconnect() {
    // Update the state to reflect disconnection
    if (connection != null) {
      connection!.dispose();
      connection = null;
    }
    isConnected = false;
    setState(() {});
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('HC-05 Bluetooth'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(isConnected ? 'Connected to HC-05' : 'Not connected'),
              SizedBox(height: 20),
              Text('Received Message:'),
              SizedBox(height: 10),
              Text(message, style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
