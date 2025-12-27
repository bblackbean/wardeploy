#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
wardeploy - Tomcat(WAR) 배포/롤백 자동화 도구 (WSL + Docker)

사용법:
  ./bin/wardeploy <명령> [옵션/인자]

명령 목록:
  up
    - docker compose up -d 를 실행해 Tomcat 컨테이너를 올립니다.
    - PC 켠 뒤 작업 시작할 때 사용

  down
    - docker compose down 을 실행해 Tomcat 컨테이너를 내립니다.
    - 작업을 끝내고 PC 끄기 전에 정리할 때 사용

  status
    - Docker 연결, 컨테이너 상태, 배포된 WAR 존재 여부, 헬스체크 결과를 출력합니다.

  deploy <war경로>
    - 기존 WAR를 backups에 백업한 뒤, 새 WAR를 webapps에 복사합니다.
    - Tomcat 컨테이너를 재시작하고 /health가 UP인지 확인합니다.
    예)
      ./bin/wardeploy deploy ./sample-war/target/sample-war-1.0.0.war

  rollback
    - backups에서 가장 최신 백업 WAR로 되돌립니다.
    - Tomcat 컨테이너를 재시작하고 /health가 UP인지 확인합니다.

  help
    - 도움말을 출력합니다.

자주 쓰는 명령 예시:
  1) ./bin/wardeploy up
  2) ./bin/wardeploy deploy <war경로>
  3) ./bin/wardeploy status
  4) ./bin/wardeploy rollback   (필요 시)
  5) ./bin/wardeploy down

EOF
