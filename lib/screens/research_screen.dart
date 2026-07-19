import 'package:flutter/material.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {

  final makes = [
    "Audi",
    "BMW",
    "Citroen",
    "Dacia",
    "Fiat",
    "Ford",
    "Honda",
    "Hyundai",
    "Kia",
    "Land Rover",
    "Mercedes",
    "Mini",
    "Nissan",
    "Peugeot",
    "Renault",
    "Seat",
    "Skoda",
    "Toyota",
    "Vauxhall",
    "Volkswagen",
    "Volvo",
  ];

  final models = [
    "Select a make first"
  ];

  String? selectedMake;
  String? selectedModel;

  final regController = TextEditingController();
  final yearController = TextEditingController();

  String jobType = "Spare Key";

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Card(

            child: Padding(

              padding: const EdgeInsets.all(16),

              child: Column(

                children: [

                  DropdownButtonFormField<String>(

                    decoration: const InputDecoration(
                      labelText: "Manufacturer",
                      border: OutlineInputBorder(),
                    ),

                    value: selectedMake,

                    items: makes
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),

                    onChanged: (value) {

                      setState(() {
                        selectedMake = value;
                        selectedModel = null;
                      });

                    },

                  ),

                  const SizedBox(height: 16),

                  TextFormField(

                    decoration: const InputDecoration(

                      labelText: "Model",

                      border: OutlineInputBorder(),

                      hintText: "Coming in Part 3",

                    ),

                    readOnly: true,

                  ),

                  const SizedBox(height: 16),

                  Row(

                    children: [

                      Expanded(

                        child: TextField(

                          controller: regController,

                          decoration: const InputDecoration(

                            labelText: "Registration",

                            hintText: "71",

                            border: OutlineInputBorder(),

                          ),

                        ),

                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: TextField(

                          controller: yearController,

                          decoration: const InputDecoration(

                            labelText: "Year",

                            hintText: "2021",

                            border: OutlineInputBorder(),

                          ),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(

                    value: jobType,

                    decoration: const InputDecoration(

                      labelText: "Job Type",

                      border: OutlineInputBorder(),

                    ),

                    items: const [

                      DropdownMenuItem(
                        value: "Spare Key",
                        child: Text("Spare Key"),
                      ),

                      DropdownMenuItem(
                        value: "All Keys Lost",
                        child: Text("All Keys Lost"),
                      ),

                      DropdownMenuItem(
                        value: "Module Replacement",
                        child: Text("Module Replacement"),
                      ),

                      DropdownMenuItem(
                        value: "EEPROM",
                        child: Text("EEPROM"),
                      ),

                    ],

                    onChanged: (value) {

                      setState(() {

                        jobType = value!;

                      });

                    },

                  ),

                  const SizedBox(height: 20),

                  SizedBox(

                    width: double.infinity,

                    child: FilledButton.icon(

                      onPressed: () {},

                      icon: const Icon(Icons.search),

                      label: const Text("Research Vehicle"),

                    ),

                  ),

                ],

              ),

            ),

          ),

          const SizedBox(height: 20),

          const Card(

            child: Padding(

              padding: EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    "Results",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text("Vehicle"),

                  Divider(),

                  Text("Keys"),

                  Divider(),

                  Text("Immobiliser"),

                  Divider(),

                  Text("Programming"),

                  Divider(),

                  Text("Tools"),

                  Divider(),

                  Text("Confidence"),

                  Divider(),

                  Text("Sources"),

                  Divider(),

                  Text("More Information"),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}
