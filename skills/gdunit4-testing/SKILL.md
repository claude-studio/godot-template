---
name: gdunit4-testing
description: GdUnit4로 GDScript 단위/씬 테스트를 작성·실행하거나 TDD를 적용할 때 사용. 테스트 스위트 작성 패턴, 핵심 단언(assert) API, CLI 실행법, 레드-그린-리팩터 절차를 안내한다.
---

# GdUnit4 테스트 스킬

이 스킬은 본 아이소메트릭 2D 템플릿에서 **GdUnit4**로 GDScript 로직(좌표 변환, 상태 기계, 게임 규칙 등)을
검증할 때 따라야 할 절차와 패턴을 정리한다. 전투·인벤토리 등 로직을 검증할 때는
`superpowers:test-driven-development`와 함께 이 스킬을 사용한다(스펙 7절 라우팅 규칙).

## 전제: GdUnit4 설치가 필요하다

GdUnit4는 Godot 엔진에 내장돼 있지 않은 **커뮤니티 애드온**이다. 테스트를 실행하려면
`addons/gdUnit4` 디렉토리가 프로젝트에 존재하고 에디터에서 플러그인이 활성화돼 있어야 한다.

- 설치 방법(AssetLib 또는 git clone)과 활성화 절차는 **`docs/SETUP.md`를 참조**한다.
- 이 템플릿 리포에는 `addons/gdUnit4`가 포함돼 있지 않다(외부 의존성). 설치 전에는
  아래 테스트가 `GdUnitTestSuite`를 찾지 못해 파싱 에러가 난다 — 정상이다.

## 테스트 작성 패턴

### 기본 구조

테스트 스위트는 `GdUnitTestSuite`를 상속하고, 검증 메서드는 **`test_` 접두사**를 붙인다.
GdUnit4가 `test_`로 시작하는 메서드를 자동으로 수집해 실행한다.

```gdscript
extends GdUnitTestSuite
## 무엇을 검증하는 스위트인지 한 줄 설명.

func test_addition() -> void:
	assert_int(2 + 3).is_equal(5)

func test_flag_default() -> void:
	assert_bool(false).is_false()
```

핵심 규칙:

- 파일은 `test/` 하위에 두고, 보통 `<대상>_test.gd` 규약으로 이름 짓는다.
  (예: `IsoUtils` 검증 → `test/unit/iso_utils_test.gd`)
- 한 `test_` 메서드는 한 가지 동작만 검증한다(이름으로 의도가 드러나게).
- 셋업/정리가 필요하면 `before()` / `after()`(스위트 단위), `before_test()` / `after_test()`
  (각 테스트 단위) 훅을 사용한다. 정확한 훅 이름은 설치된 GdUnit4 버전에서 확인한다(버전별 확인).

### 핵심 단언(assert) API

GdUnit4의 단언은 **플루언트(fluent) 스타일**이다. `assert_*(값)`이 단언 객체를 돌려주고
거기에 `.is_equal(...)` 같은 매처를 체이닝한다. 타입별 진입 함수:

| 진입 함수 | 대상 타입 | 예시 |
|-----------|-----------|------|
| `assert_int(v)` | int | `assert_int(score).is_equal(10)` |
| `assert_float(v)` | float | `assert_float(x).is_equal_approx(1.0, 0.001)` |
| `assert_bool(v)` | bool | `assert_bool(is_paused).is_true()` |
| `assert_str(v)` | String | `assert_str(name).is_equal("Player")` |
| `assert_vector(v)` | Vector2/3 등 | `assert_vector(pos).is_equal_approx(Vector2(64, 0), Vector2(0.01, 0.01))` |
| `assert_array(v)` | Array/typed array | `assert_array(cells).contains([Vector2i(0, 0)])` |
| `assert_dict(v)` | Dictionary | `assert_dict(d).contains_keys(["hp"])` |
| `assert_object(v)` | Object/Node | `assert_object(node).is_not_null()` |

자주 쓰는 매처(체이닝):

- 동등/부등: `.is_equal(x)`, `.is_not_equal(x)`
- 근사 비교(부동소수·벡터): `.is_equal_approx(x, approx)` — 라운드트립 검증에 사용
- 불리언: `.is_true()`, `.is_false()`
- null: `.is_null()`, `.is_not_null()`
- 대소 비교(수치): `.is_greater(x)`, `.is_less(x)`, `.is_greater_equal(x)`, `.is_less_equal(x)`
- 배열: `.contains([...])`, `.has_size(n)`, `.is_empty()`

주의:

- 매처 이름·시그니처는 GdUnit4 버전에 따라 다를 수 있다. 위 표의 진입 함수
  (`assert_int`/`assert_float`/`assert_bool`/`assert_vector`/`assert_array`/`assert_object`)는
  본 템플릿이 기준으로 삼는 핵심 API다. **세부 매처가 불확실하면 단정하지 말고
  설치된 버전의 GdUnit4 문서로 확인한다(버전별 확인).**
- 부동소수·벡터 비교는 반드시 근사 비교를 쓴다. 정확 일치(`is_equal`)는 좌표 변환 같은
  연산에서 미세 오차로 실패할 수 있다.

## 이 템플릿의 예제 테스트

`test/unit/iso_utils_test.gd`가 동봉돼 있다. `IsoUtils`(좌표 변환 헬퍼)를 검증하는
참고용 스위트로, 새 테스트를 작성할 때 출발점으로 삼는다. 검증 항목:

- `test_cart_iso_roundtrip()` — `cart_to_iso` → `iso_to_cart` 라운드트립 결과가 원본과 근사(`assert_vector` + 근사 비교)
- `test_depth_ordering()` — `depth(0, 0) < depth(1, 0)` 등 깊이 정렬 보조값의 단조성(`assert_int`)
- `test_map_to_screen_origin()` — 원점 셀의 스크린 좌표 검증(`assert_vector`)

`IsoUtils`는 모든 메서드가 static이므로 인스턴스 없이 `IsoUtils.cart_to_iso(...)`처럼 직접 호출해 검증한다.

## CLI 실행법 (설치 후)

> 아래는 **GdUnit4 설치(`addons/gdUnit4`)가 끝난 뒤**에만 동작한다.

GdUnit4는 `addons/gdUnit4` 안에 헤드리스 실행용 러너 스크립트(`runtest`)를 제공한다.
플랫폼별로 셸 스크립트(`runtest.sh`)와 배치 파일(`runtest.cmd`)이 들어 있다.
정확한 파일명·옵션은 설치된 버전에서 확인한다(버전별 확인). 일반적인 형태:

```bash
# 특정 디렉토리/파일의 테스트 실행 (-a = add test path; res:// 아닌 프로젝트 상대경로)
addons/gdUnit4/runtest.sh -a test/unit

# 단일 스위트만 실행
addons/gdUnit4/runtest.sh -a test/unit/iso_utils_test.gd
```

- 러너는 내부적으로 Godot 실행파일을 호출하므로 `GODOT_BIN`(또는 동등한) 환경변수로
  Godot 경로를 지정해야 할 수 있다 — 버전별 확인.
- CI/헤드리스 환경에서는 `--headless` 인자가 함께 쓰인다.

### `/godot-test` 명령어 연계

이 템플릿의 `/godot-test` 슬래시 명령은 위 러너 실행을 감싼 절차를 제공한다.
보통은 직접 CLI를 치기보다 **`/godot-test`를 사용**해 테스트를 돌리고 결과를 확인한다.
절차 정의는 `godot-test` 스킬(`skills/godot-test/SKILL.md`) 참조.

## TDD 루프 (superpowers:test-driven-development 결합)

새 로직(예: 새 상태, 새 좌표 공식, 인벤토리 규칙)을 추가할 때는 다음 순서를 지킨다.

1. **레드(Red)** — 먼저 실패하는 테스트를 작성한다.
   - `test/unit/<대상>_test.gd`에 `extends GdUnitTestSuite`로 스위트를 만들고
     기대 동작을 `test_*` 메서드로 표현한다.
   - `/godot-test`로 실행해 **빨갛게(실패) 떨어지는지** 확인한다. 실패 메시지가
     "구현이 없어서/틀려서" 나는지 확인한다(테스트 자체 오류가 아니라).
2. **그린(Green)** — 테스트를 통과시키는 **최소 구현**을 작성한다.
   - 통과만 목표로 한다. 과한 일반화는 하지 않는다.
   - 다시 `/godot-test`로 **초록(통과)** 확인.
3. **리팩터(Refactor)** — 테스트가 초록인 상태를 유지하며 구현을 정리한다.
   - 중복 제거, 네이밍 정리, 정적 타이핑 보강. 매 변경 후 `/godot-test`로 회귀 확인.

원칙:

- 한 번에 한 가지 동작만 다룬다(작은 레드-그린 사이클을 반복).
- 부동소수·벡터는 근사 비교로 단언한다.
- 좌표/Y-sort 관련 버그로 막히면 `superpowers:systematic-debugging`과
  본 템플릿의 `/iso-debug` 절차를 병행한다.
- Godot 4 API가 불확실하면 context7 MCP(`/godotengine/godot-docs`)로,
  GdUnit4 API가 불확실하면 설치된 버전의 GdUnit4 문서로 확인한다 — 추측으로 단정하지 않는다.
