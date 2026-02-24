import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';
import '../services/slot_service.dart';

class ManageClinicSettings extends StatefulWidget {
  const ManageClinicSettings({super.key});

  @override
  State<ManageClinicSettings> createState() => _ManageClinicSettingsState();
}

class _ManageClinicSettingsState extends State<ManageClinicSettings> {
  final _startCtrl = TextEditingController(text: '09:00');
  final _endCtrl = TextEditingController(text: '17:00');
  final _durationCtrl = TextEditingController(text: '20');
  // final _capacityCtrl = TextEditingController(text: '1');

  bool _loading = false;

  Future<void> save() async {
    setState(() => _loading = true);

    try {
      // 1️⃣ Save clinic settings
      await FirebaseFirestore.instance
          .collection('clinic_settings')
          .doc('main')
          .set({
        'startTime': _startCtrl.text.trim(),
        'endTime': _endCtrl.text.trim(),
        'slotDuration': int.parse(_durationCtrl.text),
        // 'defaultSlotCapacity': int.parse(_capacityCtrl.text),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2️⃣ APPLY CHANGE PIPELINE
      await SlotService.applyClinicSettingsChange();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinic settings applied successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
        print('Error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(model: FormFieldModel(label: "Clinic Start Time",readOnly: true,prefixIcon: Icons.access_time, required: true, hint: "Enter Time"), controller: _startCtrl,onTap:  () => _pickTime(_startCtrl),),
//             TextField(
//   controller: _startCtrl,
//   readOnly: true,
//   decoration: const InputDecoration(
//     labelText: 'Clinic Start Time',
//     prefixIcon: Icon(Icons.access_time),
//   ),
//   onTap: () => _pickTime(_startCtrl),
// ),

const SizedBox(height: 12),
  CustomTextField(model: FormFieldModel(label: "Clinic End Time",readOnly: true,prefixIcon: Icons.access_time, required: true, hint: "Enter Time"), controller: _endCtrl,onTap:  () => _pickTime(_endCtrl),),
// TextField(
//   controller: _endCtrl,
//   readOnly: true,
//   decoration: const InputDecoration(
//     labelText: 'Clinic End Time',
//     prefixIcon: Icon(Icons.access_time),
//   ),
//   onTap: () => _pickTime(_endCtrl),
// ),
const SizedBox(height: 12,),
  CustomTextField(model: FormFieldModel(label: "Slot Duration (minutes)",prefixIcon: Icons.access_time, required: true, hint: "Enter Duration",keyboardType: TextInputType.number), controller: _durationCtrl,),
         const SizedBox(height: 12,),   
        //  CustomTextField(model: FormFieldModel(label: "slot Capacity", hint: "hint",keyboardType: TextInputType.numberWithOptions()), controller: _capacityCtrl),
            // TextField(
            //   controller: _capacityCtrl,
            //   decoration: const InputDecoration(
            //     labelText: 'Slot Capacity',
            //   ),
            //   keyboardType: TextInputType.number,
            // ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save & Regenerate Slots'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _durationCtrl.dispose();
    // _capacityCtrl.dispose();
    super.dispose();
  }
  Future<void> _pickTime(TextEditingController controller) async {
  final now = TimeOfDay.now();

  final picked = await showTimePicker(
    context: context,
    initialTime: now,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    controller.text = formatted;
  }
}

}
