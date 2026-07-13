import 'package:flutter/material.dart';

void main() => runApp(const ProjectApp());

const zoneBlocks = {1: 14, 2: 12, 3: 20, 4: 18, 5: 20, 6: 24, 7: 12, 8: 21};

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xff1565c0),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: ProjectHome(),
      ),
    );
  }
}

class ProjectHome extends StatefulWidget {
  const ProjectHome({super.key});

  @override
  State<ProjectHome> createState() => _ProjectHomeState();
}

class _ProjectHomeState extends State<ProjectHome> {
  int tab = 0;
  int zone = 1;
  int block = 1;
  int labor = 1;
  String activity = 'نماکاری';
  String contractor = '';
  final Set<int> allowedZones = {1, 2};
  final List<Map<String, dynamic>> reports = [];

  final activities = const [
    'نماکاری', 'دیوارچینی', 'سرامیک‌کاری', 'گچ‌کاری',
    'کاشی‌کاری', 'سنگ‌کاری', 'نقاشی', 'تأسیسات مکانیکی',
    'تأسیسات برقی', 'کناف', 'عایق‌کاری', 'سایر'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0d47a1),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مدیریت پروژه', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('سامانه گزارش روزانه کارگاه', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: [dashboard(), reportForm(), reportsPage(), accessPage()][tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'داشبورد'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'ثبت گزارش'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'گزارش‌ها'),
          NavigationDestination(icon: Icon(Icons.manage_accounts), label: 'دسترسی‌ها'),
        ],
      ),
    );
  }

  Widget dashboard() {
    final total = reports.fold<int>(0, (s, r) => s + (r['labor'] as int));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('داشبورد امروز', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: metric('کل نیروی انسانی', '$total', Icons.groups)),
          Expanded(child: metric('کل بلوک‌ها', '۱۴۱', Icons.apartment)),
        ]),
        const SizedBox(height: 16),
        const Text('وضعیت زون‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...zoneBlocks.entries.map((e) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${e.key}')),
            title: Text('زون ${e.key}'),
            subtitle: Text('${e.value} بلوک'),
            trailing: Text('${reports.where((r) => r['zone'] == e.key).fold<int>(0, (s, r) => s + (r['labor'] as int))} نفر'),
          ),
        )),
      ],
    );
  }

  Widget metric(String title, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Icon(icon, size: 32),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        Text(title, textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget reportForm() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('ثبت گزارش روزانه', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('زون‌های مجاز: ${allowedZones.map((z) => 'زون $z').join('، ')}'),
      const SizedBox(height: 16),
      DropdownButtonFormField<int>(
        value: zone,
        decoration: const InputDecoration(labelText: 'زون', border: OutlineInputBorder()),
        items: allowedZones.map((z) => DropdownMenuItem(value: z, child: Text('زون $z'))).toList(),
        onChanged: (v) => setState(() { zone = v!; block = 1; }),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        value: block,
        decoration: const InputDecoration(labelText: 'بلوک', border: OutlineInputBorder()),
        items: List.generate(zoneBlocks[zone]!, (i) => DropdownMenuItem(value: i + 1, child: Text('بلوک ${i + 1}'))),
        onChanged: (v) => setState(() => block = v!),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: activity,
        decoration: const InputDecoration(labelText: 'فعالیت', border: OutlineInputBorder()),
        items: activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
        onChanged: (v) => setState(() => activity = v!),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: '1',
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'تعداد نیرو', border: OutlineInputBorder()),
        onChanged: (v) => labor = int.tryParse(v) ?? 0,
      ),
      const SizedBox(height: 12),
      TextFormField(
        decoration: const InputDecoration(labelText: 'پیمانکار', border: OutlineInputBorder()),
        onChanged: (v) => contractor = v,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('افزودن عکس کارگاه')),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: () {
          setState(() => reports.add({'zone': zone, 'block': block, 'activity': activity, 'labor': labor, 'contractor': contractor}));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('گزارش ثبت شد')));
        },
        icon: const Icon(Icons.save),
        label: const Padding(padding: EdgeInsets.all(12), child: Text('ثبت گزارش روزانه')),
      ),
    ],
  );

  Widget reportsPage() => reports.isEmpty
      ? const Center(child: Text('هنوز گزارشی ثبت نشده است'))
      : ListView(
          padding: const EdgeInsets.all(12),
          children: reports.reversed.map((r) => Card(
            child: ListTile(
              title: Text('زون ${r['zone']} • بلوک ${r['block']}'),
              subtitle: Text('${r['activity']} • ${r['contractor']}'),
              trailing: Text('${r['labor']} نفر'),
            ),
          )).toList(),
        );

  Widget accessPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('دسترسی سرناظر نمونه', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const Text('مدیر می‌تواند زون‌های مجاز سرناظر را تعیین کند.'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: List.generate(8, (i) {
          final z = i + 1;
          return FilterChip(
            label: Text('زون $z'),
            selected: allowedZones.contains(z),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  allowedZones.add(z);
                } else if (allowedZones.length > 1) {
                  allowedZones.remove(z);
                }
                if (!allowedZones.contains(zone)) {
                  zone = allowedZones.first;
                  block = 1;
                }
              });
            },
          );
        }),
      ),
    ],
  );
}
