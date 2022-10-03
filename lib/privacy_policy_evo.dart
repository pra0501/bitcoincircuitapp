import 'package:flutter/material.dart';
import 'localization/app_localizations.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  ScrollController? _controllerList;

  @override
  void initState() {
    _controllerList = ScrollController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          controller: _controllerList,
          children: <Widget>[
            Container(
                child: new Column(
                  children: <Widget>[
                    Container(
                      padding: new EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Text(AppLocalizations.of(context).translate('pp1'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp2'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp3'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp4'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp5'),
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp6'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp7'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp8'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp9'),
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp10'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp11'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp12'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp13'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp14'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp15'),
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp16'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp17'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp18'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp19'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp20'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp21'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp22'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp23'),
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp24'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp25'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp26'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp27'),
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp28'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp29'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp30'),
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(AppLocalizations.of(context).translate('pp31'),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                        ],
                      ),
                    ),
                  ],
                )
            )
          ],
        )
    );
  }
}
