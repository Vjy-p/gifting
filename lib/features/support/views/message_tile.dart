import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/support/controller/support_controller.dart';
import 'package:gifting/features/support/models/chat_model.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({super.key, required this.message, required this.isUser});
  final ChatMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.image != null)
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: Image.file(message.image!, width: 150),
            ),
          if (message.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.secondaryText.withValues(alpha: .12)
                    : AppColors.white.withValues(alpha: .045),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha: 0.01),
                    offset: const Offset(1, 2),
                    blurRadius: 1,
                    spreadRadius: 0,
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  MarkdownBody(data: message.text),
                  if (message.isError) ...[
                    Align(
                      alignment: AlignmentGeometry.centerEnd,
                      child: IconButton(
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        iconSize: 18,
                        onPressed: () {
                          Get.find<SupportController>().sendMessage(
                            text: '',
                            resnedChat: message,
                          );
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
