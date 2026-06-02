---
name: godot-run
description: Godot 프로젝트 또는 특정 씬을 실행한다. godot MCP가 있으면 MCP로, 없으면 CLI(godot --path .)로 구동한다. $ARGUMENTS로 실행할 씬 경로를 지정할 수 있다. /godot-run 으로 호출.
argument-hint: "[씬 경로(선택, 예: res://scenes/main.tscn)]"
allowed-tools: Bash(godot:*), Read, Glob
---

# /godot-run — 프로젝트/씬 실행

Godot 프로젝트 또는 현재 작업 중인 씬을 실행하고, 실행 중 출력되는 로그·에러를 확인한다.

- 인자(`$ARGUMENTS`)가 **있으면**: 그 값을 실행할 씬 경로로 본다(예: `res://scenes/main.tscn` 또는 `scenes/main.tscn`).
- 인자가 **없으면**: 프로젝트의 메인 씬(`run/main_scene` = `res://scenes/main.tscn`)을 실행한다.

## 실행 절차

### 1단계 — godot MCP 사용 가능 여부 확인 (우선)

`.mcp.json`(Claude) 또는 `.codex/config.toml`(Codex)에 `godot` 서버가 정의되어 있고 환경변수(`GODOT_MCP_PATH`, `GODOT_PATH`)가 주입되어 MCP 도구가 노출되어 있으면, **CLI보다 MCP를 우선** 사용한다. MCP는 에디터 실행·프로젝트 구동·디버그 출력 캡처를 더 안정적으로 처리한다.

- 프로젝트 실행: godot MCP의 프로젝트 실행 도구(예: `run_project`)에 프로젝트 경로(프로젝트 루트, `res://`가 가리키는 곳)를 전달한다.
- 특정 씬 실행: MCP가 씬 단위 실행을 지원하면 `$ARGUMENTS`로 받은 씬 경로를 전달한다. 지원하지 않으면 메인 씬을 실행한 뒤, 디버그 출력으로 동작을 확인한다.
- 실행 후 godot MCP의 디버그 출력 캡처(예: `get_debug_output`)로 stdout/stderr를 읽어 에러 여부를 확인한다.

godot MCP 사용법의 상세는 `godot-mcp-workflow` 스킬을 참고한다.

### 2단계 — godot MCP가 없을 때: CLI 실행 (대체)

godot MCP가 비활성(환경변수 미설정 등)이면 `godot` CLI로 직접 실행한다. CLI 작업 디렉터리는 항상 프로젝트 루트(`res://`가 가리키는 곳)를 기준으로 한다.

- **프로젝트 실행(메인 씬)** — `$ARGUMENTS`가 없을 때:

  ```bash
  godot --path .
  ```

- **특정 씬 실행** — `$ARGUMENTS`가 있을 때. **프로젝트 상대경로를 positional 인자**로 넘긴다(Godot 4.4+에서 동작):

  ```bash
  godot --path . scenes/main.tscn
  ```

  예: `godot --path . src/entities/player/player.tscn`. `$ARGUMENTS`가 `res://` 접두면 접두를 떼고 프로젝트 상대경로로 바꿔 넘긴다. (참고: `res://`·UID를 그대로 받는 `--scene` 플래그는 **Godot 4.5+ 전용**이라 본 템플릿의 4.4 타깃에서는 쓰지 않는다.)

- 백그라운드로 띄우지 말고 포그라운드로 실행해 종료 코드와 출력을 그대로 확인한다. 창을 띄우지 않고 헤드리스로 점검만 할 때는 `--headless`를 덧붙일 수 있다(렌더 확인이 필요 없는 경우에 한함).

## 결과 해석

- 정상 실행이면 게임 창이 뜬다. 메인 씬에서 **좌클릭하면** stdout에 `클릭한 타일 셀: ...`가 출력된다(`EventBus.tile_clicked` 흐름). 참고: `player_spawned`는 `_ready`에서 emit만 하고 print 리스너가 없어 stdout에 직접 찍히지는 않는다.
- `ext_resource ... not found`, `Parse error`, `SCRIPT ERROR` 등이 보이면 경로·시그니처 불일치다. 해당 파일을 Read로 열어 AGENTS.md의 규약·노드 트리/시그니처와 대조한다.
- 아이소 특유 증상(Y-sort 어긋남, 클릭 좌표가 셀과 안 맞음)이면 `iso-debug` 스킬 절차로 넘어간다.

## 주의

- `godot` 실행 파일이 PATH에 없으면 절대 경로로 호출한다(macOS 예: `/Applications/Godot.app/Contents/MacOS/Godot --path .`). 단, 절대경로 호출은 `allowed-tools`(`Bash(godot:*)`)에 잡히지 않아 권한 프롬프트가 한 번 뜰 수 있다(승인하면 정상 동작). 자주 쓴다면 `godot`를 PATH에 두는 편이 매끄럽다.
- 외부 도구(Godot 본체, godot MCP) 설치는 사용자가 직접 해야 한다. 미설치 시 `docs/SETUP.md`를 안내한다.
