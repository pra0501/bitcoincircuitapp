// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_helper.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'models/PortfolioBitcoin.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  List<Bitcoin> _searchResult = [];
  SharedPreferences? sharedPreferences;
  num _size = 0;
  double totalValuesOfPortfolio = 0.0;
  final _formKey2 = GlobalKey<FormState>();
  String? URL;

  TextEditingController? coinCountTextEditingController;
  TextEditingController? coinCountEditTextEditingController;
  final dbHelper = DatabaseHelper.instance;
  List<PortfolioBitcoin> items = [];
  TextEditingController _searchController = new TextEditingController();


  @override
  void initState() {
    // fetchRemoteValue();
    callBitcoinApi();
    coinCountTextEditingController = new TextEditingController();
    coinCountEditTextEditingController = new TextEditingController();
    dbHelper.queryAllRows().then((notes) {
      notes.forEach((note) {
        items.add(PortfolioBitcoin.fromMap(note));
        totalValuesOfPortfolio = totalValuesOfPortfolio + note["total_value"];
      });
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        child: Column(
          children: <Widget>[
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
                            autofocus: false,
                            controller: _searchController,
                            onChanged: (val) => onSearchTextChanged(val),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              prefixIcon: Container(
                                child: new IconButton(
                                  icon: new Icon(
                                    Icons.search,
                                    color: Colors.blue,
                                    size: 35,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                              labelText: AppLocalizations.of(context).translate('search'),
                              labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                              fillColor: Colors.white,
                            )),
                        suggestionsCallback: (pattern) async {
                          return await null; //_buildListView(pattern);
                        },
                        itemBuilder: (context, dynamic suggestion) {
                          return ListTile(
                            leading: Icon(Icons.search),
                            title: Text(suggestion!.name),
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
            Expanded(
                child:Container(
                  padding: EdgeInsets.only(
                      left: 10, right: 10, bottom: 10, top: 0),
                  child:
                  LazyLoadScrollView(
                    isLoading: isLoading,
                    onEndOfPage: () => callBitcoinApi(),
                    child: bitcoinList.length <= 0
                        ? Center(child: CircularProgressIndicator())
                        : _searchResult.length != 0 ||
                        _searchController.text.isNotEmpty
                        ?ListView.builder(
                        itemCount: _searchResult.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Card(
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                height: 80,
                                padding: EdgeInsets.all(8),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        callCurrencyDetails(_searchResult[i].name);
                                      },
                                      child: Row(children: [
                                      Stack(
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
                                              )),
                                          GestureDetector(
                                            onTap: () {
                                              showPortfolioDialog(_searchResult[i]);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:40, left:40),
                                              child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: Colors.blue,
                                                  child: Icon(Icons.add, color: Colors.white, size: 20,)
                                              ),
                                            ),
                                          )
                                        ],),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          callCurrencyDetails(_searchResult[i].name);
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('\$${double.parse(_searchResult[i].rate!.toStringAsFixed(2))}',
                                                style: TextStyle(fontSize: 18)),
                                            Text('${_searchResult[i].name}',
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.start,
                                            ),
                                          ],
                                        )
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          callCurrencyDetails(_searchResult[i].name);
                                        },
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                callCurrencyDetails(_searchResult[i].name);
                                              },
                                              child: Container(
                                                width:70,
                                                height: 40,
                                                child: new charts.LineChart(
                                                  _createSampleData(_searchResult[i].historyRate, double.parse(_searchResult[i].diffRate!)),
                                                  layoutConfig: new charts.LayoutConfig(
                                                      leftMarginSpec: new charts.MarginSpec.fixedPixel(5),
                                                      topMarginSpec: new charts.MarginSpec.fixedPixel(10),
                                                      rightMarginSpec: new charts.MarginSpec.fixedPixel(5),
                                                      bottomMarginSpec: new charts.MarginSpec.fixedPixel(10)),
                                                  defaultRenderer: new charts.LineRendererConfig(includeArea: true, stacked: true,),
                                                  animate: true,
                                                  domainAxis: charts.NumericAxisSpec(showAxisLine: false, renderSpec: charts.NoneRenderSpec()),
                                                  primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(double.parse(_searchResult[i].diffRate!) < 0 ? '-' : '+',
                                                    style: TextStyle(fontSize: 12, color: double.parse(_searchResult[i].diffRate!) < 0 ? Colors.red : Colors.green)),
                                                Icon(Icons.attach_money, size: 12, color: double.parse(_searchResult[i].diffRate!) < 0 ? Colors.red : Colors.green),
                                                Text(double.parse(_searchResult[i].diffRate!) < 0 ? double.parse(_searchResult[i].diffRate!.replaceAll('-', "")).toStringAsFixed(2)
                                                    : double.parse(_searchResult[i].diffRate!).toStringAsFixed(2),
                                                    style: TextStyle(fontSize: 12, color: double.parse(_searchResult[i].diffRate!) < 0 ? Colors.red : Colors.green)),
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                        :ListView.builder(
                        itemCount: bitcoinList.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Card(
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                height: 80,
                                padding: EdgeInsets.all(8),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        callCurrencyDetails(bitcoinList[i].name);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                      Stack(
                                      children: <Widget>[
                                          Container(
                                              height: 70,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: FadeInImage(
                                                  placeholder: AssetImage('assetsEvo/imagesEvo/cob.png'),
                                                  // image: NetworkImage("$URL/Bitcoin/resources/icons/${bitcoinList[i].name!.toLowerCase()}.png"),
                                                  image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${bitcoinList[i].name!.toLowerCase()}.png"),
                                                ),
                                              )),
                                          GestureDetector(
                                            onTap: () {
                                              showPortfolioDialog(bitcoinList[i]);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:40, left:40),
                                              child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: Colors.blue,
                                                  child: Icon(Icons.add, color: Colors.white, size: 20,)
                                              ),
                                            ),
                                          )]),
                                          Padding(
                                              padding: EdgeInsets.only(left:10),
                                              child:Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('\$${double.parse(bitcoinList[i].rate!.toStringAsFixed(2))}',
                                                      style: TextStyle(fontSize: 18)),
                                                  Text('${bitcoinList[i].name}',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.start,
                                                  ),
                                                ],
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          callCurrencyDetails(bitcoinList[i].name);
                                        },
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                callCurrencyDetails(bitcoinList[i].name);
                                              },
                                              child: Container(
                                                width:MediaQuery.of(context).size.width/4,
                                                height: 40,
                                                child: new charts.LineChart(
                                                  _createSampleData(bitcoinList[i].historyRate, double.parse(bitcoinList[i].diffRate!)),
                                                  layoutConfig: new charts.LayoutConfig(
                                                      leftMarginSpec: new charts.MarginSpec.fixedPixel(5),
                                                      topMarginSpec: new charts.MarginSpec.fixedPixel(10),
                                                      rightMarginSpec: new charts.MarginSpec.fixedPixel(5),
                                                      bottomMarginSpec: new charts.MarginSpec.fixedPixel(10)),
                                                  defaultRenderer: new charts.LineRendererConfig(includeArea: true, stacked: true,),
                                                  animate: true,
                                                  domainAxis: charts.NumericAxisSpec(showAxisLine: false, renderSpec: charts.NoneRenderSpec()),
                                                  primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(double.parse(bitcoinList[i].diffRate!) < 0 ? '-' : '+',
                                                    style: TextStyle(fontSize: 12, color: double.parse(bitcoinList[i].diffRate!) < 0 ? Colors.red : Colors.green)),
                                                Icon(Icons.attach_money, size: 12, color: double.parse(bitcoinList[i].diffRate!) < 0 ? Colors.red : Colors.green),
                                                Text(double.parse(bitcoinList[i].diffRate!) < 0 ? double.parse(bitcoinList[i].diffRate!.replaceAll('-', "")).toStringAsFixed(2)
                                                    : double.parse(bitcoinList[i].diffRate!).toStringAsFixed(2),
                                                    style: TextStyle(fontSize: 12, color: double.parse(bitcoinList[i].diffRate!) < 0 ? Colors.red : Colors.green)),
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<charts.Series<LinearSales, int>> _createSampleData(
      historyRate, diffRate) {
    List<LinearSales> listData = [];
    for (int i = 0; i < historyRate.length; i++) {
      double rate = historyRate[i]['rate'];
      listData.add(new LinearSales(i, rate));
    }

    return [
      new charts.Series<LinearSales, int>(
        id: 'Tablet',
        // colorFn specifies that the line will be red.
        colorFn: (_, __) => diffRate < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        // areaColorFn specifies that the area skirt will be light red.
        // areaColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
        domainFn: (LinearSales sales, _) => sales.count,
        measureFn: (LinearSales sales, _) => sales.rate,
        data: listData,
      ),
    ];
  }

  Future<void> callBitcoinApi() async {
    // var uri = '$URL/Bitcoin/resources/getBitcoinList?size=${_size}';
    var uri = 'http://45.34.15.25:8080/Bitcoin/resources/getBitcoinList?size=${_size}';
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
      setState(() {});
    }
  }
  Future<void> showPortfolioDialog(Bitcoin bitcoin) async {
    showCupertinoModalPopup(
        context: context,
        builder: (ctxt) => Container(
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              title: Text(AppLocalizations.of(context).translate('add_coins'),
                  style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:50),
                  child: Text(AppLocalizations.of(context).translate('enter_coins'),
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Form(
                    key: _formKey2,
                    child: TextFormField(
                      controller: coinCountTextEditingController,
                      style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (val) {
                        if (coinCountTextEditingController!.text == "" || int.parse(coinCountTextEditingController!.value.text) <= 0) {
                          return "At least 1 coin should be added";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                        elevation: 1,
                        child:Padding(
                            padding: EdgeInsets.only(top:10,bottom:10,left:30,right: 50),
                            child:Row(
                              children: [
                                Container(
                                    height: 60,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: FadeInImage(
                                        placeholder: AssetImage('assetsEvo/imagesEvo/cob.png'),
                                        image: NetworkImage(
                                            // "$URL/Bitcoin/resources/icons/${bitcoin.name!.toLowerCase()}.png"),
                                            "http://45.34.15.25:8080/Bitcoin/resources/icons/${bitcoin.name!.toLowerCase()}.png"),
                                      ),
                                    )
                                ),
                                SizedBox(
                                    width:10
                                ),
                                Text(bitcoin.name!,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)
                              ],))

                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: TextButton(
                        style: ButtonStyle(
                            // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent,),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.0),
                                    // side: BorderSide(color: Color(0xfff4f727))
                                )
                            )
                        ),
                        // height: 60,
                        // shape: CircleBorder(
                        //     side: BorderSide.none
                        // ),
                        child: Icon(Icons.arrow_forward, color: Colors.white, size: 35,),
                        // color: Colors.blueAccent,
                        onPressed: () =>
                            _addSaveCoinsToLocalStorage(bitcoin),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
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

  Future<void> callCurrencyDetails(name) async {
    _saveProfileData(name);
  }

  _addSaveCoinsToLocalStorage(Bitcoin bitcoin) async {
    if (_formKey2.currentState!.validate()) {
      if (items.length > 0) {
        PortfolioBitcoin? bitcoinLocal =
        items.firstWhereOrNull(
                (element) => element.name == bitcoin.name);

        if (bitcoinLocal != null) {
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: bitcoin.name,
            DatabaseHelper.columnRateDuringAdding: bitcoin.rate,
            DatabaseHelper.columnCoinsQuantity:
            double.parse(coinCountTextEditingController!.value.text) +
                bitcoinLocal.numberOfCoins,
            DatabaseHelper.columnTotalValue:
            double.parse(coinCountTextEditingController!.value.text) *
                (bitcoin.rate!) +
                bitcoinLocal.totalValue,
          };
          final id = await dbHelper.update(row);
          print('inserted row id: $id');
        } else {
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: bitcoin.name,
            DatabaseHelper.columnRateDuringAdding: bitcoin.rate,
            DatabaseHelper.columnCoinsQuantity:
            double.parse(coinCountTextEditingController!.value.text),
            DatabaseHelper.columnTotalValue:
            double.parse(coinCountTextEditingController!.value.text) *
                (bitcoin.rate!),
          };
          final id = await dbHelper.insert(row);
          print('inserted row id: $id');
        }
      } else {
        Map<String, dynamic> row = {
          DatabaseHelper.columnName: bitcoin.name,
          DatabaseHelper.columnRateDuringAdding: bitcoin.rate,
          DatabaseHelper.columnCoinsQuantity:
          double.parse(coinCountTextEditingController!.text),
          DatabaseHelper.columnTotalValue:
          double.parse(coinCountTextEditingController!.value.text) *
              (bitcoin.rate!),
        };
        final id = await dbHelper.insert(row);
        print('inserted row id: $id');
      }

      sharedPreferences = await SharedPreferences.getInstance();
      setState(() {
        sharedPreferences!.setString("currencyName", bitcoin.name!);
        sharedPreferences!.setInt("index", 3);
        sharedPreferences!.setString("title", AppLocalizations.of(context).translate('portfolio'));
        sharedPreferences!.commit();
      });
      Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
    } else {}
  }

  getCurrentRateDiff(PortfolioBitcoin items, List<Bitcoin> bitcoinList) {
    Bitcoin j = bitcoinList.firstWhere((element) => element.name == items.name);

    double newRateDiff = j.rate! - items.rateDuringAdding;
    return newRateDiff;
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    text = text.toLowerCase();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    bitcoinList.forEach((userDetail) {
      if (userDetail.name!.toLowerCase().contains(text))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

class LinearSales {
  final int count;
  final double rate;

  LinearSales(this.count, this.rate);
}
