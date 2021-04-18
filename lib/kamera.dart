import 'package:expansion_card/expansion_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'connection.dart' as conn;

class Kamera extends StatefulWidget {
  @override
  _KameraState createState() => _KameraState();
}

class _KameraState extends State<Kamera> {
  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: 'OrzeDent');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: deprecated_member_use

  List<Map> islerim = new List<Map>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  SlidingUpPanelController panelController = SlidingUpPanelController();
  ScrollController scrollController;
  var verilerinListesi;
  TextEditingController _controller;
  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });
    _controller = TextEditingController();
    // TODO: implement initState
    super.initState();
    // ignore: deprecated_member_use
  }

  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  void verilerigetirsorgusu() {
    setState(() {
      islerim.clear();
    });
    DateTime dt;
    for (var item in verilerinListesi) {
      setState(() {
        islerim.add({
          "isid": item["id"],
          "personel": item["personel"].toString(),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Expanded(flex: 1, child: _buildQrView(context)),
                Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(1),
                          child: ElevatedButton(
                            onPressed: () {
                              if (SlidingUpPanelStatus.expanded ==
                                  panelController.status) {
                                panelController.collapse();
                              } else {
                                panelController.expand();
                              }
                            },
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 32,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(1),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.pauseCamera();
                            },
                            child: Icon(
                              Icons.stop,
                              size: 32,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(1),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.resumeCamera();
                            },
                            child: Icon(
                              Icons.navigate_next_outlined,
                              size: 32,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(1),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: Icon(
                              Icons.flip_camera_ios,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    )),

                //açılan panel alanı
                Container(
                  margin: EdgeInsets.only(top: 100),
                  child: SlidingUpPanelWidget(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                              blurRadius: 5.0,
                              spreadRadius: 2.0,
                              color: const Color(0x11000000))
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Bulunan İşler',
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 30,
                                      ),
                                      Container(
                                          width: 150,
                                          child: TextField(
                                            textInputAction:
                                                TextInputAction.search,
                                            onEditingComplete: () async {
                                              verilerinListesi = await conn
                                                  .baglan
                                                  .query("select *,islemsaat.aciklama as bilgi,isler.aciklama as acik,islemsaat.id as islemid from  islemsaat inner join (hekimler inner join (isler inner join klinik on isler.klinikid=klinik.kid) on hekimler.id=isler.hekimid) on isler.id=islemsaat.isislemid where isler.is_qrcode='" +
                                                      _controller.text +
                                                      "'and isler.durum='0' and isler.personel!='" +
                                                      conn.getkad() +
                                                      "'");

                                              verilerigetirsorgusu();
                                              FocusManager.instance.primaryFocus
                                                  .unfocus();
                                            },
                                            controller: _controller,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Qr-Code',
                                            ),
                                          )),
                                    ],
                                  )
                                ],
                              ),
                              height: 50.0,
                            ),
                          ),
                          Divider(
                            height: 0.5,
                            color: Colors.grey[300],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Flexible(
                              child: Container(
                                child: ListView.separated(
                                  controller: scrollController,
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ExpansionCard(
                                      title: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.qr_code_scanner_rounded,
                                                  size: 30,
                                                ),
                                                Text(
                                                  islerim[index]["qrcode"],
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  "        Personel: " +
                                                      islerim[index]
                                                          ["personel"],
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1),
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
                                                  Text(
                                                    islerim[index]["bilginotu"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
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
                                              Divider(),
                                              Center(
                                                child: Container(
                                                    child: RaisedButton(
                                                        child:
                                                            Text("İş Devral"),
                                                        onPressed: () async {
                                                          DateTime now =
                                                              DateTime.now();
                                                          DateFormat formatter =
                                                              DateFormat(
                                                                  'yyyy-MM-dd');
                                                          String formatted =
                                                              formatter
                                                                  .format(now);
                                                          print(formatted);
                                                          var notguncelle = await conn.baglan.query("update isler inner join islemsaat on isler.id=islemsaat.isislemid set isler.personel='" +
                                                              conn.getkad() +
                                                              "',isler.islemdurum='" +
                                                              conn.getis() +
                                                              "',islemsaat.devredilen='" +
                                                              conn.getkad() +
                                                              "',islemsaat.sontarih=Convert('" +
                                                              formatted +
                                                              "',DATE),islemsaat.sonsaat='" +
                                                              now.hour
                                                                  .toString() +
                                                              ":" +
                                                              now.minute
                                                                  .toString() +
                                                              "',isler.islemdurum='" +
                                                              conn.getis() +
                                                              "' where    islemsaat.id=Convert('" +
                                                              islerim[index][
                                                                      "islemsaatid"]
                                                                  .toString() +
                                                              "',INT)");
                                                          var islemsaatekle = await conn
                                                              .baglan
                                                              .query("insert into" +
                                                                  " islemsaat(istasyonadi,saat,isislemid,qrcode,personeladi,tarih,sontarih,sonsaat,devredilen,aciklama) values('"+conn.getis()+"','" +
                                                              now.hour
                                                                  .toString() +
                                                              ":" +
                                                              now.minute
                                                                  .toString() +
                                                              "',Convert("+islerim[index]["isid"].toString()+",INT),'"+islerim[index]["qrcode"]+"','"+conn.getkad()+"','"+formatted+"','"+formatted+"','','','')");

                                                          panelController
                                                              .collapse();

                                                          showTopSnackBar(
                                                            context,
                                                            CustomSnackBar
                                                                .success(
                                                              message:
                                                                  "Güncelleme Başarılı",
                                                            ),
                                                          );
                                                        })),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      height: 0.5,
                                    );
                                  },
                                  shrinkWrap: true,
                                  itemCount: islerim.length,
                                ),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        mainAxisSize: MainAxisSize.min,
                      ),
                    ),
                    controlHeight: 0.0,
                    anchor: 0.4,
                    panelController: panelController,
                    onTap: () {
                      ///Customize the processing logic
                      if (SlidingUpPanelStatus.expanded ==
                          panelController.status) {
                        panelController.collapse();
                        _controller.text = "";
                      } else {
                        panelController.expand();
                      }
                    },
                    enableOnTap:
                        true, //Enable the onTap callback for control bar.
                  ),
                ),
              ],
            )),
        onWillPop: () {});
  }

  islerigetir() async {
    verilerinListesi = await conn.baglan.query(
        "select *,islemsaat.aciklama as bilgi,isler.aciklama as acik,islemsaat.id as islemid from  islemsaat inner join (hekimler inner join (isler inner join klinik on isler.klinikid=klinik.kid) on hekimler.id=isler.hekimid) on isler.id=islemsaat.isislemid where isler.is_qrcode='" +
            result.code.toString() +
            "'and isler.durum='0' and isler.personel!='" +
            conn.getkad() +
            "'");

    verilerigetirsorgusu();
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 500.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;

        if (result != null) {
          controller.pauseCamera();
          setState(() {
            _controller.text = result.code;
          });
          showTopSnackBar(
              context,
              GestureDetector(
                  onTap: () {
                    panelController.expand();
                    islerigetir();
                  },
                  child: CustomSnackBar.info(
                    icon: Icon(Icons.qr_code_scanner_rounded,
                        size: 70, color: Colors.white),
                    iconRotationAngle: 0,
                    message: result != null ? result.code : "Okunmadı",
                  )));
        } else {
          controller.resumeCamera();
        }
      });
    });
  }
}
