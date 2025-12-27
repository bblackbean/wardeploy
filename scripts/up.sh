#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/wardeploy.env"

echo "== wardeploy up =="

# 1) Docker 연결 체크: Docker Desktop이 꺼져 있으면 여기서 실패
if ! docker info >/dev/null 2>&1; then
  echo "실패: Docker 엔진에 연결할 수 없습니다. Docker Desktop을 실행해주세요."
  exit 1
fi

# 2) compose.yml 위치로 이동해서 컨테이너 올리기
DOCKER_DIR="$ROOT_DIR/docker"
COMPOSE_FILE="$DOCKER_DIR/compose.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "실패: compose.yml을 찾을 수 없습니다. ($COMPOSE_FILE)"
  exit 1
fi

cd "$DOCKER_DIR"
docker compose up -d

echo "완료: Tomcat 컨테이너가 올라갔습니다."
docker ps --filter "name=${TOMCAT_CONTAINER}" || true
