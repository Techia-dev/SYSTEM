import 'dart:io';

// ── Data ──────────────────────────────────────────────────
class TsField {
  String name, tsType;
  bool optional, nullable;
  bool isPick, isList;
  String? pickSource;
  List<String>? pickKeys;
  TsField({required this.name, required this.tsType, this.optional = false, this.nullable = false, this.isPick = false, this.isList = false, this.pickSource, this.pickKeys});
}

class TsIface {
  String name;
  String? extends_;
  List<String> generics;
  List<TsField> fields;
  TsIface({required this.name, this.extends_, this.generics = const [], this.fields = const []});
}

class TsEnum {
  String name;
  List<String> vals;
  TsEnum(this.name, this.vals);
}

// ── Globals ───────────────────────────────────────────────
final enums = <TsEnum>[];
final ifaces = <TsIface>[];
String outDir = 'lib/src/generated';

void main(List<String> args) async {
  final typesDir = path(args.isNotEmpty ? args[0] : '../../packages/types/src');
  outDir = path(args.length > 1 ? args[1] : 'lib/src/generated');

  // Read & parse
  for (final f in await readDir(typesDir)) {
    final raw = strip(f);
    enums.addAll(parseEnums(raw));
    ifaces.addAll(parseIfaces(raw));
  }
  
  // Also parse type aliases like "export type X = { ... }"
  for (final f in await readDir(typesDir)) {
    ifaces.addAll(parseTypeObjs(strip(f)));
  }

  print('${enums.length} enums, ${ifaces.length} interfaces');

  // Clean output dir
  final od = Directory(outDir);
  if (await od.exists()) await od.delete(recursive: true);
  await od.create(recursive: true);

  // Write
  for (final e in enums)    await write(enumFile(e.name), emitEnum(e));

  final allPickRefs = <String, List<String>>{};
  final writtenFiles = <String>{};
  for (final i in ifaces) {
    final code = emitClass(i, allPickRefs);
    if (code != null) {
      final fn = classFileName(i.name);
      await write(fn, code);
      writtenFiles.add(fn);
    }
  }

  // Write PickRef classes as separate files
  for (final e in allPickRefs.entries) {
    final fn = classFileName(e.key);
    await write(fn, emitPickRef(e.key, e.value));
    writtenFiles.add(fn);
  }

  // Barrel — only files that were actually written
  final b = StringBuffer('// AUTO-GENERATED\n');
  for (final e in enums) b.writeln("export '${enumFile(e.name)}';");
  for (final fn in writtenFiles.toList()..sort()) b.writeln("export '$fn';");
  await write('generated.dart', b.toString());

  print('Wrote to $outDir');
}

// ── Helpers ───────────────────────────────────────────────
String path(String s) => s.replaceAll('/', Platform.pathSeparator).replaceAll('\\', Platform.pathSeparator);
String strip(String s) => s.replaceAll(RegExp(r'//.*', multiLine: true), '').replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
String snake(String s) => s.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}').replaceFirst('_', '').toLowerCase();
String enumFile(String n) => '${snake(n)}.dart';
String classFileName(String n) => '${snake(n)}.dart';

Future<List<String>> readDir(String dir) async {
  final result = <String>[];
  await for (final e in Directory(dir).list()) {
    if (e is File && e.path.endsWith('.ts') && !e.path.endsWith('index.ts'))
      result.add(await e.readAsString());
  }
  return result;
}

Future<void> write(String name, String content) async =>
    await File('$outDir${Platform.pathSeparator}$name').writeAsString(content);

// ── Parser ────────────────────────────────────────────────
List<TsEnum> parseEnums(String raw) => [
  for (final m in RegExp(r'export\s+type\s+(\w+)\s*=\s*(?:\s*\|\s*)?("[^"]*"(?:\s*\|\s*"[^"]*")*)\s*;').allMatches(raw))
    TsEnum(m.group(1)!, m.group(2)!.split('|').map((s) => s.trim().replaceAll('"', '')).where((s) => s.isNotEmpty).toList())
];

List<TsIface> parseIfaces(String raw) {
  final result = <TsIface>[];
  for (final m in RegExp(r'export\s+(?:type\s+)?interface\s+(\w+)(?:<([^>]+)>)??(?:\s+extends\s+(\w+))?\s*\{([^}]*)\}', dotAll: true).allMatches(raw)) {
    final fields = parseFields(m.group(4)!, m.group(2) ?? '');
    result.add(TsIface(name: m.group(1)!, extends_: m.group(3), generics: (m.group(2) ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(), fields: fields));
  }
  return result;
}

// Parse "export type X = { ... }" (anonymous object type)
List<TsIface> parseTypeObjs(String raw) {
  final result = <TsIface>[];
  for (final m in RegExp(r'export\s+type\s+(\w+)\s*=\s*\{([^}]*)\}\s*;', dotAll: true).allMatches(raw)) {
    if (ifaces.any((i) => i.name == m.group(1)!)) continue;
    if (enums.any((e) => e.name == m.group(1)!)) continue;
    final fields = parseFields(m.group(2)!, '');
    result.add(TsIface(name: m.group(1)!, fields: fields));
  }
  return result;
}

List<TsField> parseFields(String body, String genStr) {
  final result = <TsField>[];
  final gens = genStr.split(',').map((s) => s.trim()).toSet();
  for (final line in body.split('\n')) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('//')) continue;
    if (t.contains('{')) continue; // nested object — skip
    final fm = RegExp(r'^(\w+)\s*(\?)?\s*:\s*(.+?)\s*;?\s*$').firstMatch(t);
    if (fm == null) continue;
    var tt = fm.group(3)!.trim();
    if (tt.endsWith(';')) tt = tt.substring(0, tt.length - 1).trim();

    final nullable = tt.contains('| null');
    if (nullable) tt = tt.replaceAll(RegExp(r'\s*\|\s*null'), '').trim();

    // union of string literals → String (not Pick types)
    if (tt.contains('"') && !tt.startsWith('Pick<')) tt = 'string';

    final opt = fm.group(2) == '?';
    final isPick = tt.startsWith('Pick<');
    final isList = tt.endsWith('[]') || tt.startsWith('Array<');
    String? pickSrc; List<String>? pickKeys;
    if (isPick) {
      final pm = RegExp(r'^Pick<(\w+),\s*(.+?)>$').firstMatch(tt);
      if (pm != null) { pickSrc = pm.group(1)!; pickKeys = pm.group(2)!.split('|').map((s) => s.trim().replaceAll('"', '')).where((s) => s.isNotEmpty).toList(); }
    }

    if (isList) {
      String inner = tt;
      if (inner.endsWith('[]')) inner = inner.substring(0, inner.length - 2);
      if (inner.startsWith('Array<')) inner = inner.substring(6, inner.length - 1);
      tt = 'List<${toDart(inner)}>';
    } else if (!isPick && !gens.contains(tt)) {
      tt = toDart(tt);
    }

    result.add(TsField(name: fm.group(1)!, tsType: tt, optional: opt, nullable: nullable, isPick: isPick, isList: isList, pickSource: pickSrc, pickKeys: pickKeys));
  }
  return result;
}

String toDart(String ts) {
  const m = {'string': 'String', 'number': 'num', 'boolean': 'bool', 'Date': 'String', 'any': 'Object?', 'unknown': 'Object?'};
  if (m.containsKey(ts)) return m[ts]!;
  return ts; // custom type name stays
}

// ── Generator ─────────────────────────────────────────────
String emitEnum(TsEnum e) {
  final b = StringBuffer();
  b.writeln('// AUTO-GENERATED');
  b.writeln('enum ${e.name} {');
  for (final v in e.vals) b.writeln('  $v,');
  b.writeln('  ;');
  b.writeln('  String toJson() => name;');
  b.writeln('  factory ${e.name}.fromJson(String? value) => values.firstWhere((v) => v.name == value, orElse: () => ${e.vals.first});');
  b.writeln('}');
  return b.toString();
}

String? emitClass(TsIface i, Map<String, List<String>> allPickRefs) {
  if (i.fields.isEmpty && i.generics.isEmpty) return null;
  if (i.generics.isNotEmpty) return emitGeneric(i);

  final b = StringBuffer('// AUTO-GENERATED\n');

  // Resolve Pick types FIRST (mutate f.tsType before collecting imports)
  for (final f in i.fields) {
    if (f.isPick && f.pickSource != null && f.pickKeys != null) {
      final rn = '${f.name[0].toUpperCase()}${f.name.substring(1)}Ref';
      f.tsType = rn;
      f.isPick = false;
      allPickRefs.putIfAbsent(rn, () => f.pickKeys!);
    }
  }

  // Imports
  final imported = <String>{};
  for (final f in i.fields) {
    for (final t in referencedTypes(f.tsType)) {
      if (t != i.name && !isPrimitive(t)) imported.add(t);
    }
  }
  // Note: extends_ not imported — we generate standalone classes (no extends)
  for (final imp in imported.toList()..sort()) b.writeln("import '${snake(imp)}.dart';");

  b.writeln('class ${i.name} {');

  // Fields
  for (final f in i.fields) b.writeln('  final ${dartTypeWithNull(f)} ${f.name};');
  b.writeln();

  // Constructor
  b.writeln('  const ${i.name}({');
  for (final f in i.fields) b.writeln('    ${f.optional || f.nullable ? "" : "required "}this.${f.name},');
  b.writeln('  });');
  b.writeln();

  // fromJson
  b.writeln('  factory ${i.name}.fromJson(Map<String, dynamic> json) =>');
  b.writeln('    ${i.name}(');
  for (final f in i.fields) {
    b.writeln('      ${f.name}: ${fromJsonExpr(f)},');
  }
  b.writeln('    );');
  b.writeln();

  // toJson
  b.writeln('  Map<String, dynamic> toJson() => {');
  for (final f in i.fields) {
    final key = f.name;
    if (f.optional && !f.nullable) {
      b.writeln("    if (${f.name} != null) '$key': ${toJsonExpr(f)},");
    } else {
      b.writeln("    '$key': ${toJsonExpr(f)},");
    }
  }
  b.writeln('  };');
  b.writeln();

  // copyWith
  b.writeln('  ${i.name} copyWith({');
  for (final f in i.fields) b.writeln('    ${f.tsType}? ${f.name},');
  b.writeln('  }) => ${i.name}(');
  for (final f in i.fields) b.writeln('    ${f.name}: ${f.name} ?? this.${f.name},');
  b.writeln('  );');
  b.writeln();

  // == hashCode
  final eq = i.fields.where((f) => f.name == 'id').firstOrNull != null
      ? 'other.id == id'
      : i.fields.take(2).map((f) => 'other.${f.name} == ${f.name}').join(' && ');
  b.writeln('  @override');
  b.writeln('  bool operator ==(Object other) => identical(this, other) || (other is ${i.name} && $eq);');
  final hc = i.fields.where((f) => f.name == 'id').firstOrNull != null
      ? 'id.hashCode'
      : i.fields.take(2).map((f) => '${f.name}.hashCode').join(' ^ ');
  b.writeln('  @override');
  b.writeln('  int get hashCode => $hc;');
  b.writeln('}');

  return b.toString();
}

String emitPickRef(String name, List<String> keys) {
  final b = StringBuffer('// AUTO-GENERATED\n');
  b.writeln('class $name {');
  for (final k in keys) b.writeln('  final String? $k;');
  b.writeln('  const $name({');
  for (final k in keys) b.writeln('    this.$k,');
  b.writeln('  });');
  b.writeln('  factory $name.fromJson(Map<String, dynamic> json) => $name(');
  for (final k in keys) b.writeln("    $k: json['$k']?.toString(),");
  b.writeln('  );');
  b.writeln('  Map<String, dynamic> toJson() => {');
  for (final k in keys) b.writeln("    '$k': $k,");
  b.writeln('  };');
  b.writeln('}');
  return b.toString();
}

String emitGeneric(TsIface i) {
  final p = i.generics.join(', ');
  final b = StringBuffer('// AUTO-GENERATED\nclass ${i.name}<$p> {\n');
  for (final f in i.fields) b.writeln('  final ${f.tsType} ${f.name};');
  b.writeln('  const ${i.name}({');
  for (final f in i.fields) b.writeln('    ${f.optional || f.nullable ? "" : "required "}this.${f.name},');
  b.writeln('  });');
  b.writeln('  factory ${i.name}.fromJson(Map<String, dynamic> json) =>');
  b.writeln('    ${i.name}(');
  for (final f in i.fields) {
    final dt = f.tsType;
    final genMatch = i.generics.where((g) => dt == g || dt == 'List<$g>');
    if (genMatch.isNotEmpty) {
      final g = genMatch.first;
      if (dt == g) {
        b.writeln("      ${f.name}: json['${f.name}'] as $g,");
      } else {
        b.writeln("      ${f.name}: (json['${f.name}'] as List<dynamic>?)?.cast<$g>() ?? [],");
      }
    } else {
      b.writeln("      ${f.name}: ${fromJsonExpr(f)},");
    }
  }
  b.writeln('    );');
  b.writeln('  Map<String, dynamic> toJson() => {');
  for (final f in i.fields) b.writeln("    '${f.name}': ${f.name},");
  b.writeln('  };');
  b.writeln('}');
  return b.toString();
}

// ── Type helpers ──────────────────────────────────────────
String dartTypeWithNull(TsField f) {
  final suffix = (f.nullable || f.optional) ? '?' : '';
  return '${f.tsType}$suffix';
}

String fromJsonExpr(TsField f) {
  final key = f.name;
  final dt = f.tsType;
  if (dt == 'String') return f.nullable ? "json['$key']?.toString()" : "json['$key']?.toString() ?? ''";
  if (dt == 'num') return f.nullable ? "(json['$key'] as num?)" : "(json['$key'] as num?) ?? 0";
  if (dt == 'bool') return f.nullable ? "json['$key'] as bool?" : "json['$key'] as bool? ?? false";
  if (dt.startsWith('List<')) {
    final inner = dt.substring(5, dt.length - 1);
    if (!isPrimitive(inner) && !enums.any((e) => e.name == inner)) {
      return f.nullable
        ? "(json['$key'] as List<dynamic>?)?.map((e) => $inner.fromJson(e as Map<String, dynamic>)).toList()"
        : "(json['$key'] as List<dynamic>?)?.map((e) => $inner.fromJson(e as Map<String, dynamic>)).toList() ?? []";
    }
    return f.nullable
      ? "(json['$key'] as List<dynamic>?)?.cast<$inner>()"
      : "(json['$key'] as List<dynamic>?)?.cast<$inner>() ?? []";
  }
  if (enums.any((e) => e.name == dt)) return "$dt.fromJson(json['$key']?.toString())";
  if (f.nullable) return "json['$key'] != null ? $dt.fromJson(json['$key'] as Map<String, dynamic>) : null";
  return "$dt.fromJson(json['$key'] as Map<String, dynamic>)";
}

String toJsonExpr(TsField f) {
  final dt = f.tsType;
  final nullable = f.nullable || f.optional;
  if (isPrimitive(dt) || dt == 'DateTime') return '${f.name}';
  if (enums.any((e) => e.name == dt)) return nullable ? '${f.name}?.toJson()' : '${f.name}.toJson()';
  if (dt.startsWith('List<')) return nullable ? '${f.name}?.toList()' : '${f.name}.toList()';
  return nullable ? '${f.name}?.toJson()' : '${f.name}.toJson()';
}

bool isPrimitive(String t) => ['String', 'num', 'bool', 'int', 'double', 'DateTime', 'Object?'].contains(t);

List<String> referencedTypes(String dt) {
  // Extract type names from the type string
  final result = <String>[];
  if (dt.startsWith('List<')) {
    final inner = dt.substring(5, dt.length - 1);
    if (!isPrimitive(inner)) result.add(inner);
  } else if (!isPrimitive(dt)) {
    result.add(dt);
  }
  return result;
}
