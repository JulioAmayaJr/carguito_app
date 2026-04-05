import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/delivery_points_provider.dart';

class DeliveryPointsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const DeliveryPointsFormScreen({super.key, this.item});

  @override
  State<DeliveryPointsFormScreen> createState() =>
      _DeliveryPointsFormScreenState();
}

class _DeliveryPointsFormScreenState extends State<DeliveryPointsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _selectedDepartment;
  String? _selectedMunicipality;

  TimeOfDay? _arrivalTime;
  TimeOfDay? _departureTime;

  final Map<String, bool> _deliveryDays = {
    'Lunes': false,
    'Martes': false,
    'Miércoles': false,
    'Jueves': false,
    'Viernes': false,
    'Sábado': false,
    'Domingo': false,
  };

  final Map<String, List<String>> elSalvadorCatalog = {
    'Ahuachapán': [
      'Ahuachapán',
      'Apaneca',
      'Atiquizaya',
      'Concepción de Ataco',
      'Jujutla',
      'San Francisco Menéndez',
      'Tacuba'
    ],
    'Cabañas': ['Sensuntepeque', 'Ilobasco', 'Victoria', 'San Isidro'],
    'Chalatenango': [
      'Chalatenango',
      'La Palma',
      'Citalá',
      'Nueva Concepción',
      'Tejutla',
      'San Ignacio'
    ],
    'Cuscatlán': [
      'Cojutepeque',
      'Suchitoto',
      'San Pedro Perulapán',
      'San Bartolomé Perulapía'
    ],
    'La Libertad': [
      'Santa Tecla',
      'Antiguo Cuscatlán',
      'La Libertad',
      'Zaragoza',
      'San Juan Opico',
      'Quezaltepeque',
      'Colón'
    ],
    'La Paz': [
      'Zacatecoluca',
      'Olocuilta',
      'San Luis Talpa',
      'San Luis La Herradura',
      'San Pedro Nonualco',
      'El Rosario'
    ],
    'La Unión': [
      'La Unión',
      'Santa Rosa de Lima',
      'Pasaquina',
      'Conchagua',
      'Intipucá',
      'San Alejo'
    ],
    'Morazán': [
      'San Francisco Gotera',
      'Jocoro',
      'Corinto',
      'Sociedad',
      'Perquín'
    ],
    'San Miguel': [
      'San Miguel',
      'Chinameca',
      'Ciudad Barrios',
      'El Tránsito',
      'San Jorge',
      'Moncagua',
      'Chapeltique'
    ],
    'San Salvador': [
      'San Salvador',
      'Apopa',
      'Ciudad Delgado',
      'Cuscatancingo',
      'Ilopango',
      'Mejicanos',
      'Panchimalco',
      'San Marcos',
      'San Martín',
      'Soyapango',
      'Tonacatepeque'
    ],
    'San Vicente': ['San Vicente', 'Apastepeque', 'Tecoluca', 'San Sebastián'],
    'Santa Ana': [
      'Santa Ana',
      'Chalchuapa',
      'Metapán',
      'Coatepeque',
      'El Congo',
      'Texistepeque',
      'Candelaria de la Frontera'
    ],
    'Sonsonate': [
      'Sonsonate',
      'Acajutla',
      'Armenia',
      'Izalco',
      'Juayúa',
      'Nahuizalco',
      'San Julián'
    ],
    'Usulután': [
      'Usulután',
      'Jiquilisco',
      'Santiago de María',
      'Berlin',
      'Jucuapa',
      'Santa Elena',
      'Puerto El Triunfo'
    ]
  };

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameCtrl.text = widget.item!['name']?.toString() ?? '';
      _addressCtrl.text = widget.item!['address']?.toString() ?? '';

      final dbDep = widget.item!['department']?.toString();
      final dbCity = widget.item!['city']?.toString();

      if (dbDep != null && elSalvadorCatalog.containsKey(dbDep)) {
        _selectedDepartment = dbDep;
        if (dbCity != null && elSalvadorCatalog[dbDep]!.contains(dbCity)) {
          _selectedMunicipality = dbCity;
        }
      }

      final arr = widget.item!['arrival_time']?.toString() ?? '';
      if (arr.isNotEmpty && arr.contains(':')) {
        final parts = arr.split(':');
        _arrivalTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }

      final dep = widget.item!['departure_time']?.toString() ?? '';
      if (dep.isNotEmpty && dep.contains(':')) {
        final parts = dep.split(':');
        _departureTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }

      final schedule = widget.item!['schedule'];
      if (schedule != null) {
        Map<String, dynamic> scheduleMap;
        if (schedule is String) {
          scheduleMap = jsonDecode(schedule);
        } else {
          scheduleMap = Map<String, dynamic>.from(schedule);
        }
        if (scheduleMap.containsKey('days')) {
          final days = List<String>.from(scheduleMap['days']);
          for (final day in days) {
            if (_deliveryDays.containsKey(day)) {
              _deliveryDays[day] = true;
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(BuildContext context, bool isArrival) async {
    final t = await showTimePicker(
      context: context,
      initialTime:
          (isArrival ? _arrivalTime : _departureTime) ?? TimeOfDay.now(),
    );
    if (t != null) {
      setState(() {
        if (isArrival) {
          _arrivalTime = t;
        } else {
          _departureTime = t;
        }
      });
    }
  }

  List<String> _getSelectedDays() {
    return _deliveryDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA0AA),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFF4C136)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFF4C136), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DeliveryPointsProvider>();
    final isEdit = widget.item != null;

    final municipalities = _selectedDepartment != null
        ? elSalvadorCatalog[_selectedDepartment]!
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF20242A),
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isEdit
                            ? 'Editar Punto de Entrega'
                            : 'Nuevo Punto de Entrega',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF20242A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  isEdit
                      ? 'Actualiza la información del punto'
                      : 'Registra un nuevo punto de entrega',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Completa la información para guardar el punto de entrega',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6F7480),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _FormSectionCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration(
                          hint: 'Nombre del encargado del punto de entrega',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
                        decoration: _inputDecoration(
                          hint: 'Departamento',
                          icon: Icons.map_outlined,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        items: elSalvadorCatalog.keys
                            .map(
                              (dep) => DropdownMenuItem(
                                value: dep,
                                child: Text(dep),
                              ),
                            )
                            .toList(),
                        validator: (v) => v == null ? 'Requerido' : null,
                        onChanged: (val) {
                          setState(() {
                            _selectedDepartment = val;
                            _selectedMunicipality = null;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedMunicipality,
                        decoration: _inputDecoration(
                          hint: 'Municipio',
                          icon: Icons.location_city_outlined,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        items: municipalities
                            .map(
                              (mun) => DropdownMenuItem(
                                value: mun,
                                child: Text(mun),
                              ),
                            )
                            .toList(),
                        validator: (v) => v == null ? 'Requerido' : null,
                        onChanged: (val) {
                          setState(() {
                            _selectedMunicipality = val;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          hint: 'Dirección exacta',
                          icon: Icons.location_on_outlined,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _FormSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Días de entrega',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Selecciona los días disponibles',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6F7480),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _deliveryDays.keys.map((day) {
                          final selected = _deliveryDays[day] ?? false;
                          return FilterChip(
                            label: Text(day),
                            selected: selected,
                            selectedColor: const Color(0xFFFFF2CC),
                            checkmarkColor: const Color(0xFFF4C136),
                            backgroundColor: const Color(0xFFF8F9FB),
                            side: BorderSide(
                              color: selected
                                  ? const Color(0xFFF4C136)
                                  : const Color(0xFFE3E7EE),
                            ),
                            labelStyle: TextStyle(
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                              color: const Color(0xFF30343B),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _deliveryDays[day] = selected;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_getSelectedDays().isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Selecciona al menos un día',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _FormSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Horario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Define la hora de llegada y salida',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6F7480),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeSelectorCard(
                              title: 'Hora llegada',
                              value: _arrivalTime != null
                                  ? _arrivalTime!.format(context)
                                  : 'Seleccionar',
                              icon: Icons.schedule_rounded,
                              onTap: () => _pickTime(context, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimeSelectorCard(
                              title: 'Hora salida',
                              value: _departureTime != null
                                  ? _departureTime!.format(context)
                                  : 'Seleccionar',
                              icon: Icons.more_time_rounded,
                              onTap: () => _pickTime(context, false),
                            ),
                          ),
                        ],
                      ),
                      if (_arrivalTime == null || _departureTime == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Selecciona hora de llegada y salida',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: prov.isLoading
                        ? null
                        : () async {
                            final selectedDays = _getSelectedDays();
                            if (_formKey.currentState!.validate() &&
                                _arrivalTime != null &&
                                _departureTime != null &&
                                selectedDays.isNotEmpty) {
                              final req = {
                                'name': _nameCtrl.text,
                                'address': _addressCtrl.text,
                                'department': _selectedDepartment,
                                'city': _selectedMunicipality,
                                'arrival_time': _formatTime(_arrivalTime),
                                'departure_time': _formatTime(_departureTime),
                                'schedule': jsonEncode({
                                  'days': selectedDays,
                                }),
                              };

                              if (!isEdit) {
                                final res = await prov.create(req);
                                if (res && context.mounted) {
                                  context.pop();
                                }
                                if (!res && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        prov.error ?? 'Error al guardar',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                final res =
                                    await prov.update(widget.item!['id'], req);
                                if (res && context.mounted) {
                                  context.pop();
                                }
                                if (!res && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        prov.error ?? 'Error al actualizar',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4C136),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: prov.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Guardar cambios' : 'Guardar',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _FormSectionCard extends StatelessWidget {
  final Widget child;

  const _FormSectionCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TimeSelectorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeSelectorCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == 'Seleccionar';

    return Material(
      color: const Color(0xFFF8F9FB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3E7EE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: const Color(0xFFF4C136),
                size: 22,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6F7480),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isPlaceholder
                      ? const Color(0xFF9AA0AA)
                      : const Color(0xFF2B2B2B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}