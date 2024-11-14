import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfoItem({super.key, required this.icon, required this.label, required this.value,});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 36), 
        const SizedBox(height: 2),
        Text(label ,style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        Text( value ,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

//(Icons.water_drop,'Humidty', '94')

