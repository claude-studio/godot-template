# Godot 아이소메트릭 2D 템플릿

여러 AI 코딩 에이전트(**Claude Code · Codex** 등) 연동 Godot 아이소메트릭 2D 게임 템플릿. 빈 리포를 클론하면 글로벌 설정 없이 프로젝트 레벨만으로 아이소메트릭 2D(GDScript) 개발 환경과 AI 에이전트 연동이 동작한다.

- 게임 유형: 아이소메트릭 2D
- 언어: GDScript
- Godot 타깃 버전: 4.4+
- 렌더러: GL Compatibility (픽셀아트·광범위 호환, `default_texture_filter=0` nearest)
- AI 에이전트: 도구 무관 정본 지침 `AGENTS.md` + 공용 `docs/` (Claude Code는 `.claude/`, Codex는 `.codex/`로 같은 내용을 읽음)

## 무엇이 들어있나

- 아이소 스캐폴드: 좌표 변환 헬퍼 `IsoUtils`(static 메서드), Y-sort 기반 데모 씬(`scenes/main.tscn`), 노드 기반 FSM `StateMachine`, `Player` 엔티티.
- 멀티 에이전트 공용 구성: 도구 무관 정본 `AGENTS.md` + 공용 `docs/`. Claude Code는 `.claude/CLAUDE.md`(→ `@../AGENTS.md` import)·스킬·커맨드로, Codex는 `AGENTS.md`·`.codex/config.toml`로 같은 지식을 사용한다(context7은 기본 활성, Godot MCP는 도구별 경로 설정 후 사용).
- 프로젝트 스코프 `.claude` 설정: 글로벌 설정 없이 `.claude/settings.json`만으로 플러그인·권한이 구성됨.
- context7 MCP: Godot 최신 API 문서 조회용(`.mcp.json`·`.codex/config.toml`, `npx` 자동 실행 — Node.js만 필요).
- Godot MCP: 에디터 제어·프로젝트 구동·디버그 출력 캡처용(선택, Coding-Solo/godot-mcp — 별도 설치와 경로 설정 필요).
- superpowers 플러그인: brainstorming · systematic-debugging · test-driven-development 등 워크플로 스킬.
- game-development 플러그인(`wshobson/agents`, Unity/Minecraft 중심 멀티엔진 — 본 템플릿은 그중 `godot-gdscript-patterns` 스킬만 사용): GDScript 시그널·씬·FSM·최적화 패턴 제공.
- GdUnit4 연동: 예제 테스트(`test/unit/iso_utils_test.gd`)와 테스트 실행 명령(GdUnit4 addon은 별도 설치 필요).

## 빠른 시작

1. 이 템플릿으로 새 리포를 생성하거나 클론한다.
2. Godot 4.4 이상에서 `project.godot`를 연다. 최초 1회 열 때 `.godot/` 캐시가 생성되지만, 기본 메인 씬은 외부 텍스처 임포트 없이도 headless smoke 실행이 가능하다. `.godot/`는 커밋하지 않는다(`.gitignore`가 이미 처리).
3. `docs/SETUP.md`를 따라 MCP(context7·Godot MCP)·플러그인·GdUnit4 addon을 설치한다.
   - context7 MCP는 Node.js만 있으면 `npx`로 바로 동작한다.
   - Godot MCP는 선택 기능이며, Coding-Solo/godot-mcp 빌드와 Godot 실행 파일 경로 설정 전에는 비활성/실패 상태일 수 있다.
4. 에디터에서 `F5`로 실행한다.

조작:

- 이동: `WASD` 또는 화살표 키 (`move_left` / `move_right` / `move_up` / `move_down`)
- 상호작용: `Space` 또는 `E` (`interact`)
- 좌클릭: TileSet 연결 후 클릭한 위치의 타일 셀 좌표를 출력 (`tile_clicked` 시그널)

씬에는 타일셋이 비어 있다(빈 `TileMapLayer`만 배치). 따라서 클린 클론 첫 실행에서는 좌클릭 좌표 출력이 비활성화되어 있으며, TileSet을 연결한 뒤 좌표 출력과 `tile_clicked` 시그널을 확인할 수 있다. 타일셋 추가 방법은 `docs/SETUP.md`와 `docs/ARCHITECTURE.md`에서 안내한다.

## 폴더 구조

| 경로 | 설명 |
|------|------|
| `AGENTS.md` | **도구 무관 정본 지침**(Codex 등이 직접 읽음) |
| `.claude/CLAUDE.md` | Claude Code 진입점(`@../AGENTS.md` import + Claude 전용 설정) |
| `.codex/config.toml` | Codex CLI용 MCP 서버 설정(context7 기본 활성, Godot MCP는 주석 예시) |
| `.claude/settings.json` | 프로젝트 스코프 플러그인·마켓플레이스·권한 |
| `skills/` | **공용 스킬**(SKILL.md) — 지식 4 + 워크플로/커맨드 4(`godot-run`·`godot-test`·`new-iso-scene`·`iso-debug`). 슬래시커맨드 겸용 |
| `.claude/skills` → `../skills` | 심볼릭 링크(Claude가 스킬을 읽는 경로) |
| `.codex/skills` → `../skills` | 심볼릭 링크(Codex 스킬 경로) |
| `.agents/skills` → `../skills` | 심볼릭 링크(에이전트 공용 스킬 경로 — 도구·버전별 탐지 경로 커버) |
| `.claude/agents/` | Claude 전용 서브에이전트(`godot-specialist.md`) |
| `.mcp.json` | context7 + Godot MCP 서버 설정 |
| `project.godot` | 엔진 설정(autoload·input·rendering) |
| `icon.svg` | 프로젝트 아이콘(아이소 다이아몬드) |
| `docs/SETUP.md` | 설치 안내(Godot·MCP·플러그인·GdUnit4·선택 스킬) |
| `docs/ARCHITECTURE.md` | 폴더 구조·데이터 흐름·시그널 규약 |
| `docs/GODOT_CONVENTIONS.md` | Godot 공식 컨벤션(GDScript 스타일·정적 타이핑·베스트 프랙티스, context7 검증) |
| `docs/COMMIT_CONVENTIONS.md` | 커밋 메시지 규칙(type·scope·예시, AI attribution 금지) |
| `.github/pull_request_template.md` | AI 작업 워크플로용 PR 템플릿(검증 증거·사람 리뷰 포인트 중심) |
| `src/autoload/` | 전역 싱글톤(`event_bus.gd` → EventBus, `game_state.gd` → GameState) |
| `src/systems/` | 시스템 스크립트(`iso_utils.gd` → IsoUtils, `state_machine.gd` → StateMachine) |
| `src/entities/player/` | 플레이어 엔티티(`player.gd` + `player.tscn`) |
| `scenes/` | 메인 씬(`main.tscn` + `main.gd`) |
| `assets/` | 에셋 디렉토리(현재 `.gitkeep`만 존재) |
| `test/unit/` | GdUnit4 테스트(`iso_utils_test.gd`) |

## Claude Code로 개발하기

워크플로 스킬은 슬래시커맨드를 겸한다(공용 `skills/`에 위치, `.claude/skills` 심볼릭). 이 리포를 연 Claude Code에서 다음을 `/이름`으로 호출할 수 있다(Codex는 같은 스킬을 `.codex/skills`로 공유).

| 명령어(스킬) | 설명 |
|--------|------|
| `/godot-run` | 씬 또는 프로젝트를 실행 |
| `/godot-test` | GdUnit4 테스트 실행 |
| `/new-iso-scene` | 아이소메트릭 씬 스캐폴딩 |
| `/iso-debug` | Y-sort·좌표 변환 디버깅 절차 |

스킬 라우팅 요약(상황별 사용 도구):

- 기획 초기("뭘 만들지"): `superpowers:brainstorming`
- 버그(특히 Y-sort·좌표 변환): `superpowers:systematic-debugging` + 템플릿 `iso-debug` 절차
- 로직 검증(전투·인벤토리 등): `superpowers:test-driven-development` + `gdunit4-testing` 스킬
- Godot 최신 API 확인: context7 MCP(libraryId `/godotengine/godot-docs`)
- 에디터 직접 조작(노드·씬·실행·디버그): Godot MCP(`godot-mcp-workflow` 스킬)
- GDScript 패턴(시그널·씬·FSM·최적화): game-development 플러그인의 `godot-gdscript-patterns` 스킬
- 아이소 좌표·Y-sort 지식: 템플릿 `godot-isometric` 스킬

정본 작업 지침은 `AGENTS.md`(모든 에이전트 공용)이며, Claude Code 전용 명령어·스킬·MCP 사용법은 `.claude/CLAUDE.md`, Codex 설정은 `docs/SETUP.md`의 Codex 절을 참조한다.

> MCP 구분: context7은 공식 문서 조회용이라 Node.js만 있으면 바로 뜬다. Godot MCP는 에디터 조작용 선택 서버라 `GODOT_MCP_PATH`/`GODOT_PATH`(Claude) 또는 `.codex/config.toml`의 절대경로(Codex)를 맞추기 전에는 서버 시작 실패가 날 수 있으며, 이때도 context7과 일반 코드 작업은 정상이다.

## 요구사항

- Godot 4.4 이상
- Node.js (context7 MCP의 `npx` 실행용)
- Godot MCP 사용 시: Coding-Solo/godot-mcp 빌드 후 — Claude는 `.mcp.json`의 `GODOT_MCP_PATH`/`GODOT_PATH` 환경변수로, Codex는 `.codex/config.toml`의 주석 예시를 실제 절대경로로 바꿔 주석 해제
- GdUnit4 사용 시: `addons/gdUnit4` addon 설치

플러그인(superpowers · commit-commands · game-development) · MCP(context7 · Godot MCP) · 기타 외부 의존성 설치는 사용자가 직접 수행해야 한다. (context7은 Claude Code 플러그인이 아니라 `.mcp.json`의 MCP 서버다 — `/plugin`이 아니라 `/mcp`에서 확인.) 자세한 설치 절차는 `docs/SETUP.md`, 구조·데이터 흐름·시그널 규약은 `docs/ARCHITECTURE.md`를 참조한다.
