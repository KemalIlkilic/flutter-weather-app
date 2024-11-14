import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/hourly_forecast_item.dart';

import 'package:weather_app/additional_info_item.dart';

import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather;
  Future<Map<String,dynamic>> getCurrentWeather() async {
    String cityName = "Istanbul";
    try {
      // Converts a string URL into a Uri object, which is Dart's way of handling URLs properly
      final uriObject = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?cnt=8&q=$cityName&APPID=$openWeatherAPIKey');
      //http.get() function expects a Uri object, not a string
      final res = await http.get(uriObject);
      // A Uri object is like a validated, structured version of a URL, while a string is just raw text that might or might not be a valid URL. 
      // Using Uri gives you safety and convenience features that strings don't provide.


      //jsonDecode in Dart is a function that converts a JSON string (which is just text) into Dart objects that you can actually work with.
      // JSON STRING => DART OBJECT (probably map)
      final data = jsonDecode(res.body);
      print(data);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }


  // It is called once when the State object is first created. 
  @override
  void initState() {
    super.initState();
    // by not writing await we are not resolving the future
    // we pass into FutureBuilder. It will do what it has be done.
    weather = getCurrentWeather();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(fontWeight: FontWeight.bold )),
        centerTitle: true,
        actions: [
          IconButton( onPressed:() {
            setState(() {
              weather = getCurrentWeather();
            });
            } , icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;

          List forecastList = data['list'];
          forecastList.map((forecast) {
            String dateTime = forecast['dt_txt'];
            String clock = dateTime.split(' ')[1];
            String currentSky = forecast['weather'][0]['main'];
            IconData icon = currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny;
            final temperature = forecast['main']['temp'];
            return HourlyForecastItem(clock : clock, icon : icon, temperature: temperature.toString());
          }).toList();

          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'].toString();
          final currentHumidity = currentWeatherData['main']['humidity'].toString();
          final currentSpeed = currentWeatherData['wind']['speed'].toString();

          return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  //surfaceTintColor needed for elevation effect.
                  surfaceTintColor: Colors.grey.shade400,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), 
                        child: Column(
                          children: [
                            Text('$currentTemp °K' ,style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Icon(currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny, size: 64), 
                            const SizedBox(height: 12),
                            Text(currentSky ,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Weather Forecast', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              const SizedBox(height: 4),
              /* SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: forecastList.skip(1).map((forecast) {
                          String dateTime = forecast['dt_txt'];
                          String clock = dateTime.split(' ')[1];
                          String finalClock = clock.substring(0, clock.length - 3);
                          String currentSky = forecast['weather'][0]['main'];
                          IconData icon = currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny;
                          final temperature = forecast['main']['temp'];
                          return HourlyForecastItem(clock : finalClock, icon : icon, temperature: temperature.toString());
                          }).toList(),
                  ),
              ), */
              SizedBox(
                height: 120,
                child: ListView.builder(scrollDirection: Axis.horizontal ,
                itemCount:data['list'].length-1,
                  itemBuilder : (context,index) {
                    final forecast = data['list'][index+1];
                    String dateTime = forecast['dt_txt'];
                    String clock = dateTime.split(' ')[1];
                    String finalClock = clock.substring(0, clock.length - 3);
                    String currentSky = forecast['weather'][0]['main'];
                    IconData icon = currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny;
                    final temperature = forecast['main']['temp'];
                    return HourlyForecastItem(clock : finalClock, icon : icon, temperature: temperature.toString());
                  }
                ),
              ),
              const SizedBox(height: 20),
              const Text('Additional Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(icon : Icons.water_drop, label : 'Humidity', value : currentHumidity ),
                    AdditionalInfoItem(icon : Icons.air, label : 'Wind Speed', value : currentSpeed ),
                    AdditionalInfoItem(icon : Icons.beach_access, label : 'Pressure', value : currentPressure),
                  ],
                ),
              )
            ],
          ),
        );
        },
      ),
    );
  }
}

