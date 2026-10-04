import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/devices_remote_data_source.dart';

import '../../../../helpers/fake_rest_client.dart';

void main() {
  late FakeRestClient client;
  late DevicesRemoteDataSource dataSource;

  setUp(() {
    client = FakeRestClient();
    dataSource = DevicesRemoteDataSource(restClient: client);
  });

  test('register отправляет токен и платформу', () async {
    await dataSource.register(token: 'abc', platform: 'ios');

    expect(client.last.method, 'POST');
    expect(client.last.path, '/devices/register/');
    expect(client.last.body, {'fcm_token': 'abc', 'platform': 'ios'});
  });

  test('register без платформы не отправляет поле platform', () async {
    await dataSource.register(token: 'abc');

    expect(client.last.body, {'fcm_token': 'abc'});
  });

  test('unregister отправляет токен', () async {
    await dataSource.unregister(token: 'abc');

    expect(client.last.method, 'POST');
    expect(client.last.path, '/devices/unregister/');
    expect(client.last.body, {'fcm_token': 'abc'});
  });
}
