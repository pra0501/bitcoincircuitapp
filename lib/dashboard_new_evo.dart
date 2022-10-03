// ignore_for_file: deprecated_member_use, import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'models/TopCoinData.dart';

class DashboardNew extends StatefulWidget {
  const DashboardNew({Key? key}) : super(key: key);

  @override
  _DashboardNewState createState() => _DashboardNewState();
}

class _DashboardNewState extends State<DashboardNew> {

  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  List<TopCoinData> topCoinList = [];
  List<Bitcoin> gainerLooserCoinList = [];
  List<Bitcoin> _searchResult = [];
  SharedPreferences? sharedPreferences;
  TextEditingController _searchController = new TextEditingController();
  num _size = 0;
  String? URL;

  @override
  void initState() {
    // fetchRemoteValue();
    callTopBitcoinApi();
    super.initState();
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
    callTopBitcoinApi();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height/4,
                    width: MediaQuery.of(context).size.width/.7,
                    child: topCoinList.length <= 0
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topCoinList.length,
                        itemBuilder: (BuildContext context, int i) {
                          return InkWell(
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: i % 2 == 0 ? AssetImage('assets/image/Card.png'):
                                        AssetImage('assets/image/Card1.png')
                                    )
                                ),
                                padding: EdgeInsets.all(10),
                                child:Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                  Row(
                                    children: [
                                      Container(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(left:5.0),
                                              child: FadeInImage(
                                                width: 70,
                                                height: 70,
                                                placeholder: AssetImage('assets/image/cob.png'),
                                                // image: NetworkImage("$URL/Bitcoin/resources/icons/${topCoinList[i].name!.toLowerCase()}.png"),
                                                image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${topCoinList[i].name!.toLowerCase()}.png"),
                                              ),
                                            )
                                        ),
                                        Padding(
                                            padding:
                                            const EdgeInsets.only(left:10.0),
                                            child:Text('${topCoinList[i].name}',
                                              style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white),
                                              textAlign: TextAlign.left,
                                            )
                                        ),
                                    ]),
                                    Row(
                                      children: [
                                        Padding(
                                            padding:
                                            const EdgeInsets.only(left:10.0),
                                            child:Text('${topCoinList[i].name}',
                                              style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white),
                                              textAlign: TextAlign.left,
                                            )
                                        ),
                                        SizedBox(
                                          width:10
                                        ),
                                        Text('\$${double.parse(topCoinList[i].rate!.toStringAsFixed(2))}',
                                            style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white)
                                        ),
                                    ],),
                                    Container(
                                      margin: EdgeInsets.only(left:200),
                                      //height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                        child:Row(
                                            crossAxisAlignment:CrossAxisAlignment.center,
                                            mainAxisAlignment:MainAxisAlignment.end,
                                            children:[
                                              double.parse(topCoinList[i].diffRate!) < 0
                                                  ? Container(child: Icon(Icons.arrow_drop_down_sharp, color: Colors.red, size: 18,),)
                                                  : Container(child: Icon(Icons.arrow_drop_up_sharp, color: Colors.green, size: 18,),),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Text(double.parse(topCoinList[i].diffRate!) < 0
                                                  ? "\$ " + double.parse(topCoinList[i].diffRate!.replaceAll('-', "")).toStringAsFixed(2)
                                                  : "\$ " + double.parse(topCoinList[i].diffRate!).toStringAsFixed(2),
                                                  style: TextStyle(fontSize: 18,
                                                      color: double.parse(topCoinList[i].diffRate!) < 0
                                                          ? Colors.red
                                                          : Colors.green)
                                              ),
                                              SizedBox(
                                                  height: 5,
                                                  width:15
                                              ),
                                            ]
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              callCurrencyDetails(topCoinList[i].name);
                            },
                          );
                        })
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        elevation: 1,
                        color: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: new Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width/1.09,
                          child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                                controller: _searchController,
                                onChanged: (val) => onSearchTextChanged(val),
                                style: TextStyle(fontSize: 20, color: Colors.black),
                                decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  prefixIcon: Container(
                                    child: new Icon(
                                        Icons.search,
                                        color: Colors.blue,
                                        size: 35,
                                      ),
                                  ),

                                  labelText: AppLocalizations.of(context).translate('search'),
                                  labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                                  fillColor: Colors.white,
                                )),
                            suggestionsCallback: (pattern) async {
                              return await null; //_buildListView(pattern);
                            },
                            itemBuilder: (context,dynamic suggestion) {
                              return ListTile(
                                leading: Icon(Icons.search),
                                title: Text(suggestion!.name),
                                // subtitle: Text('\$${suggestion['price']}'),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('gainer_loser'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20),
                        )),
                  ),
                ),
                gainerLooserCoinList.length <= 0
                    ? Center(child: CircularProgressIndicator())
                    : _searchResult.length != 0 ||
                    _searchController.text.isNotEmpty
                    ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _searchResult.length,
                    itemBuilder: (BuildContext context, int i) {
                      return InkWell(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white70, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: Container(
                              height: 80,
                              padding: EdgeInsets.all(8),
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          height: 70,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: FadeInImage(
                                              placeholder: AssetImage('assetsEvo/imagesEvo/cob.png'),
                                              // image: NetworkImage("$URL/Bitcoin/resources/icons/${_searchResult[i].name!.toLowerCase()}.png"),
                                              image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${_searchResult[i].name!.toLowerCase()}.png"),
                                            ),
                                          )
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        '${_searchResult[i].name}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              // Icon(
                                              //   Icons.attach_money,
                                              //   size: 20,
                                              // ),
                                              Text('\$${double.parse(_searchResult[i].rate!.toStringAsFixed(2))}',
                                                  style: TextStyle(fontSize: 18)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              double.parse(_searchResult[
                                              i]
                                                  .diffRate!) <
                                                  0
                                                  ? Container(
                                                // color: Colors.red,
                                                child: Icon(
                                                  Icons
                                                      .arrow_drop_down_sharp,
                                                  color: Colors.red,
                                                  size: 22,
                                                ),
                                              )
                                                  : Container(
                                                // color: Colors.green,
                                                child: Icon(
                                                  Icons.arrow_drop_up_sharp,
                                                  color: Colors.green,
                                                  size: 22,
                                                ),
                                              ),
                                              SizedBox(
                                                  width:2
                                              ),
                                              Text(
                                                  _searchResult[i]
                                                      .perRate!,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: double.parse(
                                                          _searchResult[
                                                          i]
                                                              .diffRate!) <
                                                          0
                                                          ? Colors.red
                                                          : Colors.green)),

                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          callCurrencyDetails(_searchResult[i].name);
                        },
                      );
                    })
                    : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: gainerLooserCoinList.length,
                    itemBuilder: (BuildContext context, int i) {
                      return InkWell(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white70, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: Container(
                              height: 80,
                              padding: EdgeInsets.all(8),
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          height: 70,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: FadeInImage(
                                              placeholder: AssetImage('assetsEvo/imagesEvo/cob.png'),
                                              // image: NetworkImage("$URL/Bitcoin/resources/icons/${gainerLooserCoinList[i].name!.toLowerCase()}.png"),
                                              image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${gainerLooserCoinList[i].name!.toLowerCase()}.png"),
                                            ),
                                          )
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        '${gainerLooserCoinList[i].name}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                  '\$${double.parse(gainerLooserCoinList[i].rate!.toStringAsFixed(2))}',
                                                  style:
                                                  TextStyle(fontSize: 18)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              double.parse(gainerLooserCoinList[
                                              i]
                                                  .diffRate!) <
                                                  0
                                                  ? Container(
                                                // color: Colors.red,
                                                child: Icon(
                                                  Icons
                                                      .arrow_drop_down_sharp,
                                                  color: Colors.red,
                                                  size: 15,
                                                ),
                                              )
                                                  : Container(
                                                // color: Colors.green,
                                                child: Icon(
                                                  Icons.arrow_drop_up_sharp,
                                                  color: Colors.green,
                                                  size: 15,
                                                ),
                                              ),
                                              SizedBox(
                                                  width:2
                                              ),
                                              Text(
                                                  gainerLooserCoinList[i]
                                                      .perRate!,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: double.parse(
                                                          gainerLooserCoinList[
                                                          i]
                                                              .diffRate!) <
                                                          0
                                                          ? Colors.red
                                                          : Colors.green)),

                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          callCurrencyDetails(gainerLooserCoinList[i].name);
                        },
                      );
                    })
                ,
              ],
            ),
          ),
        ));
  }

  Future<void> callBitcoinApi() async {
//    setState(() {
//      isLoading = true;
//    });
//     var uri = '$URL/Bitcoin/resources/getBitcoinHistoryLists?size=0';
    var uri = 'http://45.34.15.25:8080/Bitcoin/resources/getBitcoinHistoryLists?size=0';

    //  print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (data['error'] == false) {
      setState(() {
        bitcoinList.addAll(data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList());
        isLoading = false;
        _size = _size + data['data'].length;
      });
    } else {
      //  _ackAlert(context);

      setState(() {});
    }
    callTopBitcoinApi();
  }

  Future<void> callTopBitcoinApi() async {
//    setState(() {
//      isLoading = true;
//    });
    var uri =
        // '$URL/Bitcoin/resources/getBitcoinHistoryLists?size=0';
        'http://45.34.15.25:8080/Bitcoin/resources/getBitcoinHistoryLists?size=0';

    //  print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (mounted) {
      if (data['error'] == false) {
        setState(() {
          topCoinList.addAll(data['data']
              .map<TopCoinData>((json) => TopCoinData.fromJson(json))
              .toList());
          isLoading = false;
          // _size = _size + data['data'].length;
        });
      } else {
        //  _ackAlert(context);
        setState(() {});
      }
    }
    callGainerLooserBitcoinApi();
  }

  Future<void> callGainerLooserBitcoinApi() async {
//    setState(() {
//      isLoading = true;
//    });
    var uri =
    // '$URL/Bitcoin/resources/getBitcoinListLoser?size=0';
        'http://45.34.15.25:8080/Bitcoin/resources/getBitcoinListLoser?size=0';

    //  print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (mounted) {
      if (data['error'] == false) {
        setState(() {
          gainerLooserCoinList.addAll(data['data']
              .map<Bitcoin>((json) => Bitcoin.fromJson(json))
              .toList());
          isLoading = false;
          // _size = _size + data['data'].length;
        });
      } else {
        //  _ackAlert(context);
        setState(() {});
      }
    }
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    text = text.toLowerCase();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    gainerLooserCoinList.forEach((userDetail) {
      if (userDetail.name!.toLowerCase().contains(text))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }

  Future<void> callCurrencyDetails(name) async {
    _saveProfileData(name);
  }

  _saveProfileData(String name) async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setString("currencyName", name);
      sharedPreferences!.setInt("index", 4);
      sharedPreferences!.setString("title", AppLocalizations.of(context).translate('trends'));
      sharedPreferences!.commit();
    });

    Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
  }
}

class LinearSales {
  final int count;
  final double rate;

  LinearSales(this.count, this.rate);
}
