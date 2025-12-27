#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/wardeploy.env"

echo "== wardeploy down =="

# Docker 연결 체크
if ! docker info >/dev/null 2>&1; then
  echo "실패: Docker 엔진에 연결할 수 없습니다. Docker Desktop을 실행해주세요."
  exit 1
fi

DOCKER_DIR="$ROOT_DIR/docker"
COMPOSE_FILE="$DOCKER_DIR/compose.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "실패: compose.yml을 찾을 수 없습니다. ($COMPOSE_FILE)"
  exit 1
fi

cd "$DOCKER_DIR"
docker compose down

echo "완료: Tomcat 컨테이너를 내렸습니다."
