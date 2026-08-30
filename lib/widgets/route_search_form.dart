import 'package:flutter/material.dart';

import '../models/geo_point_model.dart';

class RouteSearchForm extends StatefulWidget {
  final Future<void> Function(
    GeoPointModel origin,
    GeoPointModel destination,
  ) onSearch;

  const RouteSearchForm({
    super.key,
    required this.onSearch,
  });

  @override
  State<RouteSearchForm> createState() => _RouteSearchFormState();
}

class _RouteSearchFormState extends State<RouteSearchForm> {
  final _originLatitudeController = TextEditingController();
  final _originLongitudeController = TextEditingController();
  final _destinationLatitudeController = TextEditingController();
  final _destinationLongitudeController = TextEditingController();

  @override
  void dispose() {
    _originLatitudeController.dispose();
    _originLongitudeController.dispose();
    _destinationLatitudeController.dispose();
    _destinationLongitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final originLatitude =
        double.tryParse(_originLatitudeController.text.trim());

    final originLongitude =
        double.tryParse(_originLongitudeController.text.trim());

    final destinationLatitude =
        double.tryParse(_destinationLatitudeController.text.trim());

    final destinationLongitude =
        double.tryParse(_destinationLongitudeController.text.trim());

    if (originLatitude == null ||
        originLongitude == null ||
        destinationLatitude == null ||
        destinationLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inserisci coordinate valide per partenza e destinazione.',
          ),
        ),
      );
      return;
    }

    await widget.onSearch(
      GeoPointModel(
        latitude: originLatitude,
        longitude: originLongitude,
      ),
      GeoPointModel(
        latitude: destinationLatitude,
        longitude: destinationLongitude,
      ),
    );
  }

  Widget _coordinateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pianifica percorso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _coordinateField(
                  controller: _originLatitudeController,
                  label: 'Lat. partenza',
                  icon: Icons.trip_origin,
                ),
                const SizedBox(width: 8),
                _coordinateField(
                  controller: _originLongitudeController,
                  label: 'Lon. partenza',
                  icon: Icons.trip_origin,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _coordinateField(
                  controller: _destinationLatitudeController,
                  label: 'Lat. destinazione',
                  icon: Icons.location_on,
                ),
                const SizedBox(width: 8),
                _coordinateField(
                  controller: _destinationLongitudeController,
                  label: 'Lon. destinazione',
                  icon: Icons.location_on,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.directions_bike),
                label: const Text('Calcola percorso'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}