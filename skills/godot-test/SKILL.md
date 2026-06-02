---
name: godot-test
description: GdUnit4 테스트를 CLI 러너로 실행하고 결과를 해석한다. 실패 시 TDD/체계적 디버깅과 연계한다. $ARGUMENTS로 특정 테스트 경로(예 test/unit)를 지정할 수 있다. /godot-test 로 호출.
argument-hint: "[테스트 경로(선택, 예: test/unit)]"
allowed-tools: Bash, Read, Glob, Grep
---

# /godot-test — GdUnit4 테스트 실행

GdUnit4 테스트 스위트를 명령줄 러너로 실행하고, 결과(통과/실패)를 해석한다.

## 전제 — GdUnit4 설치 확인

GdUnit4는 Godot 애드온이며 **설치가 필요**하다. 실행 전에 `addons/gdUnit4` 디렉터리가 있는지 먼저 확인한다.

```bash
ls addons/gdUnit4
```

없으면 테스트가 동작하지 않는다. `docs/SETUP.md`의 GdUnit4 설치 절차(Godot AssetLib 또는 `git clone https://github.com/godot-gdunit-labs/gdUnit4` 후 `addons/gdUnit4` 배치)를 안내하고 멈춘다. 임의로 설치하지 않는다.

## 실행 절차

CLI 러너는 GdUnit4가 `addons/gdUnit4` 아래 제공하는 스크립트를 사용한다. 작업 디렉터리는 프로젝트 루트(`res://`가 가리키는 곳)다.

- macOS/Linux:

  ```bash
  addons/gdUnit4/runtest.sh -a test
  ```

- Windows:

  ```bat
  addons/gdUnit4/runtest.cmd -a test
  ```

- `-a`(add testsuite/디렉터리)에 실행 대상 경로를 준다. `$ARGUMENTS`가 있으면 그 경로를, 없으면 `test`(전체) 또는 본 템플릿 예제인 `test/unit`을 대상으로 한다.
  - 전체: `addons/gdUnit4/runtest.sh -a test`
  - 예제만: `addons/gdUnit4/runtest.sh -a test/unit`
  - 특정 파일: `addons/gdUnit4/runtest.sh -a test/unit/iso_utils_test.gd`

- 러너가 Godot 실행 파일 경로를 요구하면 `GODOT_BIN` 환경변수로 지정한다(예: macOS `export GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot`). CI/헤드리스 환경에서는 Godot가 `--headless`로 구동되어 GPU 없이도 동작한다.

- 러너 스크립트가 실행 권한이 없다면 `chmod +x addons/gdUnit4/runtest.sh` 후 다시 실행한다.

## 결과 해석

- 러너는 스위트별 통과/실패 개수와 요약을 출력하고, 실패가 하나라도 있으면 **0이 아닌 종료 코드**로 끝난다. 종료 코드 0이면 전부 통과다.
- 출력에서 `FAILED`/`Failure`로 표시된 테스트 함수와, 기대값(expected) vs 실제값(actual) 라인을 찾는다. 본 템플릿 예제(`test/unit/iso_utils_test.gd`)는 `assert_int`/`assert_float`/`assert_vector` 기반이라 실패 시 좌표 변환 라운드트립의 어긋난 성분이 그대로 보인다.
- 리포트 파일(HTML/JUnit XML)이 생성되면 경로가 출력된다. 상세 원인을 볼 때 함께 확인한다.

## 실패 시 — superpowers 연계

테스트가 실패하면 추측으로 코드를 고치지 말고 아래 흐름을 따른다.

1. 새 기능을 만들다 실패한 것이면 `superpowers:test-driven-development` 스킬로 RED → GREEN → REFACTOR 루프를 유지한다. 실패하는 테스트를 먼저 확정하고, 그 테스트를 통과시키는 최소 변경만 한다.
2. 원인이 불분명하거나(특히 아이소 좌표/Y-sort 계산 어긋남) 재현이 까다로우면 `superpowers:systematic-debugging` 스킬로 가설 → 관찰 → 검증을 반복한다.
3. Godot API 동작이 의심되면 추정하지 말고 context7 MCP(`/godotengine/godot-docs`)로 해당 메서드 시그니처/동작을 확인한다.
4. 좌표 변환·Y-sort가 원인이면 `iso-debug` 스킬 절차와 `godot-isometric` 스킬을 함께 사용한다.

테스트 패턴·TDD 루프의 템플릿 규약 상세는 `gdunit4-testing` 스킬을 참고한다.
