import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/support/controller/support_controller.dart';
import 'package:gifting/features/support/models/chat_model.dart';
import 'package:gifting/features/support/views/message_tile.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final controller = Get.find<SupportController>();
  TextEditingController textController = TextEditingController();

  final scrollController = ScrollController();
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    // Scroll whenever messages change or the loading state flips
    _worker = everAll([controller.messages, controller.isLoading], (_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    scrollController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        final isUser = msg.role == ChatRole.user;
                        return MessageTile(message: msg, isUser: isUser);
                      },
                    );
                  }),
                ),

                // Image Preview & Loading Indicator
                Obx(() {
                  return Column(
                    children: [
                      if (controller.isLoading.value)
                        const LinearProgressIndicator(),
                      if (controller.selectedImage.value != null)
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          child: Stack(
                            children: [
                              Image.file(
                                controller.selectedImage.value!,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              IconButton(
                                style: const ButtonStyle(
                                  shape: WidgetStatePropertyAll(CircleBorder()),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  controller.removeImage();
                                },
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: AppColors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),

                // Input Area
                SafeArea(
                  top: false,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      color: AppColors.border,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image_outlined),
                          onPressed: () => controller.pickImage(),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              enabled: true,
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Obx(() {
                          return IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    controller.sendMessage(
                                      text: textController.text.trim(),
                                    );
                                    textController.clear();
                                  },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
