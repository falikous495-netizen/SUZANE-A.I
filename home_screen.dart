import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/chat_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.storage});
  final ChatStorage storage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _ai = AiService();
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _messages.addAll(widget.storage.loadMessages());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      widget.storage.saveMessages(_messages);
    }
  }

  Future<void> _persist() => widget.storage.saveMessages(_messages);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, createdAt: DateTime.now()));
      _sending = true;
    });
    await _persist();
    _scrollToBottom();

    try {
      final history = _messages
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();
      final answer = await _ai.sendMessage(history);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: answer, isUser: false, createdAt: DateTime.now()));
        _sending = false;
      });
      await _persist();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: 'Je ne peux pas joindre mon serveur pour le moment. $error',
          isUser: false,
          createdAt: DateTime.now(),
        ));
        _sending = false;
      });
      await _persist();
      _scrollToBottom();
    }
  }

  Future<void> _newConversation() async {
    if (_sending) return;
    setState(_messages.clear);
    await widget.storage.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(colors: [Color(0xFF9B5CFF), Color(0xFF3B82F6)]),
              boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(.3), blurRadius: 16)],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 11),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SUZANE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 17)),
            Text('Votre intelligence artificielle', style: TextStyle(fontSize: 10, color: Color(0xFFAAA7C4))),
          ]),
        ]),
        actions: [
          IconButton(
            tooltip: 'Nouvelle conversation',
            onPressed: _newConversation,
            icon: const Icon(Icons.add_comment_outlined),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: _messages.isEmpty
                ? _WelcomeView(onPrompt: (value) {
                    _controller.text = value;
                    _send();
                  })
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_sending && index == _messages.length) {
                        return const _TypingBubble();
                      }
                      final message = _messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            sending: _sending,
            onSend: _send,
          ),
        ]),
      ),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onPrompt});
  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 82, height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF9B5CFF), Color(0xFF315CEB)]),
              boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(.25), blurRadius: 35)],
            ),
            child: const Icon(Icons.auto_awesome, size: 39, color: Colors.white),
          ),
          const SizedBox(height: 25),
          const Text('Bonjour, bienvenue sur SUZANE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Text('Que souhaitez-vous accomplir aujourd’hui ?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFAAA7C4), fontSize: 14)),
          const SizedBox(height: 28),
          _PromptCard(icon: Icons.school_outlined, label: 'Aide-moi à apprendre quelque chose', onTap: () => onPrompt('Aide-moi à apprendre quelque chose.')),
          _PromptCard(icon: Icons.lightbulb_outline, label: 'Trouve une idée de projet', onTap: () => onPrompt('Propose-moi une idée de projet réaliste.')),
          _PromptCard(icon: Icons.edit_note, label: 'Aide-moi à rédiger un document', onTap: () => onPrompt('Aide-moi à rédiger un document professionnel.')),
        ]),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: const Color(0xFF15152B),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(children: [
            Icon(icon, color: const Color(0xFFB89BFF), size: 21),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF85819F)),
          ]),
        ),
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .86),
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: user ? const Color(0xFF6243B8) : const Color(0xFF17172D),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(user ? 17 : 5),
            bottomRight: Radius.circular(user ? 5 : 17),
          ),
          border: user ? null : Border.all(color: const Color(0xFF292744)),
        ),
        child: SelectableText(message.text, style: const TextStyle(fontSize: 14, height: 1.48)),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.only(bottom: 14, left: 8),
      child: Text('SUZANE réfléchit…', style: TextStyle(color: Color(0xFFB89BFF), fontSize: 12)),
    ),
  );
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1B),
        border: Border(top: BorderSide(color: Color(0xFF24233A))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Écrivez à SUZANE…',
              hintStyle: const TextStyle(color: Color(0xFF77748F), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF19192D),
              contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF9B5CFF), Color(0xFF4169E1)]),
          ),
          child: IconButton(
            onPressed: sending ? null : onSend,
            icon: sending
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
