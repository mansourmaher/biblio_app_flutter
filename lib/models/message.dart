class Message {
  final String id;
  final String senderId;
  final String senderNom;
  final String contenu;
  final DateTime dateEnvoi;
  final String conversationId;

  Message({
    required this.id,
    required this.senderId,
    required this.senderNom,
    required this.contenu,
    required this.dateEnvoi,
    required this.conversationId,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      senderNom: map['senderNom'] ?? '',
      contenu: map['contenu'] ?? '',
      dateEnvoi:
          map['dateEnvoi'] != null
              ? DateTime.tryParse(map['dateEnvoi'].toString().trim()) ??
                  DateTime.now()
              : DateTime.now(),
      conversationId: map['conversationId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderNom': senderNom,
      'contenu': contenu,
      'dateEnvoi': dateEnvoi.toIso8601String(),
      'conversationId': conversationId,
    };
  }
}
