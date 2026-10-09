# 途遇移动端技术文档

## 工具与依赖的声明和供给职责（2026-10-08）

本产品完全独立管理全部流程所需的工具、依赖及其它资源需求。需求唯一依据为本仓源码、公开声明、锁文件及本产品拥有的准备配方，包括准确版本、平台、官方来源、摘要或固定提交、闭包、验真方式和失败条件；塔塔控制台按当前产品声明提供资源，不维护另一份产品需求或替产品决定版本、来源与流程步骤。

本产品必须能在没有塔塔控制台时完全独立执行全部已实现流程。独立执行时，本产品自行完成可信引导、资源获取、验真、保存、复用及任务工作视图准备，不依赖控制台源码、私有资料、安装位置或资源库。

通过塔塔控制台执行本产品流程时，本产品向控制台声明所需资源并使用其已准备好的供给。控制台先核对并复用已有的匹配工具与依赖；没有的由控制台按本产品声明下载、准备、验真并保存到控制台工具库或依赖库，再交付本产品复用。本产品负责核验交付与自身需求一致并使用资源，不因控制台缺件或供给失败改为自行下载，也不另建同一资源的永久副本；可写包管理器视图与流程过程数据仍归本产品当前任务工作目录。

两种执行方式使用本产品同一声明、锁和流程实现，仅资源供给职责随执行方式改变。该职责适用于本产品全部平台与已实现流程。独立模式下资源缺失由产品处理；控制台模式下资源缺失由控制台处理。显式离线缺件、交付失败、损坏、错误摘要、来源漂移或越界必须据实失败，不自动升级、覆盖可疑原件或切换执行方式。

以上为当前职责规范；本次只更新文档，不代表现有资源协议与运行代码已完成接入或通过真实流程验收。历史记录中的“可选供给”或“产品负责缺件获取”仅描述当时实现，不作为当前职责依据。

本仓现行入口以`scripts/flows.json`及产品公开scripts实现为准；本文按日期保留的历史验收只描述当时结果，不作为当前工具、私有调用者或已撤销Publish实现的运行条件。独立塔塔门禁候选的职责和未验收状态见文末。

## 当前工作目录归属（第8步，2026-10-06）

本产品测试、编译的当前工作目录及收尾只按本文“本机固定执行目录”执行。独立入口与控制台调用共用本仓流程；永久工具与依赖原件保留在所属执行方式的源码外原件库，本轮可写资源视图、工程、下载半包和测试夹具只进入本产品当前现场。

第8、9步完成目录与路径实现、根文档迁移及测试源码维护，未运行测试、门禁、编译或安装。本文唯一原件位于<本仓根>/TuyuLove.md；产品接口及流程直接以本仓实际代码和声明为准，业务字典库与其检查已撤销，不另建登记副本。历史验收事实不表示本轮改造已经通过验收，统一测试在第10步进行。根技术文档由本仓门禁按原文、JSON解码值及既有补丁快照扫描机密，仅报告路径；文档迁出不减少资料安全检查。


## 聊天功能的唯一产品归属

**聊天客户端的逻辑功能只能在 TataChatSDK 中实现；聊天服务端的逻辑功能只能在 CitizenServe.tatachat 中实现。公民、途遇及其他产品只依赖使用。**

TuyuLove 涉及聊天时只作为依赖使用方；本条不代表尚未接入聊天的产品已经具备聊天能力。

- 消息、会话、群组、加密、协议、传输、同步、重试、聊天存储、附件、通话及聊天界面行为，按客户端与服务端职责分别归 TataChatSDK 和 CitizenServe.tatachat；新增功能、缺陷修复和平台差异也必须在所属产品内完成。
- 消费产品只提供产品入口、身份与业务权益结果、服务地址及授权、主题和公开接口要求的平台配置；只通过公开接口接入，禁止复制、重写、包装成另一套聊天内核或维护产品专属聊天实现。CitizenServe、TuyuServe 的产品身份与权益授权不包含聊天数据面的实现职责。
- 本机开发直接依赖仓库路径；公民、途遇等产品的正式版本依赖塔塔聊天正式 Release；第三方市场分发使用公开市场版本。依赖使用不以公开市场发布为前置条件，也不改变实现归属。

受控缓存固定为 `tuyulove/target/<platform>/<build|ci|release|publish>/`；四个流程目录永久独立，启动不建目录。Flutter视图、依赖展开、`.dart_tool`、Gradle、Pods、临时文件、日志和候选均只写准确流程目录。

当前依赖边界：TuyuLove 的锁文件和产品脚本自行决定依赖、版本、来源及工具；控制台不做产品依赖或工具门禁。唯一 `rely/` 只保存产品主动取得的离线原件。

本机 Build 由 Worker 创建任务、清空准确平台缓存后直接启动产品入口；后续工具、依赖和编译条件均归产品流程。Android产品函数把本轮Flutter配置选出的SDK和调用方JDK传给同一次Gradle调用，本机未提供JDK时使用Android Studio随包JBR，不增加Worker前置检查；iOS/Android 成功后安装到设备。

本文是途遇移动端（TuyuLove）唯一技术事实文档。

TuyuLove不再保存本地安全软件包目录，也不直接实现硬件金库、sr25519签名或验签。Flutter源码直接消费
CitizenSDK公开钱包与签名门面；Android/iOS原生SDK产物的正式Build接入继续按本文件末尾任务边界完成。

Flutter、Gradle、AGP、Kotlin 与 Java 的选择属于 TuyuLove 产品 Action；本机 Worker 不读取或验真受控工具，也不以工具状态阻塞产品任务。

Android产品当前统一使用Gradle9.1.0、AGP9.0.1与KGP2.2.20，并保持内置Kotlin和新DSL。根buildscript在同一依赖图声明AGP与KGP，settings不再另行解析AGP而暴露其自带KGP2.2.10；应用脚本显式导入JDK类型，避免AGP的`java`扩展遮蔽包名。这是产品配置，不是控制台前置门禁。

## 产品总览

### 途遇旅行技术文档

#### 1. 产品定义

- 中文名称：途遇旅行
- 英文品牌：`TuyuLove`
- 技术产品名：`TuyuLove`
- 仓库目录：`tuyulove/`
- 目标平台：iOS、Android
- 产品形态：独立 iOS、Android App，不是公民 App 内部页面或插件

TuyuLove 为旅行用户提供酒店、餐厅、旅行团和票务的发现、查询、预订入口，以及聊天、
游记和个人账户功能。商品、实时库存和订单由商家本地 TuyuBooking 子系统负责。

本文同时记录途遇旅行与 TuyuServe、TuyuBooking、TuyuFactory、途遇商城之间直接相关的跨产品
边界；其它产品的内部事实由各自技术文档负责，不再依赖途遇体系汇总文档。

#### 2. 系统边界

```text
TuyuLove
├── TuyuServe
│   ├── 途遇号认证
│   ├── 商家搜索索引
│   ├── 游记
│   ├── 聊天
│   ├── 媒体
│   └── 通知
└── 商家 TuyuBooking Gateway
    ├── 实时商品
    ├── 实时库存
    ├── 报价
    ├── 预订
    └── 订单状态
```

TuyuLove 不保存商家核心订单，不计算最终库存，不代收商家资金，不运行商家业务逻辑。

#### 3. 技术选型

| 范围 | 选型 |
|---|---|
| 开发语言 | Dart |
| UI 框架 | Flutter |
| 状态管理 | Provider，复用公民 App 技术栈 |
| 本地数据库 | Isar Community |
| HTTP | Dio |
| 消息同步 | HTTPS REST，按会话序号断点读取 |
| 国际化 | Flutter ARB、`flutter_localizations`、`intl` |
| 推送 | APNs、Firebase Cloud Messaging |
| 安全存储 | iOS Keychain、Android Keystore |
| 签名 | 复用公民 App 的 `sr25519` 签名能力 |

复用公民 App 指复用技术栈、通用组件和签名能力，不表示两个 App 共用产品目录、进程、
发布包或业务导航。

#### 4. 统一途遇号

所有用户只有一个统一途遇号。途遇号不区分顾客和商家，同一个途遇号可以登录不同途遇产品。

登录只允许使用途遇号绑定的 `sr25519` 私钥签署一次性挑战。手机号和邮箱只用于联系方式、
安全通知、风险二次验证、密钥更换确认和身份恢复，不得单独作为登录凭证。

TuyuLove 不保存明文私钥。应用只能调用统一签名组件获取指定登录载荷的签名结果，不得读取
或导出私钥原始字节。

登录挑战至少包含：

```text
domain
version
tuyu_id
audience
challenge_id
nonce
device_id
issued_at
expires_at
```

`audience` 必须为 `tuyulove`，防止签名在 TuyuServe 或 TuyuBooking 重放。

#### 5. 功能模块

```text
auth
discover
hotel
restaurant
tour
ticket
booking
trip
chat
account
settings
```

搜索只访问 TuyuServe 的公开索引。用户打开商家详情、查询实时库存、获取报价或提交预订时，
通过 Cloudflare Tunnel 访问该商家的 TuyuBooking Gateway。

#### 6. 数据模型边界

本地数据库允许保存：

- 用户界面设置和语言选择
- 已验证的途遇号公开信息
- 短期会话的安全引用
- 搜索和商家摘要缓存
- 游记草稿
- 聊天本地缓存
- 商家订单引用、签名凭证和最后已知状态

本地数据库不得保存：

- 用户明文私钥
- 商家完整数据库
- 商家实时库存权威副本
- 商家内部员工账户
- 支付密钥和钱包数据

#### 7. 国际化

第一阶段支持 `zh-CN` 和 `en`。设备语言为中文时使用中文，设备语言为英文时使用英文，
其他语言默认英文。用户可以在设置中手动覆盖。

界面、错误、通知和订单状态必须国际化。用户游记、聊天内容和商家自行填写的介绍不自动翻译。

#### 8. 安全要求

- 所有公网请求必须使用 HTTPS/WSS。
- 登录挑战必须短期有效且只能使用一次。
- 写请求必须携带请求标识和幂等键。
- 日志不得记录私钥、签名载荷中的敏感字段、会话令牌、手机号或邮箱原文。
- 商家订单响应必须验证来源、有效期和签名。
- 应用不得绕过 TuyuBooking 直接访问商家数据库或开源系统内部端口。

#### 9. 测试边界

后续实现至少覆盖：

- 中文和英文自动选择及手动切换
- `sr25519` 正确签名、错误签名、过期挑战和重放挑战
- 搜索索引与商家实时接口分离
- 商家在线、离线、超时和返回过期报价
- 预订幂等、取消和状态同步
- 游记草稿、媒体上传和聊天断线恢复
- iOS、Android 真机发布构建

#### 10. 计划目录

以下目录只是已确认架构规划，未获得单独许可前不得创建：

```text
tuyulove/
├── pubspec.yaml
├── lib/
│   ├── app/
│   ├── core/
│   ├── auth/
│   ├── l10n/
│   ├── shared/
│   └── features/
├── assets/
├── ios/
├── android/
└── test/
```

#### 11. 当前排除项

- 公民链连接
- 钱包和私钥托管
- 链上支付
- 微信支付、支付宝支付、银行卡支付实现
- 自动翻译用户内容


#### 途遇旅行身份登录基线（第 3 步完成）

##### 工程与平台

- 独立工程：`tuyulove`
- 客户端：Flutter / Dart，目标平台为 iOS 与 Android。
- 应用标识：`com.tuyulove`
- 本地化：Flutter gen-l10n，首期支持中文和英文，跟随设备语言。
- 状态管理：Provider / ChangeNotifier，保持与公民 App 技术栈一致。
- 服务访问：Dio 封装为 HTTPS-only `SecureApiClient`，禁止自动重定向。

##### 途遇号登录

- 唯一登录标识为途遇号，手机号和邮箱只能作为后续安全增强信息。
- TuyuServe 只保存途遇号与 sr25519 公钥绑定、密钥修订号，不保存私钥。
- 客户端私钥采用 32 字节 MiniSecret，密文保存于系统安全存储。
- iOS Secure Enclave、Android StrongBox/TEE 负责保护解密密钥与本地授权。
- Rust `schnorrkel` 使用 Substrate signing context 执行 sr25519 签名与验签。
- 签名消息使用 TUYU 域、登录操作码、SCALE 编码载荷和 Blake2-256 摘要。
- 登录挑战绑定途遇号、AccountId、密钥修订号、audience、challenge ID、device ID 和过期时间，防止跨产品、跨设备及重放使用。

##### CitizenSDK安全边界

- TuyuLove只构造TUYU登录和商家业务载荷；账户秘密、设备认证、sr25519签名与验签由CitizenSDK执行。
- 产品不保存、导入、导出或解密MiniSecret，不建立本地Rust FFI、硬件金库或第二轻节点。
- 当前直接依赖锁定 `crcfrcn/citizensdk` 的根包及提交 `0c442b4065ff1577e235cba76978749827d9f575`，声明与锁的ref/resolved-ref一致；离线原件保持该固定Git来源。

##### 当前明确不包含

- 区块链及任何支付实现。
- WSS 在线状态、推送和聊天附件。
- 游记媒体上传、缩略图和通知。
- 商家四个上游系统的生产 HTTPS 公开网关。
- Android/iOS Release 原生库打包与签名发布；该工作进入后续平台发布步骤。

##### 验证结果

- Rust 单元测试：2 项通过。
- TuyuLove Flutter 测试：16 项通过。
- Flutter Analyze：无问题。

#### 品牌与工程身份（2026-08-25 统一）

- 用户可见中文名只使用“途遇旅行”，英文名只使用 `TuyuLove`。
- Dart 包、工程目录、Workflow 目录和登录 audience 只使用 `tuyulove`。
- 官网根域为 `tuyulove.com`，TuyuServe 客户端入口为 `serve.tuyulove.com`。
- Android application ID 与 iOS bundle ID 均为 `com.tuyulove`；测试 Target 可在该标识后追加
  测试后缀，但生产应用不得追加 `.app`。
- 不提供任何退役品牌、旧工程名、旧域名、旧反向域名或旧目录的兼容读取、别名和双写。
- TuyuServe 的唯一创世 SQL 文件为 `tuyuserve/schema.sql`。

#### 正式 GitHub Release 合同（2026-08-25）

- iOS 与 Android Release 分别使用 `tuyulove-ios-v<software_version>` 和
  `tuyulove-android-v<software_version>`，只接受对应平台最新成功 CI 锁定的准确 `main` 提交。
- iOS 正式资产固定为 `tuyulove-ios.ipa`；GitHub runner 使用 本产品仓的 `IOS_KEY` 与
  `APP_PROFILE` 完成 Apple Distribution 签名，并回读验证 `com.tuyulove`。
- Android 正式资产固定为 `tuyulove-android.zip`，归档内只包含使用 本产品仓 `APP_KEY`
  签名并验签的 APK 与 AAB。
- 每个 Tag 还固定包含 `release-manifest.json` 和 `SHA256SUMS`。TuyuLove 是 `tuyutata/tuyulove` 公开仓，
  产品沿用现有签名与双重清单合同，不因组织重构切换 GitHub Artifact Attestation；主资产由 GitHub Release `sha256:` 摘要、
  文件尺寸、本地流式 SHA-256、源码 SHA 与双重清单共同验真。Release 只写入
  `software_version`，不创建、读取或传递构建号。
- GitHub Release 只构建、签名和固化正式资产；App Store 与 Google Play 发布只能由本机
  外部调用方 的独立发布动作执行，禁止 GitHub 保存商店发布凭据或执行商店发布。
- iOS 与 Android 发布预检只接受各自最新准确 Release、清单、SHA256SUMS 和
  `com.tuyulove` 应用身份。QR_V1 对外绑定的上一版本只允许本端 Release Tag，首发为 `none`；
  App Store app/build upload ID 与 Google Play edit/versionCode 只保留在原生事务中。
- 途遇商店凭据固定使用 `tuyu-appstore` Keychain 命名空间，与公民端 `appstore` 完全隔离。
  Issuer ID 和 Key ID 从 `外部调用方 Public` 读取；Apple 私钥与 Google 服务账号只有在同一次
  Touch ID 与 QR_V1 授权事务内读取。Android production 轨道在提交前再次比对，失败时恢复
  授权前准确轨道并回读验收；iOS 上传不替换既有线上版本。

#### TuyuBooking Step 2 boundary

TuyuLove remains an independent Flutter mobile application. It does not connect to a guessed Kamra/URY shared runtime. Merchant capability discovery must identify the concrete merchant module and its signed HTTPS service endpoint; live product, availability and order confirmation remain authoritative in that merchant's independent TuyuBooking module.

#### TuyuBooking Step 3 boundary

TuyuLove continues to consume one signed HTTPS origin per concrete merchant capability. Hotel/Kamra, restaurant/URY, tour/Voyant and ticket/Hi.Events have isolated server-side sites or process groups even though they ship in one merchant installer. Shared Frappe browser resources are an installation detail and never imply shared hotel/restaurant business data or a mobile-side direct connection to an upstream internal port.

#### TuyuBooking Step 4 boundary

The verified merchant flows keep accommodation, menu, activity, ticket, availability and order authority inside the selected merchant module. A later TuyuLove booking UI must call the signed HTTPS origin discovered for that concrete capability and must re-confirm live price and availability there; the mobile application must not infer a shared Kamra/URY database or use upstream internal ports.

#### TuyuBooking 第 4 步边界同步（2026-08-26）

TuyuBooking 已验证酒店及酒店餐厅、独立餐厅、旅行团和票务的真实本地业务流程。本步骤未修改途遇旅行。途遇旅行后续继续作为 iOS/Android 用户入口，通过商家 HTTPS 服务查询与预订；不得直接连接商家 PostgreSQL，也不得依赖 TuyuServe 代理商家核心订单。

#### 2026-08-27 第 8 步：旅行发现、预订、聊天和游记

途遇旅行登录后进入发现、预订、聊天和游记四个独立页面，共用现有中英文 ARB 与 Provider
状态容器。产品中文名固定为“途遇旅行”，不得使用“手机端”替代产品名称。

##### 发现与签名验真

- `GET /v1/catalog` 只读取 TuyuServe 的公开摘要。
- 客户端逐字段比对外层记录与 `signed_payload`，检查摘要仍在有效期内、商家地址为 HTTPS，
  再使用记录内安装实例公钥验证 `sr25519` 签名；任一不符整条记录拒绝展示。
- 酒店、餐厅、旅行团和票务使用同一发现模型，但保留准确 capability 和商家公开地址。

##### 商家实时报价与预订

- 报价请求直接发送到商家 `POST /tuyu/v1/quotes`，预订请求直接发送到
  `POST /tuyu/v1/bookings`，不经过 TuyuServe。
- 请求正文由当前已登录途遇账户签名，并携带独立请求标识和 HTTP 幂等键；TuyuServe Bearer
  会话不会发送给商家。
- 报价与预订响应必须由发现摘要中的商家安装实例公钥验签，并校验商品、数量、报价有效期和
  报价引用。TuyuLove 只保留客户端引用，不成为商家订单权威数据库。
- TuyuBooking Rust 已提供严格请求、响应和验签合同；四个上游系统到该公开合同的生产 HTTPS
  Gateway 尚未接通，因此当前不能宣称真实商家端到端预订已经完成。

##### 聊天与游记

- 聊天客户端只使用TataChatSDK，当前没有已配置的独立聊天实例；不在TuyuLove实现消息同步状态机。
- 游记公开读取，登录用户可幂等发布标题和正文；当前客户端发送空媒体键列表，媒体上传尚未实现。

##### 验证结果

- `flutter analyze` 无问题。
- Flutter 测试 13 项通过，其中新增发现签名和直接商家预订合同测试。
- 该阶段曾测试旧 TuyuServe 聊天方案，该结果不能证明 TataChatSDK/CitizenServe.tatachat 接入完成。发现、游记及真实商家公开 Gateway、WSS 和媒体上传仍
  按上述边界保持未完成状态。

#### 2026-08-27 统一途遇 Logo 来源

本产品使用的应用图标、启动 Logo、页面 Logo 或网站 Logo 均来自 `/Users/rhett/tuyuserve/logo/`。产品目录中的资源是平台打包副本，不是独立真源；必须通过该目录的生成器更新，并通过统一资产清单测试。

#### 2026-08-27 本机编译源码边界

本机 Flutter 在 `tuyulove/target/<platform>/` 生成普通工具配置，
业务源码逐文件只读引用主检出；不复制源码。iOS、Android 的依赖、Pods、Gradle 和本地化状态
均在本端生成，退出只清当前 owner 的内容，保留平台容器。编译与签名候选位于
`tuyulove/target/<platform>/build/`；同一Build完成真机安装及回读，不新增产物库产品目录，不清共享源码或其它平台。

#### 2026-08-29 跨产品边界归并

- TuyuLove 的使用者是旅行用户；它使用 TuyuServe 的途遇号、游记、媒体、普通通知和公开发现；聊天只依赖 TataChatSDK 与 CitizenServe.tatachat，
  但实时商品、价格、库存、报价与订单始终由目标商家的 TuyuBooking 权威实例负责。
- 发现索引只允许作为签名摘要缓存。打开商家能力或提交订单前，客户端必须使用摘要返回的具体
  HTTPS 端点重新确认实时数据；实例离线时只能展示带明确时间的缓存，TuyuServe 不得代替商家接单。
- TuyuBooking 的四个桌面主机平台 `macOS/LinuxARM/LinuxAMD/Windows` 与两个移动员工平台
  `iOS/Android` 仍属于同一商家产品；iPhone/iPad 归入 iOS，Android 手机/平板归入 Android；途遇商城是该产品
  内部采购模块。TuyuFactory 是对等的厂家系统，不是 TuyuLove 或中心商城的内部业务数据库。
- TuyuLife 是与本产品并列的独立移动产品，不共享应用身份、发布生命周期或尚未确认的生活业务。

#### 2026-08-30 本机移动端增量构建

- iOS 与 Android 使用各自独立的 外部调用方 成功缓存，复用 Flutter、Dart 依赖及对应平台工具中间产物，不读取另一平台或 TuyuLife 的缓存。
- 产品源码只读引用；工具配置在本端生成，缓存不保存产品源码、用户数据或密钥。
- iOS App与Android APK仅在各自准确Build缓存中用于签名、真机安装与回读；仅按原清理规则保留本轮target内容。GitHub CI与Release仍拥有各自独立入口和正式交付合同。

## GitHub CI 增量缓存（第 7.3 步）

途遇旅行 Android 与 iOS CI 已接入统一 CI 缓存。移动端中间状态按平台隔离，只恢复最近成功缓存；最终应用产物保存缓存前清除。

## Release 全量构建（第 7.4 步）

正式 Release 固定从干净源码执行全量构建，显式关闭 Rust 增量编译及工具链内置缓存，不读取CI作业缓存且不复用本机编译中间物。版本、签名、校验、产物和发布流程保持原有产品合同。
最新成功 CI 解析器作为可复用 Workflow 调用 Job 只传入 `ci_title`，不得声明 `env`；`CARGO_INCREMENTAL: "0"` 只属于实际 Release 构建 Job。

## 双仓统一流程最终收口（第 7.5 步）

本产品执行统一流程规则：本机编译中间物只进入本轮塔塔缓存库的build目录并按终态规则清理；GitHub CI 的作业过程数据只进入该次Runner任务空间；正式Release从干净编译状态执行。源码不进入塔塔缓存库、塔塔依赖库或塔塔产物库。

## 产品平台合同冻结（TUYU 第 3.1 步，2026-09-02）

- TuyuLove 的正式平台闭集只有 `iOS`、`Android`，不得增加、合并或改写为其它公开平台名称。
- iPhone 与 iPad 都是 `iOS` 的设备适配；Android 手机和平板都是 `Android` 的设备适配。设备、模拟器、ABI、架构和 Runner 不是产品平台。
- Flutter 官方 `ios/`、`android/` 目录保持原名；既有 Tag 后缀、脚本参数和 `<platform>` 路径模板属于待逐项审计的内部 wire，不能据此定义公开平台，也不得在未覆盖全部生产者和消费者时局部改名。
- 本步骤只冻结文档合同，没有修改 TuyuLove 源码、流程、目录、签名、数据库或发布 wire。

## 本机移动编译后安装的实施边界（2026-09-03）

- 途遇旅行（`tuyulove`）的 iOS、Android 继续使用原有独立 build 任务；仓库、产品、平台、流程模型、按钮、状态及并行调度不变，不新增安装流程或全局串行队列。
- 受控源码已扩展独立原生请求及 Android 签名、保存、安装和身份版本回读链路。每任务的路径、占有关系、响应与取消独立；只在唯一合适设备时自动安装，零台或多台明确失败，不增加设备选择界面。
- iOS 受控源码已实现实际 prepare/install 执行链，使用现有工程的 Apple Team 与标准 Xcode 描述文件和本机签名配置，不新增配置体系；缺失、歧义或不适配时明确失败。本机校验签名、Team 和描述文件，设备只回读 Bundle ID、版本和构建号，不声称可以回读设备中的证书。受控原生定向测试已通过，但真实签名安装验收尚未完成，不能据代码落地宣告设备安装成功。
- 安装失败保留有效受控产物，不自动卸载、清数据、降级或更换签名；本步没有手动仅安装重试入口，再次点击编译仍执行编译。安装后不自动启动，CI、Release 与应用商店发布不变。
- Android Release 已显式设置 signingConfig = null，不再使用默认 debug 签名；本机候选交受控签名，正式版仍由独立 Release 流程签名。iOS 沿用现有 Team 和应用标识，已只读确认本机存在匹配且未过期的安装描述文件及可用签名身份；尚未核对目标设备注册关系或执行真实签名安装，不能宣告手机已安装。
- 本次受控测试通过不代表实际运行的控制台已更新，也不代表已完成设备签名或安装。具体测试、门禁阻塞与清理证据见现有任务卡；自动安装总体任务仍未完成。

### 安装显示名称

iOS 与 Android 的系统安装显示名称遵循设备语言：中文为“途遇旅行”，英文为“TuyuLove”，其他未支持语言回退英文，不再显示简称“途遇”。Apple CFBundleDisplayName 与 CFBundleName 通过 InfoPlist.xcstrings 本地化；Android application label 引用 app_name，从现有 ARB 生成默认英文和中文资源到构建目录。既有 Bundle ID、包标识、数据目录和功能保持不变。此次不调整钱包初始化和图标。Apple 名称资源已经实际编译检查；旅行自身的 locale_test.dart 已在补齐缺失依赖后执行，3 项通过。Android 名称资源使用 GenerateAppNameResources 类型化任务和 DirectoryProperty 输出，通过 androidComponents.onVariants / addGeneratedSourceDirectory 接入各变体，未加入兼容开关；重复变量声明已删除。四产品的独立 AGP 9.0.1 原生验证均已通过：Debug 和 Release 资源消费自动触发生成任务，AAPT2 编译及链接后的资源表包含正确中英文名称，输入不变时生成任务为 UP-TO-DATE。上述验证针对名称任务及资源链路，不代表完整应用编译、安装或真机显示验收。未进行实际设备安装显示验收。

旅行的 3 项 Flutter 测试是本产品自身的执行结果，不借用其他产品的测试作为证明。该结果不代表 Android 原生资源接线已通过；实际安装显示仍须依据本产品的准确产物核对。

### Android 自适应启动图标

Android application 的 icon 与 roundIcon 统一引用 @drawable/app_icon。既有 drawable/app_icon.xml 提供位图入口，drawable-v26/app_icon.xml 提供系统原生自适应图标，app_icon_background.xml 使用正式 Logo 左上角底色并铺满裁切区域。完整前景按 108dp 图层中的居中 66dp 布局，不裁剪或重绘标识；圆形及其他系统图标形状由启动器裁切。安装名称、初始化页面和钱包功能不随本次图标调整变化。

唯一生成来源为 tuyuserve/logo，原始 AI、PNG 和既有平台位图保持不变。generate_assets.py --android-only 仅生成已登记的四产品 Android XML 并更新 manifest.json；不会批量重写其他平台图标。原生 XML 以 android_resources 记录路径和摘要；商家工程路径使用 tuyubooking/app。厂家前景继续使用其既有 prepareLogo 任务生成的 drawable/tuyu_logo。

长期验收包括权威源与衍生清单一致、四产品普通及圆形图标引用一致、标识位于裁切安全区域，以及最终安装包在实际启动器中的显示。资源测试不能替代整包编译、安装和真机视觉验收；本项不修改控制台流程或 CitizenSdk。

### Flutter 独立缓存工程视图（2026-09-10）

途遇旅行 iOS、Android 的 Flutter/Pub 命令统一在 `tuyulove/target/<平台>/flutter-project/` 执行。源码文件只读映射，本地 `path:` 包保持相对关系；所有生成状态只进入当前平台缓存。控制台不扫描产品依赖、不检查产品工具版本，也不以工程视图增加任何产品门禁。

Android Gradle 固定从 `<本仓根>/android/` 真实根启动，产品设置与应用配置读取缓存 Flutter 根生成的 `local.properties` 和插件清单。`GRADLE_USER_HOME`、项目缓存及构建输出继续归属准确 Android 缓存；不再执行缓存视图中的跨根设置脚本链接。

受控 Flutter 插件 included-build 仅开放 Gradle 9.1要求的目录所有者写位，文件内容仍只读且按摘要验真。任务初始化脚本把插件 `build` 指向途遇旅行 Android缓存，Gradle命令关闭 Problems Report，禁止在产品源码根产生 `android/build/`。
### 产品流程物理归属

本仓`scripts/flows.json`声明现有产品、平台与流程身份，完整调用入口由本仓scripts拥有。Build使用产品完整execute入口；CI与Release使用本仓`scripts/flow.mjs`。已接入Start由产品声明与产品实现负责，未接入动作不由文档新增；Publish等待后续逐产品重建。外部调用者读取当前声明、创建与跟踪独立任务，不维护产品流程的第二实现。

## CI与Release入口归属

本产品CI与Release由所属仓当前`scripts/flows.json`的remote_routes及各平台Workflow声明定位，完整执行入口为本仓`scripts/flow.mjs`。控制台读取当前声明、创建原有真实任务、获取准确仓权限并跟踪原Run；旧控制台CI/Release Shell与Swift执行文件已删除，不作为入口。

## CitizenSDK统一边界复查（2026-09-15）

途遇全部产品凡使用钱包、账户秘密、签名、验签、公民链或轻节点能力，都必须直接消费CitizenSDK公开接口；
产品只负责构造自己的业务载荷、audience和服务授权，不得自行保存账户秘密、实现sr25519、复制安全界面或
再建轻节点。`packages/`目录形式本身不是问题，但只能承载TuyuLove独有且不属于CitizenSDK的普通产品模块。

旧`packages/`目录及其中两套本地安全实现已经完整删除，MAP、Pub声明、锁文件、Dart生产引用、测试和文档
均不再保留旧路径。`CitizenSdkTuyuSigner`只把TuyuLove业务摘要交给`CitizenSdk.signing`，发现和商家响应
统一调用`CitizenSigning.verify`；应用只打开wallet与signing模块，不启动轻节点。

本轮依赖改造没有新增产品SDK准备文件。正式Git依赖、Dart调用与锁文件已完成；CitizenSDK iOS XCFramework、
Android双库、三场景本机/正式/公开来源以及CI、Release、本机Build接线必须作为本任务卡下一阶段一次性完成。
在该原生接入真实通过前，不能宣称TuyuLove整包Build或设备安装已经恢复。

## 独立 GitHub CI 与 Release 工作流

本产品每个实际产品、平台、流程身份使用下列独立文件，主 Job 为 `flow`；CI 验证源码，Release 生成正式产物，本步不实现Publish，发布待后续逐产品重建。

- `.github/workflows/tuyulove-android-ci.yml`
- `.github/workflows/tuyulove-android-release.yml`
- `.github/workflows/tuyulove-ios-ci.yml`
- `.github/workflows/tuyulove-ios-release.yml`

## 平台输入与源码外工程

tuyulove/scripts/project.mjs为本产品唯一工程装配入口，project.test.mjs验证路径与隔离。create和verify明确接收source-root、work-root及platform；调用方可指定当前任务内output，默认按源码绝对路径装配，输出不得覆盖或进入源码。Flutter、Xcode、Gradle的可写配置保存在输出工程，源文件不被工具回写。

平台声明以Runner.pbxproj、Runner.xcscheme、ProjectWorkspace/Workspace声明等文件直接保存于ios或macos目录；单文件测试、单一macOS图标资源及菜单包装层归并。工程入口仅在本次工作根重建Xcode所需固定结构，原平台声明与资源正文保持。Android扁平Manifest、资源限定文件及MainActivity由同一入口还原原逻辑路径。Android Wrapper来自调用方明确指定的固定FLUTTER_ROOT原件，输出使用既定Gradle9.1.0；缺工具、缺输入、目标已存在或来源链接越界均失败。

页面Logo唯一源码路径为tuyulove/tuyu_logo.png。CI和Release各自创建独立工作工程，后续签名只读取该工程产物；本机Build传入当前任务目录，产品不识别目录来源。SDK本机path依赖使用SDK自有公开Flutter工程入口。

Release工程路径先独立赋值，创建成功后才导出；工程创建失败必须保留退出码并立即停止。工程测试实际执行该赋值片段的成功与失败分支，不调用真实签名或发布。

Android的TUYULOVE_BUILD_DIR由本机调用方明确指定本轮源码外输出目录；Gradle产物和APK收口必须使用同一目录。产品既有独立运行默认值不变。本机App和适用的SDK原生步骤复用调用方已验真的Gradle可执行文件，执行失败必须传回，不经Wrapper重复下载工具。

本机、CI与Release使用准确锁定的公开CitizenSDK Git原件及其公开工程入口；禁止override和邻仓path依赖。原生安装件装配到本次Pub实际解析的SDK视图，Apple框架与Android双库由同一SDK源码构建，全部中间物保留在本轮工作目录。原始声明与锁均保持只读。

本产品正式Release主flow Job实际创建GitHub版本，contents权限准确为当前仓write；辅助Job与其它权限保持原登记。源提交、成功CI、版本及资产验真不放宽，不派发发布。
## 完整产品组织与执行合同

所有者：`tuyulove`，正式源码根 `<本仓根>`；本说明属于该完整产品。组件不会拆成独立仓库或目录产品。所有执行身份统一为 `产品.平台.流程`，单平台物理目录省略平台层，执行身份仍保留真实平台。

真实平台目标：`ios`、`android`。

推送门禁唯一源码位于 `<本仓根>/.github/tatagate/`，GitHub入口 `<本仓根>/.github/workflows/tatagate.yml`。控制台先从本仓已保存提交执行这份门禁，通过后推送准确SHA；GitHub main push再执行同一提交的门禁，控制台核对所属仓、Workflow、main、SHA、Run和attempt，只有success并再次回查main一致才完成推送。失败、取消、超时或身份漂移均不得显示成功，不自动重试或派发CI/Release。

技术文档由所属完整产品仓根唯一持有；私有规则和任务库由控制台私仓持有，公开产品不读取它们。公开门禁不依赖私仓资料、安装包源码、其它本机产品或个人账号；必要链真源只读本仓明确固定的公开40位SHA，不在门禁中跟随main。本机开发跨产品验收仍比较三仓已保存快照与各端真实镜像。


### 门禁与开发审查职责

准确中文注释按开发阶段逐项复核，不以保留源码每文件包含汉字作为仓库门禁的开发凭证。初始完整内容、生成文件和上游原件保持原文；真实第一方临时注释、机密、源码输出、Workflow、依赖和适用测试仍由本仓同提交门禁验真。公民门禁只把scripts中的Node命令行结果报告识别为CLI输出；本仓实际执行测试的准确协议拒绝断言不属于新运行协议，字符串、注释、模板和未登记测试中的同文不豁免。保存及推送仍逐仓独立授权，并以本机门禁和同SHA的GitHub门禁双成功为唯一终态。

## 产品介绍与开源许可

根目录 `README.md` 仅提供本产品简明介绍，不承载技术方案、任务记录或验收结论。独立自有代码采用根 `LICENSE` 的MIT；上游代码、衍生修改、依赖及组合分发遵循各自原许可、版权、例外与附加要求。


### 本机Build代码所有权

本产品的scripts/flows.json声明自身平台、准确工具版本、原始锁以及既有CI/Release入口；scripts/build.mjs独立实现requirements、prepare、build三个阶段，拥有工程准备、编译命令、候选验真和失败条件。产品只消费调用方交付的公开资源回执，按本仓原始锁取得依赖，所有生成状态进入规范源码外工作目录。平台或资源身份不符、版本错误、缺锁、链接越界、归档摘要错误、旧工程复用或编译器失败均立即失败。

本产品脚本、测试及原生工程的源码根变量统一为`TUYULOVE_ROOT`，仅表示途遇旅行所属正式源码根；生产者与消费者同步使用这一名称。Release仓库身份错误使用准确产品中文名，正式组织与仓库身份校验保持。

## 准确Git工具交付方案（2026年10月6日）

固定源码工程入口已改为只接收显式 PRODUCT_GIT_BIN：普通可执行文件、规范绝对真实路径和 Git2.54.0 在读取来源前一起核验。来源、固定提交、干净原件、原始锁只读及无 override 合同保持；缺少交付或出现路径、版本漂移即失败。公开环境自行按本仓入口交付固定工具，本机可读取现有验真工具原件，不依赖控制台私有路径。

最终冻结差异已获第二次确认并写入，保持本产品原有正常、失败、隔离和清理回归；正式来源与工程独立回归8项通过；两项Release真实Shell片段回归仍需正式GNU基础交付。准确授权和实际结果同步唯一任务卡。

工程测试的既有Release赋值片段已改用显式PRODUCT_BASH_BIN，在执行前核验真实普通入口与GNU Bash5.3.20；成功/失败分支、退出码及后续导出顺序不变，不执行正式Release。此测试输入沿用本仓实际公开工具字段，不引用其它仓库实现。

## MLS统一清理固定来源与当前验收状态

CitizenSDK当前统一固定提交为0c442b4065ff1577e235cba76978749827d9f575；CitizenApp、TuyuLove、TuyuBooking/app与TuyuFactory/app的8份声明/锁已经同步，离线原件只按该真实保存提交取得和验真。当前SDK公开Core为144项、Apple总导出148项、Flutter方法93项；旧用途钥API、结果和二维码响应已删除。MLS登记保持0x1C及同一32字节public_key，客户端钱包私钥之外只保留MLS协议秘密。

本轮源码、注释、测试源码与实际接口说明已经同步；此前测试记录不能证明本轮新快照通过。统一测试及已签名Release真实验收尚未完成，未推送或部署。


### 产品独立资源与编译入口

本产品的scripts/flows.json声明自身平台、准确工具版本、原始锁以及既有CI/Release入口；scripts/build.mjs独立实现requirements、prepare、build三个阶段，拥有工程准备、编译命令、候选验真和失败条件。产品只消费调用方交付的公开资源回执，按本仓原始锁取得依赖，所有生成状态进入规范源码外工作目录。平台或资源身份不符、版本错误、缺锁、链接越界、归档摘要错误、旧工程复用或编译器失败均立即失败。

本产品平台闭集为`ios`、`android`。调用格式为`node scripts/build.mjs <requirements|prepare|build> <platform> --work <绝对工作目录>`；requirements只读并输出唯一JSON，prepare/build从标准输入读取schema=1的资源回执。调用方交付准确工具执行器、锁定依赖目录、Git来源和归档后先prepare，再读取展开来源新增的需求，完整交付后执行build。准备、展开和编译属于同一调用工作根，各平台互不共享可写状态。独立调用方按本仓声明准备资源即可运行，无需读取其他产品工作树或私有资料。

Git依赖只接受本仓声明与锁一致的HTTPS地址及40位固定提交；原生归档只接受本产品锁定坐标及完整SHA-256。工程副本排除旧生成物，内部文件链接重映射到同轮副本，外部链接与已有工程拒绝。原始依赖缓存必须显式交付，不能落入用户默认缓存；离线编译禁止隐式取得缺失资源。已有CI/Release Workflow仍各自调用本仓scripts，不受本机可视化入口是否存在影响。入口回归由本仓`scripts/build.test.mjs`负责，适配与资源服务的验证不替代产品编译和真实候选验收。


## 2026-10-06 产品自主资源阶段（第2步）

本仓`scripts/resources.mjs`拥有工具准确来源/版本/配方、递归锁解析、缺失获取、验真、复用和本轮依赖准备；`scripts/build.mjs resources <platform> --work <绝对外部工作根>`调用同一实现，独立入口为`resources.mjs <platform> --work <工作根> [--offline]`。前者从stdin读取公开身份回执；后者允许空请求。最小宿主必须使用本仓声明的官方Node25.2.1绝对入口，本机配方限定macOS ARM；资源阶段回读官方发行归档与运行Node字节，不能从PATH取同名程序。工作根预先存在、位于源码外且不经过链接。

现存`PRODUCT_TOOL_ROOT`与`PRODUCT_DEPENDENCY_ROOT`是工具和依赖的只读路径输入，本身不能完成控制台缺件准备与交付。当前供给职责按本文“工具与依赖的声明和供给职责”执行：经控制台运行由控制台准备、保存与供给，独立运行由产品自行处理；源码外`~/.local/share/product-resources`仅描述现存独立资源存储，本轮可写状态仅在work。GNU Bash/grep/sed纳入自身需求；发行件旧Shell仅用于声明中的首次GNU构建，不进入正式PATH。下载/源码工具编译不持全局锁，最终不可变对象提交使用短锁，取消传递到工具进程组。错误摘要、损坏、未锁来源、路径越界和显式离线缺失失败并保留可疑原件。

Pub/npm/Cargo按原始锁准备；Git按固定HTTPS提交检出，Git Cargo目录源展开workspace继承并锁定相对包版本；CocoaPods按准确锁摘要恢复验真快照，缺失spec校验规范摘要，未锁源码来源拒绝取得。Android固定包与修订归产品；额外平台仅消费官方固定发行来源与发行树摘要，不借宿主历史SDK目录。Maven供给只读验真后复制到独占Gradle缓存，由产品准备现有配置，消费仍离线；全库坐标导入与旧目录清理留到第5步。

`PRODUCT_WORK_DIR`、`PRODUCT_BASH_BIN`、`PRODUCT_RSYNC_BIN`及`PRODUCT_SOURCE_DIR`是公开工作/工具/工程入口；Flutter修订不读取调用方私有变量，也不回退系统rsync。旧Flutter补丁对象与当前配方不符时拒绝复用，真实替换须按准确资源操作另行授权。本步不改变编译、签名、安装及回读顺序，不修改产品UI，也未执行真实工具下载/安装。受控资源测试不能代替官方首次取得、正式编译或最终真实运行验收；第4至7步仍待逐步确认实施。

资源原件按完整内容验真后整体提交：Git bundle与固定来源/摘要回执处于同一个不可变对象，不暴露中间状态；可选依赖供给读取`objects/<SHA256>.blob`。锁解析器、源码工具依赖与官方有序补丁也从同一产品原件存储复用。Pod spec每次按锁中的规范checksum回验，Git tag只核对发行声明并消费本产品预锁提交；HTTP发行件消费固定SHA256，首次源码准备命令来自该已验真spec并由GNU Bash执行。spec、准备后源码与文件清单整体提交，再复制到本轮缓存；供给索引不决定产品版本。正式PATH排除旧POSIX Shell，`sh`对应已验真的GNU Bash。

独立缺省资源目录内`tools`保存工具发行件及工具编译输入，`rely`保存产品依赖的归档、Git和Pod原件；工作区只承载本轮可写视图。根据用户最新要求，分步骤先完成实现与用例，整项解耦任务完成后统一测试；本步实施记录不等于真实工具首次取得、完整Build或安装验收通过。


### 第3步：产品完整Build入口（2026-10-06）

每个iOS或Android本机Build任务必须完成本平台的Release配置编译、签名验真、覆盖安装和回读；任一步失败即任务失败。

本产品的正式完整入口为已锁定Node的绝对路径调用`<本仓根>/scripts/build.mjs execute <platform> --work <已存在绝对工作根>`，可选`--offline`。输入stdin可为空；调用方可传schema/product_id/platform/work及真实run_id/program_digest，禁止私有变量或执行命令。入口内部完成需求→资源→准备→再次需求/资源闭包→编译→适用签名/安装/回读；独立与控制台调用同一实现。最小引导Node只启动本产品的资源引导器，产品按自己的官方Node声明验真、准备并重入，控制台运行Node不决定产品Node版本。

标准输出只有唯一有界JSON：schema、product_id、platform、work、completion、files及可选真实run_id。completion固定为device-install；files按本产品flows.json登记路径和SHA256。编译日志使用stderr进入现有任务日志，不新增资源任务或任务状态。完整结果只在各阶段成功、源码/锁不漂移、工具进程确认退出后落入本轮build-result.json；同根并发或复用旧结果拒绝，取消/失联/错误身份/损坏候选不得成功。

控制台每次Build直接读取本产品当前flows.json入口，调用一次execute；控制台只跟踪真实任务、核验公开结果和保存产物，不解释产品工具、依赖、编译参数或设备规则。当前控制台静态菜单、其它产品流程/安装器与程序摘要的历史耦合仍归第4步解除，本步不能当作整项解耦已完成。

Android开发材料读取和仅首次创建可由专用PRODUCT_HOST_FD=3提供，原生端仅保管既有DEV_KEY；产品自身负责材料解析、工具、临时密钥、Release包签名、证书/版本核对及USB安装回读。独立调用由产品自己的Keychain保管开发材料。材料不写入公开结果或日志，临时密钥只在工具确认退出后删除。iOS归档由产品解包并验证唯一Runner.app、原始Release配置、Apple签名profile、团队/设备授权、代码签名和entitlement，再完成主动真机探测、防降级、安装及bundleVersion回读。控制台不再包含LocalMobileTask/MobileSecurityManager执行链。

Android Build必须直接开始编译，禁止编译前选择或等待设备。签名完成后先执行ADB USB安装，不限制品牌、机型或数量，不要求设备登记或另设设备授权门禁；仅当ADB报告多个USB目标时列出全部USB设备号并逐台安装，每台安装后回拉验真。一台失败仍须尝试其余目标，任务最终失败；其他ADB直接安装失败据实失败。禁止固定设备、模拟器和无线安装。

iOS真机交互、页面验收和交易诊断必须使用XCTest，UI测试必须使用XCUITest；禁止用iPhone镜像或macOS系统控制台com.apple.Console执行这些工作。测试不得替用户完成最终交易确认。

产物保持固定android.apk/ios.app.zip；控制台通用artifact能力在产品验真后、设备安装前保存候选，保存失败阻止安装，安装失败不伪造成功。iOS profile/entitlement原生用例迁入本产品Swift验真器测试；统一验收须显式交付产品锁定Xcode的PRODUCT_TEST_SWIFT及PRODUCT_TEST_DEVELOPER_DIR，缺失时测试失败，不静默跳过。

本步同步完整入口、失败/取消/并发、结果/路径/摘要及适用移动端用例，但未运行测试、语法检查、编译、签名、安装或工具下载/替换；全部实现步骤完成后统一验收。源码交付与用例存在不代表真实Build已经通过。


### 第4步实施中：远端路由当前声明

CI/Release的规范身份、标题、版本前缀和正式版本记录标志已迁入所属仓现有scripts/flows.json的remote_routes。调用方按固定已接入动作重读当前声明；原生授权与流程查询不再使用编译期产品路由常量。产品声明只提供数据，不授予凭据、扩大平台矩阵或新增按钮。损坏、重复、越仓、字段越界及超限拒绝。

本次同步路线读取、热更新和失败边界用例，未运行测试、语法检查、编译、签名、安装或下载。第4步仍在开发中：Publish执行器、聊天安装器、Start、固定菜单声明与完整程序摘要的其余实际耦合尚未解除，不能报告该步或整项任务完成。

### 产品远端完整入口

本仓`scripts/flows.json`的`flow_entry`定位公开`scripts/flow.mjs`。`run ci <platform>`和`run release <platform>`分别执行同一产品流程，当前读取本仓Workflow与路由；Release的`version_source`声明准确版本文件类型和相对路径。成功CI选择、同源候选复用、版本递增、正式Release验真与旧Run/Artifact清理均由本产品入口完成。独立执行只需等价的本仓短期GitHub权限；没有宿主控制管道时入口自行跟踪Run，不依赖其它产品程序。

可选`PRODUCT_CONTROL_FD=3`只接受当前Run绑定确认、候选持久化确认和二值远端终态；令牌仅进入HTTPS请求头，未知身份、越仓、无成功CI、候选错源、控制帧错误、超时或取消均失败。宿主重启后的`recover`使用同一公开入口核验原Run、原候选并清理，不重新派发。公开控制协议不携带私有调用方变量，现有授权及用户操作顺序保持。源码、声明或Workflow在本次流程期间变化将拒绝继续。

相关正常、失败、身份、版本来源、独立远端跟踪、候选重试和真实控制管道边界用例位于本仓`scripts/flow.test.mjs`；当前只完善源码，尚未运行用例或远端操作。


### 产品软件记录与正式版本恢复

本仓公开`scripts/flow.mjs records`使用准确同仓短期GitHub权限，重读本仓当前路由，复用远端流程同一Run保留器并确认实际删除，再读取各平台最新正式版本。来源合同归本仓release.record_source：按实际产品选择Tag、单包正文或正式元数据资产验真，标题、版本、源码与适用不可变标志不能由调用方推测。准确元数据资产仅经官方HTTPS地址读取，跨主机不转发仓库令牌。正式资产和Tag不会在记录刷新中删除。公开结果仍是records/removed_run_ids，原记录页行为保持。

`recover`不重新派发；重新核验原候选、成功CI、原Run终态、正式资产来源与Tag，输出formal_release/removed_run_ids。控制调用方仅绑定原任务身份、原候选和产品公开回执，更新现有持久发布目标；产品验真算法不再随调用方程序编译。相关正常、失败、错资产/正文/来源、重定向隔离、独立记录刷新和恢复用例源码归本仓flow.test.mjs。

资源工具取消、超时、输出超限和异常收尾均等待主进程与整个后代组退出；无法确认退出时保留工作根和候选，禁止删除输入或改为可写。真实取消退出顺序用例仅写入resources.test.mjs，尚未执行。


### 发布实现范围

本轮新增产品发布实现已撤销，发布功能由后续逐个产品重建。现有操作入口与界面保留，当前不提供已删除实现的执行保证；Build、CI、Release和Start继续按各自现有入口运行。


### 产品独立资源与唯一依赖供给

本产品的scripts/resources.mjs独立拥有需求解析、准备配方、来源与摘要验证、可写视图和失败条件。独立执行时由产品获取、保存与复用缺件；经控制台执行时由控制台按产品声明准备、保存并供给，产品核验并使用。PRODUCT_DEPENDENCY_ROOT仅是现存只读路径输入，缺少路径或原件不得在控制台执行模式下触发产品自行下载；实际供给接入仍需代码改造与验收。依赖索引读取仅接受schema_version=2及packages、git_sources、pods，不恢复旧目录或整锁快照。

Maven的具体JAR、AAR、POM、module及分类器文件统一由packages的group:artifact、version、准确上游URL、SHA256和SRI定位objects中的原件。产品在本轮work/dependencies/maven按上游分区复制独占文件；不复制Gradle二进制元数据、锁和下载状态。产品生成本轮GRADLE_USER_HOME/init.d初始化脚本，只在自身已声明的同源仓库之前加入本轮原件视图，缺件仍按产品原仓库解析，明确离线则失败。Gradle解析、工程状态和后续编译都属于同一产品任务。

Pod由pods中的name、version、checksum匹配当前Podfile.lock；spec保存官方CDN地址和原件摘要，source保存官方podspec来源，files保存发布树相对路径、文件内容摘要与权限或安全内部链接。只物化本产品所需的单个发布坐标；其它Pod、整锁、平台或宿主变化不要求复制全树。产品仍按CocoaPods官方规范回验SPEC CHECKSUMS，再验证本产品预锁定Git提交或HTTP发行摘要与源码回执。可写缓存和工具VERSION仅在本轮work产生，不能写回共享原件。

错来源、摘要、重复同源内容、生成状态、硬链接、内部链接越界或循环、取消及任务副本漂移均据实失败。独立与控制台调用使用同一实现；控制台只提供可选原件并跟踪原有任务，UI、功能、按钮、平台与操作顺序保持。用例源码已同步，执行留待整项实现结束后的统一测试。


### 独立入口回归验真边界

资源回归使用自带固定提交、源码字节和spec的合成Pod，不借用产品真实Pod清单提供测试输入；无真实Pod需求的平台也验证来源、摘要、链接、循环、取消和物化失败。测试现场仍位于本产品target的准确平台，不写源码或其它产品目录。资源声明与生产依赖坐标不因测试夹具改变。

Apple验真器回归显式使用已验真的锁定Xcode及其SDK；官方swift入口允许包内链接，但规范目标必须属于同一Xcode且为有执行权限的普通文件。不得因此借用PATH或另一套工具。

资源取消对同一真实进程组每轮只发送一次信号；组不存在或Windows时才发送给主进程。仍等待主进程和后代实际退出，8秒未退出才强杀，12秒仍未确认则保留现场并失败；取消不能成为成功。

Apple验真器测试由同一锁定Xcode的swiftc编译实际XCTest Bundle，使用该包随附XCTest框架与Swift overlay，再由同包xctest执行；必须回读5项测试全部成功，空测试套件不得算通过。Bundle、模块缓存和临时输出仅归本产品target准确平台。


### 门禁官方归档字段与平台命名边界（2026-10-07）

平台禁用值继续来自本仓既有门禁登记。仅scripts/resources.mjs的唯一规范toolDefinitions声明内、唯一Flutter工具的archive.url可以按对应数字版本核对官方稳定版macOS归档；source、root和executable必须匹配原有官方坐标。识别后仅从平台扫描输入移除该URL，原资源源码、工具版本、来源及依赖锁均不修改。重复声明、重复键、转义或不可解析字面量、错版本、错来源及错形字段不予豁免；其它工具、字段、源码、注释和目录中的旧平台标识继续拒绝。

既有门禁测试覆盖本仓真实资源声明、官方字段、伪造来源和字段、歧义字面量、额外源码、旧平台注释与目录；全部夹具只在本产品target真实平台测试目录生成，并在finally清理。工作树诊断与绑定已保存提交SHA的正式门禁分别记录，不能将缺少Git跟踪文件的工作树冒充正式通过。

当前完整门禁回归11/11通过，失败/取消/跳过/待办均0；本仓真实根技术文档、机密扫描及平台命名检查通过。完整资源源码和补丁边界、既有链接/临时目录/根文档夹具的失败已消除。测试及工作树检查不代替绑定已保存提交SHA的正式门禁，也不代替产品真实Build、签名安装及启动验收。本轮自有日志与夹具在结果记录后按原规则删除。


### 补丁原上下文与测试夹具边界（2026-10-07）

平台扫描只对scripts/resources.mjs中唯一规范flutterPatch JSON字面量执行原上下文识别：补丁登记字段严格为path、sha256、source；path为flutter.patch，source为Flutter官方固定40位提交，正文首行固定来源必须一致，全文SHA-256必须匹配本仓登记。仅当native_assets_host.dart准确文件、hunk及lipoDylibs邻接上下文唯一匹配时，从扫描副本移除那一行已核对的上游原注释。实际资源源码和补丁正文不修改；其它补丁行、源码、字段和目录继续完整扫描。错误来源、摘要、重复声明、非规范转义、上下文漂移和新增旧平台文字均不豁免，不跳过整段补丁。

既有门禁夹具以unlinkSync删除测试目录中的链接自身；测试临时目录仅调用本仓唯一testRoot，无旧API别名。机密扫描夹具生成本仓必需的合成根文档，原文档检查及拒绝断言保持。补丁正常、错源、错摘要、错形、重复、上下文外残留等边界同步在既有test.mjs，现场在本产品target内并由finally清理。补充实现后的统一门禁验收已通过，正式提交门禁及产品真实Build/启动验收仍待完成。


本产品scripts/build.mjs的模块初始化与CLI执行分离：私有异步runCLI承载原命令主体，仅在直接执行文件时启动，拒绝时输出错误并以退出码1失败。模块求值先完成，scripts/resources.mjs可反向导入同一checkWork、requirements和平台校验，不复制实现或增加启动入口；普通import不启动CLI。现有公开参数、JSON请求、--offline、锁定Node验真和必要重入、资源/准备/编译/适用签名安装回读步骤以及取消与结果合同保持。离线缺件和非法输入必须真实失败，禁止以未完成顶层await退出替代完整结果。对应真实CLI回归只在自有target测试现场替换资源供给边界，验证反向导入、参数与错误传播，不据此声称实际产品编译通过。


本产品scripts/resources.mjs的普通inventory清单保持独占文件要求；工具原件toolInventory复用同一扫描实现，只允许全部真实名称均位于同一规范payload内的硬链接组。扫描按dev/ino分组，实际名称数量必须与nlink闭合；工具普通文件以O_NOFOLLOW打开，打开及读取后复验身份、计数、权限和字节相关元数据，扫描结束再回读全部目录、文件及链接身份与规范目标。原件外额外名称、目录或链接越界、特殊项、读取期间替换/权限/内容变化均失败。清单仍逐路径保留原有path/sha256/executable或directory/target格式，继续由既有回执、准确官方归档/版本、配方和编译输入证明验真；regular与其它资源默认独占校验不放宽。不新增公开命令、参数、声明字段或原件登记，不改版本、锁、配方和工具原件，不以拆分内部链接、重新安装或下载解决验真。回归复制本仓完整实现到所属target测试现场，仅替换文件IO边界以确定性制造读取变化，并在夹具内暴露已有私有验真函数；纯合成对象覆盖正常、拒绝与回执漂移，不据此宣称真实工具或产品编译通过。


本产品资源验真将下载运输元数据与源码工具编译身份分开：仅在源码工具证明和本产品声明的比较副本中，验证并移除archive.mirrors与upstream_patches各项mirrors。镜像须为非空、无重复、无控制字符/空白、无账号/口令/片段的准确规范HTTPS地址数组；错误格式直接失败。官方来源URL、版本、归档字节摘要、kind/root/executable、补丁来源/摘要/顺序、前置与依赖闭包、其它位置同名字段及未知字段继续严格比较。Xcode/POSIX输入、recipe.source和source.archive/source.gem摘要、原回执清单及入口独占规则不变；比较不改写原证明、声明或回执，不改变原件/登记/配方/版本/锁和实际下载策略，不读取控制台登记作为产品版本或策略来源。既有回归使用完整本仓资源实现及纯合成物理证明，逐次重算清单，验证运输差异可复用与真正输入漂移必须失败；测试不启动工具或冒充真实编译交付。


## 独立塔塔门禁与资料回归

本仓 `.github/tatagate/index.mjs` 是本机与GitHub共用的唯一门禁实现，`contracts.json`只登记本仓准确GitHub身份、已有流程与真实Node入口。GitHub在本仓main推送时自动运行 `tatagate.yml`，检出并核对该push的同一已保存SHA；其它仓库的工作树、门禁、私有规则和人工开发凭证均不是输入。

门禁检查独立Git根、准确HTTPS origin、当前受检提交及提交范围；本机只接受main，远端只接受准确仓库的main push。源码语法、真实代码注释上下文、临时残留、传输来源、所属根技术文档和受控测试登记分别检查。实现变化必须在同一范围同步所属文档与有内容的回归差异；空白调整不构成同步证据。代码与资料的语义、注释是否准确、回归是否覆盖产品功能仍须由本仓开发与最终真实验收逐项复核，非空文件或摘要不能证明业务正确。

Node清单从本仓Git已跟踪的真实测试逐项核对，漏登记、重复、失效和空入口失败；执行时必须有每份登记文件与最终汇总的完整成功回执。零用例、漏文件、失败、跳过、待办、取消及重复汇总均失败。所属产品流程、声明、资源版本与Workflow权限的回归归本仓 `scripts/flow.test.mjs`，不让其它仓库代验本产品。

门禁的工具与依赖需求、固定来源、准备配方、完整验真及同版复用合同统一由本仓 `scripts/resources.mjs` 拥有；门禁只调用公开接口，不维护第二份工具版本或配方。按当前职责规范，独立执行由产品获取和保存资源，经控制台执行由控制台准备和供给；下述既有接口与验收记录不代表控制台供给接入已完成。`prepareGateResources`准备本仓独占资源现场，`verifyGateResourceDelivery`回读准确来源、完整对象、执行器、宿主闭包和工作环境，`gateResourcePlan`从本仓既有声明派生来源。既有tools模块如存在仅转发产品资源接口。Linux门禁新增Ubuntu 24.04 x64宿主交付，macOS门禁复用本仓既有生产资源准备；不改生产流程顺序、工具版本、产品原锁或不可变原件。

固定Git输入只从本仓声明或门禁明确的40位提交取得，不消费其它产品当前main。独立执行的依赖原件归产品独立资源库，经控制台执行的依赖原件由控制台保存供给，任务缓存和编译数据归本轮target；已有多平台产品按本仓首个登记平台的test现场分配，单平台使用target/test。`gateLanguageView`使用受检Git快照与产品现有安全解包器物化本轮target工程视图，正式源码、声明和锁只读；Git包仅在任务视图元数据中投影为已验真的固定输入。

`ownedLanguageTests`按本仓已有原锁与公开入口派生适用语言调度，`validateLanguageResult`核对实际非空执行结果。有Cargo锁的工作区执行离线原锁的全部测试目标及文档测试；Flutter项目执行原有正式测试入口或完整analyze/test；已有Vitest业务套件与TypeScript公开回归实际执行。Node依赖先准备独占视图；需要实际编译产物的既有测试先调用所属产品原Build入口。依赖缺失、宿主不适用、工具加载失败或语言结果不完整均失败，不以跳过或零退出码代替通过。

取消、超时及任何非成功结论都是失败，长进程通过本产品 `runResourceProcess` 传播取消并确认整组退出；退出未确认时 `gateCleanupAllowed` 拒绝清理现场。

本轮只完善门禁实现、资料、注释和回归源码，尚未运行测试、门禁、编译、签名或安装。全部获准步骤实现完成后在最终统一验收中运行，随后按每仓准确保存SHA推送并核对该SHA的GitHub push门禁；未验收不得登记为已完成。


## 独立功能门禁

本仓 `.github/tatagate/` 只检查本仓提交。本产品现有功能检查主题为：登录与认证、请求签名、发现和预订、语言及页面状态。已有真实入口为：test/auth_api、auth_controller、booking_api、discovery_api、secure_api_client及UI现有用例。`contracts.json` 的 `functions` 只映射本仓已有用例路径、实际执行器、所属工程及具名用例，不复刻业务字段或算法；源码及公开接口继续是业务真源。当前登记 17 件既有测试来源（flutter 8 件、node 9 件），新增或移除用例须同步映射，遗漏、失效和重复必须拒绝。

Node完整报告逐文件核对；Flutter和Vitest从实际机器结果读取本仓具名套件完成数；Rust按准确原锁工作区及所属包运行全目标和文档测试，核对具名用例；Python调用实际unittest套件，拒绝零用例、失败、跳过、预期失败和意外成功。适用的原生门禁回读真实XCTest结果。执行回执绑定本仓、本次工作根和同一HEAD SHA，历史回执、加载事件、总数非空或单独零退出码均不足以证明全部功能检查成功。门禁协议夹具只证明核验器和调用边界，不能替代实际产品功能验收。

门禁资源仍由本仓 `scripts/resources.mjs` 准备和验真，实际用例需要的Cargo/npm原锁纳入本仓闭包。固定SDK只按本仓声明的同一40位提交建立本轮工程，不能读取邻仓或跟随main。Linux使用现有准确Ubuntu x64门禁宿主；本机使用原macOS ARM资源入口。Flutter需要的真实MLS、SDK ABI及适用Isar宿主在用例前准备，验证普通文件、当前工作边界及实际加载；缺库即失败，不设置跳过或替身。资源与全部测试临时数据只归本产品target内准确平台现场，不改变生产平台、生产工具版本、依赖版本或锁。

main推送自动触发本仓同SHA `tatagate.yml`，不调度其它产品门禁或CI/Release。中文注释、真实接口、所属文档与回归同步检查继续执行。当前只准备实现、注释和用例，未运行测试、语法检查、门禁、下载或编译。浏览器交互、真机、真实API/服务/数据库环境及适用平台不能由登记清单、单元测试或编译替代，须在整项实现后的统一验收逐项核对。

本地调用的既有协调目录参数只用于核对请求身份；实际测试工作根和本次功能回执由门禁自行在本仓target建立，不向快照旁协调目录写入产品状态。独立入口与控制台固定调用共享同一实现与退出结论。


本仓门禁回归执行边界：完整门禁包含本仓全部已登记真实测试；需要编译输入的既有用例由所属入口准备，禁止读取其它轮次生成物。嵌套Node回归启动独立运行器时，仅清除父运行器内部NODE_TEST_CONTEXT，产品工具和门禁输入继续保留；实际逐文件及最终结果仍拒绝零用例、遗漏、跳过和失败。回归夹具的Git/Shell来自已验真公开工具输入，禁止回退系统路径；工具转发模块不承担门禁CLI，直接参数拒绝由本仓实际门禁入口负责。 此次修正候选来自统一回归真实失败；整项真实功能验收、已保存提交门禁及同SHA远端结果尚未完成，不能据此登记为全部通过。

功能清单核验回读本仓实际Git跟踪源码，使用明确的本仓上游排除边界；漏登记、重复、不存在的入口或Rust具名用例集合不一致均失败。归档消费者仍属于本仓功能检查，不因上游目录豁免而排除。

本产品源码工具依赖准备仅返回源码外归档存储中的验真输入映射；工具候选不创建旧originals目录，也不清理不存在的目录。原始归档及编译输入仍由既有工具对象和回执完整保存，错误归档、缺前置工具、编译失败、缺输出及越界继续失败。修正后的配方形成自身对象身份，不覆盖历史原件；测试夹具遵守同一目录合同。

CitizenSDK正式消费统一固定于https://github.com/crcfrcn/citizensdk.git的根包(.)及真实提交0c442b4065ff1577e235cba76978749827d9f575；声明ref、锁ref和resolved-ref必须逐字一致，不使用浮动分支或邻仓工作树。SDK Android构建输出与JNI暂存只位于当前消费产品既有target的严格子目录，SDK依赖原件只读。离线原件按该固定提交取得与验真；本次来源统一不代表新包编译、签名、安装或业务验收已经通过。


门禁注释扫描按本仓既有词法候选区分真实注释、字符串和正则；上游Flutter锁定补丁正文不改写。真实临时注释及模板表达式内的临时标记继续拒绝。本轮临时边界验证不替代准确保存提交的完整门禁和同SHA远端验收。


## 本机固定执行目录

本产品生成状态仅允许位于本仓根target；target直属仅允许build、test两个固定目录，不建立平台、ci、release、publish或tmp固定目录。平台只属于任务身份；build承载编译，test承载测试。工具必需的内部目录仅在本轮存在。每轮先在短锁内核验身份和活跃保护，清空准确现场并回读为空；同产品共用固定现场串行领取，不同活动任务不得共享可写现场或互清。工具全部退出、结果核验及记录完成后，成功和失败均彻底清空；未确认退出时禁止清场或登记成功。候选、缓存、临时日志及可写工程不得持久留在target根，也不得建立替代持久目录。整个target必须忽略并排除源码复制、快照、摘要、资料门禁及打包输入；源码内禁止build、.dart_tool等生成目录。CI、Release在GitHub执行，不建立本机固定流程目录。

历史验收路径保留原记录；本节为当前本机目录规则。
