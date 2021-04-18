import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:orzedent/sayfalar.dart';
import 'package:page_transition/page_transition.dart';
import 'connection.dart' as connection;
import 'package:shared_preferences/shared_preferences.dart';
import 'background.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController firmacontroller = new TextEditingController();

  bool benihatirla = false, hide = true;
  SharedPreferences getValue;

  @override
  void initState() {
    super.initState();
    bilgileriGetir();
  }

  void bilgileriGetir() async {
    getValue = await SharedPreferences.getInstance();

    try {
      if (getValue.getBool("hatirla")) {
        setState(() {
          benihatirla = true;
          namecontroller.text = getValue.getString("kullanici");
          passwordcontroller.text = getValue.getString("sifre");
          firmacontroller.text = getValue.getString("firma");
        });
      }
    } catch (e) {}
  }

  void bilgilerikaydet(
      String kullanici, String sifre, String firma, bool onof) async {
    final setValue = await SharedPreferences.getInstance();

    setValue.setString("kullanici", kullanici);
    setValue.setString("sifre", sifre);
    setValue.setString("firma", firma);
    setValue.setBool("hatirla", onof);
  }

  void bilgileriSil() async {
    final setValue = await SharedPreferences.getInstance();

    setValue.setString("kullanici", "");
    setValue.setString("sifre", "");
    setValue.setString("firma", "");
    setValue.setString("hatirla", "off");
  }

  void beniHatirla(bool value) {
    setState(() {
      benihatirla = value;
      if (benihatirla)
        bilgilerikaydet(namecontroller.text, passwordcontroller.text,
            firmacontroller.text, true);
      else {
        bilgileriSil();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.10),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: firmacontroller,
                decoration: InputDecoration(
                    icon: const Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: const Icon(Icons.business_outlined),
                    ),
                    hintText: "Firma Kodunuzu Giriniz",
                    labelText: "Firma Kodu"),
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: namecontroller,
                decoration: InputDecoration(
                    icon: const Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: const Icon(Icons.person),
                    ),
                    hintText: "Kullanıcı Adınızı Giriniz",
                    labelText: "Kullanıcı Adı"),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: Stack(
                  children: [
                    TextFormField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(
                          icon: const Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: const Icon(Icons.lock),
                          ),
                          hintText: "Şifrenizi Giriniz",
                          labelText: "Şifre"),
                      obscureText: hide,
                    ),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              hide = !hide;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye_sharp),
                        ))
                  ],
                )),
            SizedBox(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        "Şifremi Unuttum",
                        style:
                            TextStyle(fontSize: 12, color: Color(0XFF2661FA)),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: SwitchListTile(
                      title: Text("Beni hatirla"),
                      value: benihatirla,
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.red[200],
                      activeColor: Colors.green,
                      onChanged: (bool a) {
                        beniHatirla(a);
                      },
                    )),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: RaisedButton(
                onPressed: () {
                  connection.dbsettings(firmacontroller.text);
                  connection.kadsettings(namecontroller.text);
                  connection.sifresettings(passwordcontroller.text);
                  connection.lisanskontrol(this.context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0),
                child: Container(
                  alignment: Alignment.center,
                  height: 40.0,
                  width: size.width * 0.5,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      gradient: new LinearGradient(colors: [
                        Color.fromARGB(255, 255, 136, 34),
                        Color.fromARGB(255, 255, 177, 41)
                      ])),
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Giriş Yap",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                "    Copyright © 2020 tüm hakları saklıdır.",
                style: TextStyle(fontSize: 14, color: Color(0XFF2661FA)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
