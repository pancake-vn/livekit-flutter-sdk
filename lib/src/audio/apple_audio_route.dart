// Copyright 2026 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// A port of the iOS audio session.
class AppleAudioPort {
  /// The `AVAudioSessionPort` constant's value, such as `Receiver`, `Speaker`
  /// or `BluetoothHFP`.
  final String type;
  final String uid;
  final String name;

  const AppleAudioPort({required this.type, required this.uid, required this.name});

  static AppleAudioPort? fromMap(Object? map) {
    if (map is! Map<Object?, Object?>) return null;
    final type = map['type'];
    final uid = map['uid'];
    final name = map['name'];
    if (type is! String || uid is! String || name is! String) return null;
    return AppleAudioPort(type: type, uid: uid, name: name);
  }

  @override
  String toString() => 'AppleAudioPort($type, $uid, $name)';
}

/// The iOS audio session's category, the ports it plays to, and the inputs it
/// could record from.
class AppleAudioRoute {
  static const none = AppleAudioRoute(category: null, outputs: [], inputs: []);

  /// The `AVAudioSessionCategory` constant's value. Null where unknown.
  final String? category;
  final List<AppleAudioPort> outputs;
  final List<AppleAudioPort> inputs;

  const AppleAudioRoute({required this.category, required this.outputs, required this.inputs});

  bool get isPlayAndRecord => category == 'AVAudioSessionCategoryPlayAndRecord';

  factory AppleAudioRoute.fromMap(Map<Object?, Object?> map) {
    List<AppleAudioPort> ports(Object? list) => [
      if (list is List)
        for (final port in list) ?AppleAudioPort.fromMap(port),
    ];
    final category = map['category'];
    return AppleAudioRoute(
      category: category is String ? category : null,
      outputs: ports(map['outputs']),
      inputs: ports(map['inputs']),
    );
  }

  @override
  String toString() => 'AppleAudioRoute($category, outputs: $outputs, inputs: $inputs)';
}
