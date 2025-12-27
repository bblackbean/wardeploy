#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/wardeploy.env"

WAR_NAME="${WAR_CONTEXT}.war"
DEST="${TOMCAT_WEBAPPS}/${WAR_NAME}"

echo "== wardeploy 상태 =="

# 1) Docker 연결 상태 확인
if docker info >/dev/null 2>&1; then
  echo "- Docker: OK"
else
  echo "- Docker: OFF (Docker Desktop 실행 필요)"
  exit 1
fi

# 2) 톰캣 컨테이너 상태 확인
CID="$(docker ps -aqf "name=^${TOMCAT_CONTAINER}$" || true)"
if [[ -z "$CID" ]]; then
  echo "- 컨테이너: 없음 (${TOMCAT_CONTAINER})"
else
  RUNNING="$(docker inspect -f '{{.State.Running}}' "$CID" 2>/dev/null || echo "false")"
  STATUS="$(docker inspect -f '{{.State.Status}}' "$CID" 2>/dev/null || echo "unknown")"
  echo "- 컨테이너: ${TOMCAT_CONTAINER} (status=${STATUS}, running=${RUNNING})"
fi

# 3) 배포된 WAR 파일
if [[ -f "$DEST" ]]; then
  echo "- 배포 WAR: 존재 ($DEST)"
  ls -lh "$DEST" | awk '{print "  - 크기: " $5 ", 수정: " $6 " " $7 " " $8}'
else
  echo "- 배포 WAR: 없음 ($DEST)"
fi

# 4) health 체크
echo -n "- 헬스체크: "
if curl -fsS "$HEALTH_URL" 2>/dev/null | grep -q "UP"; then
  echo "UP"
else
  echo "FAIL (${HEALTH_URL})"
fi

# 5) 최신 백업 폴더 있는지 확인
LATEST_DIR="$(ls -1dt "$BACKUP_DIR"/* 2>/dev/null | head -n 1 || true)"
if [[ -n "$LATEST_DIR" ]]; then
  echo "- 최신 백업: $LATEST_DIR"
else
  echo "- 최신 백업: 없음 ($BACKUP_DIR)"
fi
