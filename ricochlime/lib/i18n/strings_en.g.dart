///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'مادویار'
	String get appName => 'مادویار';

	late final Translations$homePage$en homePage = Translations$homePage$en.internal(_root);
	late final Translations$playPage$en playPage = Translations$playPage$en.internal(_root);
	late final Translations$settingsPage$en settingsPage = Translations$settingsPage$en.internal(_root);
	late final Translations$gameOverPage$en gameOverPage = Translations$gameOverPage$en.internal(_root);
	late final Translations$restartGameDialog$en restartGameDialog = Translations$restartGameDialog$en.internal(_root);
	late final Translations$tutorialPage$en tutorialPage = Translations$tutorialPage$en.internal(_root);
	late final Translations$shopPage$en shopPage = Translations$shopPage$en.internal(_root);
}

// Path: homePage
class Translations$homePage$en {
	Translations$homePage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'بازی'
	String get playButton => 'بازی';

	/// en: 'فروشگاه'
	String get shopButton => 'فروشگاه';

	/// en: 'تنظیمات'
	String get settingsButton => 'تنظیمات';

	/// en: 'آموزش'
	String get tutorialButton => 'آموزش';
}

// Path: playPage
class Translations$playPage$en {
	Translations$playPage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'بهترین: $p'
	String highScore({required Object p}) => 'بهترین: ${p}';

	/// en: 'لغو حرکت'
	String get undo => 'لغو حرکت';

	/// en: 'سکه'
	String get coins => 'سکه';
}

// Path: settingsPage
class Translations$settingsPage$en {
	Translations$settingsPage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'تنظیمات'
	String get title => 'تنظیمات';

	/// en: 'گیم‌پلی'
	String get gameplay => 'گیم‌پلی';

	/// en: 'دسترس‌پذیری'
	String get accessibility => 'دسترس‌پذیری';

	/// en: 'فونت خوانا'
	String get hyperlegibleFont => 'فونت خوانا';

	/// en: 'انتقال‌های نمایشی صفحه'
	String get stylizedPageTransitions => 'انتقال‌های نمایشی صفحه';

	/// en: 'صدای موسیقی'
	String get bgmVolume => 'صدای موسیقی';

	/// en: 'صدای جلوه‌ها'
	String get sfxVolume => 'صدای جلوه‌ها';

	/// en: 'امکان لغو حرکت'
	String get showUndoButton => 'امکان لغو حرکت';

	/// en: 'نمایش بازتاب در راهنما'
	String get showReflectionInAimGuide => 'نمایش بازتاب در راهنما';

	/// en: 'گلوله‌های بزرگ‌تر'
	String get biggerBullets => 'گلوله‌های بزرگ‌تر';

	/// en: 'حداکثر فریم‌برثانیه'
	String get maxFps => 'حداکثر فریم‌برثانیه';

	/// en: 'نمایش شمارنده فریم'
	String get showFpsCounter => 'نمایش شمارنده فریم';

	/// en: 'اطلاعات برنامه'
	String get appInfo => 'اطلاعات برنامه';

	/// en: 'مادویار Copyright (C) 2023-$buildYear Adil Hanney این برنامه بدون هیچ‌گونه ضمانتی ارائه می‌شود. این نرم‌افزار آزاد است و می‌توانید آن را تحت شرایطی بازتوزیع کنید.'
	String licenseNotice({required Object buildYear}) => 'مادویار  Copyright (C) 2023-${buildYear}  Adil Hanney\nاین برنامه بدون هیچ‌گونه ضمانتی ارائه می‌شود. این نرم‌افزار آزاد است و می‌توانید آن را تحت شرایطی بازتوزیع کنید.';
}

// Path: gameOverPage
class Translations$gameOverPage$en {
	Translations$gameOverPage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'بازی تمام شد!'
	String get title => 'بازی تمام شد!';

	/// en: 'امتیاز شما $p شد!'
	String highScoreNotBeaten({required Object p}) => 'امتیاز شما ${p} شد!';

	/// en: 'رکورد شما اکنون $pOld $pNew امتیاز است!'
	TextSpan highScoreBeaten({required InlineSpan pOld, required InlineSpan pNew}) => TextSpan(children: [
		const TextSpan(text: 'رکورد شما اکنون '),
		pOld,
		const TextSpan(text: ' '),
		pNew,
		const TextSpan(text: ' امتیاز است!'),
	]);

	/// en: '۱۰۰ سکه برای ادامه'
	String get continueWithCoins => '۱۰۰ سکه برای ادامه';

	/// en: 'شروع دوباره'
	String get restartGameButton => 'شروع دوباره';

	/// en: 'خانه'
	String get homeButton => 'خانه';
}

// Path: restartGameDialog
class Translations$restartGameDialog$en {
	Translations$restartGameDialog$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'بازی از نو شروع شود؟'
	String get title => 'بازی از نو شروع شود؟';

	/// en: 'از شروع دوباره مطمئن هستید؟ امکان لغو آن وجود ندارد'
	String get areYouSure => 'از شروع دوباره مطمئن هستید؟ امکان لغو آن وجود ندارد';

	/// en: 'صبر کنید، لغو کن!'
	String get waitCancel => 'صبر کنید، لغو کن!';

	/// en: 'بله، مطمئنم!'
	String get yesImSure => 'بله، مطمئنم!';
}

// Path: tutorialPage
class Translations$tutorialPage$en {
	Translations$tutorialPage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'آموزش'
	String get tutorial => 'آموزش';

	/// en: 'برای شکست هیولاها بکشید، هدف بگیرید و برای شلیک رها کنید.'
	String get dragAndRelease => 'برای شکست هیولاها بکشید، هدف بگیرید و برای شلیک رها کنید.';

	/// en: 'برای هدف‌گیری ماوس را حرکت دهید و برای شلیک کلیک کنید.'
	String get pointAndClick => 'برای هدف‌گیری ماوس را حرکت دهید و برای شلیک کلیک کنید.';

	/// en: 'پس از شکست هیولای طلایی، یک سکه می‌گیرید.'
	String get goldMonsters => 'پس از شکست هیولای طلایی، یک سکه می‌گیرید.';

	/// en: 'پس از شکست هیولای سبز، یک گلوله اضافه می‌گیرید.'
	String get greenMonsters => 'پس از شکست هیولای سبز، یک گلوله اضافه می‌گیرید.';

	/// en: 'گلوله‌ها را به دیوارها بزنید تا هیولاهای بیشتری را هدف بگیرند.'
	String get bounceOffWalls => 'گلوله‌ها را به دیوارها بزنید تا هیولاهای بیشتری را هدف بگیرند.';

	/// en: 'برای سریع‌تر شدن گلوله‌ها روی صفحه بزنید.'
	String get tapSpeedUp => 'برای سریع‌تر شدن گلوله‌ها روی صفحه بزنید.';

	/// en: 'رسیدن هیولا به خط جمجمه، در صورت شکست نخوردن در حرکت بعدی، پایان بازی است.'
	String get skullLine => 'رسیدن هیولا به خط جمجمه، در صورت شکست نخوردن در حرکت بعدی، پایان بازی است.';

	/// en: 'با پیشرفت شما هر دور ردیف‌های بیشتری از هیولاها ظاهر می‌شود.'
	String get moreMonsters => 'با پیشرفت شما هر دور ردیف‌های بیشتری از هیولاها ظاهر می‌شود.';

	/// en: 'سکه جمع کنید تا آیتم‌های جدید فروشگاه را باز کنید...'
	String get useCoinsInShop => 'سکه جمع کنید تا آیتم‌های جدید فروشگاه را باز کنید...';

	/// en: '...یا برای ادامه پس از پایان بازی از آن‌ها استفاده کنید.'
	String get orUseCoinsToContinue => '...یا برای ادامه پس از پایان بازی از آن‌ها استفاده کنید.';
}

// Path: shopPage
class Translations$shopPage$en {
	Translations$shopPage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'فروشگاه'
	String get title => 'فروشگاه';

	/// en: 'رنگ گلوله‌ها'
	String get bulletColors => 'رنگ گلوله‌ها';

	/// en: 'شکل گلوله‌ها'
	String get bulletShapes => 'شکل گلوله‌ها';

	/// en: 'ویژه'
	String get premium => 'ویژه';

	/// en: 'بازیابی خریدها'
	String get restorePurchases => 'بازیابی خریدها';

	/// en: 'خرید ۱۰۰۰ سکه'
	String get buy1000Coins => 'خرید ۱۰۰۰ سکه';

	/// en: 'خرید ۵۰۰۰ سکه'
	String get buy5000Coins => 'خرید ۵۰۰۰ سکه';
}
