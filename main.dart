import 'package:flutter/material.dart';

void main() => runApp(const ConstructionApp());

class ConstructionApp extends StatelessWidget {
  const ConstructionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'گزارش روزانه پروژه',
      locale: const Locale('fa'),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const Directionality(textDirection: TextDirection.rtl, child: HomePage()),
    );
  }
}

class LaborEntry {
  LaborEntry(this.zone, this.block, this.activity, this.count);
  final int zone, block, count;
  final String activity;
}

class MachineEntry {
  MachineEntry(this.zone, this.block, this.type, this.count);
  final int zone, block, count;
  final String type;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final labor = <LaborEntry>[];
  final machines = <MachineEntry>[];

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(labor: labor, machines: machines),
      LaborForm(onSave: (e) => setState(() => labor.add(e))),
      MachineForm(onSave: (e) => setState(() => machines.add(e))),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('سامانه گزارش روزانه پروژه'), centerTitle: true),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'داشبورد'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'نیروی انسانی'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing), label: 'ماشین‌آلات'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.labor, required this.machines});
  final List<LaborEntry> labor;
  final List<MachineEntry> machines;
  @override
  Widget build(BuildContext context) {
    final totalLabor = labor.fold<int>(0, (s, e) => s + e.count);
    final totalMachines = machines.fold<int>(0, (s, e) => s + e.count);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('داشبورد امروز', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: MetricCard(title: 'کل نیروی انسانی', value: '$totalLabor', icon: Icons.groups)),
          const SizedBox(width: 12),
          Expanded(child: MetricCard(title: 'ماشین‌آلات فعال', value: '$totalMachines', icon: Icons.precision_manufacturing)),
        ]),
        const SizedBox(height: 20),
        const Text('نیروی انسانی به تفکیک زون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(8, (i) {
          final z = i + 1;
          final count = labor.where((e) => e.zone == z).fold<int>(0, (s, e) => s + e.count);
          return Card(child: ListTile(leading: CircleAvatar(child: Text('$z')), title: Text('زون $z'), trailing: Text('$count نفر')));
        }),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.title, required this.value, required this.icon});
  final String title, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [Icon(icon, size: 34), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), Text(title, textAlign: TextAlign.center)]),
    ),
  );
}

const activities = [
  'دیوارچینی','وال‌پست و نعل‌درگاه','اندود و پلاستر','گچ و خاک','سفیدکاری','کاشی‌کاری','سرامیک‌کاری','سنگ‌کاری','نماکاری','عایق‌کاری','ایزوگام','سقف کاذب','کناف','نقاشی','نصب در و پنجره','تأسیسات مکانیکی','لوله‌کشی آب و فاضلاب','تأسیسات برقی','کابل‌کشی','آسانسور','محوطه‌سازی','حمل مصالح','نظافت','سایر'
];
const machineTypes = ['تاورکرین','جرثقیل','بالابر','لودر','بیل مکانیکی','کامیون','پمپ بتن','کمپرسور','ژنراتور','سایر'];

class LaborForm extends StatefulWidget {
  const LaborForm({super.key, required this.onSave});
  final ValueChanged<LaborEntry> onSave;
  @override
  State<LaborForm> createState() => _LaborFormState();
}

class _LaborFormState extends State<LaborForm> {
  int zone = 1, block = 1, count = 1;
  String activity = activities.first;
  @override
  Widget build(BuildContext context) => FormShell(
    title: 'ثبت نیروی انسانی',
    children: [
      DropdownButtonFormField<int>(value: zone, decoration: const InputDecoration(labelText: 'زون'), items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('زون ${i + 1}'))), onChanged: (v) => setState(() => zone = v!)),
      DropdownButtonFormField<int>(value: block, decoration: const InputDecoration(labelText: 'بلوک'), items: List.generate(141, (i) => DropdownMenuItem(value: i + 1, child: Text('بلوک ${i + 1}'))), onChanged: (v) => setState(() => block = v!)),
      DropdownButtonFormField<String>(value: activity, isExpanded: true, decoration: const InputDecoration(labelText: 'فعالیت'), items: activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => activity = v!)),
      TextFormField(initialValue: '1', keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد نیرو'), onChanged: (v) => count = int.tryParse(v) ?? 0),
      FilledButton.icon(onPressed: () { widget.onSave(LaborEntry(zone, block, activity, count)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('گزارش نیروی انسانی ثبت شد'))); }, icon: const Icon(Icons.save), label: const Text('ثبت گزارش')),
    ],
  );
}

class MachineForm extends StatefulWidget {
  const MachineForm({super.key, required this.onSave});
  final ValueChanged<MachineEntry> onSave;
  @override
  State<MachineForm> createState() => _MachineFormState();
}

class _MachineFormState extends State<MachineForm> {
  int zone = 1, block = 1, count = 1;
  String type = machineTypes.first;
  @override
  Widget build(BuildContext context) => FormShell(
    title: 'ثبت ماشین‌آلات',
    children: [
      DropdownButtonFormField<int>(value: zone, decoration: const InputDecoration(labelText: 'زون'), items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('زون ${i + 1}'))), onChanged: (v) => setState(() => zone = v!)),
      DropdownButtonFormField<int>(value: block, decoration: const InputDecoration(labelText: 'بلوک'), items: List.generate(141, (i) => DropdownMenuItem(value: i + 1, child: Text('بلوک ${i + 1}'))), onChanged: (v) => setState(() => block = v!)),
      DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'نوع ماشین‌آلات'), items: machineTypes.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => type = v!)),
      TextFormField(initialValue: '1', keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد'), onChanged: (v) => count = int.tryParse(v) ?? 0),
      FilledButton.icon(onPressed: () { widget.onSave(MachineEntry(zone, block, type, count)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('گزارش ماشین‌آلات ثبت شد'))); }, icon: const Icon(Icons.save), label: const Text('ثبت گزارش')),
    ],
  );
}

class FormShell extends StatelessWidget {
  const FormShell({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 16), ...children.expand((w) => [w, const SizedBox(height: 14)])],
  );
}
