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

## Docker 개발 & 배포 흐름
- Docker를 사용하면 애플리케이션을 환경과 함께 컨테이너화하여 어디서나 동일하게 실행 가능

1. 애플리케이션 준비 (Packaging)
    - 무엇을 하는 단계인가?
        - 애플리케이션 코드와 의존성 파일(예: package.py, requirements.txt)을 준비
        - 필요한 설정 파일, 환경 변수 파일, 빌드 스크립트 등을 포함
    - 언제 필요한가?
        - Docker 이미지를 만들기 전에 항상 필요
        - 이미지를 만들기 위해서는 “실행 가능한 코드 + 환경 정보”가 있어야 하기 때문
    - 왜 필요한가?
        - 컨테이너 안에서 애플리케이션이 정상 동작하려면 모든 코드와 라이브러리가 준비되어 있어야 함
        - 패키징되지 않은 코드만으로는 이미지 빌드가 불가능

1. Dockerfile 작성
    - 무엇을 하는 단계인가?
        - 애플리케이션이 실행될 환경을 정의하는 파일 생성
            - 베이스 이미지 선택 (예: python:3.11-slim)
            - 패키지 설치 명령
            - 소스 코드 복사
            - 실행 명령 설정 (예: CMD ["python", "app.py"])
    - 언제 필요한가?
        - 이미지 빌드 전에 필요
        - Dockerfile이 이미지 생성의 설계도 역할을 하기 때문
    - 왜 필요한가?
        - 컨테이너가 어떻게 생기고 어떤 환경에서 실행될지를 Docker에게 알려주기 위해 필요

1. 이미지 빌드 (Build Image)
    - 무엇을 하는 단계인가?
        - Dockerfile과 애플리케이션 패키지를 바탕으로 Docker 이미지를 생성
    - 예시
        ```
        docker build -t my-app:latest .
        ```
    - 언제 필요한가?
        - 컨테이너 실행 전에 필요
        - 이미지가 있어야 컨테이너를 띄울 수 있음
    - 왜 필요한가?
        - 이미지는 배포 가능한 불변의 실행 환경을 제공
        - 여러 환경(개발, 테스트, 운영)에서 동일한 환경을 보장

1. 컨테이너 실행 (Run Container)
    - 무엇을 하는 단계인가?
        - 빌드된 이미지를 기반으로 실제 실행 환경인 컨테이너 생성
    - 예시
        ```
        docker run -p 8080:8080 my-app:latest
        ```
    - 언제 필요한가?
        - 애플리케이션을 실제로 테스트하거나 서비스할 때 필요
    - 왜 필요한가?
        - 컨테이너는 격리된 환경에서 애플리케이션을 실행하므로, 시스템 환경에 영향을 주지 않고 어디서나 동일하게 실행 가능

1. 선택 단계: 이미지 배포 (Push to Registry)
    - 무엇을 하는 단계인가?
        - 생성한 Docker 이미지를 Docker Hub 또는 다른 Registry에 업로드
    - 언제 필요한가?
        - 다른 개발자, 서버, 클라우드 환경에서 동일한 이미지를 사용하려면 필요
    - 왜 필요한가?
        - 이미지 배포를 통해 버전 관리와 공유가 가능
        - 배포 자동화(CI/CD)에도 필수

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

## Dockerfile 작성
- 도커파일의 이름은 `Dockerfile`이 디폴트, 도커에서 공식적으로 인식하는 기본 파일명이기 때문
- Docker는 기본적으로 파일 이름이 Dockerfile일 때 자동으로 인식
- 별도 옵션 없이 아래처럼 명령을 실행 가능
    ```
    docker build .
    ```
- 다른 이름을 사용하려면 빌드할 때 파일 이름을 지정해줘야 함
    - 예를 들어 파일 이름이 MyDockerFile.txt 인 경우
        ```
        docker build -f MyDockerFile.txt .
        ```
- 예시
    ```
    # 1. 기반 이미지 선택
    FROM python:3.10-slim

    # 2. 작업 디렉토리 설정
    WORKDIR /app

    # 3. 파일 복사
    COPY . /app

    # 4. 패키지 설치
    RUN pip install --no-cache-dir -r requirements.txt

    # 5. 컨테이너 시작 시 실행할 명령
    CMD ["python", "hello.py"]
    ```

### Dockerfile 작성 전체 흐름

1. 베이스 이미지 선택 (FROM)
    - 컨테이너가 어떤 환경에서 돌아갈지 결정
        - 어떤 OS를 사용할지
        - 어떤 파이썬 버전을 사용할지
        - 가벼운 이미지인지(full/slim 등)
    - 컨테이너는 기본 OS와 Python이 설치된 “기반 환경” 위에 실행됨
        - 그래서 가장 먼저 FROM이 와야 함
        - Dockerfile 맨 위에 반드시 있어야 하는 이유
    - DockerHub에서 버전 확인 후 선택
        - slim 버전은 운영체제(리눅스)를 최소로 줄여 이미지 크기를 작게 만든 버전
    - FROM은 프로젝트의 개발 환경과 같은 버전으로 선택

1. 작업 디렉토리 및 코드 복사 (WORKDIR, COPY)
    - 컨테이너 내부에서 프로그램이 존재할 위치를 지정
    - 내 PC의 파일을 컨테이너 내부로 복사
    - 내 컴퓨터의 프로젝트 폴더 → 컨테이너의 /app 폴더로 가져가는 과정
    - WORKDIR
        - 컨테이너 안에서 “아래부터 실행할 기본 폴더”를 지정
            ```
            WORKDIR /app
            ```
            - 도커에게 명령: 이 컨테이너 안에서 앞으로의 모든 명령을 `/app`폴더에서 실행해라
                - RUN 명령 → /app 안에서 실행됨
                - COPY 명령 → /app 기준으로 복사됨 (상대경로 기준 처리)
                - CMD 명령 → /app 안에서 실행됨
                - pip 설치 → /app 기준
        - 만약 이걸 안 적으면?
            - / (루트) 경로에서 실행되어 매우 지저분해지고 구조가 망가짐
            - 도커 컨테이너는 일종의 작은 리눅스 컴퓨터
            - 컨테이너 안에서도 “현재 작업 폴더”라는 개념이 있음
            - 리눅스 서버에 접속하면 기본 폴더가 / (루트)
            - 루트에 모든 파일을 놓고 작업하면 지저분해짐, 관리 안됨
            - 관리를 위해 프로젝트 전용 폴더가 필요
            - 그래서 `/app`, `/project`와 같은 프로젝트 디렉토리를 만듬
            - 프로젝트 디렉토리 내부에서만 코드 실행, 패키지 설치, 로그 저장 등의 작업을 수행
    - COPY
        - 내 PC 파일을 컨테이너 안으로 넣는 명령
            ```
            COPY . /app
            ```
            - `COPY [호스트의 파일/폴더] [컨테이너 내의 위치]`
            - `.` → 현재 내 컴퓨터의 프로젝트 폴더
            - `/app`→ 컨테이너 내부의 /app 폴더
            - 내 컴퓨터의 프로젝트 폴더 전체를 컨테이너의 /app 폴더로 복사
    - WORKDIR은 컨테이너에서 프로젝트를 넣어둘 폴더
        - 보통 /app 많이 사용
    - COPY는 현재 폴더 통째로 넣는 것이 일반적
        - 단, .dockerignore 파일로 불필요한 파일 제외 가능

1. 필요한 패키지 설치 (RUN)
    - 컨테이너 안에서 패키지를 설치
    - 예
        ```
        RUN pip install -r requirements.txt
        ```
        - 이 명령은 실제로 컨테이너 안에서 실행되는 명령
        - 마치 Linux 서버에서 pip install 하는 것과 동일
    - 컨테이너에는 앞선 `FROM` 명령으로 OS만 존재
        - 그래서 필요한 패키지를 내부에 설치해야 함
    - 항상 파일 복사 후(COPY 이후) 작성
        - requirements.txt가 먼저 복사되어야 설치가 가능하기 때문
    - RUN 단계는 설치해야 하는 패키지에 따라 달라짐

1. 컨테이너 실행 명령 (CMD)
    - 컨테이너가 “시작될 때 실행할 메인 명령”을 지정
    - 예
        ```
        CMD ["python", "hello.py"]
        ```
        - 컨테이너가 실행되면, 파이썬으로 hello.py를 실행하라는 뜻
    - CMD는 프로그램의 “메인 함수”와 같음
        - 컨테이너는 하나의 목적을 가진 유닛
            - 그래서 컨테이너가 켜지면 무엇을 할지 지정해야 함
        - 예
            - 웹 서버 → CMD ["uvicorn", "app:app"]
            - 스케줄러 → CMD ["python", "scheduler.py"]
            - 크롤러 → CMD ["python", "crawler.py"]
    - 컨테이너의 진입점(main)을 적는 단계
    - CMD는 프로그램의 메인 시작점
        - 컨테이너 실행 시 자동으로 실행될 파일 지정