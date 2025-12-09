# practice_cicd

# Docker
- 프로그램을 환경 문제 없이 어디서나 동일하게 실행할 수 있게 만들어주는 컨테이너 기술
- 개발자가 만든 프로그램을 박스(container)에 담아서 어디서 실행하든 환경 차이 없이 똑같이 돌아가게 함

## 왜 필요한가?
- 보통 발생하는 프로그램 실행 문제
    - Python 버전이 다름
    - 라이브러리 설치 안 돼있음
    - OS가 다름(Windows / Linux / macOS)
- 이런 문제를 해결하기 위해 Docker 같은 컨테이너 기술이 등장

## 컨테이너(container)란?
- 컨테이너는 프로그램 + 필요한 라이브러리 + 실행 환경을 하나로 묶어둔 독립된 작은 컴퓨터 환경
- 예
    - Python 버전 고정
    - 필요한 pip 패키지 포함
    - 특정 OS 환경 포함
- 그래서 어디에서 실행하든 결과가 같음

## 이미지(image)란?
- 이미지는 그 컨테이너의 설계도(템플릿)

## Dockerfile이란?
- 이미지를 어떻게 만들지 적어놓는 파일
- 예
    ```
    FROM python:3.10
    COPY . /app
    RUN pip install -r requirements.txt
    CMD ["python", "crawler.py"]
    ```

## Docker 흐름 요약
- Dockerfile 작성 → 패키징
- Image 빌드(build) → 이미지 생성
- Container 실행(run) → 실제 프로그램 실행
- Registry(GHCR, Docker Hub 등)에 push → 배포

## 설치 및 준비

### WSL2
- Windows Subsystem for Linux 2
- Windows 안에서 Linux 환경을 만들어주는 기능
- 대부분의 서버와 컨테이너가 Linux 기반이므로, 실무 환경과 동일하게 테스트 가능

### WSL2에 Ubuntu 설치
- 실제 Linux 쉘 환경에서 터미널 명령어와 Python 실행 환경을 동일하게 사용하기 위해
- Microsoft Store에서 Ubuntu 검색 후 설치
- 사용자 이름 / 비밀번호는 Ubuntu 로그인, sudo 권한 등 Linux 환경 관리용

### Docker Desktop 설치 및 WSL2 통합
- Docker는 컨테이너를 만들고 실행하는 프로그램이며, Linux 환경에서 정상 동작
- Windows에서 Docker Desktop을 실행하면, 컨테이너는 Linux 환경에서 동작

### VSCode + WSL Extension
- Windows에서 VSCode를 그대로 사용하면서 WSL2 Linux 환경에서 편리하게 코드 작성, 터미널 사용 가능
- 왼쪽 아래 `><`아이콘 - Open a Remote window - Connect to WSL 하면 WSL2 Ubuntu 환경의 VSCode가 실행됨

## 관련 명령어
- Linux 명령어
    - 프로젝트 폴더 생성 및 파일 관련 명령어
    | 명령어          | 소속        | 용도            | 예시                               |
    | ------------ | --------- | ------------- | -------------------------------- |
    | `mkdir`      | Linux/WSL | 새 폴더(디렉토리) 생성 | `mkdir ~/docker-test`            |
    | `cd`         | Linux/WSL | 디렉토리 이동       | `cd ~/docker-test`               |
    | `touch`      | Linux/WSL | 새 파일 생성       | `touch requirements.txt`         |
    | `ls`         | Linux/WSL | 폴더 안 파일 목록 확인 | `ls -l`                          |
    | `cp`         | Linux/WSL | 파일/폴더 복사      | `cp -r /mnt/c/... ~/docker-test` |
    | `nano`/`vim` | Linux/WSL | 파일 편집         | `nano Dockerfile`                |
- Dockerfile 작성 관련 명령어
    - Dockerfile 안에서만 쓰는 명령어
    | Dockerfile 명령어 | 소속         | 용도                 | 예시                                    |
    | -------------- | ---------- | ------------------ | ------------------------------------- |
    | `FROM`         | Dockerfile | 베이스 이미지 지정         | `FROM python:3.11-slim`               |
    | `WORKDIR`      | Dockerfile | 컨테이너 내부 작업 디렉토리 설정 | `WORKDIR /app`                        |
    | `COPY`         | Dockerfile | 파일을 컨테이너 내부로 복사    | `COPY app.py .`                       |
    | `RUN`          | Dockerfile | 컨테이너 빌드 시 명령 실행    | `RUN pip install -r requirements.txt` |
    | `CMD`          | Dockerfile | 컨테이너 실행 시 기본 명령 지정 | `CMD ["python", "app.py"]`            |
- Docker 관련 명령어 (터미널에서 실행)
    - 터미널에서 직접 실행하는 명령어는 Docker 소속
    - WSL2 Linux 터미널에서 실행하면 Linux 환경에서 Docker CLI를 통해 컨테이너 관리 가능
    | 명령어             | 소속         | 용도                   | 예시                                      |
    | --------------- | ---------- | -------------------- | --------------------------------------- |
    | `docker build`  | Docker CLI | Dockerfile 기반 이미지 빌드 | `docker build -t docker-test .`         |
    | `docker images` | Docker CLI | 로컬 이미지 목록 확인         | `docker images`                         |
    | `docker run`    | Docker CLI | 컨테이너 실행              | `docker run --rm docker-test`           |
    | `docker login`  | Docker CLI | 레지스트리 로그인            | `docker login ghcr.io`                  |
    | `docker push`   | Docker CLI | 이미지 업로드              | `docker push ghcr.io/<사용자>/docker-test` |
- 전체 흐름 기준 명령어 요약
    | 단계               | 명령어                                         | 소속         |
    | ---------------- | ------------------------------------------- | ---------- |
    | 프로젝트 폴더 생성       | `mkdir`, `cd`, `touch`                      | Linux/WSL  |
    | 코드 작성            | `nano`, `vim`                               | Linux/WSL  |
    | Dockerfile 작성    | `FROM`, `WORKDIR`, `COPY`, `RUN`, `CMD`     | Dockerfile |
    | 이미지 빌드 & 컨테이너 실행 | `docker build`, `docker run`                | Docker CLI |
    | 이미지 업로드          | `docker login`, `docker tag`, `docker push` | Docker CLI |