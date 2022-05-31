import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

void main() {
  runApp(weatherwidget());
}

class weatherwidget extends StatefulWidget {
  const weatherwidget({Key? key}) : super(key: key);

  @override
  State<weatherwidget> createState() => _weatherwidgetState();
}

class _weatherwidgetState extends State<weatherwidget> {
  double latitude = 0;
  double longitude = 0;
  String weather_desc = '';
  int temperature = 0;
  int feelsliketemp = 0;
  int maxtemp = 0;
  int mintemp = 0;
  String city = '';
  String weather_icon = '';
  Image? image;
  Color? colour;

  Future _determinePosition() async {
    bool serviceenabled;
    LocationPermission permission;

    serviceenabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceenabled) {
      Fluttertoast.showToast(msg: 'Location Service is disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'You denied Permission');
      }
    }
    Position currentposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      latitude = currentposition.latitude;
      longitude = currentposition.longitude;
    });
  }

  void getdata() async {
    Response response = await get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=831b3576933137387d66ba40a7381c91"));
    if (response.statusCode == 200) {
      String data = response.body;

      var weather_description = jsonDecode(data)['weather'][0]['description'];
      var city_name = jsonDecode(data)['name'];
      var temp = jsonDecode(data)['main']['temp'];
      var feels_like_temp = jsonDecode(data)['main']['feels_like'];
      var temp_max = jsonDecode(data)['main']['temp_max'];
      var temp_min = jsonDecode(data)['main']['temp_min'];
      String icon = jsonDecode(data)['weather'][0]['icon'];
      setState(() {
        weather_desc = weather_description.toUpperCase();
        city = city_name;
        temperature = (temp - 273.15).toInt();
        feelsliketemp = (feels_like_temp - 273.15).toInt();
        weather_icon = icon + '@2x.png';
        maxtemp = (temp_max - 273.15).toInt();
        mintemp = (temp_min - 273.15).toInt();
        if (weather_icon[2] == 'd') {
          colour = Colors.lightBlue;
        } else {
          colour = Colors.indigo[900];
        }
      });
    } else {
      print(response.statusCode);
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    getdata();
    return MaterialApp(
      home: Scaffold(
          backgroundColor: colour,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SafeArea(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    weather_desc,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 420.0,
                  child: Image.asset('assets/images/01d@2x.png',
                      fit: BoxFit.fitWidth),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          city,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${temperature.toString()}°C',
                          style: TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${feelsliketemp.toString()}°C',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'Max',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$maxtemp°C',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 30.0,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'Min',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$mintemp°C',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10.0,
                      )
                    ],
                  )
                ],
              ),
            ],
          )),
    );
  }
}
