---
name: godot-mcp-workflow
description: Godot 에디터/씬/노드를 MCP로 직접 조작하거나 프로젝트를 실행·디버그할 때 사용.
---

# Godot MCP 워크플로

이 템플릿은 Godot 에디터를 Claude Code에서 직접 제어하기 위해 **Coding-Solo/godot-mcp** MCP
서버를 사용한다. 이 스킬은 그 서버로 프로젝트를 실행하고 디버그 출력을 캡처해 문제를 좁혀가는
일반 워크플로를 다룬다.

> 적용 시점: 프로젝트를 직접 실행해 동작을 확인하거나, 에디터에서 씬/노드/스크립트를 조작하거나,
> 런타임 에러·디버그 출력을 캡처해 원인을 찾을 때.

## 1. 서버 선언 위치

godot MCP 서버는 프로젝트 루트의 `.mcp.json`에 `"godot"`라는 이름으로 선언되어 있다.

```json
"godot": {
  "command": "node",
  "args": ["${GODOT_MCP_PATH:-/path/to/godot-mcp}/build/index.js"],
  "env": { "GODOT_PATH": "${GODOT_PATH:-}", "DEBUG": "false" }
}
```

- `${GODOT_MCP_PATH}`: Coding-Solo/godot-mcp를 클론·빌드한 경로 (예: `~/tools/godot-mcp`)
- `${GODOT_PATH}`: Godot 실행파일 경로 (예: `/Applications/Godot.app/Contents/MacOS/Godot`)

두 환경변수는 **사용자가 직접 설정**해야 한다. 클론·빌드·환경변수 설정 절차는 `docs/SETUP.md`를
참조한다. 미설정 시 godot 서버만 비활성화되고 context7 등 다른 MCP는 정상 동작한다.

## 2. 서버가 제공하는 기능 범주

> 중요: 정확한 도구 이름·인자는 **서버 버전마다 다르다**. 아래는 기능의 *범주*이며,
> 단정하지 말고 항상 **현재 연결된 MCP의 도구 목록을 먼저 확인**한 뒤 실제 이름으로 호출한다.

Coding-Solo/godot-mcp가 **실제 제공**하는 도구(설치 버전 기준):

- **실행·디버그**: `run_project`(프로젝트/씬 실행), `get_debug_output`(stdout/stderr·런타임 에러·`print()` 캡처), `stop_project`, `launch_editor`.
- **씬 생성·노드 추가**: `create_scene`, `add_node`, `load_sprite`, `save_scene`, `export_mesh_library`.
- **정보·UID**: `get_godot_version`, `list_projects`, `get_project_info`, `get_uid`, `update_project_uids`.

이 서버가 **제공하지 않는** 것(다른 서버/포크엔 있을 수 있음): 기존 **씬 트리/노드 속성 조회(introspection)**, 기존 **노드 속성 수정**, **GDScript 파일 읽기/쓰기**. 이런 작업은 MCP 대신 `.tscn`/`.gd`를 텍스트로 직접 Read/Edit한다.

### 도구 목록 확인이 먼저다

호출 전에 반드시 현재 세션에 노출된 godot MCP 도구 목록을 확인한다. 도구 이름이 추측과 다르면
**실제 노출된 이름**으로 호출한다. 목록에 godot 도구가 전혀 없으면 서버가 연결되지 않은 것이므로
아래 6번 "대체 경로"로 넘어간다.

## 3. 일반 워크플로

1. **실행**: godot MCP의 "프로젝트/씬 실행" 도구로 대상(전체 프로젝트 또는 특정 씬)을 실행한다.
   - 메인 씬은 `scenes/main.tscn` (project.godot의 `run/main_scene`).
   - 특정 씬만 빠르게 확인하려면 해당 `.tscn` 경로를 지정해 실행한다.
2. **디버그 출력/에러 캡처**: 실행 도구가 반환하는 출력 또는 별도 "디버그 출력 캡처" 도구로
   stdout/stderr, 런타임 에러, `print()` 결과를 수집한다. 에러 메시지·스택·해당 줄을 그대로 보존한다.
3. **막히면 근거를 먼저 확보**:
   - Godot 4 API가 조금이라도 불확실하면 **context7 MCP**로 확인한다
     (`resolve-library-id` → `query-docs`, libraryId `/godotengine/godot-docs`).
   - 원인이 분명치 않으면 **`superpowers:systematic-debugging`** 스킬을 적용한다
     (가설 수립 → 최소 재현 → 가설 검증 → 수정). 아이소 좌표/Y-sort 관련이면 `/iso-debug` 절차를
     함께 사용한다.
   - 추측으로 우회하지 말 것. 원인을 문서·재현으로 확정한 뒤 고친다.
4. **수정 → 재실행**: 스크립트/씬을 수정한 뒤 다시 1번부터 실행해 디버그 출력으로 회귀를 확인한다.
   에러가 사라지고 기대 동작이 나올 때까지 2~4를 반복한다.

### 에디터 직접 조작(씬/노드)

씬을 바꿀 때, **새 씬·노드 추가**는 godot MCP(`create_scene`/`add_node`/`load_sprite`/`save_scene`)로 할 수 있다.
다만 이 서버에는 **기존 노드 속성 수정·씬 트리 조회·GDScript 읽기/쓰기 도구가 없으므로**, 그런 변경은
텍스트 `.tscn`/`.gd`를 직접 Read/Edit한다. 어느 쪽이든 변경 후 반드시 실행해 런타임에서 깨지지 않는지
검증하고, 노드 경로(`$Sprite2D` 등)와 씬 트리가 정본 노드 트리와 일치하는지 확인한다.

## 4. 디버그 출력 읽는 요령

- 런타임 에러는 보통 `SCRIPT ERROR:` / `ERROR:` 접두로 시작하고 파일·줄 번호가 따라온다 — 그 위치부터 본다.
- `Invalid get index ... on base: 'null instance'` 류는 노드 경로 불일치(`@onready`/`$경로`)가 흔한 원인이다.
- autoload(`EventBus`, `GameState`) 미등록 시 전역 식별자 접근이 실패한다 — project.godot의 autoload 등록을 확인한다.
- Y-sort/좌표가 의도와 다르면 출력만으로 단정하지 말고 `/iso-debug` 절차로 좁힌다.

## 5. 테스트는 별도 경로

GdUnit4 단위 테스트 실행은 이 스킬이 아니라 `gdunit4-testing` 스킬과 `/godot-test` 명령어를 사용한다.
이 스킬은 "실행해서 직접 동작/디버그 확인"에 집중한다.

## 6. MCP가 미설치/미연결일 때의 대체 경로

godot MCP 도구가 목록에 없거나(서버 미연결) `${GODOT_MCP_PATH}`/`${GODOT_PATH}` 미설정이면,
Godot CLI를 직접 실행해 동일한 목적(실행·디버그 출력 확인)을 달성할 수 있다.

- **프로젝트 실행** (프로젝트 루트에서):
  ```shell
  "$GODOT_PATH" --path . scenes/main.tscn
  ```
- **특정 씬만 실행**: 위에서 씬 경로만 바꾼다.
- **디스플레이 없이(서버/CI) 실행**: `--headless` 추가.
  ```shell
  "$GODOT_PATH" --headless --path . scenes/main.tscn
  ```
- **하위 디렉토리에서 프로젝트 자동 탐색**: `--upwards` 사용.

stdout/stderr가 곧 디버그 출력이므로, 위 명령의 출력에서 `ERROR:`/`SCRIPT ERROR:`와 `print()` 결과를
그대로 읽어 3번 워크플로(원인 확인 → 수정 → 재실행)에 사용한다.

또한 이 템플릿에는 실행 전용 명령어 **`/godot-run`** 이 있다. MCP 없이 씬/프로젝트를 실행할 때
이 스킬을 쓰면 CLI 호출이 표준화된다 — 자세한 인자는 `godot-run` 스킬(`skills/godot-run/SKILL.md`)을 참조한다.

> 위 CLI 플래그(`--path`, `--headless`, `--upwards`, 씬 경로 직접 지정)는 Godot 공식 문서
> (command line tutorial)에서 확인한 동작이다.
