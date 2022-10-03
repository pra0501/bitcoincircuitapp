
// ignore_for_file: deprecated_member_use, import_of_legacy_library_into_null_safe

import 'package:crypto_font_icons/crypto_font_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coins_page_evo.dart';
import 'dashboard_new_evo.dart';
import 'dashboard_page_evo.dart';
import 'localization/AppLanguage.dart';
import 'localization/app_localizations.dart';
import 'models/LanguageData.dart';
import 'portfolio_page_evo.dart';
import 'privacy_policy_evo.dart';
import 'trends_page_evo.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  int _selectedIndex = 0;
  String _lable = 'TOP COINS';
  SharedPreferences? sharedPreferences;
  final PageStorageBucket bucket = PageStorageBucket();
  String? languageCodeSaved;

  List<LanguageData> languages = [
    LanguageData(languageCode: "en", languageName: "English"),
    LanguageData(languageCode: "it", languageName: "Italian"),
    LanguageData(languageCode: "de", languageName: "German"),
    LanguageData(languageCode: "sv", languageName: "Swedish"),
    LanguageData(languageCode: "fr", languageName: "French"),
    LanguageData(languageCode: "nb", languageName: "Norwegian"),
    LanguageData(languageCode: "es", languageName: "Spanish"),
    LanguageData(languageCode: "nl", languageName: "Dutch"),
    LanguageData(languageCode: "fi", languageName: "Finnish"),
    LanguageData(languageCode: "ru", languageName: "Russian"),
    LanguageData(languageCode: "pt", languageName: "Portuguese"),
    LanguageData(languageCode: "ar", languageName: "Arabic"),
  ];

  @override
  void initState() {
    getSharedPrefData();

    super.initState();
  }

  Future<void> getSharedPrefData() async {
    final SharedPreferences prefs = await _sprefs;
    setState(() {
      _selectedIndex = prefs.getInt("index") ?? 0;
      _lable = prefs.getString("title") ?? AppLocalizations.of(context).translate('top_coins');
      languageCodeSaved = prefs.getString('language_code') ?? "en";
      _saveProfileData();
    });
  }

  _saveProfileData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setInt("index", 0);
      sharedPreferences!.setString("title", AppLocalizations.of(context).translate('top_coins'));
      // sharedPreferences.commit();
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // centerTitle: true,
        title: _lable == AppLocalizations.of(context).translate('top_coins')
            ?Text(AppLocalizations.of(context).translate('top_coins'),style:TextStyle(color: Colors.black, fontWeight:FontWeight.bold),textAlign: TextAlign.start,)
            :_lable== AppLocalizations.of(context).translate('coins')
            ?Text(AppLocalizations.of(context).translate('coins'),style:TextStyle(color: Colors.black, fontWeight:FontWeight.bold),textAlign: TextAlign.start,)
            :_lable== AppLocalizations.of(context).translate('portfolio')
            ?Text(AppLocalizations.of(context).translate('portfolio'),style:TextStyle(color: Colors.black, fontWeight:FontWeight.bold),textAlign: TextAlign.start,)
            :_lable==AppLocalizations.of(context).translate('trends')
            ?Text(AppLocalizations.of(context).translate('trends'),style:TextStyle(color: Colors.black, fontWeight:FontWeight.bold),textAlign: TextAlign.start,)
            :_lable==AppLocalizations.of(context).translate('privacy_policy')
            ?Text(AppLocalizations.of(context).translate('privacy_policy'),style:TextStyle(color: Colors.black, fontWeight:FontWeight.bold),textAlign: TextAlign.start,)
        : Text(AppLocalizations.of(context).translate('home'),style:TextStyle(color: Colors.black, fontWeight:FontWeight.bold),textAlign: TextAlign.start,),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.language,
              color: Colors.black,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(child: Text(AppLocalizations.of(context).translate('select_language'))),
                      content: Container(
                          width: double.maxFinite,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: languages.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Container(
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                          onTap: () async {
                                            appLanguage.changeLanguage(Locale(
                                                languages[i].languageCode!));
                                            await getSharedPrefData();
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(languages[i].languageName!),
                                              languageCodeSaved ==
                                                      languages[i].languageCode
                                                  ? Icon(
                                                      Icons
                                                          .radio_button_checked,
                                                      color: Colors.blue,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      color: Colors.blue,
                                                    ),
                                            ],
                                          )),
                                      Divider()
                                    ],
                                  ),
                                );
                              })),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel')),
                        )
                      ],
                    );
                  });
            },
          ),
        ],
      ),
      body: PageStorage(
        child: _widgetOptions.elementAt(_selectedIndex),
        bucket: bucket,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: new Icon(
              CryptoFontIcons.BTC,
              size: 30,
            ),
            label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_filled,
              size: 30,
            ),
              label: ""
          ),BottomNavigationBarItem(
            icon: Icon(
              Icons.monetization_on,
              size: 30,
            ),
              label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_balance_wallet,
              size: 30,
            ),
              label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.trending_up,
              size: 30,
            ),
              label: ""
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.policy,
                size: 30,
              ),
              label: ""
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff4b67d8),
        // selectedFontSize: 13,
        iconSize: 20,
        onTap: _onItemTapped,
        elevation: 2,
      ),
    );
  }

  final List _widgetOptions = [
    DashboardNew(
      key: PageStorageKey('dashboardNewPageId'),
    ),
    DashboardPage(
      key: PageStorageKey('dashboardPageId'),
    ),
    CoinsPage(
      key: PageStorageKey('coinsPageId'),
    ),
    PortfolioPage(
      key: PageStorageKey('portfolioPageId'),
    ),
    TrendPage(
      key: PageStorageKey('trendPageId'),
    ),
    PrivacyPolicyPage(
      key: PageStorageKey('privacyPageId'),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0)
        _lable = AppLocalizations.of(context).translate('top_coins');
      else if (index == 1)
        _lable = AppLocalizations.of(context).translate('home');
      else if (index == 2)
        _lable = AppLocalizations.of(context).translate('coins');
      else if (index == 3)
        _lable = AppLocalizations.of(context).translate('portfolio');
      else if(index == 4)
        _lable=AppLocalizations.of(context).translate('trends');
      else if(index==5)
        _lable=AppLocalizations.of(context).translate('privacy_policy');
    });
  }
}
