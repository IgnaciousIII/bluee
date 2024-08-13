import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothHandler extends ChangeNotifier {
  BluetoothConnection? connection;
  bool accidentDetected = false;
  bool isConnected = false;

  BluetoothHandler() {
    _initBluetooth();
  }

  void _initBluetooth() async {
    // Check if Bluetooth is enabled
    BluetoothState state = await FlutterBluetoothSerial.instance.state;
    if (state == BluetoothState.STATE_ON) {
      _connectToDevice();
    } else {
      await FlutterBluetoothSerial.instance.requestEnable();
      _connectToDevice();
    }
  }

  Future<void> _connectToDevice() async {
    // Retrieve paired devices
    List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

    // Replace with your HC-05 device name
    BluetoothDevice? hc05 = bondedDevices.firstWhere(
      (device) => device.name == 'HC-05',
      orElse: () => throw Exception('HC-05 not found'),
    );

    try {
      connection = await BluetoothConnection.toAddress(hc05.address);
      print('Connected to device');
      isConnected = true;
      notifyListeners();

      connection?.input!.listen((data) {
        _handleValue(data);
      }).onDone(() {
        isConnected = false;
        notifyListeners();
      });
    } catch (e) {
      print('Error connecting to device: $e');
      isConnected = false;
      notifyListeners();
    }
  }

  void _handleValue(Uint8List data) {
    // Assuming that the data contains a single byte to indicate accident
    if (data.isNotEmpty && data[0] == 1) { // Adjust value checking logic as needed
      accidentDetected = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }
}
