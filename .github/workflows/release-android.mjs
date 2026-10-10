#!/usr/bin/env node
// 正式版本身份由本仓自动化解析，独立于本机编译。
// 本仓本目标的完整自动化只由同名Workflow调用；版本与产物均在GitHub生成。
import { createHash } from 'node:crypto';
import { spawnSync, execFileSync } from 'node:child_process';
import { appendFileSync, copyFileSync, createReadStream, existsSync, lstatSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { basename, dirname, isAbsolute, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

export async function loveRelease(release,platform,readTag){
 if(!automationTarget(platform))fail('自动化目标未声明');
 if(platform!=='ios'&&platform!=='android')fail('交友端未实现该正式移动版本');
 const name=release?.tag_name,prefix=owner.product+'-'+platform+'-v';
 if(typeof name!=='string'||!name.startsWith(prefix))return null;
 const encoded=name.slice(prefix.length),match=/^(\d+\.\d+\.\d+)-r([1-9]\d*)-a([1-9]\d*)$/u.exec(encoded);
 if(!match)fail('交友端正式移动版本编码错误');
 const run_id=Number(match[2]),run_attempt=Number(match[3]);
 if(![run_id,run_attempt].every(Number.isSafeInteger))fail('交友端正式构建身份越界');
 const ref=await readTag(name);
 if(ref?.ref!=='refs/tags/'+name||ref.object?.type!=='commit'||typeof ref.object.sha!=='string'||!/^[a-f0-9]{40}$/u.test(ref.object.sha))fail('交友端移动发布没有准确源码Tag');
 return {run_id,version:match[1],tag:name,source_sha:ref.object.sha,run_attempt};
}
function automationTarget(platform){
 if(typeof platform!=='string'||!/^[-a-z0-9]+$/u.test(platform))return false;
 return existsSync(join(root,'.github/workflows/release-'+platform+'.mjs'))&&existsSync(join(root,'.github/workflows/release-'+platform+'.yml'));
}

export const owner = Object.freeze({"product": "tuyulove", "platform": "android", "repository": "tuyutata/tuyulove", "version_source": {"kind": "pubspec", "path": "pubspec.yaml"}, "required_assets": [], "asset_locations": ["$RUNNER_TEMP/citizenweb-release.tgz", "$RUNNER_TEMP/citizenweb-candidate"], "asset_patterns": ["*.tgz", "release-manifest.json", "SHA256SUMS"], "required_patterns": ["*.tgz", "release-manifest.json", "SHA256SUMS"]});
const commands = Object.freeze({
  "1": {
    "shell": "bash",
    "source": "printf 'version=3.47.2\n' >> \"$GITHUB_OUTPUT\""
  },
  "2": {
    "shell": "bash",
    "source": "# 安装后先验真，再统一准备目标平台缓存与受控修订。\nflutter --version --machine >/dev/null\nplatform=\"android\"\nflutter --version >/dev/null"
  },
  "3": {
    "shell": "bash",
    "source": "sdkmanager \"platforms;android-36\" \"build-tools;37.0.1\" \"platform-tools\" \"cmdline-tools;22.0\""
  },
  "4": {
    "shell": "bash",
    "source": "set -euo pipefail\n# 本次Release独占源码外工程，后续签名只读取此工程输出。\nproject_work=\"$RUNNER_TEMP/tuyulove-android-project\"\nmkdir \"$project_work\"\nproject_work=\"$(cd \"$project_work\" && pwd -P)\"\nTUYULOVE_PROJECT_ROOT=\"$(node \"$GITHUB_WORKSPACE/.github/workflows/release-android.mjs\" project create --source-root \"$GITHUB_WORKSPACE\" --work-root \"$project_work\" --platform android)\"\n# 单独导出，保留工程创建失败的退出状态。\nexport TUYULOVE_PROJECT_ROOT\nprintf 'TUYULOVE_PROJECT_ROOT=%s\\n' \"$TUYULOVE_PROJECT_ROOT\" >> \"$GITHUB_ENV\"\ncd \"$TUYULOVE_PROJECT_ROOT\"\nset -euo pipefail\nflutter pub get --enforce-lockfile\nflutter pub get --offline --enforce-lockfile\nflutter analyze\nflutter test\n# 原生库绑定同一锁定SDK与本轮Pub视图；回执只含固定的公开路径字段。\nsdk_environment=\"$project_work/sdk-environment.json\"\nnode \"$GITHUB_WORKSPACE/.github/workflows/release-android.mjs\" project native --source-root \"$GITHUB_WORKSPACE\" --work-root \"$project_work\" --output \"$TUYULOVE_PROJECT_ROOT\" --platform android >\"$sdk_environment\"\nwhile IFS= read -r -d '' key && IFS= read -r -d '' value; do\n  export \"$key=$value\"\ndone < <(node --input-type=module - \"$sdk_environment\" <<'NODE_NATIVE_ENV'\nimport {readFileSync} from 'node:fs';\nconst allowed=new Set(['CITIZENSDK_ANDROID_CORE_DIR','CITIZENSDK_ANDROID_BUILD_DIR','CITIZENSDK_SOURCE_DIR']);\nconst value=JSON.parse(readFileSync(process.argv[2],'utf8'));\nfor(const [key,path] of Object.entries(value)) {\n if(!allowed.has(key)||typeof path!=='string'||/[\\x00-\\x1f]/.test(path)) throw Error('SDK公开路径回执无效');\n process.stdout.write(key+'\\0'+path+'\\0');\n}\nNODE_NATIVE_ENV\n)\nflutter build apk --release --target-platform android-arm64 --build-name=\"$SOFTWARE_VERSION\"\nflutter build appbundle --release --target-platform android-arm64 --build-name=\"$SOFTWARE_VERSION\""
  },
  "5": {
    "shell": "bash",
    "source": "set -euo pipefail\numask 077\nwork=\"$RUNNER_TEMP/tuyulove-android-signing\"\nrm -rf \"$work\" \"$RELEASE_DIR\"\nmkdir -p \"$work\" \"$RELEASE_DIR/payload\"\ntrap 'rm -rf \"$work\"' EXIT\npython3 - \"$work\" <<'PY'\nimport base64, os, pathlib, re, sys\nroot = pathlib.Path(sys.argv[1]); fields = {}\nfor raw in os.environ.get(\"APP_KEY\", \"\").splitlines():\n    line = raw.strip()\n    if not line or line.startswith(\"#\"): continue\n    name, sep, value = line.partition(\"=\")\n    if not sep or name.strip() in fields or not value.strip(): raise SystemExit(\"APP_KEY 行格式无效\")\n    fields[name.strip()] = value.strip()\nif set(fields) - {\"keystore\", \"password\", \"alias\", \"keyPassword\"}: raise SystemExit(\"APP_KEY 包含未登记字段\")\nalias = fields.get(\"alias\", \"upload\")\nif not re.fullmatch(r\"[A-Za-z0-9._-]{1,128}\", alias): raise SystemExit(\"APP_KEY alias 无效\")\ntry: key = base64.b64decode(fields[\"keystore\"], validate=True); password = fields[\"password\"]\nexcept (KeyError, ValueError) as exc: raise SystemExit(\"APP_KEY 缺少有效签名材料\") from exc\nif not 1024 <= len(key) <= 32 * 1024 * 1024: raise SystemExit(\"APP_KEY keystore 大小无效\")\n(root / \"release.keystore\").write_bytes(key); (root / \"password\").write_text(password)\n(root / \"key-password\").write_text(fields.get(\"keyPassword\", password)); (root / \"alias\").write_text(alias)\nPY\nTUYU_ANDROID_STORE_PASSWORD=\"$(cat \"$work/password\")\"\nTUYU_ANDROID_KEY_PASSWORD=\"$(cat \"$work/key-password\")\"\nexport TUYU_ANDROID_STORE_PASSWORD TUYU_ANDROID_KEY_PASSWORD\nalias=\"$(cat \"$work/alias\")\"\napksigner=\"$ANDROID_HOME/build-tools/37.0.1/apksigner\"\n\"$apksigner\" sign --ks \"$work/release.keystore\" --ks-pass env:TUYU_ANDROID_STORE_PASSWORD --key-pass env:TUYU_ANDROID_KEY_PASSWORD --v4-signing-enabled false --ks-key-alias \"$alias\" --out \"$RELEASE_DIR/payload/tuyulove.apk\" \"$TUYULOVE_PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk\"\ncp \"$TUYULOVE_PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab\" \"$RELEASE_DIR/payload/tuyulove.aab\"\nzip -d \"$RELEASE_DIR/payload/tuyulove.aab\" 'META-INF/*' >/dev/null || true\njarsigner -keystore \"$work/release.keystore\" -storepass:env TUYU_ANDROID_STORE_PASSWORD -keypass:env TUYU_ANDROID_KEY_PASSWORD \"$RELEASE_DIR/payload/tuyulove.aab\" \"$alias\"\n\"$apksigner\" verify --verbose --print-certs \"$RELEASE_DIR/payload/tuyulove.apk\" | tee \"$work/apk-verification.txt\"\ngrep -F 'Verified using v2 scheme (APK Signature Scheme v2): true' \"$work/apk-verification.txt\"\njarsigner -verify \"$RELEASE_DIR/payload/tuyulove.aab\"\ntest \"$(apkanalyzer manifest application-id \"$RELEASE_DIR/payload/tuyulove.apk\")\" = com.tuyulove\n(cd \"$RELEASE_DIR/payload\" && zip -X \"$RELEASE_DIR/tuyulove-android.zip\" tuyulove.apk tuyulove.aab)"
  },
  "6": {
    "shell": "bash",
    "source": "node <<'NODE'\nconst { createHash } = require('node:crypto'); const fs = require('node:fs'); const root = process.env.RELEASE_DIR;\nconst hash = (name) => createHash('sha256').update(fs.readFileSync(`${root}/${name}`)).digest('hex');\nconst manifest = { product_id: 'tuyulove', platform: 'android', software_version: process.env.SOFTWARE_VERSION, git_commit_sha: process.env.SOURCE_SHA, producer_run_id: Number(process.env.PRODUCER_RUN_ID), package_name: 'com.tuyulove', assets: [{ name: 'tuyulove-android.zip', sha256: hash('tuyulove-android.zip') }] };\nfs.writeFileSync(`${root}/release-manifest.json`, `${JSON.stringify(manifest, null, 2)}\\n`);\nfs.writeFileSync(`${root}/SHA256SUMS`, `${hash('tuyulove-android.zip')}  tuyulove-android.zip\\n${hash('release-manifest.json')}  release-manifest.json\\n`);\nNODE"
  }
});
const actions = Object.freeze({});
const shaPattern = /^[0-9a-f]{40}$/u;
const fail = message => { throw new Error(message); };
const root = fileURLToPath(new URL('../../', import.meta.url));
const workflowPath = `.github/workflows/release-${owner.platform}.yml`;
const prefix = `${owner.product}-${owner.platform}-v`;

export function context(environment = process.env) {
  const number = name => {
    const value = environment[name];
    if (!/^[1-9][0-9]*$/u.test(value || '') || !Number.isSafeInteger(Number(value))) fail('GitHub运行坐标无效');
    return Number(value);
  };
  if (environment.GITHUB_ACTIONS !== 'true' || environment.GITHUB_REPOSITORY !== owner.repository
    || environment.GITHUB_REF !== 'refs/heads/main' || environment.GITHUB_EVENT_NAME !== 'workflow_dispatch'
    || !shaPattern.test(environment.GITHUB_SHA || '')
    || environment.GITHUB_WORKFLOW_REF !== `${owner.repository}/${workflowPath}@refs/heads/main`) fail('所属GitHub运行身份无效');
  return { repository: owner.repository, product_id: owner.product, platform: owner.platform,
    source_sha: environment.GITHUB_SHA, run_id: number('GITHUB_RUN_ID'),
    run_number: number('GITHUB_RUN_NUMBER'), run_attempt: number('GITHUB_RUN_ATTEMPT'), workflow: workflowPath };
}

export async function request(path, { method = 'GET', body, raw = false, size, fetch: send = globalThis.fetch } = {}) {
  const token = process.env.GH_TOKEN || process.env.GITHUB_TOKEN;
  if (!token || /[\s\u0000-\u001f\u007f]/u.test(token)) fail('缺少GitHub任务令牌');
  const url = path.startsWith('https://') ? new URL(path) : new URL(`https://api.github.com/repos/${owner.repository}/${path}`);
  if (!['api.github.com', 'uploads.github.com'].includes(url.hostname) || url.protocol !== 'https:' || url.username || url.password || !url.pathname.startsWith(`/repos/${owner.repository}/`)) fail('GitHub接口地址无效');
  const headers = { Authorization: `Bearer ${token}`, Accept: raw ? 'application/octet-stream' : 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2026-03-10', 'User-Agent': owner.product };
  if (body !== undefined) headers['Content-Type'] = body?.pipe ? 'application/octet-stream' : 'application/json';
  if(body?.pipe){if(!Number.isSafeInteger(size)||size<=0)fail('资产上传长度无效');headers['Content-Length']=String(size);}
  let response = await send(url, { method, headers, redirect: raw ? 'manual' : 'error', signal: AbortSignal.timeout(300_000),
    ...(body === undefined ? {} : { body: body?.pipe ? body : JSON.stringify(body), ...(body?.pipe ? { duplex: 'half' } : {}) }) });
  if(raw&&response.status===302){
    const location=new URL(response.headers.get('location'));
    if(location.protocol!=='https:'||location.username||location.password)fail('正式资产回读地址无效');
    response=await send(location,{method:'GET',redirect:'error',credentials:'omit',signal:AbortSignal.timeout(300_000)});
  }
  if (response.status === 404) return null;
  if (!response.ok) fail(`GitHub接口失败：${response.status}，操作未确认`);
  if (raw) return response;
  return response.status === 204 ? {} : response.json();
}

export async function pages(path, field = null, api = request) {
  const rows = [];
  for (let page = 1; ; page++) {
    const data = await api(`${path}${path.includes('?') ? '&' : '?'}per_page=100&page=${page}`);
    const values = field ? data?.[field] : data;
    if (!Array.isArray(values)) fail('GitHub分页数据无效');
    rows.push(...values);
    if (values.length < 100) return rows;
  }
}

function seedVersion() {
  const source = owner.version_source;
  if (source.kind === 'sequence') return '0.0.0';
  const text = readFileSync(join(root, source.path), 'utf8');
  if (source.kind === 'json') return String(JSON.parse(text).version);
  if (source.kind === 'spec') {
    const matches = [...text.matchAll(/^\s*spec_version:\s*(\d+)\s*,\s*$/gm)];
    if (matches.length !== 1) fail('Runtime版本真源不唯一');
    return matches[0][1];
  }
  if (source.kind === 'cargo') {
    const value = /^\[package\][\s\S]*?^version\s*=\s*"(\d+\.\d+\.\d+)"/mu.exec(text)?.[1];
    if (!value) fail('本仓Cargo版本真源无效');
    return value;
  }
  const value = /^version:\s*(\d+\.\d+\.\d+)(?:\+\d+)?\s*$/mu.exec(text)?.[1];
  if (!value) fail('本仓软件版本真源无效');
  return value;
}

export function nextVersion(seed, versions, protocol = false, runNumber = 1) {
  if (protocol) {
    if (!/^\d+$/u.test(seed) || versions.some(value => !/^\d+$/u.test(value))) fail('协议版本无效');
    const value = Math.max(Number(seed), ...versions.map(Number)) + (versions.length ? 1 : 0);
    if (!Number.isSafeInteger(value) || value < 1 || value > 0xffffffff) fail('协议版本越界');
    return String(value);
  }
  const parse = value => {
    const match = /^(0|[1-9]\d*)\.(0|[1-9]\d?)\.(0|[1-9]\d?)$/u.exec(value);
    if (!match) fail('软件版本无效');
    const parts=match.slice(1).map(Number);if(parts.some(value=>!Number.isSafeInteger(value)))fail('软件版本越界');return parts;
  };
  const values = [seed, ...versions].map(parse).sort((a,b) => a[0]-b[0] || a[1]-b[1] || a[2]-b[2]);
  let [major, minor, patch] = values.at(-1);
  if (versions.length) { if (++patch > 99) { patch = 0; if (++minor > 99) { minor = 0; major++; } } }
  if(!Number.isSafeInteger(runNumber)||runNumber<1)fail('版本运行序号无效');
  const initial=parse(seed),floor=BigInt(initial[0])*10000n+BigInt(initial[1])*100n+BigInt(initial[2])+BigInt(runNumber-1);
  const historical=BigInt(major)*10000n+BigInt(minor)*100n+BigInt(patch);
  if(floor>historical){major=Number(floor/10000n);minor=Number(floor/100n%100n);patch=Number(floor%100n);}
  if(![major,minor,patch].every(Number.isSafeInteger))fail('软件版本越界');
  return `${major}.${minor}.${patch}`;
}

function output(name, value, file = process.env.GITHUB_OUTPUT) {
  if (!file || /[\r\n]/u.test(String(value))) fail('GitHub步骤输出无效');
  appendFileSync(file, `${name}=${value}\n`);
}

export async function prepare() {
  const identity = context();
  const releases = await pages('releases');
  const versions = [];
  for (const release of releases) {
    if (release.draft || release.prerelease || !String(release.tag_name).startsWith(prefix)) continue;
    const notes = (await loveRelease(release,owner.platform,tag=>request('git/ref/tags/'+encodeURIComponent(tag))));
    if (!notes || notes.platform !== owner.platform) continue;
    const run = await request(`actions/runs/${notes.run_id}`);
    if (run?.status === 'completed' && run.conclusion === 'success' && run.path === workflowPath) versions.push(notes.version);
  }
  const version = nextVersion(seedVersion(), versions, owner.version_source.kind === 'spec', identity.run_number);
  const tag = `${prefix}${version}-r${identity.run_id}-a${identity.run_attempt}`;
  for (const [name,value] of Object.entries({version, tag, source_sha:identity.source_sha,
    run_id:identity.run_id, run_attempt:identity.run_attempt, run_number:identity.run_number})) output(name,value);
}

function runVersion() {
  const identity = context();
  const version = process.env.RELEASE_VERSION;
  const tag = process.env.RELEASE_TAG;
  nextVersion(version, [], owner.version_source.kind === 'spec');
  if (tag !== `${prefix}${version}-r${identity.run_id}-a${identity.run_attempt}`) fail('本次版本与Tag不一致');
  return {...identity, version, tag};
}

export function job() {
  const identity = runVersion();
  if (execFileSync('git', ['rev-parse','HEAD'], {cwd:root,encoding:'utf8'}).trim() !== identity.source_sha) fail('检出源码不符');
  const work = join(process.env.RUNNER_TEMP, owner.product, owner.platform, String(identity.run_id), String(identity.run_attempt), process.env.GITHUB_JOB);
  mkdirSync(work,{recursive:true});
  const variables = {RELEASE_WORK:work, RELEASE_ASSETS_DIR:join(work,'assets'), SOURCE_SHA:identity.source_sha,
    SOFTWARE_VERSION:identity.version, VERSION_TAG:identity.tag, BUILD_NUMBER:String(identity.run_number),
    CARGO_HOME:join(work,'cargo-home'), CARGO_TARGET_DIR:join(work,'cargo'), PUB_CACHE:join(work,'pub'),
    GRADLE_USER_HOME:join(work,'gradle'), npm_config_cache:join(work,'npm'), XDG_CACHE_HOME:join(work,'cache'),
    TMPDIR:join(work,'tmp'), TMP:join(work,'tmp'), TEMP:join(work,'tmp')};
  for (const path of ['cargo-home','cargo','pub','gradle','npm','cache','tmp','assets']) mkdirSync(join(work,path),{recursive:true});
  for (const [name,value] of Object.entries(variables)) { process.env[name]=value; output(name,value,process.env.GITHUB_ENV); }
}

export function step(key) {
  runVersion();
  const value = commands[key];
  if (!value || !['bash','pwsh'].includes(value.shell)) fail('本目标构建步骤无效');
  const directory = join(process.env.RELEASE_WORK,'commands');mkdirSync(directory,{recursive:true});
  const file = join(directory, value.shell === 'pwsh' ? 'step.ps1' : 'step.sh');
  writeFileSync(file, value.shell === 'bash' ? 'set -euo pipefail\n'+value.source : "$ErrorActionPreference = 'Stop'\n"+value.source,{mode:0o700});
  const result = spawnSync(value.shell === 'pwsh' ? 'pwsh' : 'bash', value.shell === 'pwsh' ? ['-NoProfile','-File',file] : [file],
    {cwd:process.cwd(),env:process.env,stdio:'inherit'});
  rmSync(file,{force:true});
  if (result.error || result.status !== 0) fail(`本仓构建步骤失败：${key}`);
}

export function action(name, args) {
  runVersion();
  const value = actions[name];if (!value) fail('本目标动作无效');
  const directory = join(process.env.RELEASE_WORK,'commands');mkdirSync(directory,{recursive:true});
  const file = join(directory,value.shell === 'bash'?'action.sh':'action.mjs');
  const source=value.source.replace(/__PRODUCT_URL__([^'"\s]+)__END_URL__/gu,(_,path)=>pathToFileURL(join(root,path)).href);
  writeFileSync(file,source,{mode:0o700});
  const result=spawnSync(value.shell==='bash'?'bash':process.execPath,[file,...args],{cwd:root,env:process.env,stdio:'inherit'});
  rmSync(file,{force:true});if(result.error||result.status!==0)fail(`本仓动作失败：${name}`);
}

function regular(path) {
  const stat=lstatSync(path);if(!stat.isFile()||stat.isSymbolicLink()||stat.size<=0)fail('正式产物不是非空普通文件');return stat;
}
async function digestFile(path) { const hash=createHash('sha256');for await(const bytes of createReadStream(path))hash.update(bytes);return hash.digest('hex'); }
function assetName(name) { if(!name||name!==basename(name)||/[\u0000-\u001f\u007f]/u.test(name))fail('正式资产文件名无效');return name; }

export async function collect(paths) {
  const identity=runVersion(),destination=process.env.RELEASE_ASSETS_DIR;
  if(!destination||!paths.length)fail('本仓没有完整产物');mkdirSync(destination,{recursive:true});
  const files=[];
  for(const path of paths){const file=resolve(path),stat=regular(file),name=assetName(basename(file));
    if(files.some(row=>row.name===name))fail('正式资产重名');
    const target=join(destination,name);if(file!==target)copyFileSync(file,target);
    files.push({name,size:stat.size,sha256:await digestFile(target)});
  }
  if(owner.required_assets.some(name=>!files.some(row=>row.name===name)))fail('本目标必要产物缺失');
  const metadata={schema:1,...identity,assets:files};
  writeFileSync(join(destination,'automation.json'),JSON.stringify(metadata,null,2)+'\n');
  output('assets',destination);return metadata;
}

export async function collectProduced() {
  const paths=[],seen=new Set();
  const expand=value=>value.replace(/\$\{([A-Z_]+)\}|\$([A-Z_]+)/gu,(_,a,b)=>process.env[a||b]||'');
  for(const location of owner.asset_locations){
    const path=expand(location);if(!path||!existsSync(path))continue;
    const candidates=lstatSync(path).isDirectory()?readdirSync(path).map(name=>join(path,name)):[path];
    for(const candidate of candidates){if(!lstatSync(candidate).isFile()||seen.has(resolve(candidate)))continue;
      const name=basename(candidate);if(!owner.asset_patterns.some(pattern=>new RegExp('^'+pattern.replace(/[.+?^${}()|[\]\\]/gu,'\\$&').replaceAll('*','.*')+'$','u').test(name)))continue;
      seen.add(resolve(candidate));paths.push(candidate);
    }
  }
  if(owner.required_patterns.some(pattern=>!paths.some(path=>new RegExp('^'+pattern.replace(/[.+?^${}()|[\]\\]/gu,'\\$&').replaceAll('*','.*')+'$','u').test(basename(path)))))fail('本目标完整正式资产缺失');
  return collect(paths);
}



export async function publish(directory) {
  const identity=runVersion();const metadata=JSON.parse(readFileSync(join(directory,'automation.json'),'utf8'));
  if(Object.entries(identity).some(([key,value])=>metadata[key]!==value)||!Array.isArray(metadata.assets)||!metadata.assets.length)fail('完整产物身份无效');
  const files=metadata.assets;
  if(readdirSync(directory).sort().join('\0')!==[...files.map(value=>value.name),'automation.json'].sort().join('\0'))fail('产物目录与完整资产集合不符');
  for(const file of files){const path=join(directory,assetName(file.name));if(regular(path).size!==file.size||await digestFile(path)!==file.sha256)fail('正式产物在交付前改变');}
  if(await request(`git/ref/tags/${encodeURIComponent(identity.tag)}`)!==null)fail('本次Tag已经存在');
  await request('git/refs',{method:'POST',body:{ref:`refs/tags/${identity.tag}`,sha:identity.source_sha}});
  const release=await request('releases',{method:'POST',body:{tag_name:identity.tag,target_commitish:identity.source_sha,
    name:`${owner.product} · ${owner.platform} · ${identity.version}`,draft:false,prerelease:false,make_latest:'false',
    body:`${owner.product} · ${owner.platform} · ${identity.version}\nSource: ${identity.source_sha}\nRun: ${identity.run_id} / ${identity.run_attempt}`}});
  if(!Number.isSafeInteger(release?.id)||!release.upload_url)fail('正式Release创建未确认');
  for(const file of files){const url=new URL(release.upload_url.replace(/\{.*$/u,''));url.searchParams.set('name',file.name);
    const asset=await request(url.href,{method:'POST',body:createReadStream(join(directory,file.name)),size:file.size});
    if(asset?.name!==file.name||asset.size!==file.size||asset.state!=='uploaded')fail('正式资产上传未确认');
    const response=await request(asset.url,{raw:true});if(!response?.body)fail('正式资产回读失败');
    const hash=createHash('sha256');let size=0;for await(const bytes of response.body){hash.update(bytes);size+=bytes.length;if(size>file.size)fail('正式资产回读超过声明大小');}
    if(size!==file.size||hash.digest('hex')!==file.sha256)fail('GitHub资产逐件回读不一致');
  }
  const readback=await request(`releases/${release.id}`);if((await loveRelease(readback,owner.platform,tag=>request('git/ref/tags/'+encodeURIComponent(tag))))?.run_id!==identity.run_id||readback.draft||readback.prerelease
    ||readback.assets?.length!==files.length)fail('完整正式Release回查失败');
  for(const file of files){const asset=readback.assets.find(value=>value.name===file.name);if(!asset||asset.state!=='uploaded'||asset.size!==file.size||asset.digest!==`sha256:${file.sha256}`)fail('完整正式资产证明回查失败');}
  output('verified','true');output('release_id',release.id);output('tag',identity.tag);
}

function ownedRun(run) {
  // 每个目标只处理自身现行Workflow；文件缺失不能证明历史任务归属。
  return Number.isSafeInteger(run?.id)&&run.id>0&&run.path===workflowPath
    &&run.head_branch==='main'&&run.event==='workflow_dispatch'
    &&(!run.repository||run.repository.full_name===owner.repository);
}

export function cleanupPlan(runs,current,result) {
  if(!['success','failed'].includes(result)||!ownedRun(current)||!Number.isFinite(Date.parse(current.created_at)))fail('清理所属任务身份无效');
  const earlier=run=>Date.parse(run.created_at)<Date.parse(current.created_at)
    ||Date.parse(run.created_at)===Date.parse(current.created_at)&&run.id<current.id;
  return runs.filter(run=>ownedRun(run)&&run.id!==current.id&&run.status==='completed'&&earlier(run)
    &&(run.conclusion==='success'?'success':'failed')===result).sort((a,b)=>a.id-b.id);
}

async function remove(path,api) { await api(path,{method:'DELETE'});const readPath=path.replace(/^git\/refs\//u,'git/ref/');if(await api(readPath)!==null)fail('删除回查仍存在，清理失败'); }
async function removeRunRelease(run,releases,api) {
  for(const release of releases){
    const metadata=(await loveRelease(release,owner.platform,tag=>api('git/ref/tags/'+encodeURIComponent(tag))));
    if(!metadata||metadata.run_id!==run.id)continue;
    if(metadata.source_sha!==run.head_sha)fail('正式Release与所属Run不一致');
    const tag=metadata.tag;
    const again=await api(`actions/runs/${run.id}`);
    if(again&&again.id!==Number(process.env.GITHUB_RUN_ID)
      &&(again.status!=='completed'||again.run_attempt!==run.run_attempt||again.conclusion!==run.conclusion))fail('所属任务已变化，停止清理');
    await remove(`releases/${release.id}`,api);
    const beforeTag=await api(`actions/runs/${run.id}`);
    if(beforeTag&&beforeTag.id!==Number(process.env.GITHUB_RUN_ID)
      &&(beforeTag.status!=='completed'||beforeTag.run_attempt!==run.run_attempt||beforeTag.conclusion!==run.conclusion))fail('所属任务已变化，停止清理');
    await remove(`git/refs/tags/${encodeURIComponent(tag)}`,api);
  }
}
export async function cleanup(result,identity=context(),api=request) {
  const current=await api(`actions/runs/${identity.run_id}`);
  const plan=cleanupPlan(await pages('actions/runs','workflow_runs',api),current,result);
  const releases=await pages('releases',null,api),removed=[];
  for(const row of plan){const run=await api(`actions/runs/${row.id}`);if(!run){removed.push(row.id);continue;}
    if(run.run_attempt!==row.run_attempt||cleanupPlan([run],current,result).length!==1)continue;
    await removeRunRelease(run,releases,api);
    // 失败若只形成Tag也按它的准确Run坐标处理，不能留下同类孤立产物。
    const tags=await api(`git/matching-refs/tags/${prefix}`);
    if(!Array.isArray(tags))fail('所属Tag集合无效');
    for(const reference of tags){
      const tag=String(reference.ref||'').slice('refs/tags/'.length);
      if(!String(reference.ref||'').startsWith('refs/tags/'+prefix)
        ||!new RegExp(`-r${run.id}-a[1-9][0-9]*$`,'u').test(tag)||Number(tag.slice(tag.lastIndexOf('-a')+2))>run.run_attempt)continue;
      if(reference.object?.type!=='commit'||reference.object.sha!==run.head_sha)fail('所属Tag来源已改变，停止清理');
      const again=await api(`actions/runs/${run.id}`);
      if(!again||cleanupPlan([again],current,result).length!==1)fail('所属任务已改变，停止清理');
      await remove(`git/refs/tags/${encodeURIComponent(tag)}`,api);
    }
    for(const asset of await pages(`actions/runs/${run.id}/artifacts`,'artifacts',api)){
      if(!Number.isSafeInteger(asset.id)||asset.id<=0)fail('所属Artifact坐标无效');
      const again=await api(`actions/runs/${run.id}`);if(!again||again.status!=='completed'||again.run_attempt!==run.run_attempt||again.conclusion!==run.conclusion)fail('历史任务已变化，停止清理');
      await remove(`actions/artifacts/${asset.id}`,api);
    }
    const final=await api(`actions/runs/${run.id}`);
    if(final&&(final.run_attempt!==run.run_attempt||cleanupPlan([final],current,result).length!==1))fail('历史任务状态改变，停止清理');
    if(final)await remove(`actions/runs/${run.id}`,api);removed.push(run.id);
  }
  return removed;
}

export function precedingResult(needs) {
  if(!needs||typeof needs!=='object'||Array.isArray(needs)||!Object.keys(needs).length)fail('前置任务结果缺失');
  return Object.values(needs).every(value=>value?.result==='success')?'success':'failed';
}
async function discardCurrent(identity,api) {
  for(const release of await pages('releases',null,api)){
    const metadata=(await loveRelease(release,owner.platform,tag=>api('git/ref/tags/'+encodeURIComponent(tag))));
    if(metadata?.run_id===identity.run_id&&metadata.run_attempt===identity.run_attempt)
      await removeRunRelease({id:identity.run_id,head_sha:identity.source_sha},[release],api);
  }
  const tag=process.env.RELEASE_TAG;
  if(tag&&tag.startsWith(prefix)&&tag.endsWith(`-r${identity.run_id}-a${identity.run_attempt}`)){
    const path=`git/refs/tags/${encodeURIComponent(tag)}`;
    if(await api(path.replace(/^git\/refs\//u,'git/ref/'))!==null)await remove(path,api);
  }
}
export async function finish(needs=JSON.parse(process.env.RELEASE_NEEDS||'null'),api=request,identity=context()) {
  const result=precedingResult(needs),errors=[];
  const attempt=async action=>{try{return await action();}catch(error){errors.push(error);return null;}};
  let removed;
  if(result==='success') {
    removed=await attempt(()=>cleanup('success',identity,api));
    if(errors.length) {
      await attempt(()=>discardCurrent(identity,api));
      await attempt(()=>cleanup('failed',identity,api));
    }
  } else {
    // 本次撤销失败也必须尝试清理同目标旧失败；各项真实错误均保留。
    await attempt(()=>discardCurrent(identity,api));
    removed=await attempt(()=>cleanup('failed',identity,api));
  }
  if(errors.length)throw new AggregateError(errors,'本目标最后处理失败：'+errors.map(error=>error.message).join('；'));
  if(process.env.GITHUB_STEP_SUMMARY)appendFileSync(process.env.GITHUB_STEP_SUMMARY,`本目标${result==='success'?'成功':'失败'}；已清理同类旧Run：${removed.join('、')||'无'}。\n`);
  if(result==='failed')fail('前置任务未全部成功');
}

// 本目标实际构建与组包接口。
async function productCommand() { return false; }


// 产品工程视图由当前流程本身实现，不调用其它流程脚本。
const projectInternals=await(async()=>{
const {execFileSync}=await import('node:child_process');
const {chmodSync,copyFileSync,existsSync,lstatSync,mkdirSync,readFileSync,readdirSync,realpathSync,rmSync,symlinkSync,writeFileSync}=await import('node:fs');
const {dirname,isAbsolute,join,parse,relative,resolve,sep}=await import('node:path');
const {fileURLToPath,pathToFileURL}=await import('node:url');
// tuyulove：扁平源码是唯一输入，平台工具要求的目录只在本次工作根装配。
// 每个产品拥有自己的映射；不读取其他产品的构建配置，不复用任务输出。




// 第一方依赖只来自宿主声明和锁中的准确公开Git提交；不读取邻仓、不接受override。
// Git检出和标准Flutter消费视图均属于本次工作根，宿主源码声明和锁保持原字节。
const firstPartyRepositories = Object.freeze({
  citizen_sdk: 'https://github.com/crcfrcn/citizensdk.git',
  tatachat_sdk: 'https://github.com/tuyutata/tatachatsdk.git',
});
function dependencyBlock(text, name) {
  const matches = [...text.matchAll(new RegExp('^  ' + name + ':\\n(?:[ \\t]{4,}[^\\n]*\\n)+', 'gm'))];
  if (matches.length !== 1) fail('第一方依赖块不唯一：' + name);
  return matches[0][0];
}
function dependencyField(block, key) {
  const matches = [...block.matchAll(new RegExp('^[ \\t]+' + key + ':\\s*(.*?)\\s*$', 'gm'))];
  if (matches.length !== 1) fail('第一方依赖字段不唯一：' + key);
  const value = matches[0][1];
  return value.startsWith('"') && value.endsWith('"') ? JSON.parse(value)
    : value.startsWith("'") && value.endsWith("'") ? value.slice(1, -1) : value;
}
// 固定Git版本与普通绝对入口一起验证；不从PATH或系统目录选择替代执行器。
function sourceGitEnvironment(environment = process.env) {
  const path = environment.PRODUCT_GIT_BIN;
  if (typeof path !== 'string' || !isAbsolute(path) || resolve(path) !== path || /[\x00-\x1f]/u.test(path)) fail('Git必须显式交付规范绝对路径');
  const info = lstatSync(path);
  if (!info.isFile() || info.isSymbolicLink() || !(info.mode & 0o111) || realpathSync(path) !== path) fail('Git必须是准确普通执行器');
  const env = { HOME: environment.HOME, PATH: dirname(path), LANG: 'C', LC_ALL: 'C',
    GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: '/dev/null', GIT_TERMINAL_PROMPT: '0' };
  if (execFileSync(path, ['--version'], { env, encoding: 'utf8', timeout: 20000, stdio: ['ignore', 'pipe', 'pipe'] }).trim() !== 'git version 2.54.0') fail('Git版本不符');
  return { path, env };
}
function sourceGit(root, args) {
  const { path, env } = sourceGitEnvironment();
  return execFileSync(path, ['-c', 'credential.helper=', '-c', 'core.hooksPath=/dev/null',
    '-c', 'protocol.file.allow=never', '-c', 'gc.auto=0', '-C', root, ...args], {
    encoding: 'utf8', timeout: 180000, maxBuffer: 1024 * 1024,
    stdio: ['ignore', 'pipe', 'pipe'],
    env,
  }).trim();
}
function verifyGitDirectory(root) {
  if (!isAbsolute(root) || resolve(root) !== root || root === parse(root).root) fail('Git来源根无效');
  let at = parse(root).root;
  for (const part of relative(at, root).split(sep)) {
    at = join(at, part);
    const info = lstatSync(at, { throwIfNoEntry: false });
    if (!info?.isDirectory() || info.isSymbolicLink()) fail('Git来源根缺失或经过链接');
  }
}
function resolveFirstPartyDependencies(source, work) {
  verifyGitDirectory(source); verifyGitDirectory(work);
  if (existsSync(join(source, 'pubspec_overrides.yaml'))) fail('第一方依赖禁止override');
  const manifest = readFileSync(join(source, 'pubspec.yaml'), 'utf8');
  if (/^    path:/mu.test(manifest)) fail('宿主直接依赖禁止源码外path来源');
  const lock = readFileSync(join(source, 'pubspec.lock'), 'utf8');
  const result = {};
  for (const [name, url] of Object.entries(firstPartyRepositories)) {
    if (!new RegExp('^  ' + name + ':$', 'm').test(manifest)) continue;
    const declared = dependencyBlock(manifest, name), locked = dependencyBlock(lock, name);
    const sha = dependencyField(declared, 'ref');
    if (!/^    git:\s*$/m.test(declared) || !/^[0-9a-f]{40}$/.test(sha)
      || dependencyField(declared, 'url') !== url || dependencyField(declared, 'path') !== '.'
      || dependencyField(locked, 'source') !== 'git' || dependencyField(locked, 'url') !== url
      || dependencyField(locked, 'path') !== '.' || dependencyField(locked, 'ref') !== sha
      || dependencyField(locked, 'resolved-ref') !== sha
      || dependencyField(locked, 'version') !== '1.0.0') fail('第一方声明、锁和唯一Git来源不一致：' + name);
    const parent = join(work, 'git-sources'); mkdirSync(parent, { recursive: true, mode: 0o700 });
    verifyGitDirectory(parent);
    const root = join(parent, name);
    if (!existsSync(root)) {
      mkdirSync(root, { mode: 0o700 });
      const owned = lstatSync(root);
      try {
        sourceGit(root, ['init', '--quiet']);
        sourceGit(root, ['remote', 'add', 'origin', url]);
        sourceGit(root, ['fetch', '--no-tags', '--depth=1', 'origin', sha]);
        sourceGit(root, ['checkout', '--quiet', '--detach', sha]);
      } catch {
        const now = lstatSync(root, { throwIfNoEntry: false });
        if (now?.isDirectory() && !now.isSymbolicLink() && now.dev === owned.dev && now.ino === owned.ino) rmSync(root, { recursive: true });
        fail('第一方固定Git提交取得失败；未使用邻仓或重试：' + name);
      }
    }
    verifyGitDirectory(root); verifyGitDirectory(join(root, '.git'));
    if (resolve(sourceGit(root, ['rev-parse', '--show-toplevel'])) !== root
      || resolve(sourceGit(root, ['rev-parse', '--absolute-git-dir'])) !== join(root, '.git')
      || resolve(root, sourceGit(root, ['rev-parse', '--git-common-dir'])) !== join(root, '.git')
      || sourceGit(root, ['rev-parse', '--abbrev-ref', 'HEAD']) !== 'HEAD'
      || sourceGit(root, ['rev-parse', 'HEAD']) !== sha || sourceGit(root, ['remote', 'get-url', 'origin']) !== url
      || sourceGit(root, ['status', '--porcelain=v1', '--untracked-files=all']) !== ''
      || !new RegExp('^name:\\s*' + name + '\\s*$', 'm').test(readFileSync(join(root, 'pubspec.yaml'), 'utf8'))) {
      fail('第一方Git检出身份或源码已变：' + name);
    }
    result[name] = { root, url, sha };
  }
  if (!result.citizen_sdk) fail('宿主缺少唯一CitizenSDK直接依赖');
  return result;
}
function projectedPubMetadata(source, dependencies, views) {
  let manifest = readFileSync(join(source, 'pubspec.yaml'), 'utf8');
  let lock = readFileSync(join(source, 'pubspec.lock'), 'utf8');
  for (const [name] of Object.entries(dependencies)) {
    const target = views[name];
    if (typeof target !== 'string' || !isAbsolute(target) || target !== resolve(target)) fail('SDK视图路径无效');
    manifest = manifest.replace(dependencyBlock(manifest, name), '  ' + name + ':\n    path: ' + JSON.stringify(target) + '\n');
    lock = lock.replace(dependencyBlock(lock, name), '  ' + name + ':\n    dependency: "direct main"\n    description:\n      path: '
      + JSON.stringify(target) + '\n      relative: false\n    source: path\n    version: "1.0.0"\n');
  }
  return { 'pubspec.yaml': manifest, 'pubspec.lock': lock };
}

const platformEntries = Object.freeze([
  [
    "android/app/src/debug-AndroidManifest.xml",
    "android/app/src/debug/AndroidManifest.xml"
  ],
  [
    "android/app/src/profile-AndroidManifest.xml",
    "android/app/src/profile/AndroidManifest.xml"
  ],
  [
    "android/app/src/main/MainActivity.kt",
    "android/app/src/main/kotlin/com/tuyulove/MainActivity.kt"
  ],
  [
    "android/app/src/main/res/launch_background-v21.xml",
    "android/app/src/main/res/drawable-v21/launch_background.xml"
  ],
  [
    "android/app/src/main/res/styles.xml",
    "android/app/src/main/res/values/styles.xml"
  ],
  [
    "android/app/src/main/res/styles-night.xml",
    "android/app/src/main/res/values-night/styles.xml"
  ],
  [
    "android/gradle-wrapper.properties",
    "android/gradle/wrapper/gradle-wrapper.properties"
  ],
  [
    "ios/Runner.pbxproj",
    "ios/Runner.xcodeproj/project.pbxproj"
  ],
  [
    "ios/Runner.xcscheme",
    "ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"
  ],
  [
    "ios/ProjectWorkspace.xcworkspacedata",
    "ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
  ],
  [
    "ios/ProjectWorkspaceChecks.plist",
    "ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist"
  ],
  [
    "ios/ProjectWorkspaceSettings.xcsettings",
    "ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings"
  ],
  [
    "ios/Workspace.xcworkspacedata",
    "ios/Runner.xcworkspace/contents.xcworkspacedata"
  ],
  [
    "ios/WorkspaceChecks.plist",
    "ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist"
  ],
  [
    "ios/WorkspaceSettings.xcsettings",
    "ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings"
  ],
  [
    "ios/RunnerTests.swift",
    "ios/RunnerTests/RunnerTests.swift"
  ]
]);
const generated = new Set(['.git', '.DS_Store', '.dart_tool', 'build', 'target', '.gradle',
  '.symlinks', '.plugin_symlinks', 'Pods', 'ephemeral', 'node_modules', 'xcuserdata', 'swiftpm']);
const generatedFiles = new Set(['.flutter-plugins', '.flutter-plugins-dependencies', '.packages',
  'Generated.xcconfig', 'flutter_export_environment.sh', 'local.properties',
  'GeneratedPluginRegistrant.h', 'GeneratedPluginRegistrant.m', 'GeneratedPluginRegistrant.swift',
  'generated_plugin_registrant.cc', 'generated_plugin_registrant.h', 'generated_plugins.cmake',
  'generated_config.cmake']);
const writable = new Set(['pubspec.yaml', 'pubspec.lock', 'pubspec_overrides.yaml',
  'analysis_options.yaml', 'Podfile.lock', 'project.pbxproj', 'Runner.pbxproj',
  'settings.gradle', 'settings.gradle.kts']);
const platforms = new Set(['ios', 'android', 'macos', 'windows', 'linux', 'linux-arm', 'linux-amd']);

function fail(message) { throw new Error('tuyulove工程：' + message); }
function inside(root, value) { const p = relative(root, value); return p === '' || (!isAbsolute(p) && p !== '..' && !p.startsWith('..' + sep)); }
function directory(value, label) {
  if (typeof value !== 'string' || !isAbsolute(value) || resolve(value) !== value || value === parse(value).root) fail(label + '须为规范绝对路径');
  let at = parse(value).root;
  for (const part of relative(at, value).split(sep)) {
    at = join(at, part);
    const s = lstatSync(at, { throwIfNoEntry: false });
    if (!s?.isDirectory() || s.isSymbolicLink()) fail(label + '缺失或经过链接');
  }
  return value;
}
function parameters({ source, work, output, platform = process.env.TUYU_PLATFORM || (process.platform === 'darwin' ? 'macos' : process.platform === 'win32' ? 'windows' : 'linux') }) {
  directory(source, '源码根'); directory(work, '工作根');
  if (!inside(join(source, 'target'), work) || work === join(source, 'target')) fail('工作根必须位于本产品target内');
  if (!platforms.has(platform)) fail('平台无效');
  output ??= join(work, 'flutter-project', source.replace(/^[A-Za-z]:[\\/]|^[\\/]+/u, ''));
  if (!isAbsolute(output) || resolve(output) !== output || !inside(work, output) || output === work) fail('输出须属于本次工作根');
  let at = dirname(output);
  while (!existsSync(at)) at = dirname(at);
  directory(at, '输出父目录');
  return { source, work, output, platform };
}

function sourceFiles(root) {
  const files = [];
  const walk = (base) => {
    for (const e of readdirSync(base, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      if (generated.has(e.name) || generatedFiles.has(e.name)) continue;
      const input = join(base, e.name);
      if (e.isSymbolicLink()) fail('来源包含未登记链接：' + relative(root, input));
      if (e.isDirectory()) walk(input);
      else if (e.isFile()) files.push(input);
      else fail('来源包含非常规文件');
    }
  };
  walk(root);
  return files;
}

function put(input, output, copy = false) {
  if (lstatSync(output, { throwIfNoEntry: false })) fail('目标重复：' + output);
  mkdirSync(dirname(output), { recursive: true });
  if (copy || process.platform === 'win32') copyFileSync(input, output);
  else symlinkSync(input, output);
}

function wrappers(environment) {
  const root = directory(environment.FLUTTER_ROOT, '固定Flutter工具根');
  return ['gradlew', 'gradlew.bat', 'gradle/wrapper/gradle-wrapper.jar'].map(name => {
    const input = join(root, 'bin/cache/artifacts/gradle_wrapper', name);
    directory(dirname(input), 'Wrapper原件父目录');
    const s = lstatSync(input, { throwIfNoEntry: false });
    if (!s?.isFile() || s.isSymbolicLink() || s.size === 0) fail('Wrapper原件缺失：' + name);
    return { name, input };
  });
}

async function createProject(options, environment = process.env) {
  const p = parameters(options);
  if (lstatSync(p.output, { throwIfNoEntry: false })) fail('输出已存在');
  const inputs = sourceFiles(p.source);
  const mapping = new Map(platformEntries);
  for (const [source] of mapping) if (!inputs.includes(join(p.source, source))) fail('平台输入缺失：' + source);
  const toolInputs = p.platform === 'android' ? wrappers(environment) : [];
  // 先核实全部固定输入，再排他创建本次输出；清理只持有这一次的inode身份。
  mkdirSync(dirname(p.output), { recursive: true });
  mkdirSync(p.output);
  const owned = lstatSync(p.output);
  try {
    for (const input of inputs) {
      const rel = relative(p.source, input).split(sep).join('/');
      const target = mapping.get(rel) || rel;
      if (mapping.has(rel) && inputs.includes(join(p.source, target))) fail('来源同时存在标准布局与扁平布局：' + target);
      put(input, join(p.output, target), writable.has(input.split(sep).at(-1)));
    }
    for (const item of toolInputs) {
      put(item.input, join(p.output, 'android', item.name), true);
      if (item.name === 'gradlew') chmodSync(join(p.output, 'android', item.name), 0o755);
    }
    // 宿主先验真Git原件，再调用各SDK唯一公开布局入口；只改写本轮Pub元数据副本。
    const dependencies = resolveFirstPartyDependencies(p.source, p.work), views = {};
    for (const [name, item] of Object.entries(dependencies)) {
      const target = join(p.output, '.source-packages', name);
      const api = await import(pathToFileURL(join(item.root, 'scripts/release.mjs')).href);
      if (typeof api.createFlutterSourceView !== 'function') fail('SDK缺少公开Flutter布局入口');
      mkdirSync(dirname(target), { recursive: true });
      await api.createFlutterSourceView(item.root, target);
      views[name] = target;
    }
    for (const [name, value] of Object.entries(projectedPubMetadata(p.source, dependencies, views))) {
      const output = join(p.output, name);
      if (lstatSync(output, { throwIfNoEntry: false })?.isSymbolicLink()) rmSync(output);
      writeFileSync(output, value);
    }
    verifyProject(p);
    return p.output;
  } catch (error) {
    const s = lstatSync(p.output, { throwIfNoEntry: false });
    if (s?.isDirectory() && !s.isSymbolicLink() && s.dev === owned.dev && s.ino === owned.ino) rmSync(p.output, { recursive: true });
    throw error;
  }
}

function verifyProject(options) {
  const p = parameters(options);
  directory(p.output, '输出工程');
  for (const [input, output] of platformEntries) {
    const source = join(p.source, input), target = join(p.output, output);
    const s = lstatSync(target, { throwIfNoEntry: false });
    if (!s || (s.isSymbolicLink() ? realpathSync(target) !== source : !s.isFile())) fail('平台入口缺失或来源不一致：' + output);
    if (!readFileSync(source).equals(readFileSync(target))) fail('平台入口字节不符：' + output);
  }
  const dependencies = resolveFirstPartyDependencies(p.source, p.work);
  const views = Object.fromEntries(Object.keys(dependencies).map(name => [name, join(p.output, '.source-packages', name)]));
  for (const [name, expected] of Object.entries(projectedPubMetadata(p.source, dependencies, views))) {
    const path = join(p.output, name), info = lstatSync(path, { throwIfNoEntry: false });
    if (!info?.isFile() || info.isSymbolicLink() || readFileSync(path, 'utf8') !== expected) fail('本轮Pub声明或锁漂移');
  }
  if (!existsSync(join(p.output, 'pubspec.yaml'))) fail('输出缺少pubspec');
  if (p.platform === 'android') for (const name of ['gradlew', 'gradlew.bat', 'gradle/wrapper/gradle-wrapper.jar']) {
    const item = lstatSync(join(p.output, 'android', name), { throwIfNoEntry: false });
    if (!item?.isFile() || item.isSymbolicLink() || !item.size) fail('输出Wrapper无效');
  }
  return p.output;
}


// 编译只消费锁定的Git原件；原生安装件归本轮SDK视图，源码与声明/锁均保持只读。
async function prepareNativeProject(options, environment = process.env) {
  const p = parameters(options);
  verifyProject(p);
  const dependency = resolveFirstPartyDependencies(p.source, p.work).citizen_sdk;
  const sdk = dependency.root, view = join(p.output, '.source-packages/citizen_sdk');
  const api = await import(pathToFileURL(join(sdk, 'scripts/release.mjs')).href);
  api.assertFlutterSourceView(sdk, view);
  const stage = join(p.work, 'sdk-native');
  if (lstatSync(stage, { throwIfNoEntry: false })) fail('SDK原生工作目录已存在');
  mkdirSync(stage);
  const owned = lstatSync(stage);
  const nativeWork = join(stage, 'work'), nativeOutput = join(stage, 'output');
  const sources = join(stage, 'sources');
  const target = { ios: 'apple', macos: 'apple', android: 'android', windows: 'Windows',
    'linux-arm': 'LinuxARM', 'linux-amd': 'LinuxAMD' }[p.platform];
  const dependencyPlatform = { ios: 'macOS', macos: 'macOS', android: 'Android',
    windows: 'Windows', 'linux-arm': 'LinuxARM', 'linux-amd': 'LinuxAMD' }[p.platform];
  if (!target) fail('SDK原生平台未登记');
  const child = { ...environment, CITIZENSDK_WORK_DIR: nativeWork,
    CITIZENSDK_NATIVE_OUTPUT_DIR: nativeOutput, CITIZENSDK_SOURCE_SHA: dependency.sha,
    CITIZENSDK_VERSION: '1.0.0', CITIZENSDK_FLUTTER_ROOT: environment.FLUTTER_ROOT,
    CITIZENSDK_GRADLE: p.platform === 'android' ? (environment.CITIZENSDK_GRADLE || join(p.output, 'android/gradlew')) : environment.CITIZENSDK_GRADLE };
  if (child.CITIZENSDK_DEPENDENCY_RECEIPT) fail('SDK依赖收据必须由本轮生成');
  const dependencyScript = join(sdk, 'scripts/dependencies.mjs');
  const run = (file, args) => execFileSync(file, args, {
    env: child, stdio: ['ignore', 'pipe', 'inherit'], encoding: 'utf8', maxBuffer: 1024 * 1024 });
  try {
    run(process.execPath, [dependencyScript, 'prepare-environment', '--scope', 'citizensdk',
      '--platform', dependencyPlatform, '--work', sources]);
    child.CITIZENSDK_ZXING_SOURCE_DIR = join(sources, 'zxing-cpp-3.1.1');
    if (['windows', 'linux-arm', 'linux-amd'].includes(p.platform)) {
      const prepared = JSON.parse(run(process.execPath, [dependencyScript, 'prepare-native',
        '--scope', 'citizensdk', '--platform', dependencyPlatform, '--work', join(stage, 'dependencies'),
        '--sources', sources, '--sdk', sdk, '--mode', environment.CARGO_INCREMENTAL === '0' ? 'release' : 'ci',
        '--source-sha', dependency.sha, '--software-version', '1.0.0']));
      child.CITIZENSDK_DEPENDENCY_RECEIPT = prepared.receipt;
    }
    mkdirSync(nativeWork); mkdirSync(nativeOutput);
    if (p.platform === 'windows') {
      for (const key of ['CITIZENSDK_WORK_DIR', 'CITIZENSDK_NATIVE_OUTPUT_DIR', 'CITIZENSDK_DEPENDENCY_RECEIPT',
        'CITIZENSDK_FLUTTER_ROOT', 'PUB_CACHE']) if (child[key]) {
        child[key] = execFileSync('cygpath', ['-u', child[key]], { encoding: 'utf8' }).trim();
      }
    }
    execFileSync('bash', [join(sdk, 'scripts/build-native.sh'), target], { env: child, stdio: ['ignore', 2, 2] });
    const result = {};
    if (p.platform === 'ios' || p.platform === 'macos') {
      const framework = join(nativeOutput, 'apple/CitizenSDK.xcframework');
      directory(framework, 'SDK Apple框架');
      symlinkSync(framework, join(view, 'darwin/CitizenSDK.xcframework'), 'dir');
    } else if (p.platform === 'android') {
      const core = join(nativeOutput, 'android/arm64-v8a');
      for (const name of ['libcitizensdk.so', 'libcitizensdk_jni.so']) {
        const info = lstatSync(join(core, name), { throwIfNoEntry: false });
        if (!info?.isFile() || info.isSymbolicLink() || !info.size) fail('SDK Android双库缺失');
      }
      Object.assign(result, { CITIZENSDK_ANDROID_CORE_DIR: core,
        CITIZENSDK_ANDROID_BUILD_DIR: join(stage, 'gradle'), CITIZENSDK_SOURCE_DIR: view });
    } else {
      const installed = join(nativeOutput, p.platform === 'windows' ? 'Windows' : 'linux/' + target);
      if (p.platform === 'windows') api.assertWindowsNativeArtifact(sdk, installed);
      const destination = join(view, p.platform === 'windows' ? 'windows' : 'linux');
      const install = (from, to) => {
        mkdirSync(to, { recursive: true });
        directory(to, 'SDK安装目标');
        for (const name of readdirSync(from).sort()) {
          const input = join(from, name), output = join(to, name), info = lstatSync(input);
          if (info.isDirectory() && !info.isSymbolicLink()) install(input, output);
          else if (info.isFile() && !info.isSymbolicLink()) {
            const present = lstatSync(output, { throwIfNoEntry: false });
            if (present) {
              if ((!present.isFile() && !present.isSymbolicLink())
                || !readFileSync(output).equals(readFileSync(input))) fail('SDK安装件与源码头冲突');
              rmSync(output);
            }
            copyFileSync(input, output, 1);
          } else fail('SDK安装来源包含链接或特殊文件');
        }
      };
      install(installed, destination);
    }
    verifyProject(p);
    return result;
  } catch (error) {
    // SDK依赖策略未安全释放时保留本轮目录，让外层准确失败而不删除仍占用资源。
    if (error.retainSdkStage || error.status === 75) { error.retainSdkStage = true; throw error; }
    const current = lstatSync(stage, { throwIfNoEntry: false });
    if (current?.isDirectory() && !current.isSymbolicLink()
      && current.dev === owned.dev && current.ino === owned.ino) rmSync(stage, { recursive: true });
    throw error;
  }
}

async function runProjectCLI(values){
 try{
  const [command,...argv]=values,args={},keys={'--source-root':'source','--work-root':'work','--output':'output','--platform':'platform'};
  for(let i=0;i<argv.length;i+=2){const key=keys[argv[i]];if(!key||args[key]||!argv[i+1])fail('参数未知、重复或缺值');args[key]=argv[i+1];}
  const value=command==='native'?JSON.stringify(await prepareNativeProject(args))
   :command==='dependencies'?JSON.stringify(resolveFirstPartyDependencies(args.source,args.work))
   :command==='create'?await createProject(args):command==='verify'?verifyProject(args)
   :fail('工程命令只允许create/verify/dependencies/native');
  process.stdout.write(value+'\n');
 }catch(error){process.stderr.write(error.message+'\n');process.exitCode=error.retainSdkStage||error.status===75?75:1;}
}

return {sourceGitEnvironment,resolveFirstPartyDependencies,platformEntries,createProject,verifyProject,prepareNativeProject,runProjectCLI};
})();
const direct=process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url);
const testing=direct&&Boolean(process.env.NODE_TEST_CONTEXT)&&process.argv.length===2;
if(direct&&!testing){
  try{const [command,...args]=process.argv.slice(2);
    if(command==='project')await projectInternals.runProjectCLI(args);else if(command==='prepare')await prepare();else if(command==='job')job();else if(command==='step')step(args[0]);
    else if(command==='action')action(args[0],args.slice(1));else if(command==='collect')await collect(args);
    else if(command==='collect-produced')await collectProduced();else if(command==='publish')await publish(args[0]);else if(command==='finish')await finish();
    else if(!await productCommand(command,args))fail('自动化命令无效');
  }catch(error){console.error(error.message);process.exitCode=1;}
}

if(testing){
  const {default:assert}=await import('node:assert/strict');const {default:test}=await import('node:test');

  test('旧入口不能成为任一现行平台的清理归属证明',()=>{
    const current={id:9,path:workflowPath,head_branch:'main',event:'workflow_dispatch',created_at:'2026-01-02T00:00:00Z'};
    const old={...current,id:1,status:'completed',conclusion:'success',created_at:'2026-01-01T00:00:00Z'};
    for(const path of ['.github/workflows/release.yml',`.github/workflows/${owner.product}-${owner.platform}-ci.yml`,'.github/workflows/deleted.yml'])
      assert.deepEqual(cleanupPlan([{...old,path}],current,'success'),[]);
  });
  test('撤销当前产物失败仍处理旧失败且最终失败',async()=>{
    const current={id:9,path:workflowPath,head_branch:'main',event:'workflow_dispatch',created_at:'2026-01-02T00:00:00Z'};
    let releases=0,history=0;
    const api=async path=>{
      if(path.startsWith('releases?')){if(++releases===1)throw Error('撤销中断');return [];}
      if(path==='actions/runs/9')return current;
      if(path.startsWith('actions/runs?')){history++;return {workflow_runs:[]};}
      throw Error('未声明请求');
    };
    await assert.rejects(finish({build:{result:'failure'}},api,{run_id:9}),/撤销中断/);
    assert.equal(history,1);assert.equal(releases,2);
  });
  test('清理旧失败Run同时回收其多个Attempt的准确孤立Tag',async()=>{
    const old={id:2,run_attempt:2,path:workflowPath,head_branch:'main',event:'workflow_dispatch',head_sha:'a'.repeat(40),status:'completed',conclusion:'failure',created_at:'2026-01-01T00:00:00Z'},current={...old,id:9,status:'in_progress',created_at:'2026-01-02T00:00:00Z'};
    const deleted=new Set(),tags=[1,2].map(attempt=>({ref:`refs/tags/${prefix}1.0.0-r2-a${attempt}`,object:{type:'commit',sha:old.head_sha}}));
    const api=async(path,options={})=>{
      if(options.method==='DELETE'){deleted.add(path);return {};}
      if(deleted.has(path)||deleted.has(path.replace('git/ref/','git/refs/')))return null;
      if(path.startsWith('actions/runs?'))return {workflow_runs:[old,current]};
      if(path.startsWith('releases?')||path.includes('/artifacts?'))return path.includes('/artifacts?')?{artifacts:[]}:[];
      if(path.startsWith('git/matching-refs/'))return tags;
      if(path==='actions/runs/2')return old;if(path==='actions/runs/9')return current;
      throw Error('未声明的请求');
    };
    assert.deepEqual(await cleanup('failed',{run_id:9},api),[2]);assert.equal([...deleted].filter(path=>path.startsWith('git/refs/')).length,2);
  });
  test('全部前置成功才成功，其余结论一律失败',()=>{
    assert.equal(precedingResult({build:{result:'success'},publish:{result:'success'}}),'success');
    for(const result of ['failure','cancelled','skipped','timed_out',undefined])assert.equal(precedingResult({build:{result}}),'failed');
    assert.throws(()=>precedingResult({}));
  });
  test('当前Run尚在运行也能清理同目标旧结果，保护其它目标和活动任务',()=>{
    const row=(id,conclusion='success',status='completed',path=workflowPath)=>({id,conclusion,status,path,head_branch:'main',event:'workflow_dispatch',created_at:new Date(1700000000000+id*1000).toISOString()});
    const current=row(6,null,'in_progress');const rows=[row(1),row(2,'failure'),row(3,'success','in_progress'),row(4,'success','completed','.github/workflows/release-other.yml'),current,row(7)];
    assert.deepEqual(cleanupPlan(rows,current,'success').map(row=>row.id),[1]);
    assert.deepEqual(cleanupPlan(rows,current,'failed').map(row=>row.id),[2]);
  });
  test('软件版本进位与协议版本边界',()=>{
    assert.equal(nextVersion('1.0.0',['1.99.99']),'2.0.0');assert.equal(nextVersion('9',['9'],true),'10');
    assert.throws(()=>nextVersion(String(0xffffffff),[String(0xffffffff)],true));
  });
  test('历史完整分页不截断超过1000条记录',async()=>{
    const rows=Array.from({length:1005},(_,id)=>({id}));const api=async path=>rows.slice((Number(/page=(\d+)$/u.exec(path)[1])-1)*100,Number(/page=(\d+)$/u.exec(path)[1])*100);
    assert.equal((await pages('releases',null,api)).length,1005);
  });
  test('失败清理只删除所属旧失败产物及Run，成功和活动任务独立保留',async()=>{
    const row=(id,conclusion,status='completed')=>({id,run_attempt:1,conclusion,status,path:workflowPath,head_branch:'main',event:'workflow_dispatch',repository:{full_name:owner.repository},head_sha:'a'.repeat(40),created_at:new Date(1700000000000+id*1000).toISOString()});
    const current=row(10,null,'in_progress'),rows=[row(1,'success'),row(2,'failure'),row(3,null,'in_progress'),current];
    const gone=new Set(),removed=[];
    const api=async(path,options={})=>{
      if(options.method==='DELETE'){removed.push(path);gone.add(path);return {};}
      if(gone.has(path))return null;
      if(path.startsWith('actions/runs?'))return {workflow_runs:rows};
      if(path.startsWith('releases?')||path.startsWith('git/matching-refs/'))return [];
      if(path.startsWith('actions/runs/2/artifacts?'))return {artifacts:[{id:20}]};
      if(path==='actions/artifacts/20')return {id:20};
      const match=/^actions\/runs\/(\d+)$/u.exec(path);if(match)return rows.find(row=>row.id===Number(match[1]))??null;
      throw Error('未声明的模拟接口：'+path);
    };
    assert.deepEqual(await cleanup('failed',{run_id:10},api),[2]);
    assert.deepEqual(removed,['actions/artifacts/20','actions/runs/2']);
  });

  test('GitHub运行序号保证成功历史清理后版本不会回到初始值',()=>{
    assert.equal(nextVersion('1.0.0',[],false,4),'1.0.3');
    assert.equal(nextVersion('1.99.99',[],false,2),'2.0.0');
    assert.equal(nextVersion('1.0.0',['3.0.0'],false,4),'3.0.1');
    assert.throws(()=>nextVersion('1.0.0',[],false,0));
  });

}
