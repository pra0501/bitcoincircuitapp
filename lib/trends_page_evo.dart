// ignore_for_file: deprecated_member_use, import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'models/Bitcoin.dart';

class TrendPage extends StatefulWidget {
  const TrendPage({Key? key}) : super(key: key);

  @override
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  int buttonType = 3;
  String name = "";
  double coin = 0;
  String result = '';
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  String? currencyNameForImage;
  String _type = "Week";
  List<LinearSales> currencyData = [];
  List<Bitcoin> bitcoinList = [];
  double diffRate = 0;
  String? URL;
  @override
  void initState() {
    // fetchRemoteValue();
    callBitcoinApi();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var analytics = FirebaseAnalytics();
      analytics.logEvent(name: 'open_trends');
    });
  }
  fetchRemoteValue() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      // await remoteConfig.setConfigSettings(RemoteConfigSettings(
      //   fetchTimeout: const Duration(seconds: 10),
      //   minimumFetchInterval: Duration.zero,
      // ));
      // await remoteConfig.fetchAndActivate();

      await remoteConfig.fetch(expiration: const Duration(seconds: 30));
      await remoteConfig.activateFetched();
      URL = remoteConfig.getString('bit_evo_url').trim();

      print(URL);
      setState(() {

      });
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    callBitcoinApi();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xff0f2f2f3),
            borderRadius: BorderRadius.only(topRight: Radius.circular(25),topLeft: Radius.circular(25)),
            image: DecorationImage(image: AssetImage("assets/image/Graph (1).png"), fit: BoxFit.fill,),
          ),
          child: Column(
            children: <Widget>[
              Container(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(height: 10,),
                        Row(
                          children: <Widget>[
                            Container(
                                height: 80, width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: currencyNameForImage != null
                                      ? FadeInImage.assetNetwork(placeholder:'assetsEvo/imagesEvo/cob.png',
                                      // image:"$URL/Bitcoin/resources/icons/${currencyNameForImage!.toLowerCase()}.png")
                                      image:"http://45.34.15.25:8080/Bitcoin/resources/icons/${currencyNameForImage!.toLowerCase()}.png")
                                      : Image.asset("assetsEvo/imagesEvo/cob.png"),
                                )
                            ),
                            Text('$name',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                          Padding(
                              padding: const EdgeInsets.only(left:10.0),
                              child:Text('$name',
                                style: TextStyle(fontSize: 25,fontWeight:FontWeight.bold,color:Colors.white),
                                textAlign: TextAlign.left,
                              )
                          ),
                          SizedBox(
                              width:15
                          ),
                          Text('\$$coin', style: TextStyle(fontSize: 25,fontWeight:FontWeight.bold,color:Colors.white)),
                        ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(diffRate < 0 ? '-' : "+", style: TextStyle(fontSize: 16, color: diffRate < 0 ? Colors.red : Colors.green)),
                            Icon(Icons.attach_money, size: 16, color: diffRate < 0 ? Colors.red : Colors.green),
                            Text('$result', style: TextStyle(fontSize: 16, color: diffRate < 0 ? Colors.red : Colors.green)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only( bottom: 10, top: 0),
                  child: ListView(
                    children: <Widget>[
                      Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top:5.0),
                                child: new Row(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                          width: MediaQuery.of(context).size.width / 1.01,
                                          height: MediaQuery.of(context).size.height / 2.0,
                                          child: SfCartesianChart(
                                            plotAreaBorderWidth: 0,
                                            enableAxisAnimation: true,
                                            enableSideBySideSeriesPlacement: true,
                                            series:<ChartSeries>[
                                              LineSeries<LinearSales, double>(
                                                dataSource: currencyData,
                                                xValueMapper: (LinearSales data, _) => data.date,
                                                yValueMapper: (LinearSales data, _) => data.rate,
                                                color: Colors.white,
                                                dataLabelSettings: DataLabelSettings(isVisible: true, borderColor: Colors.white),
                                                markerSettings: MarkerSettings(isVisible: true),
                                              )
                                            ],
                                            primaryXAxis: NumericAxis(isVisible: false,),
                                            primaryYAxis: NumericAxis(isVisible: false,),
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ButtonTheme(
                                    minWidth: 50.0, height: 40.0,
                                    child: new ElevatedButton(
                                      child: new Text("1W" , style: TextStyle(fontSize: 15),
                                      ),
                                      style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all<Color>(buttonType == 3 ? Colors.white:Color(0xff96a5ff)),
                                          backgroundColor: MaterialStateProperty.all<Color>(buttonType == 3 ? Color(0xff96a5ff) : Colors.white,),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                // side: BorderSide(color: Color(0xfff4f727))
                                              )
                                          )
                                      ),
                                      // textColor: buttonType == 3 ? Color(0xff96a5ff) : Colors.white,
                                      // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),),
                                      // color: buttonType == 3 ? Colors.white : Color(0xff96a5ff),
                                      onPressed: () {
                                        setState(() {
                                          buttonType = 3;
                                          _type = "Week";
                                          callBitcoinApi();
                                        });
                                      },
                                    ),
                                  ),
                                  ButtonTheme(
                                    minWidth: 50.0, height: 40.0,
                                    child: new ElevatedButton(
                                      child: new Text('1M', style: TextStyle(fontSize: 15),),
                                      style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all<Color>(buttonType == 4 ? Colors.white:Color(0xff96a5ff)),
                                          backgroundColor: MaterialStateProperty.all<Color>(buttonType == 4 ? Color(0xff96a5ff) : Colors.white,),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                // side: BorderSide(color: Color(0xfff4f727))
                                              )
                                          )
                                      ),
                                      // textColor: buttonType == 4 ? Color(0xff96a5ff) : Colors.white,
                                      // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),),
                                      // color: buttonType == 4 ? Colors.white : Color(0xff96a5ff),
                                      onPressed: () {
                                        setState(() {
                                          buttonType = 4;
                                          _type = "Month";
                                          callBitcoinApi();
                                        });
                                      },
                                    ),
                                  ),
                                  ButtonTheme(
                                    minWidth: 50.0, height: 40.0,
                                    child: new ElevatedButton(
                                      child: new Text('1Y', style: TextStyle(fontSize: 15),),
                                      style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all<Color>(buttonType == 5 ? Colors.white:Color(0xff96a5ff)),
                                          backgroundColor: MaterialStateProperty.all<Color>(buttonType == 5 ? Color(0xff96a5ff) : Colors.white,),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                // side: BorderSide(color: Color(0xfff4f727))
                                              )
                                          )
                                      ),

                                      // textColor: buttonType == 5 ? Color(0xff96a5ff) : Colors.white,
                                      // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),),
                                      // color: buttonType == 5 ? Colors.white : Color(0xff96a5ff),
                                      onPressed: () {
                                        setState(() {
                                          buttonType = 5;
                                          _type = "Year";
                                          callBitcoinApi();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Future<void> callBitcoinApi() async {
    final SharedPreferences prefs = await _sprefs;
    var currencyName = prefs.getString("currencyName") ?? 'BTC';
    currencyNameForImage = currencyName;
    // var uri = '$URL/Bitcoin/resources/getBitcoinGraph?type=$_type&name=$currencyName';
    var uri = 'http://45.34.15.25:8080/Bitcoin/resources/getBitcoinGraph?type=$_type&name=$currencyName';
    print(uri);
    var response = await get(Uri.parse(uri));
    //  print(response.body);
    final data = json.decode(response.body) as Map;
    //print(data);
    if (data['error'] == false) {
      setState(() {
        bitcoinList = data['data'].map<Bitcoin>((json) => Bitcoin.fromJson(json)).toList();
        double count = 0;
        diffRate = double.parse(data['diffRate']);
        if (diffRate < 0) result = data['diffRate'].replaceAll("-", "");
        else result = data['diffRate'];
        currencyData = [];
        bitcoinList.forEach((element) {
          currencyData.add(new LinearSales(count, element.rate!));
          name = element.name!;
          String step2 = element.rate!.toStringAsFixed(2);
          double step3 = double.parse(step2);
          coin = step3;
          count = count + 1;
        });
        //  print(currencyData.length);
      });
    } else {
      //  _ackAlert(context);

    }
  }
}

class LinearSales {
  final double date;
  final double rate;

  LinearSales(this.date, this.rate);
}
