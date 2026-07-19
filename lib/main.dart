import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const VehicleKeyVerifierApp());

class VehicleKeyVerifierApp extends StatelessWidget {
  const VehicleKeyVerifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Key Verifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF075A91)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final savedKey = GlobalKey<SavedPageState>();

  @override
  Widget build(BuildContext context) {
    final pages = [
      ResearchPage(onSaved: () => savedKey.currentState?.reload()),
      SavedPage(key: savedKey),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Key Verifier'),
        actions: [
          IconButton(
            tooltip: 'Gemini API key',
            onPressed: () => showApiKeyDialog(context),
            icon: const Icon(Icons.key),
          ),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.manage_search), label: 'Research'),
          NavigationDestination(icon: Icon(Icons.bookmarks), label: 'Saved Data'),
        ],
      ),
    );
  }
}

Future<void> showApiKeyDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final controller = TextEditingController(text: prefs.getString('gemini_api_key') ?? '');
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Gemini API key'),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'API key',
          helperText: 'Stored locally on this phone for the MVP.',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            await prefs.setString('gemini_api_key', controller.text.trim());
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class ResearchPage extends StatefulWidget {
  const ResearchPage({required this.onSaved, super.key});
  final VoidCallback onSaved;

  @override
  State<ResearchPage> createState() => _ResearchPageState();
}

class _ResearchPageState extends State<ResearchPage> {
  static const makesModels = <String, List<String>>{
    'Audi': ['A1', 'A3', 'A4', 'A5', 'A6', 'Q2', 'Q3', 'Q5', 'Q7', 'TT'],
    'BMW': ['1 Series', '2 Series', '3 Series', '4 Series', '5 Series', 'X1', 'X3', 'X5', 'MINI'],
    'Citroën': ['Berlingo', 'C1', 'C3', 'C4', 'C5 Aircross', 'Dispatch', 'Relay'],
    'Dacia': ['Duster', 'Jogger', 'Logan', 'Sandero', 'Spring'],
    'Fiat': ['500', 'Doblo', 'Ducato', 'Panda', 'Punto', 'Tipo'],
    'Ford': ['Fiesta', 'Focus', 'Kuga', 'Puma', 'Ranger', 'Transit', 'Transit Connect', 'Transit Custom'],
    'Honda': ['Civic', 'CR-V', 'HR-V', 'Jazz'],
    'Hyundai': ['i10', 'i20', 'i30', 'Ioniq', 'Kona', 'Santa Fe', 'Tucson'],
    'Jaguar': ['E-Pace', 'F-Pace', 'F-Type', 'XE', 'XF', 'XJ'],
    'Kia': ['Ceed', 'Niro', 'Picanto', 'Rio', 'Sorento', 'Sportage'],
    'Land Rover': ['Defender', 'Discovery', 'Discovery Sport', 'Freelander', 'Range Rover', 'Range Rover Evoque', 'Range Rover Sport'],
    'Mercedes-Benz': ['A-Class', 'B-Class', 'C-Class', 'E-Class', 'GLA', 'GLC', 'Sprinter', 'Vito'],
    'Nissan': ['Juke', 'Leaf', 'Micra', 'Navara', 'Note', 'NV200', 'Qashqai', 'X-Trail'],
    'Peugeot': ['108', '2008', '208', '3008', '308', '5008', 'Boxer', 'Expert', 'Partner'],
    'Renault': ['Captur', 'Clio', 'Kadjar', 'Kangoo', 'Master', 'Megane', 'Trafic', 'Zoe'],
    'SEAT': ['Arona', 'Ateca', 'Ibiza', 'Leon', 'Tarraco'],
    'Škoda': ['Citigo', 'Fabia', 'Karoq', 'Kodiaq', 'Octavia', 'Superb', 'Yeti'],
    'Toyota': ['Aygo', 'C-HR', 'Corolla', 'Hilux', 'Prius', 'Proace', 'RAV4', 'Yaris'],
    'Vauxhall': ['Astra', 'Combo', 'Corsa', 'Crossland', 'Insignia', 'Mokka', 'Movano', 'Vivaro'],
    'Volkswagen': ['Caddy', 'Crafter', 'Golf', 'Passat', 'Polo', 'T-Cross', 'T-Roc', 'Tiguan', 'Transporter'],
    'Volvo': ['S60', 'V40', 'V60', 'XC40', 'XC60', 'XC90'],
  };

  final make = TextEditingController();
  final model = TextEditingController();
  final reg = TextEditingController();
  final year = TextEditingController();
  String keyType = 'Unknown / research it';
  String jobType = 'Add key';
  bool busy = false;
  Map<String, dynamic>? result;

  void syncFromReg(String value) {
    final n = int.tryParse(value.trim());
    if (n == null || n < 1 || n > 99) return;
    final base = n >= 50 ? 2000 + n - 50 : 2000 + n;
    final period = n >= 50 ? 'Sep $base – Feb ${base + 1}' : 'Mar $base – Aug $base';
    year.text = '$base ($period)';
    setState(() {});
  }

  void syncFromYear(String value) {
    final match = RegExp(r'(20\d{2})').firstMatch(value);
    if (match == null) return;
    final y = int.parse(match.group(1)!);
    if (y < 2001 || y > 2049) return;
    final spring = y - 2000;
    final autumn = spring + 50;
    reg.text = '$spring / $autumn';
    setState(() {});
  }

  Future<void> research() async {
    if (make.text.trim().isEmpty || model.text.trim().isEmpty || year.text.trim().isEmpty) {
      showMessage('Enter a make, model and year or registration age.');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    if (apiKey.isEmpty) {
      showMessage('Add your Gemini API key using the key button at the top.');
      return;
    }
    setState(() {
      busy = true;
      result = null;
    });
    try {
      final data = await GeminiVerifier(apiKey).research(
        make: make.text.trim(),
        model: model.text.trim(),
        year: year.text.trim(),
        registrationAge: reg.text.trim(),
        keyType: keyType,
        jobType: jobType,
      );
      setState(() => result = data);
    } catch (e) {
      showMessage('Research failed: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final modelSuggestions = makesModels[make.text] ?? const <String>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('UK vehicle research', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('Enter either the registration age or vehicle year. The other field fills automatically.'),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (v) => makesModels.keys.where((e) => e.toLowerCase().contains(v.text.toLowerCase())),
                onSelected: (v) => setState(() {
                  make.text = v;
                  model.clear();
                }),
                fieldViewBuilder: (_, c, f, __) {
                  c.text = make.text;
                  c.addListener(() => make.text = c.text);
                  return TextField(controller: c, focusNode: f, decoration: const InputDecoration(labelText: 'Make'));
                },
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                key: ValueKey(make.text),
                optionsBuilder: (v) => modelSuggestions.where((e) => e.toLowerCase().contains(v.text.toLowerCase())),
                onSelected: (v) => model.text = v,
                fieldViewBuilder: (_, c, f, __) {
                  c.text = model.text;
                  c.addListener(() => model.text = c.text);
                  return TextField(controller: c, focusNode: f, decoration: const InputDecoration(labelText: 'Model'));
                },
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: reg, keyboardType: TextInputType.number, onChanged: syncFromReg, decoration: const InputDecoration(labelText: 'Registration age', hintText: '71'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: year, keyboardType: TextInputType.number, onChanged: syncFromYear, decoration: const InputDecoration(labelText: 'Vehicle year', hintText: '2021'))),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: keyType,
                decoration: const InputDecoration(labelText: 'Key type'),
                items: ['Unknown / research it', 'Standard remote key', 'Proximity / smart key', 'Slot key', 'Blade transponder key'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => keyType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: jobType,
                decoration: const InputDecoration(labelText: 'Job type'),
                items: ['Add key', 'All keys lost', 'Both add key and AKL'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => jobType = v!),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: busy ? null : research,
                icon: const Icon(Icons.travel_explore),
                label: Text(busy ? 'Researching online…' : 'Research & Verify'),
              ),
            ]),
          ),
        ),
        if (busy) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        if (result != null) ResultView(result: result!, onSaved: widget.onSaved),
      ],
    );
  }
}

class ResultView extends StatelessWidget {
  const ResultView({required this.result, required this.onSaved, super.key});
  final Map<String, dynamic> result;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final fields = (result['fields'] as Map?)?.cast<String, dynamic>() ?? {};
    final sources = (result['sources'] as List?)?.cast<dynamic>() ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(result['vehicle']?.toString() ?? 'Research result', style: Theme.of(context).textTheme.headlineSmall),
          Text('Status: ${result['verification_status'] ?? 'unverified'}'),
          const Divider(height: 28),
          ...fields.entries.map((e) {
            final v = e.value is Map ? (e.value as Map).cast<String, dynamic>() : {'value': e.value};
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(pretty(e.key)),
              subtitle: Text('${v['value'] ?? 'Research Required'}\n${v['evidence'] ?? ''}'),
              trailing: Chip(label: Text(v['confidence']?.toString() ?? 'unknown')),
            );
          }),
          if ((result['notes'] ?? '').toString().isNotEmpty) ...[
            const Divider(),
            Text('More information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result['notes'].toString()),
          ],
          if (sources.isNotEmpty) ...[
            const Divider(),
            Text('Sources', style: Theme.of(context).textTheme.titleMedium),
            ...sources.map((s) {
              final m = s is Map ? s.cast<String, dynamic>() : <String, dynamic>{};
              final url = m['url']?.toString() ?? '';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link),
                title: Text(m['site_name']?.toString() ?? url),
                subtitle: Text(m['claim']?.toString() ?? ''),
                onTap: url.isEmpty ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              );
            }),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await SavedStore.save(result);
              onSaved();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Saved Data')));
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Result'),
          ),
        ]),
      ),
    );
  }
}

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});
  @override
  State<SavedPage> createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  List<Map<String, dynamic>> items = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    items = await SavedStore.load();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final shown = items.where((e) => jsonEncode(e).toLowerCase().contains(query.toLowerCase())).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search saved vehicles'),
        ),
      ),
      Expanded(
        child: shown.isEmpty
            ? const Center(child: Text('No saved vehicle data yet.'))
            : ListView.builder(
                itemCount: shown.length,
                itemBuilder: (_, i) {
                  final r = shown[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(r['vehicle']?.toString() ?? 'Saved vehicle'),
                      subtitle: Text('${r['verification_status'] ?? 'unverified'} • ${r['saved_at'] ?? ''}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Saved vehicle')),
                            body: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [ResultView(result: r, onSaved: reload)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

class SavedStore {
  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('saved_results') ?? [];
    return raw.map((e) => (jsonDecode(e) as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> save(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await load();
    final copy = Map<String, dynamic>.from(result)..['saved_at'] = DateTime.now().toIso8601String();
    items.removeWhere((e) => e['vehicle'] == copy['vehicle']);
    items.insert(0, copy);
    await prefs.setStringList('saved_results', items.map(jsonEncode).toList());
  }
}

class GeminiVerifier {
  GeminiVerifier(this.apiKey);
  final String apiKey;

  Future<Map<String, dynamic>> research({
    required String make,
    required String model,
    required String year,
    required String registrationAge,
    required String keyType,
    required String jobType,
  }) async {
    final prompt = '''You are a strict UK automotive locksmith research assistant.
Research this UK-market vehicle only: $make $model, year/period $year, UK registration age $registrationAge, key variant $keyType, requested job $jobType.
Use current Google Search results and never guess. Distinguish add-key from all-keys-lost. For every populated field, require explicit supporting evidence. Two URLs alone do not prove agreement: compare the actual claims. Treat duplicated or reseller-copied pages as one source family.
Return JSON only with this exact structure:
{
 "vehicle":"...",
 "verification_status":"verified|partial|conflicting|research_required",
 "fields":{
   "blade_profile":{"value":"...","confidence":"confirmed|single_source|conflicting|unknown","evidence":"brief source agreement"},
   "transponder_family":{"value":"...","confidence":"...","evidence":"..."},
   "chip_or_ic":{"value":"...","confidence":"...","evidence":"..."},
   "frequency":{"value":"...","confidence":"...","evidence":"..."},
   "key_type":{"value":"...","confidence":"...","evidence":"..."},
   "add_key_obd":{"value":"yes|no|conditional|unknown","confidence":"...","evidence":"..."},
   "all_keys_lost_obd":{"value":"yes|no|conditional|unknown","confidence":"...","evidence":"..."},
   "bench_or_module_removal":{"value":"...","confidence":"...","evidence":"..."},
   "pin_security_online_requirements":{"value":"...","confidence":"...","evidence":"..."},
   "supported_tools":{"value":"...","confidence":"...","evidence":"..."}
 },
 "notes":"practical UK locksmith notes and variant warnings",
 "sources":[{"url":"https://...","site_name":"...","claim":"what this source explicitly supports"}]
}
Use Research Required for anything unsupported. Do not provide bypass, theft, or unauthorised-entry instructions.''';

    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'tools': [
          {'google_search': {}}
        ],
        'generationConfig': {'responseMimeType': 'application/json', 'temperature': 0.1}
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini returned ${response.statusCode}: ${response.body}');
    }
    final envelope = jsonDecode(response.body) as Map<String, dynamic>;
    final text = envelope['candidates']?[0]?['content']?['parts']?[0]?['text']?.toString();
    if (text == null || text.isEmpty) throw Exception('No structured answer returned.');
    final cleaned = text.replaceAll(RegExp(r'^```json\s*|\s*```$'), '');
    final data = (jsonDecode(cleaned) as Map).cast<String, dynamic>();

    final grounding = envelope['candidates']?[0]?['groundingMetadata']?['groundingChunks'];
    if (grounding is List) {
      final existing = (data['sources'] as List?)?.cast<dynamic>() ?? <dynamic>[];
      final urls = <String>{};
      for (final s in existing) {
        if (s is Map && s['url'] != null) urls.add(s['url'].toString());
      }
      for (final chunk in grounding) {
        final web = chunk is Map ? chunk['web'] : null;
        if (web is Map && web['uri'] != null && urls.add(web['uri'].toString())) {
          existing.add({
            'url': web['uri'],
            'site_name': web['title'] ?? web['uri'],
            'claim': 'Grounding source returned by Google Search'
          });
        }
      }
      data['sources'] = existing;
    }
    return data;
  }
}

String pretty(String value) => value
    .split('_')
    .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
    .join(' ');
