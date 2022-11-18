import 'package:flutter/material.dart';

import 'DeviceInfo.dart';
import 'ipDeviceInfo.dart';

class ScrennPhone extends StatefulWidget {
  final List<dynamic> list;
  const ScrennPhone({Key? key, required this.list}) : super(key: key);

  @override
  State<ScrennPhone> createState() => _ScrennPhoneState();
}

class _ScrennPhoneState extends State<ScrennPhone> {
  Map<String, dynamic> map = {};
  Future init() async {
    final ipAdress = await IpInfoApi.getIpAdress();
    final phone = await DeviceInfo.getPhone();

    if (!mounted) return;
    setState(() => map = {'IP Adress': ipAdress, 'phone': phone});
    widget.list.add(map);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone connecter")),
      body: Container(),
    );
  }
}
