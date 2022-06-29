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

  Widget get _chatBox => Row(
        children: [
          Expanded(
            child: TextField(
              decoration: kTextFieldDecoration.copyWith(hintText: "ex. How you doin'!"),
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
      );

  late final Stream<List<MessengerData>> _messagesStream =
      MessengingService().messageStream(widget.match);

  @override
  void initState() {
    MessengingService().markMessagesRead(widget.match);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      appBar: _appBar,
      body: ListView(
        children: [
          StreamBuilder(
            stream: _messagesStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<MessengerData>> snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return AnimatedList(itemBuilder: (context, index, animation) {
                  if (snapshot.data![index].sender == currentUserUID) {
                    return OutBubble(message: snapshot.data![index].message);
                  } else {
                    return InBubble(message: snapshot.data![index].message);
                  }
                });
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
          ),
          _chatBox
        ],
      ),
    );
  }
}
