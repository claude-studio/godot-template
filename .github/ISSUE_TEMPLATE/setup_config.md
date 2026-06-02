---
name: ⚙️ 설정 변경 / 설정 오류
about: 템플릿을 쓰다 설정이 잘못됐거나(MCP·플러그인·project.godot 등) 새 설정을 추가·변경해야 할 때 사용합니다.
title: "chore(config): "
labels: ["config"]
assignees: []
---

<!--
이 레포는 "글로벌 설정 없이 프로젝트 레벨만으로" 여러 AI 에이전트에서 즉시 동작하는 것을 목표로 합니다.
그래서 설정 문제는 곧 "다른 사람의 클론이 깨지느냐"의 문제입니다.
무엇이/왜 잘못됐고, 어떤 파일을 어떻게 바꿔야 하는지 구체적으로 적어
다른 에이전트가 추측 없이 따라 할 수 있게 하세요.
설치 누락이 원인인 경우가 많으니 docs/SETUP.md를 먼저 확인하세요.
-->

## 종류

- [ ] 설정 **오류** — 현재 설정이 잘못돼 동작하지 않음
- [ ] 설정 **변경** — 기존 값을 바꿔야 함
- [ ] 설정 **추가** — 새 항목(플러그인·MCP·autoload·input 등)을 더해야 함

## 대상 설정 <!-- 해당하는 것 모두 체크 -->

- [ ] `project.godot` (autoload / input map / rendering / features)
- [ ] `.mcp.json` (Claude Code — context7 / godot MCP, `${GODOT_MCP_PATH}`·`${GODOT_PATH}`)
- [ ] `.codex/config.toml` (Codex — MCP `args` 절대경로, `[mcp_servers.godot.env] GODOT_PATH`)
- [ ] `.claude/settings.json` (플러그인 / 마켓플레이스 / 권한)
- [ ] `addons/gdUnit4` (GdUnit4 설치·버전)
- [ ] 공용 `skills/` 또는 심볼릭 링크(`.claude/skills`·`.codex/skills`·`.agents/skills`)
- [ ] `AGENTS.md` / `.claude/CLAUDE.md` / `docs/` 지침
- [ ] 기타: <!-- 파일 경로 명시 -->

## 요약

<!-- 무엇을, 왜 바꿔야 하는지 2~4줄. 예: "godot MCP가 GODOT_PATH 미설정으로 안 떠서 에디터 조작이 안 됨." -->

## 현재 상태 (As-Is)

<!--
지금 설정이 어떻게 돼 있는지. 관련 파일의 해당 줄을 그대로 인용하세요.
오류면 재현 절차 + 콘솔/에러 메시지(예: "Failed to start MCP server", "Unknown setting", parse 에러)도 포함.
-->

```text
(현재 설정값 / 에러 메시지)
```

## 원하는 상태 (To-Be)

<!-- 어떤 값으로 바뀌어야 하는가. 가능하면 변경 후 diff 형태로. -->

```text
(변경 후 설정값)
```

## 근거 / 공식 문서

<!--
임의 우회·추측 금지(AGENTS.md 원칙). 왜 이 값이 맞는지 근거를 대세요.
- Godot 설정: context7 `/godotengine/godot-docs` 또는 docs/SETUP.md / docs/GODOT_CONVENTIONS.md
- MCP·플러그인: docs/SETUP.md
-->

- **참조한 문서·도구**:
- **설치 누락 가능성 점검**: <!-- 의존성(addons/gdUnit4, MCP 서버 경로 등)이 실제로 설치돼 있는지 확인했는가 -->

## 영향 범위

- [ ] **다른 에이전트 호환성** — Claude Code와 Codex 양쪽에서 동일하게 동작하는가(MCP·스킬은 양쪽 설정을 함께 갱신)
- [ ] **클린 클론** — 이 레포를 새로 클론한 사람이 글로벌 설정 없이 동작하는가
- [ ] 환경 의존(절대경로·OS별 경로)이 들어가는가 → 그렇다면 어떻게 문서화할지

## ✅ 완료 조건(Acceptance)

- [ ] <!-- 예: `/godot-run`이 godot MCP로 main.tscn을 실행하고 디버그 출력을 캡처한다 -->
- [ ] <!-- 예: 변경이 .mcp.json과 .codex/config.toml 양쪽에 반영됐다 -->
- [ ] <!-- 예: docs/SETUP.md에 변경된 설정 절차를 갱신했다 -->
