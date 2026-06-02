# SETUP — 외부 의존성 설치 가이드

이 문서는 본 템플릿을 클론한 뒤 **사용자가 직접 실행**해야 하는 외부 의존성 설치 절차를 다룬다.
프로젝트 안에 들어 있는 파일(`.claude/`, `.mcp.json`, `project.godot` 등)은 클론하면 바로 존재하지만,
Godot 본체·Node.js·Godot MCP 서버·GdUnit4·Claude Code 플러그인은 각자 환경에 설치해야 동작한다.

예시 명령은 **macOS 기준**을 우선 표기하고, 다른 OS는 메모로 차이를 덧붙인다.
`res://`는 이 템플릿(프로젝트) 루트를 가리킨다.

## 한눈에 보는 설치 항목

| 항목 | 필수 여부 | 없을 때 영향 |
|------|-----------|--------------|
| Godot 4.4+ | 필수 | 프로젝트를 열거나 실행할 수 없음 |
| Node.js | 필수 | context7 MCP(npx) 동작 불가, Godot MCP 빌드 불가 |
| context7 MCP | 자동(npx) | (자동) Godot 공식 문서 조회 불가 |
| Godot MCP (Coding-Solo/godot-mcp) | 선택(권장) | 에디터 직접 제어·실행·디버그 캡처 불가, context7은 정상 |
| GdUnit4 | 선택(테스트 시 필수) | `/godot-test`·단위 테스트 실행 불가 |
| Claude Code 플러그인 | 선택(권장) | superpowers·game-development 스킬 사용 불가 |
| 서드파티 Godot 스킬 | 선택(미검증) | 영향 없음(옵션) |
| Codex CLI | 선택 | Codex로 작업할 때만 필요(AGENTS.md는 자동, MCP는 `.codex/config.toml`) |

---

## 1. Godot 4.4+ 설치

본 템플릿은 Godot **4.4 이상**을 타깃으로 한다(`project.godot`의 `config/features`가 "4.4").
언어는 **GDScript**이므로 `.NET`(C#) 빌드가 아닌 **표준(Standard) 빌드**를 사용한다.

### 다운로드

- 공식 사이트: https://godotengine.org/download
- "Godot Engine"(Standard) 버전을 받는다. (".NET" 버전은 C# 전용이라 불필요)

### macOS

1. 공식 사이트에서 macOS용 `.zip`을 받아 압축을 푼 뒤 `Godot.app`을 `/Applications`로 옮긴다.
2. 또는 Homebrew 사용:

   ```bash
   brew install --cask godot
   ```

   설치 후 실행 파일 경로는 보통 다음과 같다(뒤에서 `GODOT_PATH`로 사용):

   ```
   /Applications/Godot.app/Contents/MacOS/Godot
   ```

### Windows / Linux 메모

- **Windows**: 공식 사이트에서 `Godot_v4.x-stable_win64.exe`를 받아 임의 폴더에 둔다. 실행 파일 경로 자체가 `GODOT_PATH`가 된다.
- **Linux**: 공식 사이트의 `Godot_v4.x-stable_linux.x86_64`를 받거나 배포판 패키지/Flatpak(`flathub: org.godotengine.Godot`)을 사용한다.

### godot CLI를 PATH에 두기

Godot 실행 파일은 곧 CLI 도구이기도 하다. 터미널에서 `godot`만으로 호출하려면 PATH에 노출한다.

- macOS / Linux (zsh) — `~/.zshrc`에 추가:

  ```bash
  # Godot CLI를 PATH에 노출 (macOS 예시)
  export PATH="/Applications/Godot.app/Contents/MacOS:$PATH"
  # 이름이 'Godot'이므로 소문자 'godot'으로 쓰려면 별칭(alias)을 둔다
  alias godot="/Applications/Godot.app/Contents/MacOS/Godot"
  ```

  적용:

  ```bash
  source ~/.zshrc
  ```

- 확인:

  ```bash
  godot --version
  ```

### 자주 쓰는 CLI 사용법(참고)

context7 공식 문서로 확인한 표준 CLI 옵션이다(본 템플릿의 `/godot-run`·Godot MCP가 내부적으로 이런 형태를 사용).

```bash
# 프로젝트 디렉터리를 지정해 실행 (project.godot가 있는 폴더)
godot --path /path/to/godot-template

# 특정 씬만 실행
godot --path /path/to/godot-template scenes/main.tscn

# 그래픽 출력 없이 실행(CI·테스트·서버 등)
godot --headless --path /path/to/godot-template
```

> 메모: `--headless`는 디스플레이 없이 구동하는 옵션이다. GdUnit4 테스트를 CI에서 돌릴 때 유용하다.

---

## 2. Node.js 설치

Node.js는 두 곳에서 필요하다.

1. **context7 MCP**: `npx`로 자동 실행되므로 npm(=Node.js)이 있어야 한다.
2. **Godot MCP 빌드**: `npm install` / `npm run build`에 필요하다.

### 설치 (macOS)

```bash
# Homebrew
brew install node

# 또는 nvm으로 LTS 설치 (권장: 버전 관리 용이)
# https://github.com/nvm-sh/nvm 설치 후
nvm install --lts
nvm use --lts
```

### Windows / Linux 메모

- **Windows**: 공식 인스톨러 https://nodejs.org (LTS) 사용.
- **Linux**: 배포판 패키지 또는 nvm 사용.

### 확인

```bash
node --version
npm --version
npx --version
```

> 권장: Node.js **LTS**(18 이상). `npx`가 정상 동작해야 context7 MCP가 자동으로 뜬다.

---

## 3. context7 MCP — 자동(npx), 추가 설치 없음

context7은 **별도 설치가 필요 없다.** 본 템플릿 루트의 `.mcp.json`에 이미 선언되어 있고,
`npx -y @upstash/context7-mcp` 형태로 **Claude Code가 자동 실행**한다(최초 1회 패키지 다운로드).

`.mcp.json`의 해당 선언(참조용):

```json
"context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp"] }
```

### 동작 확인

1. 위 **2. Node.js**가 설치되어 `npx`가 동작하는지 확인.
2. 프로젝트를 Claude Code로 연다(프로젝트 루트에서 `claude`).
3. Claude Code 안에서 MCP 서버 목록을 확인한다:

   ```
   /mcp
   ```

   `context7` 서버가 떠 있으면 정상이다.
4. 간단 질의로 확인: Godot 문서 조회를 시키면 context7 도구(`resolve-library-id` → `query-docs`, libraryId `/godotengine/godot-docs`)가 호출된다.

> 메모: 최초 실행 시 `npx`가 패키지를 받느라 수 초~수십 초 걸릴 수 있다. 네트워크가 필요하다.
>
> 메모(레이트리밋): 키 없이도 동작하지만 조회가 잦으면 레이트리밋이 걸릴 수 있다. 빈번히 쓴다면 context7 API 키를 발급해 `.mcp.json`(Claude)·`.codex/config.toml`(Codex)의 `args`에 `--api-key <KEY>`를 추가한다(예: `["-y", "@upstash/context7-mcp", "--api-key", "<KEY>"]`).

---

## 4. Godot MCP (Coding-Solo/godot-mcp) 설치

에디터 직접 제어(노드/씬 조작), 프로젝트 실행, 디버그 출력 캡처를 Claude Code에서 하려면
**Coding-Solo/godot-mcp** 서버를 클론·빌드한 뒤 환경변수 두 개를 설정한다.
이 서버는 **선택**이지만 본 템플릿의 핵심 워크플로(`godot-mcp-workflow` 스킬)에서 사용하므로 권장한다.

### 4-1. 클론 · 빌드

원하는 도구 폴더에서(예: `~/tools`):

```bash
git clone https://github.com/Coding-Solo/godot-mcp
cd godot-mcp
npm install
npm run build
```

빌드가 끝나면 `build/index.js`가 생성된다. **클론한 폴더의 절대경로**를 기억해 둔다(예: `~/tools/godot-mcp`).

### 4-2. 환경변수 설정

`.mcp.json`의 godot 서버 선언은 환경변수 두 개를 그대로 사용한다(참조용):

```json
"godot": {
  "command": "node",
  "args": ["${GODOT_MCP_PATH:-/path/to/godot-mcp}/build/index.js"],
  "env": { "GODOT_PATH": "${GODOT_PATH:-}", "DEBUG": "false" }
}
```

따라서 아래 변수를 셸 프로필에 설정한다(`GODOT_MCP_PATH`는 필수, `GODOT_PATH`는 godot-mcp가 Godot 실행파일을 자동 탐지하면 생략 가능 — 자동 탐지 실패/특정 버전 지정 시에만 설정).

| 변수 | 의미 | 예시(macOS) |
|------|------|-------------|
| `GODOT_MCP_PATH` | 위에서 클론·빌드한 godot-mcp 폴더의 절대경로 (필수) | `$HOME/tools/godot-mcp` |
| `GODOT_PATH` | Godot **실행 파일** 경로 (선택 — 자동 탐지 override) | `/Applications/Godot.app/Contents/MacOS/Godot` |

zsh(`~/.zshrc`) 예시:

```bash
# Godot MCP 서버 (.mcp.json이 ${GODOT_MCP_PATH}/build/index.js를 실행)
export GODOT_MCP_PATH="$HOME/tools/godot-mcp"
# Godot 실행 파일 경로 (macOS 기준)
export GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
```

적용:

```bash
source ~/.zshrc
```

### Windows / Linux 메모

- `GODOT_PATH`는 OS별 실제 실행 파일 경로로 바꾼다.
  - Windows 예: `C:\tools\godot\Godot_v4.x-stable_win64.exe`
  - Linux 예: `/opt/godot/Godot_v4.x-stable_linux.x86_64`
- 환경변수는 해당 OS 방식대로 설정한다(Windows는 시스템 환경변수 또는 PowerShell `$Env:`).

### 동작 확인

1. `node --version`으로 Node.js가 동작하는지 확인(위 **2.** 참고).
2. 새 터미널을 열어 두 변수가 비어 있지 않은지 확인:

   ```bash
   echo "$GODOT_MCP_PATH"
   echo "$GODOT_PATH"
   ls "$GODOT_MCP_PATH/build/index.js"   # 파일이 존재해야 함
   ```

3. 프로젝트를 Claude Code로 열고 `/mcp`로 `godot` 서버가 떠 있는지 확인.

> 메모: `.mcp.json`은 `${GODOT_MCP_PATH:-…}`·`${GODOT_PATH:-}` 형태의 **기본값**을 써서, 변수가 미설정이어도 설정 파싱이 깨지지 않는다. 따라서 두 변수가 미설정/오경로면 **godot 서버만 비활성**될 뿐 context7은 **항상** 정상 동작한다(전체 MCP 설정이 함께 무력화되지 않음).

---

## 5. GdUnit4 설치 (테스트 프레임워크)

본 템플릿의 단위 테스트(`test/unit/iso_utils_test.gd`)와 `/godot-test` 명령은 **GdUnit4** 애드온을 사용한다.
GdUnit4가 없으면 테스트 스위트(`extends GdUnitTestSuite`)를 해석할 수 없으므로 테스트 시 설치가 필요하다.

설치 방법은 두 가지다. 둘 중 하나만 하면 된다.

### 방법 A — Godot AssetLib (권장, 가장 간단)

1. Godot 에디터로 본 프로젝트를 연다.
2. 상단 **AssetLib** 탭으로 이동.
3. **gdUnit4**를 검색해 설치(다운로드 → Install). 이때 `addons/gdUnit4` 경로로 배치된다.

### 방법 B — git clone 후 수동 배치

```bash
# gdUnit4는 godot-gdunit-labs 조직으로 이전됨(구 MikeSchulze/gdUnit4)
git clone https://github.com/godot-gdunit-labs/gdUnit4
```

클론한 저장소 안의 `addons/gdUnit4` 폴더를 본 템플릿의 `addons/gdUnit4`(즉 `res://addons/gdUnit4`)로 복사한다.
(저장소 구조상 애드온은 `addons/gdUnit4` 하위에 위치한다. 이 폴더만 프로젝트로 옮기면 된다.)

### 공통 — 에디터에서 플러그인 활성화

1. Godot 에디터: **Project → Project Settings → Plugins**.
2. 목록에서 **gdUnit4**를 찾아 **Enable** 체크.
3. 활성화 후 에디터를 다시 열거나 안내에 따라 재시작한다.

### 동작 확인

- 에디터 하단/사이드에 GdUnit4 패널이 보이면 정상.
- 또는 Claude Code에서 `/godot-test`를 실행해 `test/unit/iso_utils_test.gd`가 통과하는지 확인한다.

> 메모: 이 템플릿의 `.gitignore`(공식 4.1+ 기준)는 `addons/`도 `export_presets.cfg`도 무시하지 않는다 — GdUnit4 애드온과 익스포트 프리셋을 커밋해 함께 배포해도 된다. 무시 대상은 `.godot/` 캐시·`*.translation`·`/tools/`·`.claude/worktrees/` 등이며, 비밀정보는 `.godot/export_credentials.cfg`에 분리되어(=`.godot/` 무시로) 자동 보호된다. 반대로 애드온을 리포에서 빼고 환경마다 직접 설치하려면 각자 `.gitignore`에 `addons/gdUnit4/`를 추가한 뒤 위 절차로 설치하면 된다.

---

## 6. Claude Code 플러그인 설치

본 템플릿은 `.claude/settings.json`에 사용할 플러그인과 마켓플레이스를 **프로젝트 스코프**로 선언해 둔다.
따라서 **프로젝트를 Claude Code로 열면** 다음 플러그인 설치를 묻는 프롬프트가 뜬다(승인하면 설치).

- `superpowers` — 브레인스토밍·TDD·체계적 디버깅 등 워크플로 스킬
- `commit-commands` — 커밋 보조 명령
- `game-development` (마켓플레이스 `claude-code-workflows`, 리포 `wshobson/agents`; Unity/Minecraft 중심 멀티엔진 플러그인 — 본 템플릿은 그중 `godot-gdscript-patterns` 스킬만 사용) — GDScript 시그널·씬·FSM·최적화 패턴 제공

> context7은 플러그인이 아니라 `.mcp.json`(위 **3.**)으로 관리한다. 중복 설치하지 않는다.

### 수동 설치 (프롬프트가 안 뜨거나 직접 추가할 때)

```
/plugin marketplace add wshobson/agents
```

이후 `/plugin`(플러그인 관리 UI)에서 **game-development**을 활성화한다.
`superpowers`·`commit-commands`도 같은 `/plugin` UI에서 설치·활성화할 수 있다.

### 동작 확인

- `/plugin`으로 설치 목록에서 위 세 플러그인이 활성화되어 있는지 확인.
- 스킬 호출이 되는지 확인(예: 기획 단계에서 `superpowers:brainstorming`).

---

## 7. (선택) 서드파티 Godot 스킬 — 미검증, 옵션

아래 마켓플레이스는 **본 템플릿에서 검증하지 않은 서드파티**다. 필요에 따라 옵션으로만 추가한다.
설치하지 않아도 템플릿의 기본 기능에는 영향이 없다.

- GdUnit4 + PlayGodot 기반 E2E 관련:

  ```
  /plugin marketplace add Randroids-Dojo/Godot-Claude-Skills
  ```

- 추가 Godot 스킬 모음:

  ```
  /plugin marketplace add alexmeckes/godot-claude-skills
  ```

> 주의: 위 두 항목은 **미검증(옵션)**이다. 동작·호환을 보장하지 않으며, 사용 전 각 저장소의 README를 직접 확인할 것.

---

## 8. Codex CLI에서 사용하기 (멀티 에이전트)

이 템플릿은 Claude Code와 **OpenAI Codex CLI**에서 같은 규칙·지식·MCP로 동작하도록 구성돼 있다.
도구별로 읽는 파일이 다를 뿐, 진실 원천은 공용이다.

| 계층 | 공용 정본 | Claude Code | Codex CLI |
|------|-----------|-------------|-----------|
| 작업 지침 | `AGENTS.md` | `.claude/CLAUDE.md`(→ `@../AGENTS.md` import) | `AGENTS.md` 자동 로드(루트→CWD 계층) |
| 지식·규약 | `docs/` | 〃 | 〃 |
| MCP 서버 | — | `.mcp.json` | `.codex/config.toml` |

### 8-1. 작업 지침 — 추가 설정 불필요

Codex는 리포 루트의 `AGENTS.md`를 자동으로 읽는다(현재 작업 위치에서 루트까지의 `AGENTS.md`를 계층적으로 병합, 깊은 파일이 우선). 별도 설정 없이 규약·라우팅·워크플로 절차가 적용된다.
(참고: Codex의 `AGENTS.md` 본문 한도는 약 32 KiB `project_doc_max_bytes`. 개인용 덮어쓰기는 `AGENTS.override.md`.)

### 8-2. MCP 서버 — `.codex/config.toml`

이 리포에는 Codex용 `.codex/config.toml`이 포함돼 있다(`.mcp.json`과 동등한 `context7` + `godot` 서버 정의).

- Codex 설정 우선순위(요지): **CLI 플래그(`--config`)가 최우선이고, 프로젝트 `.codex/config.toml`이 개인 `~/.codex/config.toml`보다 우선**한다(그 외 system/admin 관리 레이어가 더 상위로 병합될 수 있음).
- 신뢰된(trusted) 리포에서 프로젝트 `.codex/config.toml`이 로드된다. 처음 이 리포에서 Codex를 실행하면 신뢰 여부를 묻는데, 신뢰로 설정한다.
- `godot` 서버는 **절대경로 수정이 필요**하다. `.codex/config.toml`을 열어 다음을 환경에 맞게 바꾼다(TOML은 환경변수를 자동 확장하지 않음):
  - `args = ["…/godot-mcp/build/index.js"]` → 4절에서 빌드한 실제 경로
  - `[mcp_servers.godot.env]`의 `GODOT_PATH` → Godot 실행파일 절대경로
- 프로젝트 config가 로드되지 않는 버전이라면 같은 내용을 `~/.codex/config.toml`에 넣는다.
- `context7`는 수정 없이 동작한다(Node.js만 필요).

### 8-3. 스킬·서브에이전트는 어떻게 공유되나

- **스킬은 공용**이다: 모든 스킬(`SKILL.md`)은 최상위 `skills/`에 있고, `.claude/skills`·`.codex/skills`·`.agents/skills`가 각각 그곳을 가리키는 **심볼릭 링크**다. 같은 `SKILL.md`(동일 포맷)라 도구 간 공유된다. 단 도구·버전마다 스킬 자동 탐지 경로가 다를 수 있어, 자동 인식이 안 되더라도 **`AGENTS.md`+`docs/`가 동일 지식을 보장**한다(항상 동작하는 안전망). 워크플로 스킬(`godot-run`·`godot-test`·`new-iso-scene`·`iso-debug`)은 슬래시커맨드 겸용이다. (예전 `.claude/commands/`는 스킬로 통합됨.)
- **서브에이전트(`.claude/agents/godot-specialist.md`)만 Claude 전용**이다(격리된 컨텍스트·도구 제한이라 스킬로 환원되지 않음). 같은 역할이 필요하면 Codex는 `config.toml [agents]`로 둘 수 있다. 어차피 그 지식은 `AGENTS.md`·`docs/`·공용 스킬에도 있어 Codex가 동등하게 따른다.

> ⚠️ **심볼릭 링크 주의**: `.claude/skills`·`.codex/skills`·`.agents/skills`는 `../skills`를 가리키는 git 심볼릭 링크(mode 120000)다.
> - macOS/Linux + git 기본 설정에서는 클론 시 그대로 복원된다.
> - **Windows**나 `git config core.symlinks false` 환경에서는 링크가 일반 텍스트 파일로 체크아웃될 수 있다. 그럴 땐 `git config core.symlinks true` 후 재클론하거나, 링크를 지우고 `skills/`를 `.claude/skills`·`.codex/skills`·`.agents/skills`로 **복사**한다.
> - 어떤 도구가 심볼릭을 안 따르면, 그 도구의 스킬 경로에 `skills/` 내용을 직접 두면 된다(단일 소스는 `skills/`).
> - Codex의 프로젝트 스킬 자동 탐지 경로는 버전에 따라 다르다(`.codex/skills` 또는 `.agents/skills` — 그래서 둘 다 심볼릭으로 둠). 그래도 인식이 안 되면 `~/.codex/skills/`로 복사하거나 Codex 문서를 확인한다. 어떤 경우든 `AGENTS.md`는 자동 로드되어 규약·워크플로 절차는 그대로 적용된다.

---

## 9. 동작 확인 체크리스트

설치를 마쳤다면 아래를 순서대로 점검한다.

- [ ] `godot --version` 이 4.4 이상을 출력한다. (1절)
- [ ] `node --version` / `npm --version` / `npx --version` 이 정상 출력된다. (2절)
- [ ] 프로젝트 루트에서 `godot --path .` 로 프로젝트가 열린다(또는 에디터로 정상 오픈). (1절)
- [ ] Claude Code에서 `/mcp` 실행 시 `context7` 서버가 떠 있다. (3절)
- [ ] (Godot MCP 사용 시) `echo "$GODOT_MCP_PATH"`·`echo "$GODOT_PATH"` 가 올바른 경로를 출력하고, `$GODOT_MCP_PATH/build/index.js` 파일이 존재한다. (4절)
- [ ] (Godot MCP 사용 시) `/mcp` 에 `godot` 서버가 떠 있다. (4절)
- [ ] (테스트 사용 시) `res://addons/gdUnit4` 가 존재하고 Plugins에서 gdUnit4가 Enable 상태다. (5절)
- [ ] (테스트 사용 시) `/godot-test` 로 `test/unit/iso_utils_test.gd` 가 통과한다. (5절)
- [ ] `/plugin` 에 `superpowers`·`commit-commands`·`game-development` 이 활성화되어 있다. (6절)
- [ ] (Codex 사용 시) Codex가 `AGENTS.md`를 인식하고, `.codex/config.toml`의 `godot` 경로를 환경에 맞게 수정했다. (8절)

> 모든 외부 의존성은 **사용자 환경에 직접 설치**해야 하며, 미설치 시 해당 기능만 비활성화될 뿐 나머지는 정상 동작한다.
