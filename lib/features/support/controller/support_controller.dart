import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:gifting/core/constants/constants.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/support/models/chat_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class SupportController extends GetxController {
  late final GenerativeModel model;
  late final ChatSession chatSession;
  final Rxn<File> selectedImage = Rxn<File>();

  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    model = GenerativeModel(
      model: Constants.geminiAIModel,
      apiKey: Constants.geminiApiKey,
    );
    chatSession = model.startChat();
    super.onInit();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      log('picked image ${image.name}');
      selectedImage.value = File(image.path);
    }
  }

  Future<void> removeImage() async {
    selectedImage.value = null;
    log('removed image ${selectedImage.value?.path}');
  }

  Future<void> sendMessage({
    required String text,
    ChatMessage? resnedChat,
  }) async {
    if (isLoading.value) return;

    if (text.isEmpty && selectedImage.value == null && resnedChat == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    // 1. Add user message to UI immediately
    final userMsg = ChatMessage(
      text: resnedChat != null ? resnedChat.text : text,
      image: resnedChat != null ? resnedChat.image : selectedImage.value,
      role: resnedChat != null ? resnedChat.role : ChatRole.user,
      isError: false,
    );

    messages.add(userMsg);
    int messageIndex = messages.length - 1;

    try {
      Stream<GenerateContentResponse> responseStream;
      // String? responseText;

      if (selectedImage.value != null) {
        // Multi-modal request (Image + Text)
        final bytes = await selectedImage.value!.readAsBytes();
        // final content = [
        //   Content.multi([TextPart(text), DataPart('image/jpeg', bytes)]),
        // ];
        // // final response = await _model.generateContent(content);
        // // responseText = response.text;
        // responseStream = _model.generateContentStream(content);

        responseStream = chatSession.sendMessageStream(
          Content.multi([TextPart(text), DataPart('image/jpeg', bytes)]),
        );
      } else {
        // Text-only request (uses session history)
        // final response = await _chatSession.sendMessage(
        //   Content.text(text),
        // );
        // log(
        //   "response ${response.text} ${response.candidates} $response ${response.usageMetadata}",
        // );
        // responseText = response.text;

        responseStream = chatSession.sendMessageStream(Content.text(text));
      }

      // final botMsg = ChatMessage(
      //   text: responseText ?? "No response",
      //   role: ChatRole.model,
      // );
      // emit(
      //   state.copyWith(
      //     messages: List.from(state.messages)..add(botMsg),
      //     isLoading: false,
      //   ),
      // );

      String fullText = '';
      await for (final chunk in responseStream) {
        final chunkText = chunk.text ?? '';
        fullText += chunkText;
        log('count11 ${messages.length}');
        if (messages.isNotEmpty) {
          if (messages.last.role == ChatRole.model) {
            messages.last = ChatMessage(text: fullText, role: ChatRole.model);
          } else {
            messages.add(ChatMessage(text: fullText, role: ChatRole.model));
          }

          // selectedImage.value = null;
          // isLoading.value = false;
        }
      }
      selectedImage.value = null;
      isLoading.value = false;
    } on GenerativeAIException catch (e, stackTree) {
      log('Error sending the message ai ${e.message} --  $stackTree');
      // selectedImage.value = null;
      isLoading.value = false;
      // customToast(title: 'Support', text: e.message);
      customToast(title: 'Support', text: 'Something went wrong!');
      messages[messageIndex].isError = true;
      messages.refresh();
    } catch (e, stackTree) {
      log('Error sending the message $e $stackTree');
      // selectedImage.value = null;
      isLoading.value = false;
      customToast(title: 'Support', text: 'Something went wrong!');
      messages[messageIndex].isError = true;
      messages.refresh();
    } finally {
      // selectedImage.value = null;
      isLoading.value = false;
    }
  }
}
