import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import '../virtualConsultation/callSettings.dart';
class VoiceCallPage extends StatefulWidget {
  final String callID;
  final String userName;
  final String userID;

  const VoiceCallPage({Key? key, required this.callID, required this.userID, required this.userName}) : super(key: key);

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: appId,
      channelName: "doclinkr", // Assuming this is your channel name
      tempToken: token,
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  void initAgora() async {
    await client.initialize();
  }

  @override
  void initState() {
    super.initState();
    print(widget.callID);
    print(widget.userID);
    print(widget.userName);
    initAgora();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                  client: client,
                  layoutType: Layout.oneToOne,
                disabledVideoWidget: Center(
                  child: Text(
                    'Video Disabled',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              AgoraVideoButtons(
                client: client,
                enabledButtons: [
                  BuiltInButtons.toggleMic,
                  BuiltInButtons.callEnd,
                ],
                onDisconnect: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

