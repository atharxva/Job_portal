import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final relatedUser = notification.relatedUser;
    final String senderName =
        relatedUser != null ? '${relatedUser['firstName']} ${relatedUser['lastName']}' : 'Unknown User';
    
    // Determine the message based on notification type
    String message = '';
    switch (notification.type) {
      case 'like':
        message = 'liked your post';
        break;
      case 'comment':
        message = 'commented on your post';
        break;
      case 'connectionAccepted':
        message = 'accepted your connection request';
        break;
      default:
        message = 'has a new notification';
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: relatedUser != null && relatedUser['profileImage'] != null
              ? NetworkImage(relatedUser['profileImage'])
              : null,
          child: relatedUser == null || relatedUser['profileImage'] == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: '$senderName ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: message),
            ],
          ),
        ),
        subtitle: Text(
          DateFormat.yMMMd().add_jm().format(notification.createdAt),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: notification.relatedPost != null && notification.relatedPost!['image'] != null
            ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(notification.relatedPost!['image']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : null,
      ),
    );
  }
}
