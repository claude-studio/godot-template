# AGENTS.md — Godot 아이소메트릭 2D 템플릿 작업 지침

이 문서는 **모든 AI 코딩 에이전트가 공유하는 정본(canonical) 작업 지침**이다. 특정 도구에 묶이지 않는다.
불확실하면 추측하지 말고 아래 도구(context7)로 확인한다. 직접 받은 사용자 지시가 이 문서보다 우선한다.

## 도구별 진입점 (어떻게 이 지침이 공유되는가)

- **Codex CLI**: 이 `AGENTS.md`를 리포 루트에서 자동으로 읽는다(작업 파일이 속한 더 깊은 디렉토리의 `AGENTS.md`가 우선). MCP 서버는 `.codex/config.toml`(신뢰된 리포) 또는 `~/.codex/config.toml`에서 읽는다.
- **Claude Code**: `.claude/CLAUDE.md`가 이 파일을 `@../AGENTS.md`로 import한다. 추가로 `.claude/`의 스킬·슬래시커맨드·서브에이전트·플러그인 설정을 사용한다(Claude 전용).
- **공통 지식**: `docs/`(SETUP·ARCHITECTURE·GODOT_CONVENTIONS·COMMIT_CONVENTIONS)가 **도구 무관 정본 지식**이다. 어떤 에이전트든 이 문서들을 읽고 따른다.
- **스킬도 공용**이다: 모든 스킬(`SKILL.md`)은 최상위 **`skills/`** 에 있고, `.claude/skills`·`.codex/skills`·`.agents/skills`가 각각 그곳을 가리키는 **심볼릭 링크**다(같은 `SKILL.md` 포맷이라 도구 간 공유). 단 각 도구·버전의 스킬 자동 탐지 경로가 다를 수 있으므로, 자동 인식이 안 되면 `AGENTS.md`+`docs/`가 동일 지식을 보장한다. 워크플로 스킬(`godot-run`·`godot-test`·`new-iso-scene`·`iso-debug`)은 Claude에서 `/이름` 슬래시커맨드로도 호출된다.
- **서브에이전트(`.claude/agents/`)만 Claude 전용** 메커니즘이다(격리된 위임). 그 지식은 `AGENTS.md`·`docs/`·공용 스킬에도 반영돼 있어 Codex는 동등하게 따를 수 있고, 필요하면 Codex의 `config.toml [agents]`로 대응한다.

## 프로젝트 개요

- **유형**: 아이소메트릭 2D 게임 템플릿
- **엔진**: Godot **4.4+** (`config/features`는 "4.4" — 상위 호환), 렌더러는 **GL Compatibility**
- **언어**: **GDScript** (C# 아님)
- **렌더링**: 픽셀아트 친화 — `default_texture_filter=0`(nearest)
- **테스트**: **GdUnit4** (`addons/gdUnit4`)
- **Godot MCP**: Coding-Solo/godot-mcp (에디터 실행·프로젝트 구동·디버그 출력 캡처)
- **목표**: 빈 리포를 클론하면 **글로벌 설정 없이 프로젝트 레벨만으로** 여러 AI 에이전트(Claude Code·Codex 등)에서 즉시 동작
- `res://` 는 이 리포 루트를 가리킨다.

## 디렉토리 구조

```
AGENTS.md           # (이 문서) 도구 무관 정본 지침 — Codex 등이 직접 읽음
skills/             # 공용 스킬(SKILL.md) — 모든 에이전트 공유, 워크플로 스킬은 슬래시커맨드 겸용
  godot-isometric/ · godot-mcp-workflow/ · gdunit4-testing/ · godot-project-conventions/   # 지식 스킬
  godot-run/ · godot-test/ · new-iso-scene/ · iso-debug/                                   # 워크플로(커맨드) 스킬
.claude/            # Claude Code 전용 연동
  CLAUDE.md         #   @../AGENTS.md import + Claude 전용 설정
  settings.json     #   프로젝트 스코프 플러그인/마켓플레이스/권한
  agents/           #   godot-specialist.md (서브에이전트 — Claude 전용 메커니즘)
  skills/           #   → ../skills 심볼릭 링크
.codex/             # Codex CLI 설정
  config.toml       #   MCP 서버 정의(.mcp.json과 동등)
  skills/           #   → ../skills 심볼릭 링크
.agents/            # 에이전트 공용(도구·버전별 스킬 탐지 경로 커버)
  skills/           #   → ../skills 심볼릭 링크
.mcp.json           # Claude Code용 MCP 서버 정의(context7 + godot)
.github/            # AI 작업용 템플릿
  pull_request_template.md  #   PR 템플릿
  ISSUE_TEMPLATE/   #   이슈 템플릿(버그·설정 변경/오류·기능·문서) + config.yml(라우팅)
project.godot       # autoload·input·rendering 설정
icon.svg            # 아이소 다이아몬드 아이콘
README.md           # 템플릿 사용 안내
docs/               # 공용 지식(도구 무관)
  SETUP.md          #   설치(Godot·MCP·플러그인·GdUnit4)
  ARCHITECTURE.md   #   구조·데이터 흐름·시그널 규약
  GODOT_CONVENTIONS.md  # Godot 공식 컨벤션(context7 검증)
  COMMIT_CONVENTIONS.md # 커밋 메시지 규칙
src/
  autoload/         # event_bus.gd(EventBus), game_state.gd(GameState)
  systems/          # iso_utils.gd(IsoUtils), state_machine.gd(StateMachine)
  entities/player/  # player.gd(Player), player.tscn
scenes/             # main.tscn(run/main_scene), main.gd
assets/             # 아트·오디오 등 리소스(.gitkeep)
test/unit/          # GdUnit4 테스트(iso_utils_test.gd)
```

규칙:
- 자동 로드 싱글톤은 `src/autoload/`, 재사용 시스템은 `src/systems/`, 게임 객체는 `src/entities/<이름>/`.
- 씬과 그 스크립트는 같은 폴더에 같은 이름으로 둔다(`player.tscn` ↔ `player.gd`).
- 아트/오디오 등 리소스는 `assets/`.

## 작업 지식 · 스킬 라우팅

작업 성격에 따라 아래 표대로 **먼저** 지식/도구를 선택한다. 코드를 건드리기 전에 해당 지식을 확인한다.
"공통" 항목은 모든 에이전트가, "Claude" 항목은 Claude Code에서 추가로 쓸 수 있는 래퍼다.

| 상황 | 공통 지식 / 도구 | 도구별 래퍼·플러그인 |
|------|------------------|----------------------|
| 기획 초기, 요구사항 모호 | 무엇을 만들지 먼저 구체화 | `superpowers:brainstorming` |
| 버그(특히 Y-sort·좌표 변환) | 체계적 디버깅 + 아래 "아이소 디버깅 절차" + `docs/GODOT_CONVENTIONS.md` | `superpowers:systematic-debugging`, `/iso-debug` |
| 전투·인벤토리 등 로직 검증 | 테스트 우선(TDD) + GdUnit4 (`docs/SETUP.md`) | `superpowers:test-driven-development`, `gdunit4-testing` 스킬 |
| Godot 최신 API 확인 | **context7 MCP** (`resolve-library-id` → `query-docs`, libraryId `/godotengine/godot-docs`) | (동일) |
| 에디터 직접 조작(노드/씬/실행/디버그) | **godot MCP** (`.codex/config.toml` 또는 `.mcp.json`) | `godot-mcp-workflow` 스킬 |
| GDScript 패턴·공식 컨벤션 | `docs/GODOT_CONVENTIONS.md` | `godot-gdscript-patterns` 스킬 |
| 아이소 좌표·Y-sort·TileMapLayer | `docs/GODOT_CONVENTIONS.md` + 아래 "핵심 규약" | `godot-isometric` 스킬 |
| 구조·네이밍 규약 | 이 문서 + `docs/GODOT_CONVENTIONS.md` | `godot-project-conventions` 스킬 |

> 위 표의 `godot-isometric`·`godot-mcp-workflow`·`gdunit4-testing`·`godot-project-conventions`·`godot-run`·`godot-test`·`new-iso-scene`·`iso-debug` 스킬은 `skills/`에 있어 **Claude·Codex 공용**이다. 반면 `superpowers:*`·`godot-gdscript-patterns`는 **Claude 플러그인**, `godot-specialist`는 **Claude 서브에이전트**다(다른 도구는 동일 지식을 이 문서·`docs/`·공용 스킬로 따른다).

판단 우선순위:
1. API 사실이 필요하면 **context7**부터 (추측 금지).
2. 에디터/씬/실행 조작은 **godot MCP**로 (수동 안내 대신 직접).
3. 로직을 새로 짜면 **TDD + GdUnit4**로 먼저 테스트를 세운다.

## 핵심 규약

> **Godot 공식 컨벤션**(GDScript 스타일 가이드·정적 타이핑·포매팅·아키텍처 베스트 프랙티스)은
> `docs/GODOT_CONVENTIONS.md` 에 context7(`/godotengine/godot-docs`) 검증과 함께 정리되어 있다.
> 코드 작성·리뷰 시 그 문서를 기준으로 삼는다. 아래는 이 템플릿에서 특히 강조하는 항목이다.
>
> 공식 가이드 필수 항목 요약:
> - **멤버 순서**: `@tool`→`class_name`→`extends`→`##주석`→signal→enum→const→static→`@export`→var→`@onready`→메서드(`_init`→`_enter_tree`→`_ready`→`_process`→`_physics_process`).
> - **`get_node()`는 타입 명시**(추론 시 `Node`로 떨어짐). 모호하면 명시, 중복이면 `:=`, 반환은 항상 `->`.
> - 함수 사이 빈 줄 2·내부 1, 연산자/콤마 뒤 공백 1, 불필요한 괄호 생략, 불리언은 `and`/`or`/`not`.
> - 결합은 "아래로 호출, 위로 시그널". autoload는 절제(`EventBus`/`GameState`만).

### 네이밍
- 파일·디렉토리: `snake_case` (예: `iso_utils.gd`, `state_machine.gd`).
- 클래스(`class_name`): `PascalCase` (예: `IsoUtils`, `StateMachine`, `Player`).
- 노드 이름: `PascalCase` (예: `World`, `GroundLayer`, `ObjectLayer`, `Player`).
- private 멤버/메서드: `_` 프리픽스 (예: `_current_state`, `_update(delta)`).
- 시그널: `snake_case` 과거형·명사형 (예: `player_spawned`, `state_changed`, `tile_clicked`).
- 상수: `CONSTANT_CASE`.

### Autoload (싱글톤)
- **EventBus** (`src/autoload/event_bus.gd`): 전역 시그널 허브. 노드 간 직접 참조 대신 시그널로 느슨하게 결합한다. 예: `EventBus.player_spawned.emit(self)`. `class_name`을 두지 않는다(autoload 이름 `EventBus`로 전역 접근).
- **GameState** (`src/autoload/game_state.gd`): 점수·일시정지 등 전역 상태. 상태 변경은 GameState 메서드를 통해서만 하고, 부수효과(예: 일시정지)는 EventBus 시그널로 알린다.
- 새 전역 시그널은 **EventBus 에만** 추가한다. 임의의 노드에 전역 상태를 두지 않는다.

### 정적 타이핑
- 모든 변수·인자·반환에 **타입을 명시**한다. 추론 대입은 `:=` 사용. (세부 규칙은 `docs/GODOT_CONVENTIONS.md`.)
- `@export`, `@onready`, `signal`의 관용을 따른다. 들여쓰기는 **탭**. 주석은 한국어로 간결하게.

### 아이소메트릭 좌표·Y-sort (함정 주의)
- **런타임 셀↔픽셀 변환**은 `TileMapLayer.local_to_map()` / `map_to_local()`를 **우선** 사용한다. 순수 계산이 필요할 때만 `IsoUtils`의 static 메서드를 쓴다.
- 전역 좌표를 다룰 땐 `Node2D.to_local(global_pos)`로 먼저 로컬화한 뒤 `local_to_map`을 호출한다. (전역 좌표를 바로 넘기면 어긋난다 — 흔한 함정.)
- Y-sort는 CanvasItem의 `y_sort_enabled = true`일 때만 동작한다.
  - 움직이는 캐릭터(Player)와 정렬 대상 오브젝트는 **같은 Y-sort 부모**(`y_sort_enabled=true`) 아래 둔다.
  - 바닥(Ground) 레이어는 보통 Y-sort를 **끄고**, 오브젝트 레이어는 **켠다**.
  - Y-sort 레이어와 비-Y-sort 레이어는 **서로 다른 `z_index`**를 둔다. 안 그러면 레이어가 한 덩어리로 섞여 정렬된다.
  - TileMapLayer는 `y_sort_origin`(픽셀)으로 타일별 정렬 기준점을 오프셋한다.
- **TileMap 노드는 deprecated** (4.3+). 항상 개별 **`TileMapLayer`** 노드를 쓴다.
- 아이소 TileSet은 Tile Shape를 **Isometric**으로 설정한다.

### FSM
- 상태 기계는 `StateMachine`(노드 기반). 자식 노드를 상태로 쓰고 `_enter(msg: Dictionary)/_exit()/_update(delta)/_physics_update(delta)`를 덕 타이핑(`has_method`)으로 호출한다(전이 시 `transition_to(name, msg)`의 `msg`가 `_enter`로 전달됨). 별도 State 베이스 클래스는 두지 않는다(단순성 우선).

## 도구 사용 원칙

- **Godot API는 추측하지 않는다.** 시그니처·속성·동작이 조금이라도 불확실하면 context7로 `/godotengine/godot-docs`를 질의해 확인한 뒤 코드를 쓴다.
- **에디터 조작은 godot MCP로** 직접 한다(씬 열기·노드 추가·프로젝트 실행·디버그 출력 캡처). 수동 클릭을 시키기 전에 MCP 가능 여부를 먼저 본다. godot MCP는 **경로 설정이 끝나야** 동작한다 — Claude Code는 `.mcp.json`의 `${GODOT_MCP_PATH}`/`${GODOT_PATH}` 환경변수로, Codex는 `.codex/config.toml`의 `args` 절대경로와 `[mcp_servers.godot.env]`의 `GODOT_PATH`를 직접 수정한다(TOML은 환경변수를 자동 확장하지 않으므로 `GODOT_MCP_PATH`를 쓰지 않고 경로를 직접 적는다). 미설정 시 context7만 동작한다.
- **테스트는 GdUnit4로** 작성·실행한다(`addons/gdUnit4` 설치 필요). 로직 추가 시 TDD 루프를 따른다. 단, 클린 클론에는 GdUnit4 애드온이 포함되어 있지 않으므로 `addons/gdUnit4`가 없으면 `/godot-test` 실패를 코드 실패로 단정하지 말고 “GdUnit4 미설치로 unit test 미실행”이라고 기록한다.
- 외부 의존성(`npm`, `git clone`, 플러그인 설치)은 **사용자가 직접 실행**한다. 설치 절차는 `docs/SETUP.md`를 참조·안내한다. 코드가 깨지면 임의 우회 대신 설치 누락부터 의심한다.

## 워크플로 절차 (도구 무관)

아래 절차는 Claude Code에선 슬래시 커맨드로 제공되고, Codex 등 다른 에이전트는 같은 단계를 직접 수행한다.

- **실행(run)** — godot MCP가 있으면 그것으로 프로젝트/씬을 실행하고 디버그 출력을 캡처한다. 없으면 `godot --path .` (특정 씬은 상대경로 positional `godot --path . scenes/main.tscn` — `res://`/UID용 `--scene` 플래그는 Godot 4.5+ 전용이라 4.4 타깃에선 미사용). `SCRIPT ERROR`/`Parse error`/`ext_resource not found`를 확인한다. *(Claude: `/godot-run`)*
- **테스트(test)** — `addons/gdUnit4` 설치 전제. GdUnit4 CLI 러너로 `test/`를 실행하고 실패 시 체계적 디버깅으로 좁힌다. 애드온이 없으면 설치 누락으로 분류하고 멈춘다. 코드/씬 변경 검증은 별도로 `godot --headless --path . --quit-after 10` smoke test를 실행해 parse/import/runtime 시작 오류를 확인한다. *(Claude: `/godot-test`)*
- **새 아이소 씬** — `World`(`y_sort_enabled=true`) · `GroundLayer`(비 Y-sort, `z_index=-1`) · `ObjectLayer`(`y_sort_enabled=true`, `z_index=0`) · `Camera2D` 구조로 스캐폴딩하고, 엔티티는 World 아래에 둔다(z_index 기본 0을 유지해 ObjectLayer와 같은 정렬 그룹에 포함 — Godot은 같은 z_index끼리만 Y-sort). *(Claude: `/new-iso-scene`)*
- **아이소 디버깅(iso-debug)** — Y-sort 어긋남/클릭 좌표 불일치 등은 ① 좌표 변환이 `local_to_map(to_local(...))`인지 ② Y-sort 부모/`z_index` 분리 ③ `y_sort_origin` 순으로 점검하고, API는 context7로 확인한다. *(Claude: `/iso-debug`)*

각 절차는 `skills/<이름>/SKILL.md`(`godot-run`·`godot-test`·`new-iso-scene`·`iso-debug`)에 스킬로 구현돼 있다 — Claude·Codex 공용이며 Claude에선 `/이름`으로도 호출한다.

## 제약

- **커밋 메시지에 AI attribution(`Co-Authored-By` 등)을 넣지 않는다.** 형식·type·scope·예시는 `docs/COMMIT_CONVENTIONS.md`를 따른다 (`<type>(<scope>): <제목>`, 제목 50자 이내, 본문 bullet 5~7개, 코드 리뷰에서 보이는 내용은 제외).
- **변경 전 검증**: 코드/씬을 바꾸면 실행/테스트로 확인한 뒤 완료로 보고한다. 검증 없이 "완료"라고 하지 않는다. PR은 `.github/pull_request_template.md`를 따른다.
- **파일 경로·이름·시그니처·노드 트리**는 이 문서·`docs/`의 정의를 그대로 따른다. 임의 변경 금지.
- 모든 문서·주석·README는 **한국어**. 코드 식별자·키워드는 원문 유지. 과장 없이 정확하게.
