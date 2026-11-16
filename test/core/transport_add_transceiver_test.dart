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

@Timeout(Duration(seconds: 10))
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_client/src/core/transport.dart';
import '../mock/peerconnection_mock.dart';

class _FakeTrack extends Fake implements rtc.MediaStreamTrack {}

class _CountingPeerConnection extends MockPeerConnection {
  int transceiversAdded = 0;

  @override
  Future<rtc.RTCRtpTransceiver> addTransceiver({
    rtc.MediaStreamTrack? track,
    rtc.RTCRtpMediaType? kind,
    rtc.RTCRtpTransceiverInit? init,
  }) {
    transceiversAdded++;
    return super.addTransceiver(track: track, kind: kind, init: init);
  }
}

void main() {
  // WebRTC frees a closed peer connection's call, and adding a transceiver to it afterwards crashes the process. A
  // publish still under way as the room disconnects asks for exactly that.
  test('a transport being disposed passes no new transceiver to its peer connection', () async {
    final pc = _CountingPeerConnection();
    final transport = await Transport.create(
      (configuration, [constraints = const {}]) async => pc,
      connectOptions: const ConnectOptions(),
    );

    final disposed = transport.dispose();
    await expectLater(
      transport.addTransceiver(
        track: _FakeTrack(),
        kind: rtc.RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: rtc.RTCRtpTransceiverInit(direction: rtc.TransceiverDirection.SendOnly),
      ),
      throwsA(isA<UnexpectedConnectionState>()),
    );
    await disposed;

    expect(pc.transceiversAdded, 0);
  });
}
