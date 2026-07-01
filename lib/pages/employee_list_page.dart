import 'dart:io';

import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/database_service.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    final list = await DatabaseService.instance.getEmployees();

    if (!mounted) return;

    setState(() {
      employees = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("社員一覧"),
      ),
      body: employees.isEmpty
          ? const Center(
              child: Text("登録されている社員はいません"),
            )
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: File(employee.faceData).existsSync()
                        ? CircleAvatar(
                            backgroundImage: FileImage(
                              File(employee.faceData),
                            ),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(employee.name),
                    subtitle: Text("ID: ${employee.id}"),
                  ),
                );
              },
            ),
    );
  }
}