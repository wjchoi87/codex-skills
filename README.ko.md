# codex-skills

장기 실행, 워크플로 오케스트레이션, 재개 가능한 핸드오프, 실행 증명을 위한 Codex 커스텀 스킬 모음입니다.

이 스킬들은 지속적인 에이전트 워크플로 패턴을 Codex에 맞게 옮겨온 것이며, 일부는 [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)에서 영감을 받았습니다.

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

## 스킬 목록

- `runner`
- `orchestrator`
- `continuity-handoff`
- `execution-proof`
- `ddukddak`

### `ddukddak`

Codex 작업을 단순 편집이 아니라 신뢰 가능한 실행 하네스로 감싸는 스킬입니다.

다음 같은 상황에 적합합니다.

- 컨텍스트 수집, 구현, 검증이 모두 필요한 비단순 코딩 작업
- "look into this", "best way"처럼 부드러운 표현이지만 실제 액션을 요구하는 요청
- tool discipline, delegation, persistent state, recovery를 함께 써야 하는 작업
- 테스트, 빌드, diagnostics, artifact, 또는 명확한 blocker로 완료를 증명해야 하는 작업

핵심적으로 강조하는 점:

- 실행 전 intent classification
- 파일, 명령어, 문서, artifact에서 얻은 구체적인 컨텍스트
- local, background, persistent, delegated, dependency-gated lane으로 작업 라우팅
- 좁은 검증에서 넓은 검증으로 이어지는 verification ladder
- 추측이 아니라 전략 변경을 통한 failure recovery

### `runner`

일회성 셸 명령이 아니라, 오래 실행되는 프로세스를 지속적인 실행 단위로 관리하는 스킬입니다.

다음 같은 상황에 적합합니다.

- 개발 서버 실행
- 오래 걸리는 빌드
- 시간이 걸리는 테스트 스위트
- 크롤러나 배치 작업
- 학습 작업이나 데이터 처리 실행
- 원래 명령어, 세션 핸들, 로그, 아티팩트를 잃지 않아야 하는 모든 작업

핵심적으로 강조하는 점:

- `task_id`, `session_id`, `pane_id`, `pid` 같은 안정적인 실행 식별자 유지
- 새 실행을 만들기 전에 기존 실행에 재연결
- 세션 출력, 프로세스 생존 여부, 로그, 아티팩트로 상태 확인
- stdout가 조용하다고 완료로 간주하지 않기

### `orchestrator`

복잡한 작업을 느슨한 편집 나열이 아니라, 의존성과 단계가 있는 워크플로로 다루는 스킬입니다.

다음 같은 상황에 적합합니다.

- 여러 단계로 이루어진 큰 작업
- 즉시 코딩과 조사/검증 작업이 섞여 있는 경우
- blocker와 prerequisite가 있는 작업
- 나중에 결과를 수집해야 하는 background 작업
- 핵심 경로를 막지 않으면서 다른 작업 흐름도 함께 굴려야 하는 경우

핵심적으로 강조하는 점:

- 실행 방식 결정 전에 작업 성격 분류
- critical path와 sidecar work 분리
- 명시적인 blocker와 task dependency
- 필요할 때 background 결과 수집
- 여러 단계 진행을 위한 orchestration ledger 유지

### `continuity-handoff`

중단, 요약, 컨텍스트 압축 이후에도 Codex가 안전하게 이어서 작업할 수 있도록 상태를 보존하는 스킬입니다.

다음 같은 상황에 적합합니다.

- 중간에 compact될 수 있는 긴 대화
- 나중에 멈췄다가 다시 이어야 하는 작업
- 정확한 세션 상태나 task 상태가 중요한 경우
- "여기서부터 계속"만으로는 부족한 핸드오프
- 쉬었다가 다시 시작해도 다음 단계가 검증 가능해야 하는 워크플로

핵심적으로 강조하는 점:

- 정확한 session, task, command, artifact 참조 저장
- 기억에 의존한 상태와 검증된 상태 구분
- 행동 전에 실제 소스에서 컨텍스트 복원
- 다음 액션과 resume 시 가장 먼저 확인할 항목 보존

### `execution-proof`

Codex 작업이 실제로 시작되고, 살아 있었고, phase를 따라 진행되었으며, 최종 상태에 도달했다는 것을 파일 기반으로 남기는 스킬입니다.

다음 같은 상황에 적합합니다.

- 채팅 출력만으로는 신뢰가 부족한 작업
- 외부에서 완료 여부를 검증해야 하는 긴 워크플로
- 기계가 읽는 증명과 사람이 읽는 증명을 함께 남겨야 하는 경우
- 하나의 논리적 run 아래 여러 재시도 attempt가 생길 수 있는 작업

핵심적으로 강조하는 점:

- `run_id`와 `attempt_id` 분리 추적
- heartbeat 기반 실행 지속성 증명
- `.codex/runs/...` 아래의 machine proof
- 빠르게 확인 가능한 `proof.md`

## 함께 쓰는 방식

이 스킬들은 Codex 위에 얇은 운영 레이어처럼 함께 동작하도록 설계되어 있습니다.

- 비단순 엔지니어링 작업의 상위 실행 루프에는 `ddukddak`
- 전체 워크플로 구조화에는 `orchestrator`
- 그중 하나가 장기 실행 프로세스가 되면 `runner`
- 그 워크플로 또는 프로세스를 나중에 다시 이어야 하면 `continuity-handoff`
- 실제로 끝까지 돌았다는 외부 증명이 필요하면 `execution-proof`

보통은 이런 흐름으로 쓰면 됩니다.

1. `ddukddak`으로 intent를 분류하고, 컨텍스트를 모으고, 도구를 고르고, 실행/검증/복구합니다.
2. 작업이 단계, blocker, 병렬 workstream으로 나뉘면 `orchestrator`로 구조화합니다.
3. 서버, 빌드, 장기 실행 명령은 `runner`로 추적합니다.
4. 멈추거나 요약하거나 나중에 재개해야 할 때 `continuity-handoff`로 정확한 상태를 남깁니다.
5. 실제 진행과 완료를 신뢰할 수 있게 남기려면 `execution-proof`로 proof artifact를 생성합니다.

## 설계 목표

이 스킬들은 Codex 워크플로를 더 다음과 같이 만드는 것을 목표로 합니다.

- 오래 가는 작업에 강하게
- 재시작에 안전하게
- 상태를 명시적으로 다루게
- 장기 실행과 다단계 작업에 더 잘 맞게
- 여러 머신 간 동기화가 쉽게
- 채팅 밖에서도 실행 완료를 검증하기 쉽게

## 설치

각 폴더를 `~/.codex/skills/` 아래에 복사하거나 심볼릭 링크로 연결하면 됩니다.

예시:

```bash
ln -s ~/src/codex-skills/runner ~/.codex/skills/runner
ln -s ~/src/codex-skills/orchestrator ~/.codex/skills/orchestrator
ln -s ~/src/codex-skills/continuity-handoff ~/.codex/skills/continuity-handoff
ln -s ~/src/codex-skills/execution-proof ~/.codex/skills/execution-proof
ln -s ~/src/codex-skills/ddukddak ~/.codex/skills/ddukddak
```

또는:

```bash
./install.sh
```

새 스킬을 인식하려면 Codex를 재시작하세요.

## Plugin 패키징

이 저장소에는 이제 Codex plugin 패키지도 포함되어 있습니다.

- plugin 루트: `plugins/codex-skills`
- manifest: `plugins/codex-skills/.codex-plugin/plugin.json`
- 로컬 marketplace metadata: `.agents/plugins/marketplace.json`

이 구조를 사용하면 여러 스킬을 하나의 배포 단위로 묶을 수 있습니다.

다만 이 저장소의 marketplace metadata는 **Codex UI에서 정렬과 설치 가능 상태를 표현하는 repo 범위 메타데이터**에 가깝고, 자동으로 어떤 전역 공개 plugin marketplace에 등록된다는 뜻은 아닙니다.
