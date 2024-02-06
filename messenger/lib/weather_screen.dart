import 'dart:convert';
import 'dart:ui';
import 'package:apps/additional_info_item.dart';
import 'package:apps/hourly_forecast_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      // To load the .env file contents into dotenv.
      await dotenv.load(fileName: ".env");
      // then access variables from .env throughout the application
      final apiKey = dotenv.env['OPENAPIKEY'];
      const String city = 'Kathmandu';
      final resp = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$apiKey'));
      print(apiKey);
      final data = jsonDecode(resp.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(
                Icons.refresh_sharp,
              )),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getWeatherData(),
        builder: (context, snapshot) {
          // handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          // handle error state
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          // handle data state

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'] - 273.15;
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentSky = currentWeatherData['weather'][0]['main'];

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currentTemp.toStringAsFixed(2)}°C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Clear'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 80,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                '$currentSky',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 1; i <= 10; i++)
                //         HourlyForecastCard(
                //           icon: Icons.cloud,
                //           time: epochToDate(data['list'][i]['dt']),
                //           temperature:
                //               (data['list'][1]['main']['temp'] - 273.15)
                //                   .toStringAsFixed(2),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final forecast = data['list'][index + 1];
                      final time = DateTime.parse(forecast['dt_txt']);
                      final temp = (forecast['main']['temp'] - 273.15)
                          .toStringAsFixed(2);
                      final sky = forecast['weather'][0]['main'].toString();
                      return HourlyForecastCard(
                        icon: sky == 'Clouds' || sky == 'Clear'
                            ? Icons.cloud
                            : Icons.sunny,
                        time: DateFormat.j().format(time),
                        temperature: temp,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // additional information
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                          icon: Icons.water_drop_rounded,
                          label: 'Humidity',
                          value: currentHumidity.toString()),
                      AdditionalInfoItem(
                          icon: Icons.wind_power_rounded,
                          label: 'Wind Speed',
                          value: currentWindSpeed.toString()),
                      AdditionalInfoItem(
                          icon: Icons.umbrella_rounded,
                          label: 'Pressure',
                          value: currentPressure.toString()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
