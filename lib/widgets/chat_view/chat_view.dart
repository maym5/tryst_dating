import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';
import 'package:rendezvous_beta_v3/services/messaging_service.dart';
import 'package:rendezvous_beta_v3/widgets/chat_view/chat_bubble.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class ChatView extends StatefulWidget {
  const ChatView(
      {Key? key, required this.image, required this.name, required this.match})
      : super(key: key);
  final String name;
  final String image;
  final String match;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String _messageText = "";
  final TextEditingController _textController = TextEditingController();

  PreferredSize get _appBar => PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: AppBar(
          toolbarHeight: 75,
          leading: BackButton(
            color: Colors.redAccent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.image),
                radius: 20,
              ),
              const SizedBox(height: 10),
              Text(widget.name, style: kTextStyle.copyWith(fontSize: 15))
            ],
          ),
        ),
      );

  Widget get _chatBox => SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "ex. How you doin'!"),
                cursorColor: Colors.redAccent,
                onChanged: (chat) {
                  setState(() {
                    _messageText = chat;
                  });
                },
              ),
            ),
            TextButton(
                onPressed: () {
                  MessengingService().sendMessage(_messageText, widget.match);
                  setState(() {
                    _messageText = "";
                    _textController.text = _messageText;
                  });
                },
                child: Text("SEND",
                    style: kTextStyle.copyWith(
                        color: Colors.redAccent, fontSize: 15)))
          ],
        ),
      );

  late final Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    MessengingService().markMessagesRead(widget.match);
    _messagesStream = MessengingService().messageStream(widget.match);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      appBar: _appBar,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MessagesStreamBuilder(
            stream: _messagesStream,
            name: widget.name,
          ),
          _chatBox
        ],
      ),
    );
  }
}

class MessagesStreamBuilder extends StatefulWidget {
  const MessagesStreamBuilder(
      {Key? key, required this.stream, required this.name})
      : super(key: key);
  final Stream<QuerySnapshot> stream;
  final String name;

  @override
  State<MessagesStreamBuilder> createState() => _MessagesStreamBuilderState();
}

class _MessagesStreamBuilderState extends State<MessagesStreamBuilder> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          final messages = snapshot.data!.docs;
          List<MessengerData> messagesData = [];
          for (var message in messages) {
            final Map data = message.data() as Map;
            final MessengerData messengerData =
                MessengerData(message: data["message"], sender: data["sender"]);
            messagesData.add(messengerData);
          }
          return Expanded(
            child: ListView.builder(
                controller: _scrollController,
                itemCount: messagesData.length,
                itemBuilder: (context, index) {
                  if (messagesData[index].sender == currentUserUID) {
                    return OutBubble(message: messagesData[index].message);
                  } else {
                    return InBubble(message: messagesData[index].message);
                  }
                }),
          );
        } else if (!snapshot.hasData) {
          return Container(
            alignment: Alignment.center,
            child: Text(
                "Get the ball rolling and send ${widget.name} a message!",
                textAlign: TextAlign.center,
                style: kTextStyle),
          );
          // no data
        } else {
          // oops theres an error
          return Container(
            alignment: Alignment.center,
            child: Text(
                "Oops! There's been an error, that's our bad. Try again later",
                textAlign: TextAlign.center,
                style: kTextStyle),
          );
        }
      },
    );
  }
}
