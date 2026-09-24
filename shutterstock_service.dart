import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class ShutterstockConnection {
  final bool connected;
  final String? connectionId;
  final String? accountName;

  const ShutterstockConnection({
    required this.connected,
    this.connectionId,
    this.accountName,
  });

  factory ShutterstockConnection.fromJson(
    Map<String, dynamic> json,
  ) {
    return ShutterstockConnection(
      connected: json['connected'] == true,
      connectionId: json['connection_id']?.toString(),
      accountName: json['account_name']?.toString(),
    );
  }
}

class ShutterstockService {
  // The app talks only to a backend supplied at build/run time.
  static String get baseUrl => AppConfig.backendBaseUrl;

  static SupabaseClient get _supabase {
    return Supabase.instance.client;
  }

  static String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.id;
  }

  static Future<ShutterstockConnection> connect({
    required String accountName,
  }) async {
    AppConfig.requireBackendConfiguration();
    final uri = Uri.parse(
      '$baseUrl/stocks/shutterstock/connect',
    ).replace(
      queryParameters: {
        'user_id': _userId,
        'account_name': accountName.trim(),
      },
    );

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Shutterstock connection failed: ${response.body}',
      );
    }

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    final connection =
        ShutterstockConnection.fromJson(data);

    // Сохраняем подключение за конкретным
    // Supabase-пользователем.
    await _supabase.from('stock_connections').upsert(
      {
        'user_id': _userId,
        'provider': 'shutterstock',
        'account_label': connection.accountName,
        'external_account_id': connection.connectionId,
        'status': connection.connected
            ? 'connected'
            : 'disconnected',
        'connected_at':
            DateTime.now().toIso8601String(),
        'updated_at':
            DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,provider',
    );

    return connection;
  }

  static Future<ShutterstockConnection>
      getConnection() async {
    AppConfig.requireBackendConfiguration();
    final uri = Uri.parse(
      '$baseUrl/stocks/shutterstock/status',
    ).replace(
      queryParameters: {
        'user_id': _userId,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Could not get Shutterstock status: '
        '${response.body}',
      );
    }

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    return ShutterstockConnection.fromJson(data);
  }

  static Future<void> disconnect() async {
    AppConfig.requireBackendConfiguration();
    final uri = Uri.parse(
      '$baseUrl/stocks/shutterstock/disconnect',
    ).replace(
      queryParameters: {
        'user_id': _userId,
      },
    );

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Could not disconnect Shutterstock: '
        '${response.body}',
      );
    }

    await _supabase
        .from('stock_connections')
        .update(
          {
            'status': 'disconnected',
            'updated_at':
                DateTime.now().toIso8601String(),
          },
        )
        .eq('user_id', _userId)
        .eq('provider', 'shutterstock');
  }
}
