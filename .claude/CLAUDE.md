@../AGENTS.md

# Claude Code 전용 설정

위 정본 지침(`AGENTS.md`)을 따른다. 아래는 **Claude Code에서만** 추가로 쓰는 래퍼·설정이다.
(Codex 등 다른 에이전트는 이 `.claude/` 자산을 읽지 않는다. 그들에겐 `AGENTS.md` + `docs/` + `.codex/config.toml`이 동등한 역할을 한다.)

## 플러그인 (프로젝트 스코프 — `.claude/settings.json`)

- **superpowers** — `brainstorming`, `systematic-debugging`, `test-driven-development` 등 핵심 스킬.
- **commit-commands** — `/commit` (메시지는 `docs/COMMIT_CONVENTIONS.md` 준수).
- **game-development** — Unity/Minecraft 중심 멀티엔진 플러그인. 본 템플릿은 그중 `godot-gdscript-patterns` 스킬만 사용.
- 마켓플레이스: `wshobson/agents`(claude-code-workflows)를 `extraKnownMarketplaces`로 선언. 리포 오픈 시 설치 프롬프트가 뜬다.

## MCP 서버 (`.mcp.json`)

- `context7`(문서 조회), `godot`(에디터 제어). `enableAllProjectMcpServers=true`로 자동 승인.
- 동일한 서버를 Codex는 `.codex/config.toml`에서 읽는다.

## 스킬 (공용 `skills/` ← `.claude/skills` 심볼릭 링크)

스킬은 최상위 `skills/`에 있고 `.claude/skills`가 심볼릭 링크로 가리킨다(Codex는 `.codex/skills`·`.agents/skills`로 공유 — 자동 탐지는 도구·버전에 따라 다를 수 있어, 안 되면 `AGENTS.md`+`docs/`가 보장). 모두 같은 `SKILL.md` 포맷.

지식 스킬:
- `godot-isometric` — 아이소 좌표·Y-sort·TileMapLayer
- `godot-mcp-workflow` — godot MCP로 에디터 제어
- `gdunit4-testing` — GdUnit4 설치·테스트 패턴·TDD
- `godot-project-conventions` — 폴더 구조·네이밍·시그널 규약

워크플로 스킬(슬래시커맨드 겸용 — `/이름`으로 호출, 인자 지원):
- `/godot-run` — 프로젝트/씬 실행
- `/godot-test` — GdUnit4 테스트 실행
- `/new-iso-scene` — 아이소 씬 스캐폴딩
- `/iso-debug` — Y-sort·좌표 디버깅 절차

(예전 `.claude/commands/`는 스킬로 통합됐다. Claude Code는 스킬을 `/이름`으로 호출 가능하고, Codex 스킬도 동일 포맷이라 공유된다.)

## 서브에이전트 (`.claude/agents/` — Claude 전용)

- `godot-specialist` — Godot 4 GDScript/아이소/씬 작업 위임용. 서브에이전트는 격리된 컨텍스트·도구 제한을 갖는 Claude 고유 메커니즘이라 스킬로 합치지 않는다. Codex는 같은 역할을 `config.toml [agents]`로 둘 수 있다(선택).
