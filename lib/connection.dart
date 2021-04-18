import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:orzedent/islerim.dart' as isler;
import 'package:orzedent/sayfalar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final String _host = "45.80.175.31";
final int _port = 3306;
final String _user = "root";
final String _password = "Celil.OrzeDB-5353.!!";
String _db = "", _k_ad = "", _sifre = "",_is="";

bool durum = false;
List<String> istasyonlar = List();
MySqlConnection baglan;

Set dbsettings(String dbname) {
  _db = dbname;
}

Set kadsettings(String kad) {
  _k_ad = kad;
}
Set istasyonsettings(String istasyon) {
  _is = istasyon;
}


Set sifresettings(String sifre) {
  _sifre = sifre;
}

String getkad() {
  return _k_ad;
}
String getis() {
  return _is;
}

List<String> parcala = List();

lisanskontrol(BuildContext context) async {
  parcala.clear();
  istasyonlar.clear();
  int difference = 0;
  String tarih = "", yenitarih = "";
  try {
    baglan = await MySqlConnection.connect(
      ConnectionSettings(
          host: _host, port: _port, user: _user, password: _password, db: _db),
    );
    var lisanstarihi = await baglan.query('select * from ayarlar');
    for (var item in lisanstarihi) {
      tarih = item["lisansbitis"].toString();
      yenitarih = tarih.replaceAll(".", "-");
      parcala = yenitarih.split('-');

      DateTime dt =
          DateTime.parse(parcala[2] + "-" + parcala[1] + "-" + parcala[0]);
      final date2 = DateTime.now();
      difference = dt.difference(date2).inDays;
      print(difference);
      if (difference >= 0) {
        var kulltrue = await baglan.query(
            "select * from kullanicilar inner join istasyon on kullanicilar.istasyonid = istasyon.istasyonid where kullanicilar.k_ad='" +
                _k_ad +
                "' and kullanicilar.sifre='" +
                _sifre +
                "' order by kullanicilar.aktif desc");
       // print(kulltrue);

        if (kulltrue.length != 0) {
           for (var item1 in kulltrue) {
                istasyonlar.add(item1["istasyonad"].toString());
           }
             
          CoolAlert.show(
            onConfirmBtnTap: () {
              
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rotate,
                      duration: Duration(seconds: 2),
                      child: sayfalar()));
            },
            confirmBtnText: "Devam Et",
            title: "",
            context: context,
            type: CoolAlertType.success,
            text: "Giriş Başarılı",
          );


        } else {
          showTopSnackBar(
            context,
            CustomSnackBar.error(
              message:
                  "Hatalı Bilgi girişi yapılmıştır.Lütfen kontrol ederek tekrar deneyiniz !!!",
            ),
          );
        }
      } else {
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message:
                "Lisans Tarihiniz Dolmuştur !!! Ödeme İşlemleri için Yöneticinize başvurunuz !!!",
          ),
        );
      }
    }

  } catch (e) {
    showTopSnackBar(
      context,
      CustomSnackBar.error(
        message:
            "Hatalı Bilgi girişi yapılmıştır.Lütfen kontrol ederek tekrar deneyiniz !!!",
      ),
    );
  }
}
