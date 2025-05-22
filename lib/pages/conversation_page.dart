// ignore_for_file: unnecessary_this, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:banterhub/models/appwrite_conversations_model.dart';
import 'package:banterhub/models/appwrite_message.dart';
import 'package:banterhub/providers/auth_provider.dart';
import 'package:banterhub/services/appWrite_cloud_storage_service.dart';
import 'package:banterhub/services/appWrite_db_service.dart';
import 'package:banterhub/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String receiverUserId;
  final String receiverImageUrl;
  final String receiverUserName;

  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.receiverUserId,
    required this.receiverImageUrl,
    required this.receiverUserName,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceWidth;
  late double _deviceHeight;

  late AuthProvider _auth;
  final GlobalKey<FormState> _messageFormKey = GlobalKey<FormState>();
  final ScrollController _listViewScrollController = ScrollController();
  String _messageText = '';

  String uploadedImageUrl = "";

  late Stream<AppwriteConversation> conversationStream;

  @override
  void initState() {
    super.initState();
    conversationStream = AppWriteDBService.instance
        .getConversationInAppWriteDB(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.receiverUserName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageInputField(_context),
            ),
          ],
        );
      },
    );
  }

  Widget _messageInputField(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 65, 65, 65),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.015,
      ),
      child: Form(
        key: _messageFormKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(),
            _attachImageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        validator: (_input) {
          if (_input == null || _input.isEmpty) {
            return 'Please enter a message.';
          }
          return null;
        },
        onChanged: (_input) {
          _messageFormKey.currentState!.save();
        },
        onSaved: (_input) {
          setState(() {
            _messageText = _input ?? "";
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Type a message...',
          border: InputBorder.none,
        ),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton() {
    return IconButton(
      icon: const Icon(
        Icons.send,
        color: Colors.white,
      ),
      onPressed: () {
        if (_messageFormKey.currentState!.validate()) {
          try {
            AppWriteDBService.instance.sendMessageInAppWriteDB(
              widget.conversationId,
              AppwriteMessage(
                senderId: _auth.user!.uid,
                content: _messageText,
                timeStamp: DateTime.now().toUtc(),
                type: AppwriteMessageType.Text,
              ),
            );
            _messageText = '';
            _messageFormKey.currentState!.reset();
          } catch (e) {
            print("Error Sending Message: $e");
          }
        }
      },
    );
  }

  Widget _attachImageButton() {
    return FloatingActionButton(
      mini: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(500),
      ),
      onPressed: () async {
        var pickedFile = await MediaService.instance.uploadImage("gallery");

        if (pickedFile != null) {
          // Upload to Appwrite
          String? imageUrl = await AppWriteStorageService.instance
              .uploadMediaMessageToAppWrite(
                  widget.conversationId, _auth.user!.uid, pickedFile);

          if (imageUrl != null) {
            print("✅ Media uploaded: $imageUrl");

            await AppWriteDBService.instance.sendMessageInAppWriteDB(
              widget.conversationId,
              AppwriteMessage(
                senderId: _auth.user!.uid,
                content: imageUrl,
                timeStamp: DateTime.now().toUtc(),
                type: AppwriteMessageType.Image,
              ),
            );
          } else {
            print("❌ Failed to upload image.");
          }
        } else {
          print("No image was selected.");
        }
      },
      backgroundColor: Colors.purpleAccent,
      child: const Icon(
        Icons.camera_enhance,
        color: Colors.white,
      ),
    );
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight * 0.79,
      width: _deviceWidth,
      padding: EdgeInsets.only(
        left: _deviceWidth * 0.01,
        right: _deviceWidth * 0.01,
        top: _deviceHeight * 0.005,
        bottom: _deviceHeight * 0.01,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: StreamBuilder<AppwriteConversation>(
        stream: conversationStream,
        builder: (BuildContext _context, _snapshot) {
          Timer(
            Duration(milliseconds: 50),
            () {
              _listViewScrollController.jumpTo(
                _listViewScrollController.position.maxScrollExtent,
              );
            },
          );
          var _conversationData = _snapshot.data;
          if (_snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWanderingCubes(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            );
          }

          if (_snapshot.hasError) {
            return Center(child: Text('Error: ${_snapshot.error}'));
          }

          if (!_snapshot.hasData || _conversationData == null) {
            return const Center(
                child: Text(
              'No conversations found.',
              style: TextStyle(color: Colors.white),
            ));
          }

          if (_conversationData.messages.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            controller: _listViewScrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: _conversationData.messages.length,
            itemBuilder: (BuildContext context, int index) {
              var _messageData = _conversationData.messages[index];
              bool _isOwnMessage = _messageData.senderId == _auth.user!.uid;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: _isOwnMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    _isOwnMessage
                        ? Container()
                        : Container(
                            height: _deviceHeight * 0.05,
                            width: _deviceWidth * 0.1,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(this.widget.receiverImageUrl),
                                fit: BoxFit.cover,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                    SizedBox(
                      width: _deviceWidth * 0.02,
                    ),
                    _messageData.type == AppwriteMessageType.Text
                        ? _textMessageBubble(
                            _messageData.content,
                            _isOwnMessage,
                            _messageData.timeStamp,
                          )
                        : _imageMessageBubble(
                            _messageData.content,
                            _isOwnMessage,
                            _messageData.timeStamp,
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _textMessageBubble(
      String _message, bool _isOwnMessage, DateTime _time) {
    List<Color> _colorScheme = _isOwnMessage
        ? [
            Colors.purpleAccent,
            const Color.fromARGB(255, 213, 115, 230),
          ]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];

    return Container(
      constraints: BoxConstraints(
        maxWidth: _deviceWidth * 0.75, // Responsive width
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorScheme,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              _message,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              timeago.format(_time),
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      String _imageUrl, bool _isOwnMessage, DateTime _time) {
    List<Color> _colorScheme = _isOwnMessage
        ? [
            Colors.purpleAccent,
            const Color.fromARGB(255, 213, 115, 230),
          ]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorScheme,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(_imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          Text(
            timeago.format(_time),
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
