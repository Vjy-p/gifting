import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enquiry_model.dart';

class EnquiryServices {
  EnquiryServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // Future<String> submit(EnquiryModel enquiry) async {
  //   final result = await _client
  //       .from('enquiries')
  //       .insert(enquiry.toJson())
  //       .select('reference_code')
  //       .single();

  //   return result['reference_code'] as String;
  // }

  Future<String> submit(EnquiryModel enquiry) async {
    try {
      final reference =
          'TG-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';

      final data = enquiry.toJson();
      data['reference_code'] = reference;

      await _client.from('enquiries').insert(data);

      return reference;
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase submit enquiry error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected submit enquiry error: $error, $stackTrace');

      rethrow;
    }
  }
}
