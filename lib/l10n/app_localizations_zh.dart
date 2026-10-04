// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '途遇旅行';

  @override
  String get brandMark => '途遇旅行';

  @override
  String get loginTitle => '从这里，遇见下一段旅程。';

  @override
  String get loginSubtitle => '一个途遇号，统一使用旅行与商家服务。';

  @override
  String get tuyuIdLabel => '途遇号';

  @override
  String get loginAction => '安全签名登录';

  @override
  String get localSigningHint => '身份密钥只保存在本设备安全存储中，每次登录均在本地完成 sr25519 签名。';

  @override
  String get loginError => '登录验证失败，请检查途遇号和本机身份密钥。';

  @override
  String get loginSuccess => '身份验证成功，欢迎使用途遇旅行。';

  @override
  String get tabDiscover => '发现';

  @override
  String get tabBooking => '预订';

  @override
  String get tabChat => '聊天';

  @override
  String get tabTrips => '游记';

  @override
  String get searchHint => '搜索酒店、餐厅、旅行团或票务';

  @override
  String get operationFailed => '操作失败，请检查网络或服务状态后重试。';

  @override
  String get noData => '暂无内容';

  @override
  String get requestQuote => '实时询价';

  @override
  String get bookingEmpty => '请先从发现页选择服务并获取实时报价。';

  @override
  String get quoteAmount => '实时报价';

  @override
  String get quoteExpires => '报价有效期';

  @override
  String get confirmBooking => '确认预订';

  @override
  String get bookingId => '预订号';

  @override
  String get bookingStatus => '状态';

  @override
  String get peerTuyuId => '对方途遇号';

  @override
  String get startChat => '开始聊天';

  @override
  String get messageHint => '输入消息';

  @override
  String get send => '发送';

  @override
  String get tripTitle => '游记标题';

  @override
  String get tripContent => '记录这段旅程';

  @override
  String get publishTrip => '发布游记';
}
