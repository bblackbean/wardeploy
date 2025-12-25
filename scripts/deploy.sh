#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/wardeploy.env"

# 입력값(배포할 war 경로) 검증
WAR_PATH="${1:?war경로가 필요합니다}"
[[ -f "$WAR_PATH" ]] || { echo "WAR 파일이 없습니다: $WAR_PATH"; exit 1; }

# 배포 목적지 경로 만들기
WAR_NAME="${WAR_CONTEXT}.war"
DEST="${TOMCAT_WEBAPPS}/${WAR_NAME}"

# 필요한 디렉토리(백업 폴더/webapps) 준비
mkdir -p "$BACKUP_DIR" "$TOMCAT_WEBAPPS"

# 백업용 폴더 만들기(시간 스탬프)
STAMP="$(date +"%Y%m%d_%H%M%S")"
BK_DIR="${BACKUP_DIR}/${STAMP}"
mkdir -p "$BK_DIR"

# 기존 war 백업
echo "[1] 기존 WAR 백업 -> $BK_DIR"
if [[ -f "$DEST" ]]; then
  cp "$DEST" "$BK_DIR/"
fi

# 새 war 배포(복사)
echo "[2] 새 WAR 배포 -> $DEST"
cp "$WAR_PATH" "$DEST"

# 톰캣 도커 컨테이너 재시작
echo "[3] 톰캣 컨테이너 재시작 -> $TOMCAT_CONTAINER"
docker restart "$TOMCAT_CONTAINER" >/dev/null

# 헬스체크로 성공 판정(up 나올 때까지 대기)
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
