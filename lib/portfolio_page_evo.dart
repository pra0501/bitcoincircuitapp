// ignore_for_file: deprecated_member_use, import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_helper.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'models/PortfolioBitcoin.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  SharedPreferences? sharedPreferences;
  num _size = 0;
  double totalValuesOfPortfolio = 0.0;
  final _formKey = GlobalKey<FormState>();
  String? URL;

  TextEditingController? coinCountTextEditingController;
  TextEditingController? coinCountEditTextEditingController;
  final dbHelper = DatabaseHelper.instance;
  List<PortfolioBitcoin> items = [];

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
                height: MediaQuery.of(context).size.height/4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xff0f2f2f3),
                  image: DecorationImage(
                    image: AssetImage("assets/image/Card Wallet.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context).translate('total_portfolio'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '\$${totalValuesOfPortfolio.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
            ),
            Expanded(
                child: items.length > 0 && bitcoinList.length > 0
                    ? ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Card(
                        elevation: 1,
                        child: Container(
                          height: MediaQuery.of(context).size.height/11,
                          width: MediaQuery.of(context).size.width/.5,
                          child:GestureDetector(
                              onTap: () {
                                showPortfolioEditDialog(items[i]);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                      height: 70,
                                      width:60,
                                      child: FadeInImage(
                                          placeholder: AssetImage('assets/image/cob.png'),
                                          // image: NetworkImage("$URL/Bitcoin/resources/icons/${items[i].name.toLowerCase()}.png"),
                                          image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${items[i].name.toLowerCase()}.png"),
                                        ),
                                      )
                                  ),
                                  // SizedBox(width:5),
                                  Padding(
                                      padding: EdgeInsets.all(5),
                                      child:Container(
                                        width:90,
                                          child:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text('${items[i].name}',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left,
                                              ),
                                              Container(
                                                child: Text('\$ ${items[i].rateDuringAdding.toStringAsFixed(2)}',
                                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              ),
                                            ],
                                          )
                                      )
                                  ),
                                  // SizedBox(width:20),
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child:Container(
                                          width:30,
                                          child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(' ${items[i].numberOfCoins.toStringAsFixed(0)}',
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.end,),
                                          ]
                                      ))
                                  ),
                                  SizedBox(width:20),
                                  Container(
                                      width:110,
                                      child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Text('\$${items[i].totalValue.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.end,),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _showdeleteCoinFromPortfolioDialog(items[i]);
                                        },
                                        child:Text(AppLocalizations.of(context).translate('remove'),
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                                          textAlign: TextAlign.end,),
                                      ),
                                    ],
                                  )),
                                  SizedBox(
                                    width: 2,
                                  )
                                ],
                              )
                          ),
                        ),
                      );
                    })
                    : Center(
                    child: Text(AppLocalizations.of(context)
                        .translate('no_coins_added')))
            ),
          ],
        ),
      ),
    );
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
      //  _ackAlert(context);
      setState(() {});
    }
  }

  Future<void> showPortfolioEditDialog(PortfolioBitcoin bitcoin) async {
    coinCountEditTextEditingController!.text = bitcoin.numberOfCoins.toInt().toString();
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
              title: Text(AppLocalizations.of(context).translate('update_coins'),
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
                    key: _formKey,
                    child: TextFormField(
                      controller: coinCountEditTextEditingController,
                      style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ], // O
                      //only numbers can be entered
                      validator: (val) {
                        if (coinCountEditTextEditingController!.value.text == "" ||
                            int.parse(coinCountEditTextEditingController!.value.text) <= 0) {
                          return "at least 1 coin should be added";
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
                                        placeholder: AssetImage('assets/image/cob.png'),
                                        image: NetworkImage(
                                          // "$URL/Bitcoin/resources/icons/${bitcoin.name.toLowerCase()}.png"),
                                            "http://45.34.15.25:8080/Bitcoin/resources/icons/${bitcoin.name.toLowerCase()}.png"),
                                      ),
                                    )
                                ),
                                SizedBox(
                                    width:10
                                ),
                                Text(bitcoin.name,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)
                              ],
                            )
                        )
                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child:TextButton(
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
                            _updateSaveCoinsToLocalStorage(bitcoin),
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

  getCurrentRateDiff(PortfolioBitcoin items, List<Bitcoin> bitcoinList) {
    Bitcoin j = bitcoinList.firstWhere((element) => element.name == items.name);

    double newRateDiff = j.rate! - items.rateDuringAdding;
    return newRateDiff;
  }

  _updateSaveCoinsToLocalStorage(PortfolioBitcoin bitcoin) async {
    if (_formKey.currentState!.validate()) {
      int adf = int.parse(coinCountEditTextEditingController!.text);
      print(adf);
      Map<String, dynamic> row = {
        DatabaseHelper.columnName: bitcoin.name,
        DatabaseHelper.columnRateDuringAdding: bitcoin.rateDuringAdding,
        DatabaseHelper.columnCoinsQuantity:
        double.parse(coinCountEditTextEditingController!.value.text),
        DatabaseHelper.columnTotalValue: (adf) * (bitcoin.rateDuringAdding),
      };
      final id = await dbHelper.update(row);
      print('inserted row id: $id');
      sharedPreferences = await SharedPreferences.getInstance();
      setState(() {
        sharedPreferences!.setString("currencyName", bitcoin.name);
        sharedPreferences!.setInt("index", 3);
        sharedPreferences!.setString("title", AppLocalizations.of(context).translate('portfolio'));
        sharedPreferences!.commit();
      });
      Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
    } else {}
  }

  void _showdeleteCoinFromPortfolioDialog(PortfolioBitcoin item) {
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
              title: Text(AppLocalizations.of(context).translate('remove_coins'),
                  style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:50),
                  child: Text(AppLocalizations.of(context).translate('do_you'),
                    style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
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
                                        placeholder: AssetImage('assets/image/cob.png'),
                                        image: NetworkImage(
                                          // "$URL/Bitcoin/resources/icons/${item.name.toLowerCase()}.png"),
                                            "http://45.34.15.25:8080/Bitcoin/resources/icons/${item.name.toLowerCase()}.png"),
                                      ),
                                    )
                                ),
                                SizedBox(
                                    width:10
                                ),
                                Text(item.name,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)
                              ],))

                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: TextButton(
                        style: ButtonStyle(
                          // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent,),
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
                        // color: Colors.redAccent,
                        onPressed: () => _deleteCoinsToLocalStorage(item),
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

  _deleteCoinsToLocalStorage(PortfolioBitcoin item) async {
    // int adf = int.parse(coinCountEditTextEditingController.text);
    // print(adf);

    final id = await dbHelper.delete(item.name);
    print('inserted row id: $id');
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setInt("index", 2);
      sharedPreferences!.setString("title", AppLocalizations.of(context).translate('coins'));
      sharedPreferences!.commit();
    });
    Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
  }
}
