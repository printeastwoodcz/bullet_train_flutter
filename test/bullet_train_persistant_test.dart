import 'package:bullet_train/bullet_train.dart';
import 'package:bullet_train/src/bullet_train_client.dart';
import 'package:bullet_train/src/model/feature_user.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, String>{});
  BulletTrainClient bulletTrain;
  setUpAll(() {
    bulletTrain = BulletTrainClient(
        apiKey: apiKey,
        seeds: seeds,
        config: BulletTrainConfig(storeType: StoreType.persistant));
  });

  group('[Bullet Train: Persistent storage]', () {
    test('When test multiple init with seed', () async {
      var result = await bulletTrain.initStore(seeds: seeds, clear: true);
      expect(result, true);

      var resultFF = await bulletTrain.getFeatureFlags(reload: false);
      expect(resultFF, isNotNull);
      expect(resultFF, isNotEmpty);
      expect(resultFF.length, seeds.length);

      var result2 = await bulletTrain.initStore(seeds: seeds);
      expect(result2, false);

      var resultFF2 = await bulletTrain.getFeatureFlags(reload: false);
      expect(resultFF2, isNotNull);
      expect(resultFF2, isNotEmpty);
      expect(resultFF2.length, seeds.length);
      expect(resultFF2, isNotNull);
      expect(resultFF2, isNotEmpty);
      expect(resultFF2.length, seeds.length);
    });
    test('When init remove all items and Save seeds', () async {
      await bulletTrain.clearStore();
      var result = await bulletTrain.getFeatureFlags(reload: false);
      expect(result, isEmpty);

      await bulletTrain.initStore(seeds: seeds, clear: true);
      var result2 = await bulletTrain.getFeatureFlags(reload: false);
      expect(result2, isNotEmpty);
    });
    test('When has seeded Features then success', () async {
      var result = await bulletTrain.getFeatureFlags(reload: false);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
    test('When has Feature then success', () async {
      var result = await bulletTrain.getFeatureFlags();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });

    test('When get Features then success', () async {
      var result = await bulletTrain.hasFeatureFlag('enabled_feature');
      expect(result, true);
    });

    test('When get Features for user then success', () async {
      var user = FeatureUser(identifier: 'test_sample_user');
      var result = await bulletTrain.getFeatureFlags(user: user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });

    test('When get User traits then success', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await bulletTrain.getTraits(user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var trait in result) {
        expect(trait, isNotNull);
      }
    });

    test('When get User traits for invalid user then return empty', () async {
      var user = FeatureUser(identifier: 'invalid_users_another_user');
      var result = await bulletTrain.getTraits(user);

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('When get User trait then success', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await bulletTrain.getTraits(user, keys: ['age']);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('When get User trait Update then Updated', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await bulletTrain.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result.value, isNotNull);

      var toUpdate = result.copyWith(value: '25');
      var updateResult = await bulletTrain.updateTrait(user, toUpdate);
      expect(updateResult, isNotNull);
      expect(updateResult.value, '25');
    });
  });
}
