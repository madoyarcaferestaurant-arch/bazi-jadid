import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/enums/game_progress.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/models/audio_settings.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/entities/items/item.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/notifiers/audio_settings_notifier.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/notifiers/game_progress_notifier.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/notifiers/inventory_notifier.dart';

class Providers {
  static final audioSettingsProvider =
      NotifierProvider<AudioSettingsNotifier, AudioSettings>(
        AudioSettingsNotifier.new,
      );

  static final gameProgressProvider =
      NotifierProvider<GameProgressNotifier, GameProgress>(
        GameProgressNotifier.new,
      );

  static final inventoryProvider =
      NotifierProvider<InventoryNotifier, List<Item>>(InventoryNotifier.new);
}
