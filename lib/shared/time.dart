// 转换和校验途遇接口的毫秒时间值。

typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now().toUtc();
