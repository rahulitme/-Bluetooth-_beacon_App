// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:async';
// import 'package:permission_handler/permission_handler.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
//   List<BluetoothDevice> devices = [];
//   List<BluetoothDevice> connectedDevices = [];
//   bool isScanning = false;
//   bool isBluetoothOn = false;
//   bool isBluetoothSupported = true;
//   String statusMessage = '';
//   late AnimationController _animationController;
//   bool isSimulationMode = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
//     _initializeBluetooth();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeBluetooth() async {
//     try {
//       _log("Checking Bluetooth support...");
//       isBluetoothSupported = await FlutterBluePlus.isSupported;
//       _log("Bluetooth supported: $isBluetoothSupported");
//       if (!isBluetoothSupported) {
//         _updateStatus('Bluetooth is not supported. Simulation mode available.');
//         return;
//       }

//       // Request Bluetooth permissions
//       await _requestPermissions();

//       _log("Checking if Bluetooth is on...");
//       // ignore: deprecated_member_use
//       isBluetoothOn = await FlutterBluePlus.isOn;
//       _log("Bluetooth is on: $isBluetoothOn");

//       // Listen for Bluetooth state changes
//       FlutterBluePlus.adapterState.listen((state) {
//         _log("Bluetooth state changed: $state");
//         setState(() {
//           isBluetoothOn = state == BluetoothAdapterState.on;
//         });
//         if (isBluetoothOn) {
//           _updateStatus('Bluetooth is on. Ready to scan.');
//           _scanForDevices();
//         } else {
//           _updateStatus('Bluetooth is off. Please turn it on.');
//         }
//       });

//       // Get connected devices
//       connectedDevices = FlutterBluePlus.connectedDevices;
//       _log('Connected devices: ${connectedDevices.length}');
//     } catch (e) {
//       _log('Error initializing Bluetooth: $e');
//       setState(() {
//         isBluetoothSupported = false;
//       });
//     }
//   }

//   Future<void> _requestPermissions() async {
//     if (await Permission.bluetoothScan.request().isGranted &&
//         await Permission.bluetoothConnect.request().isGranted &&
//         await Permission.location.request().isGranted) {
//       _log('Bluetooth permissions granted');
//     } else {
//       _log('Bluetooth permissions not granted');
//       _updateStatus('Bluetooth permissions are required.');
//     }
//   }

//   void _scanForDevices() async {
//     if (isSimulationMode) {
//       _simulateScan();
//       return;
//     }

//     if (!isBluetoothSupported) {
//       _updateStatus('Bluetooth is not supported. Use simulation mode.');
//       return;
//     }

//     if (!isBluetoothOn) {
//       _updateStatus('Please turn on Bluetooth to scan for devices.');
//       return;
//     }

//     if (isScanning) {
//       _log("Already scanning, ignoring scan request.");
//       return;
//     }

//     setState(() {
//       isScanning = true;
//       devices.clear();
//     });

//     try {
//       _log("Stopping any ongoing scan...");
//       await FlutterBluePlus.stopScan();

//       _log("Starting new scan...");
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
//       _updateStatus('Scanning for devices...');
      
//       FlutterBluePlus.scanResults.listen((results) {
//         _log("Scan results received: ${results.length} devices");
//         setState(() {
//           devices = results.map((r) => r.device).toList();
//         });
//       }, onDone: () {
//         _log("Scan completed");
//         setState(() {
//           isScanning = false;
//         });
//         _updateStatus(devices.isEmpty ? 'No devices found.' : 'Scan completed.');
//       }, onError: (e) {
//         _log("Error during scan: $e");
//         setState(() {
//           isScanning = false;
//         });
//         _updateStatus('Error occurred while scanning.');
//       });
//     } catch (e) {
//       _log('Error scanning: $e');
//       setState(() {
//         isScanning = false;
//       });
//       _updateStatus('Failed to start scanning.');
//     }
//   }

//   void _simulateScan() {
//     setState(() {
//       isScanning = true;
//       devices.clear();
//     });
//     _updateStatus('Simulating scan...');

//     // Simulate a delay
//     Future.delayed(const Duration(seconds: 3), () {
//       setState(() {
//         devices = [
//           BluetoothDevice(remoteId: const DeviceIdentifier('00:11:22:33:44:55'), name: 'Simulated Device 1'),
//           BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'), name: 'Simulated Device 2'),
//         ];
//         isScanning = false;
//       });
//       _updateStatus('Simulated scan completed.');
//     });
//   }

//   void _updateStatus(String message) {
//     setState(() {
//       statusMessage = message;
//     });
//     _log("Status updated: $message");
//   }

//   void _log(String message) {
//     if (kDebugMode) {
//       print("BluetoothDebug: $message");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bluetooth Devices'),
//         actions: [
//           if (isScanning)
//             Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: RotationTransition(
//                 turns: _animationController,
//                 child: const Icon(Icons.refresh),
//               ),
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               statusMessage,
//               style: Theme.of(context).textTheme.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           if (!isBluetoothSupported || isSimulationMode)
//             SwitchListTile(
//               title: const Text('Simulation Mode'),
//               value: isSimulationMode,
//               onChanged: (bool value) {
//                 setState(() {
//                   isSimulationMode = value;
//                 });
//                 _updateStatus(isSimulationMode ? 'Simulation mode enabled.' : 'Simulation mode disabled.');
//               },
//             ),
//           Expanded(
//             child: Stack(
//               children: [
//                 if (devices.isEmpty && connectedDevices.isEmpty)
//                   Center(child: Text(isScanning ? 'Scanning...' : 'No devices found'))
//                 else
//                   ListView.builder(
//                     itemCount: devices.length + connectedDevices.length,
//                     itemBuilder: (context, index) {
//                       BluetoothDevice device = index < connectedDevices.length
//                           ? connectedDevices[index]
//                           : devices[index - connectedDevices.length];
//                       return ListTile(
//                         // ignore: deprecated_member_use
//                         title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
//                         subtitle: Text(device.remoteId.toString()),
//                       );
//                     },
//                   ),
//                 if (isScanning)
//                   Container(
//                     color: Colors.black.withOpacity(0.5),
//                     child: const Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _scanForDevices,
//         child: const Icon(Icons.search),
//       ),
//     );
//   }
// }

// class Permission {
//   // ignore: prefer_typing_uninitialized_variables
//   static var bluetoothConnect;
  
//   // ignore: prefer_typing_uninitialized_variables
//   static var bluetoothScan;
  
//   // ignore: prefer_typing_uninitialized_variables
//   static var location;
// }


import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:myapp/widgets/%20bluetooth_device_tile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  bool isBluetoothOn = false;
  bool isBluetoothSupported = true;
  String statusMessage = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    try {
      // Check if Bluetooth is supported
      isBluetoothSupported = await FlutterBluePlus.isSupported;
      if (!isBluetoothSupported) {
        _updateStatus('Bluetooth is not supported.');
        return;
      }

      // Request Bluetooth and location permissions
      await _requestPermissions();

      // Check if Bluetooth is on
      // ignore: deprecated_member_use
      isBluetoothOn = await FlutterBluePlus.isOn;

      FlutterBluePlus.adapterState.listen((state) {
        setState(() {
          isBluetoothOn = state == BluetoothAdapterState.on;
        });
        if (isBluetoothOn) {
          _updateStatus('Bluetooth is on. Ready to scan.');
          _scanForDevices();
        } else {
          _updateStatus('Bluetooth is off. Please turn it on.');
        }
      });
    } catch (e) {
      setState(() {
        isBluetoothSupported = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.locationWhenInUse]!.isGranted) {
      // Permissions granted
    } else {
      _updateStatus('Bluetooth and location permissions are required.');
    }
  }

  void _scanForDevices() async {
    if (!isBluetoothSupported || !isBluetoothOn) {
      _updateStatus('Please turn on Bluetooth to scan for devices.');
      return;
    }

    if (isScanning) return;

    setState(() {
      isScanning = true;
      devices.clear();
    });

    try {
      // Start scanning for devices
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          devices = results.map((r) => r.device).toList();
        });
      }, onDone: () {
        setState(() {
          isScanning = false;
        });
        _updateStatus(devices.isEmpty ? 'No devices found.' : 'Scan completed.');
      });
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      _updateStatus('Failed to start scanning.');
    }
  }

  void _updateStatus(String message) {
    setState(() {
      statusMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          if (isScanning)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: RotationTransition(
                turns: _animationController,
                child: const Icon(Icons.refresh),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: devices.isEmpty
                ? Center(child: Text(isScanning ? 'Scanning...' : 'No devices found'))
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      BluetoothDevice device = devices[index];
                      return BluetoothDeviceTile(device: device);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanForDevices,
        child: const Icon(Icons.search),
      ),
    );
  }
}


