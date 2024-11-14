import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String clock;
  final IconData icon;
  final String temperature;
  const HourlyForecastItem({super.key, required this.clock, required this.icon,
                            required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Card(
                    surfaceTintColor: Colors.grey.shade400,
                    elevation: 4,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(clock ,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Icon(icon, size: 36),
                          const SizedBox(height: 8), 
                          Text('$temperature K'),
                        ],
                      ),
                    ),
                  );
  }
}


