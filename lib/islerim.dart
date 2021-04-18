import 'package:flutter/material.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:orzedent/login.dart';
import 'package:page_transition/page_transition.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'connection.dart' as conn;

class Islerim extends StatefulWidget {
  @override
  _IslerimState createState() => _IslerimState();
}

class _IslerimState extends State<Islerim> {
  TextEditingController notController = TextEditingController();
  TextEditingController araController = TextEditingController();
  List<Map> islerim = new List<Map>();

  bool _folded = true;
  var verilerinListesi;
  void handleClick(String value) {
    switch (value) {
      case 'Ayarlar':
        break;
      case 'Çıkış Yap':
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rotate,
                duration: Duration(seconds: 2),
                child: login()));
        break;
    }
  }

  void verilerigetirsorgusu() {
    setState(() {
      islerim.clear();
    });
    DateTime dt;
    for (var item in verilerinListesi) {
      setState(() {
        islerim.add({
          "personel":item["personel"],
          "islemsaatid": item["islemid"],
          'giristarih': (dt = item["giristarih"])
              .add(Duration(days: 1))
              .toString()
              .substring(0, 11),
          'cikistarih': (dt = item["cikistarih"])
              .add(Duration(days: 1))
              .toString()
              .substring(0, 11),
          'provatarih': (dt = item["provatarih"])
              .add(Duration(days: 1))
              .toString()
              .substring(0, 11),
          'qrcode': item["is_qrcode"].toString(),
          'klinik': item["klinikad"].toString(),
          'hekimadi': item["hekimadi"].toString(),
          'hastaadi': item["hastadi"].toString(),
          'islem': item["islem"].toString(),
          'renkkodu': item["renk"].toString(),
          'islemadeti': item["adet"].toString(),
          'aciklama':
              item["acik"].toString() == "" ? "-" : item["acik"].toString(),
          "bilginotu": item["bilgi"].toString() == "" || item["bilgi"] == null
              ? "-"
              : item["bilgi"].toString(),
        });
      });
    }
  }

  // ignore: deprecated_member_use

  islerigetir() async {
    try {
      verilerinListesi = await conn.baglan.query(
          "select *,islemsaat.aciklama as bilgi,isler.aciklama as acik,islemsaat.id as islemid from  islemsaat inner join (hekimler inner join (isler inner join klinik on isler.klinikid=klinik.kid) on hekimler.id=isler.hekimid) on isler.id=islemsaat.isislemid where isler.personel='" +
              conn.getkad() +
              "' and isler.durum='0' and isler.islemdurum='" +
              conn.getis() +
              "' group by isler.id");

      verilerigetirsorgusu();
    } catch (e) {
      return null;
    }
  }

  Future _refreshData() async {
    await Future.delayed(Duration(seconds: 3))
        .then((value) => ({islerigetir()}));

    setState(() {
      islerim.clear();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(conn.getis()=="")
    conn.istasyonsettings(conn.istasyonlar[0]);
    
    islerigetir();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize:
                    Size.fromHeight(120.0), // here the desired height
                child: AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      "İşlerim Ekranı",
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      PopupMenuButton<String>(
                        onSelected: handleClick,
                        itemBuilder: (BuildContext context) {
                          return {
                            'İşlerimi Yazdır',
                            'Raporlar',
                            'Muhasebem',
                            'Ayarlar',
                            'Çıkış Yap',
                          }.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ],
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(0.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              width: _folded
                                  ? 56
                                  : MediaQuery.of(context).size.width,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.white,
                                boxShadow: kElevationToShadow[6],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 16),
                                      child: !_folded
                                          ? TextField(
                                              controller: araController,
                                              textInputAction:
                                                  TextInputAction.search,
                                              decoration: InputDecoration(
                                                  hintText: 'İşlerimde Ara...',
                                                  hintStyle: TextStyle(
                                                      color: Colors.blue[300]),
                                                  border: InputBorder.none),
                                              onEditingComplete: () async {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                verilerinListesi = await conn
                                                    .baglan
                                                    .query("select *,islemsaat.aciklama as bilgi,isler.aciklama as acik,islemsaat.id as islemid  from  islemsaat inner join (hekimler inner join (isler inner join klinik on isler.klinikid=klinik.kid) on hekimler.id=isler.hekimid) on isler.id=islemsaat.isislemid where isler.personel='" +
                                                        conn.getkad() +
                                                        "' and isler.durum='0' and isler.islemdurum='" +
                                                        conn.getis() +
                                                        "' and (isler.hastadi like '%" +
                                                        araController.text +
                                                        "%' or isler.is_qrcode like '%" +
                                                        araController.text +
                                                        "%') group by isler.id ");
                                                verilerigetirsorgusu();
                                              },
                                            )
                                          : null,
                                    ),
                                  ),
                                  Container(
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        borderRadius: BorderRadius.only(
                                          topLeft:
                                              Radius.circular(_folded ? 32 : 0),
                                          topRight: Radius.circular(32),
                                          bottomLeft:
                                              Radius.circular(_folded ? 32 : 0),
                                          bottomRight: Radius.circular(32),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Icon(
                                            _folded
                                                ? Icons.search
                                                : Icons.close,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _folded = !_folded;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )))),
            body: RefreshIndicator(
                backgroundColor: Colors.teal,
                color: Colors.white,
                displacement: 150,
                strokeWidth: 3,
                onRefresh: _refreshData,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                          child: Text("Aktif İstasyon :    "),
                        ),
                        DropdownButton<String>(
                          value: conn.getis(),
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              conn.istasyonsettings(newValue);
                            });
                            islerigetir();
                          },
                          items: conn.istasyonlar
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                      child: Text("Toplam Bulunan İş Sayısı :   " +
                          islerim.length.toString()),
                    ),
                    Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: islerim.length,
                            itemBuilder: (context, index) {
                              return ExpansionCard(
                                title: Card(
                                  elevation: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.qr_code_scanner_rounded,
                                              size: 30,
                                            ),
                                            Text(
                                              "  " +
                                                  islerim[index]["qrcode"] +
                                                  "     " +
                                                  "Hekim Adı : " +
                                                  islerim[index]["hekimadi"],
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text("Klinik : "),
                                                  Text(
                                                    islerim[index]["klinik"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Hasta Adı : "),
                                                  Text(
                                                    islerim[index]["hastaadi"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("İşlem : "),
                                                  Text(
                                                    islerim[index]["islem"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Renk Kodu : "),
                                                  Text(
                                                    islerim[index]["renkkodu"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("İşlem Adeti : "),
                                                  Text(
                                                    islerim[index]
                                                        ["islemadeti"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Açıklama  : "),
                                                  Expanded(
                                                      child: Text(
                                                    islerim[index]["aciklama"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Bilgi Notu : "),
                                                  Expanded(
                                                      child: Column(
                                                    children: [
                                                      Text(
                                                        islerim[index]
                                                            ["bilginotu"],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Divider(),
                                                      Container(
                                                          height: 30,
                                                          child: RaisedButton(
                                                              child: Text(
                                                                  "Değiştir"),
                                                              onPressed: () {
                                                                if (islerim[index]
                                                                            [
                                                                            "bilginotu"]
                                                                        .toString() ==
                                                                    "-") {
                                                                  setState(() {
                                                                    notController
                                                                            .text =
                                                                        "Bir Not Giriniz...";
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    notController
                                                                        .text = islerim[index]
                                                                            [
                                                                            "bilginotu"]
                                                                        .toString();
                                                                  });
                                                                }
                                                                showDialog<
                                                                        void>(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return PlatformAlertDialog(
                                                                        title: Text(
                                                                            'Yeni Not Giriş Ekranı'),
                                                                        content:
                                                                            TextFormField(
                                                                          maxLines:
                                                                              15,
                                                                          controller:
                                                                              notController,
                                                                        ),
                                                                        actions: <
                                                                            Widget>[
                                                                          PlatformDialogAction(
                                                                            child:
                                                                                Text('İptal'),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                          PlatformDialogAction(
                                                                            child:
                                                                                Text('Güncelle'),
                                                                            actionType:
                                                                                ActionType.Preferred,
                                                                            onPressed:
                                                                                () async {
                                                                              var notguncelle = await conn.baglan.query("update islemsaat set aciklama='" + notController.text + "' where id=Convert('" + islerim[index]["islemsaatid"].toString() + "',INT)");

                                                                              setState(() {
                                                                                islerim[index]["bilginotu"] = notController.text;
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                              showTopSnackBar(
                                                                                context,
                                                                                CustomSnackBar.success(
                                                                                  message: "Güncelleme Başarılı",
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    });
                                                              }))
                                                    ],
                                                  ))
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Giriş Tarihi : "),
                                                  Text(
                                                    islerim[index]
                                                        ["giristarih"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Çıkış Tarihi : "),
                                                  Text(
                                                    islerim[index]
                                                        ["cikistarih"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Prova Tarihi: "),
                                                  Text(
                                                    islerim[index]
                                                        ["provatarih"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 5.0,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            })),
                  ],
                ))),
        onWillPop: () {});
  }
}
