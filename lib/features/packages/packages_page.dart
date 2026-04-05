import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/app_client.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  List items = [];

  Future load() async {
    final response = await AppClient.instance.get(AppConstants.packages);
    setState(() {
      items = response.data;
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paquetes')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          return ListTile(title: Text(items[i].toString()));
        },
      ),
    );
  }
}
