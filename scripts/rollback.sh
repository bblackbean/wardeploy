#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/wardeploy.env"

WAR_NAME="${WAR_CONTEXT}.war"
DEST="${TOMCAT_WEBAPPS}/${WAR_NAME}"

# 최신 백업 폴더 찾기
LATEST_DIR="$(ls -1dt "$BACKUP_DIR"/* 2>/dev/null | head -n 1 || true)"
if [[ -z "$LATEST_DIR" ]]; then
  echo "실패: 백업이 없습니다. ($BACKUP_DIR)"
  exit 1
fi

# 최신 백업 폴더 안에 war 있는지 확인
BK_WAR="$LATEST_DIR/$WAR_NAME"
if [[ ! -f "$BK_WAR" ]]; then
  echo "실패: 최신 백업에 $WAR_NAME 이 없습니다. ($BK_WAR)"
  exit 1
fi

# 롤백 실행(덮어쓰기)
echo "[1] 롤백 대상 백업 -> $BK_WAR"
echo "[2] 롤백 배포 -> $DEST"
cp "$BK_WAR" "$DEST"

# 톰캣 컨테이너 재시작
echo "[3] 톰캣 컨테이너 재시작 -> $TOMCAT_CONTAINER"
docker restart "$TOMCAT_CONTAINER" >/dev/null

# 롤백 성공여부 확인
echo "[4] 헬스체크 -> $HEALTH_URL (최대 ${TIMEOUT_SEC}초)"
for ((i=0; i< TIMEOUT_SEC; i+=2)); do
  if curl -fsS "$HEALTH_URL" 2>/dev/null | grep -q "UP"; then
    echo "성공"
    exit 0
  fi
  sleep 2
done

echo "실패: 헬스체크 타임아웃"
exit 1
