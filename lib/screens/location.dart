import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth_service.dart';
import 'timer_email.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> with WidgetsBindingObserver {
  bool gpsEnabled = false;
  bool permissionGranted = false;
  bool isLoading = true;
  l.Location location = l.Location();
  late StreamSubscription<l.LocationData> subscription;
  GoogleMapController? mapController;
  Marker? userMarker;
  LatLng? lastKnownPosition;
  bool bluetoothConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadLastKnownLocation().then((_) {
      checkStatus();
    });

    // Start listening to Bluetooth service changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bluetoothHandler = Provider.of<BluetoothHandler>(context, listen: false);
      bluetoothHandler.addListener(_onBluetoothUpdate);
    });
  }

  @override
  void dispose() {
    stopTracking();
    WidgetsBinding.instance.removeObserver(this);

    // Clean up Bluetooth service listener
    final bluetoothHandler = Provider.of<BluetoothHandler>(context, listen: false);
    bluetoothHandler.removeListener(_onBluetoothUpdate);

    super.dispose();
  }

  void _onBluetoothUpdate() {
    final bluetoothHandler = Provider.of<BluetoothHandler>(context, listen: false);

    if (bluetoothHandler.isConnected && !bluetoothConnected) {
      setState(() {
        bluetoothConnected = true;
      });
      _showConnectionSuccessMessage();
    }

    if (bluetoothHandler.accidentDetected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimerPage(
            coordinates: lastKnownPosition,
          ),
        ),
      );
    }
  }

  void _showConnectionSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bluetooth Connected Successfully')),
    );
  }

  @override
  void didPopNext() {
    startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: lastKnownPosition ?? const LatLng(0, 0),
                          zoom: 15.0,
                        ),
                        markers: userMarker != null ? {userMarker!} : {},
                        onMapCreated: (controller) {
                          mapController = controller;
                          if (userMarker != null) {
                            mapController?.animateCamera(
                                CameraUpdate.newLatLng(userMarker!.position));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (!bluetoothConnected)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Text(
                        'Connecting to Bluetooth...',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> checkStatus() async {
    bool permissionGranted = await isPermissionGranted();
    if (permissionGranted) {
      bool gpsEnabled = await isGpsEnabled();
      if (gpsEnabled) {
        startTracking();
      } else {
        bool isGpsActive = await location.requestService();
        setState(() {
          gpsEnabled = isGpsActive;
          if (gpsEnabled) {
            startTracking();
          }
        });
      }
    } else {
      await requestLocationPermission();
    }
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isGpsEnabled() async {
    return await location.serviceEnabled();
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.request();
    setState(() {
      permissionGranted = permissionStatus == PermissionStatus.granted;
    });
    if (permissionGranted) {
      checkStatus();
    }
  }

  void startTracking() async {
    subscription = location.onLocationChanged.listen((event) {
      updateLocation(event);
    });
  }

  void stopTracking() {
    subscription.cancel();
  }

  void updateLocation(l.LocationData data) async {
    LatLng newPosition = LatLng(data.latitude!, data.longitude!);
    setState(() {
      userMarker = Marker(
        markerId: const MarkerId('userMarker'),
        position: newPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      lastKnownPosition = newPosition;
      isLoading = false;
    });

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
      saveLastKnownLocation(newPosition);
    }
  }

  Future<void> saveLastKnownLocation(LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', position.latitude);
    await prefs.setDouble('longitude', position.longitude);
  }

  Future<void> loadLastKnownLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');
    if (latitude != null && longitude != null) {
      setState(() {
        lastKnownPosition = LatLng(latitude, longitude);
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
