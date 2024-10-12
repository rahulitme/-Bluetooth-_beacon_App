import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceTile extends StatelessWidget {
  final BluetoothDevice device;

  const BluetoothDeviceTile({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // If the device name is not available, show "Unknown Device"
      // ignore: deprecated_member_use
      title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
      subtitle: Text(device.remoteId.toString()), // Corrected from 'device.id' to 'remoteId'
      trailing: const Icon(Icons.bluetooth),
      onTap: () {
        // Handle device selection (e.g., attempt to connect to the device)
      },
    );
  }
}

