import 'dart:math';
import 'dart:convert';

import 'package:kraken/dom.dart';
import 'dart:io';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'module_manager.dart';

enum ReadyState { CONNECTING, OPEN, CLOSING, CLOSED }
typedef MQTTEventCallback = void Function(String id, Event event);

class MQTTModule extends BaseModule {
  @override
  String get name => 'MQTT';

  Map<String, MqttClient> _clientMap = {};
  int _clientId = 0;

  MQTTModule(ModuleManager moduleManager) : super(moduleManager);

  void dispose() {
    _clientMap.forEach((key, client) {
      client.disconnect();
    });
    _clientMap.clear();
  }

  @override
  String invoke(String method, dynamic args, InvokeModuleCallback callback) {
    if (method == 'init') {
      return init(args[0], args[1]);
    } else if (method == 'open') {
      open(args[0], args[1]);
    } else if (method == 'close') {
      close(args[0]);
    } else if (method == 'publish') {
      publish(args[0], args[1], args[2], args[3], args[4]);
    } else if (method == 'subscribe') {
      subscribe(args[0], args[1], args[2]);
    } else if (method == 'unsubscribe') {
      unsubscribe(args[0], args[1]);
    } else if (method == 'getReadyState') {
      return getReadyState(args[0]);
    } else if (method == 'addEvent') {
      addEvent(args[0], args[1], (String id, Event event) {
        moduleManager.emitModuleEvent('MQTT', data: id, event: event);
      });
    }

    return '';
  }

  String init(String url, String clientId) {
    // The client identifier can be a maximum length of 23 characters
    clientId = clientId.isEmpty ? '${DateTime.now().millisecondsSinceEpoch}:${Random().nextInt(999999999)}' : clientId;
    Uri uri = Uri.parse(url);
    int port = uri.port == 0 ? MqttClientConstants.defaultMqttPort : uri.port;
    final MqttServerClient client = MqttServerClient.withPort(uri.host, clientId, port);

    if (uri.isScheme('mqtts'))
      client.secure = true;
    else if (uri.isScheme('ws') || uri.isScheme('wss')) client.useWebSocket = true;

    var id = (_clientId++).toString();
    _clientMap[id] = client;
    return id;
  }

  void open(String id, Map<String, dynamic> options) {
    MqttClient client = _clientMap[id];
    String username;
    String password;
    if (options.containsKey('keepalive')) {
      client.keepAlivePeriod = options['keepalive'];
    }

    if (client is MqttServerClient) {
      if (options.containsKey('trustedCertificates')) {
        // Set the security context as you need, note this is the standard Dart SecurityContext class.
        // If this is incorrect the TLS handshake will abort and a Handshake exception will be raised,
        // no connect ack message will be received and the broker will disconnect.
        final context = SecurityContext.defaultContext;
        context.setTrustedCertificates(options['trustedCertificates']);
        // If needed set the private key file path and the optional passphrase and any other supported security features
        // Note that for flutter users the parameters above can be set in byte format rather than file paths.
        client.securityContext = context;
      }
    }

    if (options.containsKey('username')) {
      username = options['username'];
    }

    if (options.containsKey('password')) {
      password = options['password'];
    }

    client.connect(username, password);
  }

  // ignore: non_constant_identifier_names
  void subscribe(String id, String topic, int QoS) {
    MqttClient client = _clientMap[id];
    client.subscribe(topic, MqttQos.values[QoS]);
  }

  void unsubscribe(String id, String topic) {
    MqttClient client = _clientMap[id];
    client.unsubscribe(topic);
  }

  // ignore: non_constant_identifier_names
  int publish(String id, String topic, String message, int QoS, bool retain) {
    MqttClient client = _clientMap[id];

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    return client.publishMessage(topic, MqttQos.values[QoS], builder.payload, retain: retain);
  }

  void close(String id) {
    MqttClient client = _clientMap[id];
    client.disconnect();
    _clientMap.remove(id);
  }

  String getReadyState(String id) {
    MqttClient client = _clientMap[id];
    ReadyState state = ReadyState.CLOSED;

    if (client != null) {
      switch (client.connectionStatus.state) {
        case MqttConnectionState.connecting:
          state = ReadyState.CONNECTING;
          break;
        case MqttConnectionState.connected:
          state = ReadyState.OPEN;
          break;
        case MqttConnectionState.disconnecting:
          state = ReadyState.CLOSING;
          break;
        case MqttConnectionState.faulted:
        case MqttConnectionState.disconnected:
        default:
          state = ReadyState.CLOSED;
      }
    }

    return state.index.toString();
  }

  void addEvent(String id, String type, MQTTEventCallback callback) {
    MqttClient client = _clientMap[id];

    if (type == 'message') {
      /// The client has a change notifier object(see the Observable class) which we then listen to to get
      /// notifications of published updates to each subscribed topic.
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final String topic = c[0].topic;
        final MqttPublishMessage recMess = c[0].payload;
        final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        Event event = MessageEvent(jsonEncode({'topic': topic, 'message': message}), origin: client.server);
        callback(id, event);
      });
    } else if (type == 'open') {
      client.onConnected = () {
        Event event = Event('open');
        callback(id, event);
      };
    } else if (type == 'close') {
      client.onDisconnected = () {
        Event event = Event('close');
        callback(id, event);
      };
    } else if (type == 'publish') {
      /// If needed you can listen for published messages that have completed the publishing
      /// handshake which is Qos dependant. Any message received on this stream has completed its
      /// publishing handshake with the broker.
      client.published.listen((MqttPublishMessage message) {
        CustomEventInit init = CustomEventInit(detail: jsonEncode({
          'topic': message.variableHeader.topicName,
          'message': MqttPublishPayload.bytesToStringAsString(message.payload.message),
          'code': message.variableHeader.returnCode,
        }));
        CustomEvent event = CustomEvent('publish', init);
        callback(id, event);
      });
    } else if (type == 'subscribe') {
      /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
      /// You can add these before connection or change them dynamically after connection if
      /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
      /// can fail either because you have tried to subscribe to an invalid topic or the broker
      /// rejects the subscribe request.
      client.onSubscribed = (String topic) {
        CustomEventInit init = CustomEventInit(detail: jsonEncode({
          'topic': topic
        }));
        Event event = CustomEvent('subscribe', init);
        callback(id, event);
      };
    } else if (type == 'subscribeerror') {
      client.onSubscribeFail = (String topic) {
        CustomEventInit init = CustomEventInit(detail: jsonEncode({
          'topic': topic
        }));
        Event event = CustomEvent('subscribeerror', init);
        callback(id, event);
      };
    } else if (type == 'unsubscribe') {
      client.onUnsubscribed = (String topic) {
        CustomEventInit init = CustomEventInit(detail: jsonEncode({
          'topic': topic
        }));
        Event event = CustomEvent('unsubscribe', init);
        callback(id, event);
      };
    }
  }

}
