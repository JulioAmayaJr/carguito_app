import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/app_client.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  List items = [];

  Future load() async {
    final response = await AppClient.instance.get(AppConstants.companies);
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
      appBar: AppBar(title: const Text('Empresas')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          return ListTile(title: Text(items[i].toString()));
        },
      ),
    );
  }
}
