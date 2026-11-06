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

import 'package:collection/collection.dart';

/// The kinds of audio device LiveKit's Android audio session can route a call to.
enum AndroidAudioDeviceType { earpiece, speakerphone, wiredHeadset, bluetoothHeadset }

/// An audio device of LiveKit's Android audio session, told apart by [type]
/// and, for Bluetooth, [name].
class AndroidAudioDevice {
  final AndroidAudioDeviceType type;

  /// The session's name for the device, which picks it. Not always worth
  /// showing: see [label].
  final String name;

  /// A Bluetooth headset's own name, to show. Null for the other types, and
  /// where the platform reports none: some devices give the phone's model.
  final String? label;

  const AndroidAudioDevice({required this.type, required this.name, this.label});

  /// Null for a type this version does not know.
  static AndroidAudioDevice? fromMap(Map<Object?, Object?> map) {
    final type = AndroidAudioDeviceType.values.firstWhereOrNull((type) => type.name == map['type']);
    final name = map['name'];
    final label = map['label'];
    if (type == null || name is! String) return null;
    return AndroidAudioDevice(type: type, name: name, label: label is String ? label : null);
  }

  @override
  bool operator ==(Object other) => other is AndroidAudioDevice && other.type == type && other.name == name;

  @override
  int get hashCode => Object.hash(type, name);

  @override
  String toString() => 'AndroidAudioDevice(${type.name}, $name)';
}

/// The devices LiveKit's Android audio session offers, and the one it routes
/// to. Empty while no session runs.
class AndroidAudioDevices {
  static const none = AndroidAudioDevices(devices: [], selected: null);

  final List<AndroidAudioDevice> devices;
  final AndroidAudioDevice? selected;

  const AndroidAudioDevices({required this.devices, required this.selected});

  factory AndroidAudioDevices.fromMap(Map<Object?, Object?> map) {
    final devices = map['devices'];
    final selected = map['selected'];
    return AndroidAudioDevices(
      devices: [
        if (devices is List)
          for (final device in devices)
            if (device is Map<Object?, Object?>) ?AndroidAudioDevice.fromMap(device),
      ],
      selected: selected is Map<Object?, Object?> ? AndroidAudioDevice.fromMap(selected) : null,
    );
  }

  @override
  String toString() => 'AndroidAudioDevices($devices, selected: $selected)';
}
