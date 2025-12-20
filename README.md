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
- Docker 전체 흐름 + GHCR 배포 시각 다이어그램
    ```
    # Docker 전체 흐름 + GHCR 배포

            [Source Code]
                    |
                    v
            +----------------+
            |  Docker Build  |
            |  (Dockerfile)  |
            +----------------+
                    |
                    v
            +--------------+
            | Docker Image |
            +--------------+
                    |
        ----------------------
        |                    |
        v                    v
    [Run Container]        [Docker Tag & Push]
    - Test / Dev            - Tag image for GHCR
    - Local container       - docker tag my-app:latest ghcr.io/user/my-app:1.0
    - Port Mapping (-p)     - docker push ghcr.io/user/my-app:1.0
    - Volume (-v)
        |                   
        v                   
    [Container Running]
    - Accessible via mapped ports
    - Data persisted via volume

    -----------------------------

    [Other Environment / Server]
        |
        v
    [docker pull ghcr.io/user/my-app:1.0]
        |
        v
    [Run Container on new environment]
    ```
    - Docker Build
        - Dockerfile 기반으로 이미지 생성
        - 애플리케이션 + 의존성 + 환경 포함
    - Docker Image
        - 빌드 완료된 이미지
        - 여러 환경에서 동일하게 실행 가능
    - Run Container
        - 호스트에서 컨테이너 실행
        - 포트 매핑(-p)으로 외부 접속
        - 볼륨(-v)으로 데이터 영속화
    - Docker Tag & Push (GHCR)
        - GHCR에 이미지 업로드
        - WSL2에서 로그인하면 PowerShell에서도 동일하게 push 가능
    - Pull & Run on Other Environment
        - 다른 서버나 환경에서 이미지를 내려받아 동일하게 실행 가능

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

    # 3. 의존성 파일 복사
    COPY requirements.txt .

    # 4. 패키지 설치
    RUN pip install --no-cache-dir -r requirements.txt

    # 5. 소스 코드 복사
    COPY . .

    # 5. 컨테이너 시작 시 실행할 명령
    CMD ["python", "hello.py"]
    ```
    - 실무에서 이 흐름을 지키는 이유
        | 항목             | 이유         |
        | -------------- | ---------- |
        | slim 이미지       | 용량 ↓, 보안 ↑ |
        | WORKDIR        | 명확한 구조     |
        | 의존성 먼저 COPY    | 캐시 활용      |
        | --no-cache-dir | 이미지 최적화    |
        | CMD 사용         | 실행 책임 분리   |

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
            - 불필요한 OS 구성 제거 (이미지 용량 ↓, 보안 ↑)
    - FROM은 프로젝트의 개발 환경과 같은 버전으로 선택

1. 작업 디렉토리 설정 (WORKDIR)
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
    - WORKDIR은 컨테이너에서 프로젝트를 넣어둘 폴더
        - 보통 /app 많이 사용

1. 의존성 파일 복사 (COPY)
    - 왜 “전체 파일”이 아니라 “의존성 파일만” 먼저 복사하나요?
        - Docker는 **캐시(Cache)**를 사용합니다.
            - requirements.txt가 안 바뀌면
            - 패키지 설치 단계를 다시 실행하지 않음
            - 그러므로 빌드 속도 압도적으로 빨라짐
    - COPY
        - 내 PC 파일을 컨테이너 안으로 넣는 명령
            ```
            COPY requirements.txt .
            ```
            - `COPY [호스트의 파일/폴더] [컨테이너 내의 위치]`
            - `requirements.txt` → 현재 내 컴퓨터의 의존성 파일
            - `.`→ 컨테이너 내부의 /app 폴더(앞에서 WORKDIR을 /app으로 설정했기 때문)
            - 내 컴퓨터의 의존성 파일을 컨테이너의 /app 폴더로 복사
    - COPY는 현재 폴더 통째로 넣는 것이 일반적
        - 단, .dockerignore 파일로 불필요한 파일 제외 가능

1. 필요한 패키지 설치 (RUN)
    - 컨테이너 안에서 패키지를 설치
    - 예
        ```
        RUN pip install --no-cache-dir -r requirements.txt
        ```
        - 이 명령은 실제로 컨테이너 안에서 실행되는 명령
        - 마치 Linux 서버에서 pip install 하는 것과 동일
        - `--no-cache-dir`: 불필요한 캐시 제거 → 이미지 용량 감소
    - 컨테이너에는 앞선 `FROM` 명령으로 OS만 존재
        - 그래서 필요한 패키지를 내부에 설치해야 함
    - 항상 파일 복사 후(COPY 이후) 작성
        - requirements.txt가 먼저 복사되어야 설치가 가능하기 때문
    - RUN 단계는 설치해야 하는 패키지에 따라 달라짐

1. 소스 코드 복사 (COPY)
    - 전체 파일 복사
        ```
        COPY . .
        ```
        - 내 PC의 프로젝트 폴더 전체를 컨테이너 안의 /app 폴더로 전부 복사
    - 의존성 파일부터 복사 및 설치 후 전체 파일 복사하는 일련의 순서에 대한 이유
        - 코드만 수정하면
            - 패키지 설치는 캐시 사용하고
            - 코드만 빠르게 갱신
        - Docker는 Dockerfile의 한 줄을 하나의 Layer로 인식하는데
            - 한 줄(Layer)의 입력이 이전 빌드와 같으면 다시 실행하지 않고 저장된 캐시를 사용
    - `COPY . .`의 위험성
        - `COPY . .` 은 프로젝트 폴더에 있는 모든 파일을 복사
        - 보통 폴더에는 아래와 같은 것들이 존재
            - .env (DB 비밀번호, API KEY)
            - 등의 민감 정보
        - 그래서 민감 정보를 유출하지 않기 위해 `.dockerignore` 사용
            - 예시
                ```
                # .dockerignore
                .env
                *.key
                *.pem
                secrets/
                ```
        - 불필요한 파일로 이미지가 비대해짐
            - .venv/
            - .git
            - 등의 불필요한 파일이 들어감
    - `.dockerignore`
        - Docker 이미지 빌드 시 제외할 파일과 폴더를 정의하는 설정 파일
        - Docker는 docker build를 실행할 때 빌드 컨텍스트(Build Context) 라는 개념을 사용하며, .dockerignore는 이 빌드 컨텍스트에 포함되지 않을 대상을 지정
        - .dockerignore에 적힌 파일은 Docker 이미지에 절대 포함되지 않음
        - `.gitignore`와의 차이점
            | 구분          | .gitignore | .dockerignore |
            | ----------- | ---------- | ------------- |
            | 대상          | Git        | Docker        |
            | 목적          | 커밋 제외      | 이미지 빌드 제외     |
            | COPY . . 영향 | ❌ 없음       | ✅ 있음          |
            | 보안 영향       | 간접적        | 직접적           |
        - 적용되는 시점
            - Dockerfile이 실행되기 전, 즉 빌드 컨텍스트를 만드는 순간에 적용
            - Dockerfile에 `COPY . .`을 사용하더라도 `.dockerignore`에 포함된 파일은 처음부터 복사 대상이 아님
        - 파일 위치
            - 빌드 컨텍스트의 루트 디렉토리에 위치해야 함
            - Dockerfile과 같은 레벨에 두어야 함
            - 프로젝트 폴더의 일반적인 구조
                ```
                project/
                ├─ Dockerfile
                ├─ .dockerignore
                ├─ .gitignore
                ├─ requirements.txt
                ├─ src/
                └─ .env
                ```
        - `.dockerignore`가 없을 때 발생하는 문제
            - 비밀 정보 유출
                - `.env`, API KEY 등이 이미지에 포함되어 레지스트리에 업로드될 수 있음
            - 이미지 용량 증가
                - `.venv/`, `.git/`, `__pycache__`등이 이미지에 포함되어 빌드/푸쉬/배포 속도 저하
            - 캐시 무효화 증가
                - README 수정 등의 의존성 패키지와 무관한 변경시 불필요한 패키지 재설치 발생
        - 작성 기준
            - 컨테이너 실행에 필요 없는 것은 전부 제외
                - 로컬 개발용 파일
                - 테스트용 데이터
                - 문서
                - 설정 파일
                - 캐시/로그
        

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

## 컨테이너 실행 (Run Container)
- 빌드된 이미지를 기반으로 실제 실행 환경인 컨테이너를 생성
- 예
    ```
    docker run -p 8080:8080 my-app:latest
    ```
- 언제 필요한가?
    - 애플리케이션을 실제로 테스트하거나 서비스할 때 필요
- 왜 필요한가?
    - 컨테이너는 격리된 환경에서 애플리케이션을 실행하므로, 시스템 환경에 영향을 주지 않고 어디서나 동일하게 실행 가능
- 포트 → 외부와 통신 연결
- 볼륨 → 데이터 저장/공유

### 포트(Port) 연결
- 컨테이너 안에서 실행되는 애플리케이션의 네트워크 포트를 호스트 컴퓨터와 연결하는 것
- 언제 필요한가?
    - 컨테이너 안의 애플리케이션을 외부에서 접속하거나 테스트할 때 필요
    - 예: 웹 서버 컨테이너를 브라우저에서 접속하려면 필수
- 왜 필요한가?
    - 컨테이너는 기본적으로 격리되어 있어서 외부에서 바로 접근 불가
    - 포트 매핑을 통해 “호스트 포트 ↔ 컨테이너 포트” 연결이 필요
- 어떻게 사용하는가?
    - docker run 시 -p 호스트포트:컨테이너포트 옵션 사용
        ```
        docker run -p 8080:80 my-app:latest
        ```
        - 호스트 8080번 포트 → 컨테이너 80번 포트
        - 이렇게 하면 브라우저에서 `http://localhost:8080`으로 컨테이너 앱 접속 가능

### 볼륨(Volume) 연결
- 컨테이너와 호스트, 혹은 컨테이너 간에 파일/데이터를 공유하는 방법
- 언제 필요한가?
    - 컨테이너를 삭제해도 데이터를 유지하고 싶을 때
    - 코드 변경 시 컨테이너를 다시 빌드하지 않고 바로 반영하고 싶을 때
- 왜 필요한가?
    - 컨테이너는 기본적으로 일시적인 환경이므로, 데이터를 저장하지 않으면 컨테이너 삭제 시 데이터도 사라짐
    - 볼륨을 사용하면 데이터 영속화와 호스트와의 동기화 가능
- 어떻게 사용하는가?
    - docker run 시 -v 호스트경로:컨테이너경로 옵션 사용
        ```
        docker run -v ./data:/app/data my-app:latest
        ```
        - 호스트 ./data 폴더 ↔ 컨테이너 /app/data 폴더
        - 컨테이너 안에서 변경한 파일이 호스트에도 반영되고, 반대로 호스트 파일 변경도 컨테이너에서 반영됨

## 이미지 배포
- 무엇을 하는 단계인가?
    - 생성한 Docker 이미지를 Docker Hub 또는 다른 Registry에 업로드
- 언제 필요한가?
    - 다른 개발자, 서버, 클라우드 환경에서 동일한 이미지를 사용하려면 필요
- 왜 필요한가?
    - 이미지 배포를 통해 버전 관리와 공유가 가능
    - 배포 자동화(CI/CD)에도 필수

### 컨테이너 레지스트리
- 컨테이너 이미지를 보관, 관리, 공유하는 서버
- Docker 이미지의 저장소
- 왜 필요한가?
    - 이미지를 다른 사람이나 서버와 공유할 때 필요
    - CI/CD 파이프라인에서 자동 배포할 때 필요
    - 여러 환경(개발, 테스트, 운영)에서 동일한 환경을 보장
- 쉽게 비유하면
    - GitHub가 코드 저장소라면, Docker Registry는 컨테이너 이미지 저장소
- 대표적인 컨테이너 레지스트리
    | 이름                            | 종류                | 특징               | 추천 상황                       |
    | ----------------------------- | ----------------- | ---------------- | --------------------------- |
    | **Docker Hub**                | Public / Official | 가장 유명, 공개 이미지 많음 | 오픈 소스 이미지 활용, 간단한 공유        |
    | **AWS ECR**                   | Private           | AWS 환경에 최적화      | AWS EC2, ECS, EKS와 연동       |
    | **GCP Artifact Registry**     | Private           | GCP 환경 최적화       | GCP Compute, GKE 사용 시       |
    | **Azure Container Registry**  | Private           | Azure 환경 최적화     | Azure VM, AKS 사용 시          |
    | **GitHub Container Registry** | Public / Private  | GitHub 계정과 연동    | GitHub Actions CI/CD와 함께 사용 |
- 언제 어떤 레지스트리를 선택할까?
    1. 오픈 소스로 공유할 때 → Docker Hub
    1. 클라우드 환경과 연동 → 해당 클라우드 레지스트리
        - AWS → ECR
        - GCP → Artifact Registry
        - Azure → ACR
    1. Private 이미지 → Private Registry
        - GitHub Container Registry 또는 사내 전용 레지스트리
- 컨테이너 이미지를 레지스트리에 올리는 과정
    - 순서 요약
        ```
        [이미지 빌드 완료]
                ↓
        [레지스트리 로그인]
                ↓
        [이미지 태깅]
                ↓
        [이미지 푸시]
                ↓
        [필요 시 다른 환경에서 Pull 후 컨테이너 실행]
        ```

    1. 레지스트리 로그인
        - Docker Hub
            ```
            docker login
            ```
        - AWS ECR
            ```
            aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
            ```
        - GitHub Container Registry (GHCR)
            ```
            echo <GH_TOKEN> | docker login ghcr.io -u <GitHub_username> --password-stdin
            ```
            - GH_TOKEN은 GitHub Personal Access Token으로, write:packages 권한 필요
            - 윈도우 사용시
                - Docker Desktop + WSL2 통합 구조
                    - Docker Desktop 설치 시, 하나의 Docker Engine을 사용
                    - Windows PowerShell과 WSL2(Ubuntu) 터미널 모두 같은 Docker 엔진에 접근 가능
                    - 즉, 이미지, 컨테이너, 로그인 정보 모두 공유
                - GHCR 인증 정보가 Docker Engine에 저장되므로, vscode의 Windows PowerShell에서도 그대로 사용 가능
                - 별도로 WSL에서 빌드하거나 push할 필요 없음
                - 물론 WSL에서 그대로 태깅, 푸시, 풀 수행 가능

    1. 이미지 태깅(Tag)
        - 레지스트리에 올릴 이름과 버전을 지정
        - Docker Hub
            ```
            docker tag my-app:latest johndoe/my-app:1.0
            ```
        - AWS ECR
            ```
            docker tag my-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:1.0
            ```
        - GHCR
            ```
            docker tag my-app:latest ghcr.io/johndoe/my-app:1.0
            ```
    
    1. 이미지 푸시(Push)
        - 레지스트리에 업로드
        - Docker Hub
            ```
            docker push johndoe/my-app:1.0
            ```
        - AWS ECR
            ```
            docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:1.0
            ```
        - GHCR
            ```
            docker push ghcr.io/johndoe/my-app:1.0
            ```
    
    1. 이미지 풀(Pull)
        - 다른 환경이나 서버에서 이미지를 내려받아 컨테이너 실행 가능
        - Docker Hub
            ```
            docker pull johndoe/my-app:1.0
            ```
        - AWS ECR
            ```
            docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:1.0
            ```
        - GHCR
            ```
            docker pull ghcr.io/johndoe/my-app:1.0
            ```
- 참고
    - GHCR의 경우 리포지토리가 Private일 수 있으므로, GH_TOKEN과 권한 설정이 중요
    - 태그(:latest, :v1.0)를 잘 관리하면 버전별 배포가 편리
    - CI/CD에서는 자동 태그 + 자동 푸시를 설정하면 효율적


# GitHub Container Registry(GHCR)
- GitHub에서 제공하는 컨테이너 이미지 저장소(Container Registry)
- Docker Hub와 비슷하지만, GitHub 계정 및 저장소와 밀접하게 연결되어 있음
- 언제 사용하는가?
    - 팀 프로젝트에서 이미지 버전을 GitHub와 함께 관리하고 싶을 때
    - CI/CD(GitHub Actions)와 연동하여 자동 배포할 때
    - 사내/비공개 이미지를 저장해야 할 때
    - Docker Hub의 Pull 제한 문제를 피하고 싶을 때
- 왜 사용하는가?
    - GitHub 저장소와 자연스럽게 통합됨
    - Private 공개 범위 조정 가능
    - Pull token, 권한 제어가 더 세밀함
    - GitHub Actions로 자동화하기 편함

## GHCR 사용 전체 흐름
- GHCR 사용 전체 흐름
    ```
    [1] Docker 이미지 빌드
                ↓
    [2] GitHub Token 생성 (Fine-grained)
                ↓
    [3] WSL2에서 GHCR 로그인
                ↓
    [4] GHCR 규칙에 맞게 이미지 태깅(tag)
                ↓
    [5] 이미지 Push (GHCR 업로드)
                ↓
    [6] 다른 환경에서 Pull & Run
    ```

## GHCR 사용 준비 - GitHub Token 생성
- GHCR에 로그인하려면 GitHub Token이 필요함
    - Docker는 GHCR에 push할 때 “GitHub Token을 사용한 인증”이 필요
- GitHub Token은 두 종류가 존재
- Fine-grained Token vs Classic Token
    | 항목           | Fine-grained Tokens  | Tokens (Classic) |
    | ------------ | -------------------- | ---------------- |
    | 보안           | **매우 안전** (최소 권한 부여) | 위험 (계정 전체 권한 부여) |
    | 권한 설정        | 저장소별, 패키지별 세밀한 제어    | 전체 패키지 권한 일괄     |
    | GitHub 권장 여부 | **공식 권장**            | 점진적 폐지 예정        |
    | 만료           | 반드시 설정               | 영구 가능            |
    | 사용 추천        | ✔ 강력 추천              | ❌ 가능하면 사용하지 않음   |
- 왜 Fine-grained를 사용해야 하는가?
    - GHCR은 “패키지별 권한”이 중요
    - Fine-grained는 특정 저장소 + 특정 패키지에만 접근 가능
    - 토큰이 유출되어도 피해 범위 최소화
    - GitHub이 공식적으로 권장
- 따라서 GHCR 사용 시 Fine-grained Token 필수

### Fine-grained Token 생성 방법
1. GitHub → Settings
1. Developer settings
1. Personal access tokens → Fine-grained tokens
1. Generate new token
1. 필수 권한 설정
    - Repository access
        - 토큰이 접근할 저장소 선택
        - Contents: Read and Write
        - Metadata: Read
    - Account permissions
        - Packages: Read and Write ← GHCR push/pull 위해 필수

## GHCR 로그인
- PowerShell에서는 echo TOKEN | docker login를 사용하기가 번거롭거나 실패하는 경우가 많음
- WSL2(Ubuntu)에서 로그인하는 것이 가장 안정적
- WSL2에서 GHCR 로그인
    ```
    echo "<MY_GITHUB_TOKEN>" | docker login ghcr.io -u <GitHub_Username> --password-stdin
    ```
- 로그인 성공 메세지 확인
    ```
    Login Succeeded
    ```
- WSL2에서 로그인하면 PowerShell에서도 push/pull 가능
    - Docker Desktop은 Windows PowerShell과 WSL2에서 같은 Docker 엔진을 공유하기 때문
    - 로그인만 WSL에서 하고, 빌드·태깅·푸시는 PowerShell에서 수행 가능
- 이미 로그인되어 있는지 확인하는 방법 (터미널)
    - 방법1: 현재 설정된 자격 증명 파일 직접 보기
        - Linux/WSL 또는 macOS:
            ```
            cat ~/.docker/config.json
            ```
        - Windows PowerShell:
            ```
            type $env:USERPROFILE\.docker\config.json
            ```
        - 여기서 확인할 부분
            - 파일 안에 아래처럼 "ghcr.io"가 있으면 로그인된 상태
                ```
                "auths": {
                    "ghcr.io": {
                        "auth": "xxxxxxxxxx..."
                    }
                }
                ```
            - "auth" 값이 있으면 “이미 인증 정보 저장됨 = 로그인됨”
    - 방법2: docker logout으로 확인
        - 실제로 logout 시도해보면 로그인 여부를 알 수 있음
            ```
            docker logout ghcr.io
            ```
        - 결과1: 로그인되어 있다면
            ```
            Removing login credentials for ghcr.io
            ```
        - 결과2: 로그인되어 있지 않다면
            ```
            Not logged in to ghcr.io
            ```
    - 방법3: Docker Desktop UI에서 확인
        - Docker Desktop은 “GHCR 로그인됨”을 직접적으로 표시하지 않음
        - Docker Desktop의 UI 자체에는 “어떤 레지스트리에 로그인되어 있음”이라는 표시가 없음
        - 간접적으로 확인할 수 있는 방법은 있음
        - Docker Desktop의 설정에서 확인 가능
            - Docker Desktop → Settings → Docker Engine → config.json 조회
            - "auths" 항목 확인
                ```
                "auths": {
                    "ghcr.io": {
                        "auth": "xxxxxxxxxx..."
                    }
                }
                ```

## GHCR 규칙에 맞게 이미지 태깅(tag)
- 형식: `docker tag <로컬_이미지명>:<로컬_버전> ghcr.io/<GitHub_사용자명>/<이미지명>:<버전>`
    ```
    docker tag my-app:latest ghcr.io/johndoe/my-app:1.0
    ```

## 이미지 Push (GHCR 업로드)
- 형식: `docker push ghcr.io/<GitHub_사용자명>/<이미지명>:<버전>`
    ```
    docker push ghcr.io/johndoe/my-app:1.0
    ```

## 다른 환경에서 Pull & Run
- 다른 PC, 서버, Docker가 설치된 어디에서든 가능
- Pull 형식: `docker pull ghcr.io/<GitHub_사용자명>/<이미지명>:<버전>`
    ```
    docker pull ghcr.io/johndoe/my-app:1.0
    ```
- Run 형식: `docker run -p <호스트포트>:<컨테이너포트> ghcr.io/<GitHub_사용자명>/<이미지명>:<버전>`
    ```
    docker run -p 8080:80 ghcr.io/johndoe/my-app:1.0
    ```

## GHCR에 푸시한 이미지는 어디에 저장되나?
- GHCR(GitHub Container Registry)에 푸시하면 GitHub 서버에 저장됨
- 정확히는 GitHub 계정 또는 조직의 컨테이너 레지스트리 공간에 저장됨
- Docker Hub처럼 별도의 서버를 직접 볼 수 있는 구조가 아니라, GitHub의 리포지토리와 연결된 레지스트리에 저장됨
- GHCR에 푸쉬하면, 아래의 URL로 접근 가능
    ```
    https://ghcr.io/<GitHub_사용자명>/<이미지명>:<버전>
    ```
    - `<GitHub_사용자명>` → 계정 또는 조직
    - `<이미지명>` → 저장된 이미지 이름
    - `<버전>` → 태그

### GHCR에서 푸시한 결과를 확인하는 방법
- 방법1: GitHub 웹 UI
    1. GitHub에서 로그인
    1. 왼쪽 메뉴 → Packages 선택 또는 계정 프로필 → Packages
    1. 푸시한 이미지가 리스트로 나타남
        - 각 패키지를 클릭하면
            - 버전(tag)
            - 푸시 날짜
            - Pull 명령어 예시
            - 등을 확인 가능
    1. 즉, GHCR는 GitHub Packages UI를 통해 확인 가능
- 방법2: 터미널에서 확인
    1. Docker CLI 사용
        - docker 이미지를 pull 시도하면 정상 동작 여부로 확인 가능
            ```
            docker pull ghcr.io/<사용자명>/<이미지명>:<버전>
            ```
        - 또는 레지스트리 목록을 조회
            ```
            docker search ghcr.io/<사용자명>/<이미지명>
            ```
    1. GitHub API 사용
        - GitHub의 패키지 API를 통해 계정/조직의 패키지 리스트 확인 가능
            ```
            GET /users/<사용자명>/packages?package_type=container
            ```
            - JSON 형태로 푸시한 이미지와 태그 정보 제공
            - CI/CD나 자동 스크립트에서 유용

# Github Actions
- 왜 필요한가?
    - 개발을 하다 보면 매번 아래와 같은 일을 반복
        - 코드를 푸시했는데 빌드가 깨졌는지 확인
        - 테스트 직접 실행
        - 서버에 배포
    - 사람이 수동으로 하면 실수 + 시간 소요
- Github Actions는 GitHub에서 발생한 이벤트를 계기로 미리 정해둔 작업을 자동으로 실행하는 시스템
    - 자동 빌드
    - 자동 테스트
    - 자동 배포
    - 이것을 통틀어 CI/CD라고 함
        - Continuous Integration / Continuous Deployment
        - 지속 통합 / 지속 배포
- GitHub Actions는 `YAML 파일에 적힌 설계도`를 GitHub가 읽고 실행하는 시스템
    - 자동화 규칙을 코드로 선언하는 방식
    - 왜 YAML을 채택했을까?
        - 사람이 읽기 쉬움
        - 기계가 파싱하기 쉬움
        - 설정 파일에 특화
    - YAML 파일이 존재하고, 정의된 Event가 발생할 때 GitHub Actions가 동작
    - YAML 파일의 위치는 `.github/workflows/파일이름.yml`
        - 이름은 중요하지 않지만, 위치는 절대적으로 고정되어야 함
            - GitHub가 그 경로만 스캔하기 때문
    - YAML 파일 하나가 Workflow 하나를 담당
        - 여러 자동화가 필요하면 여러개의 YAML 파일 사용 가능
- GitHub에서 일어나는 일을 계기로 미리 정의한 작업을 깨끗한 환경에서 자동으로 실행하는 시스템

## 실행 흐름
- 논리적 실행 흐름
    ```
    Workflow ( Event → Job → Step )
    ```

## Workflow
- Workflow 란?
    - 이벤트가 발생했을 때 실행할 작업 시나리오
    - `.github/workflows/이름.yml`
    - 저장소 안에 명시적으로 선언
    - GitHub Actions에서 Workflow는 YAML 파일로 정의되는 최상위 단위이며, Event와 Job은 Workflow 내부에 선언
        - Event는 Workflow의 실행 조건
        - Job은 Workflow가 수행하는 실제 작업 단위
- 예시 구조
    ```
    name: Docker Build Test

    on: push

    jobs:
        build:
            ...
    ```
    - name: UI에 보이는 이름
        - GitHub Actions 탭에 표시

## Event - 언제 실행할 것인가?
- 왜 필요한가?
    - 어떤 상황에서 자동화를 돌릴지 조건이 필요
- Event 란?
    - GitHub에서 발생하는 모든 행동
        - push
        - pull request
        - release
        - issue 생성
        - schedule (cron)
- 예시
    ```
    on:
        push:
            branches: [ main ]
    ```
    - main 브랜치에 코드가 올라오면 자동으로 다음 단계 실행
- 자동화의 출발 버튼

### 이벤트 트리거
- 워크플로를 실행 “시킬지 말지”를 결정
- 이 단계에서 조건 불만족 → 워크플로 자체가 실행 안 됨
- 코드 변경 관련
    | 이벤트                   | 설명                               |
    | --------------------- | -------------------------------- |
    | `push`                | 커밋이 push될 때                      |
    | `pull_request`        | PR 생성 / 수정 / 머지 시                |
    | `pull_request_target` | PR 대상 브랜치 기준 실행 (fork PR, 보안 주의) |
- 수동 / 시간 기반 (자동화 핵심)
    | 이벤트                 | 설명                |
    | ------------------- | ----------------- |
    | `workflow_dispatch` | 수동 실행 버튼 (입력값 가능) |
    | `schedule`          | cron 기반 주기 실행     |
- 릴리즈 / 배포 관련
    | 이벤트                 | 설명                      |
    | ------------------- | ----------------------- |
    | `release`           | GitHub Release 생성/수정/삭제 |
    | `deployment`        | deployment 생성 시         |
    | `deployment_status` | 배포 성공/실패 시              |
- 이슈 / 협업 관련
    | 이벤트             | 설명                     |
    | --------------- | ---------------------- |
    | `issues`        | issue 열기/닫기/수정         |
    | `issue_comment` | issue 또는 PR 댓글         |
    | `discussion`    | GitHub Discussions 이벤트 |
- 저장소 / 설정 관련
    | 이벤트      | 설명                  |
    | -------- | ------------------- |
    | `fork`   | repo fork 시         |
    | `star`   | repo star 찍힐 때      |
    | `watch`  | watch(구독)할 때        |
    | `public` | private → public 전환 |
- 특수 / 고급 이벤트
    | 이벤트                   | 설명                      |
    | --------------------- | ----------------------- |
    | `workflow_call`       | 다른 워크플로에서 호출 (재사용 워크플로) |
    | `repository_dispatch` | 외부 API 호출로 실행           |
    | `check_run`           | GitHub Check 실행 결과      |
    | `check_suite`         | Check 묶음 결과             |

### 이벤트 필터링
- 어떤 경우의 이벤트만 반응할지를 제한
- 이벤트 필터링은 트리거의 하위 조건
- 필터링 목적
    - 불필요한 워크플로 실행 방지를 통해
        - 실행 시간 절약
        - Actions 사용량 절약
        - 의도한 자동화만 실행
- branches / branches-ignore
    - 설명
        | 옵션                | 설명           |
        | ----------------- | ------------ |
        | `branches`        | 특정 브랜치에서만 실행 |
        | `branches-ignore` | 특정 브랜치 제외    |
    - 사용 가능 이벤트
        - push
        - pull_request
    - 예시
        ```
        on:
            push:
                branches: [main, develop]
        ```
- paths / paths-ignore
    - 설명
        | 옵션             | 설명                  |
        | -------------- | ------------------- |
        | `paths`        | 특정 파일/디렉토리 변경 시만 실행 |
        | `paths-ignore` | 특정 경로 변경은 무시        |
    - 사용 가능 이벤트
        - push
        - pull_request
    - 예시
        ```
        on:
            push:
                paths:
                    - "crawler/**"
                    - "Dockerfile"
        ```
- types (이벤트 세부 동작 필터)
    - 이벤트별 `types`
        | 이벤트             | 자주 쓰는 `types`                     |
        | --------------- | --------------------------------- |
        | `pull_request`  | `opened`, `synchronize`, `closed` |
        | `issues`        | `opened`, `edited`, `closed`      |
        | `release`       | `published`, `created`            |
        | `issue_comment` | `created`                         |
    - 사용 가능 이벤트
        - pull_request
        - issues
        - issue_comment
        - release
        - deployment
    - 예시
        ```
        on:
            pull_request:
                types: [opened, synchronize]
        ```
- tags / tags-ignore
    - 설명
        | 옵션            | 설명              |
        | ------------- | --------------- |
        | `tags`        | 특정 태그 push 시 실행 |
        | `tags-ignore` | 특정 태그 제외        |
    - 사용 가능 이벤트
        - push
    - 예시
        ```
        on:
            push:
                tags:
                  - "v*"
        ```

### 실행 제어 로직
- 워크플로가 이미 시작된 뒤, 무엇을 실행할지 결정
- schedule + cron 필터
    - schedule은 필터링 불가
        - branch / path 지정 불가
    - 예시
        ```
        on:
            schedule:
                - cron: "0 */6 * * *"
        ```
    - 항상 default branch 기준 실행
    - 조건 분기는 `if:`로 처리
- workflow_dispatch.inputs 로 입력값 정의
    - 이벤트 필터링이 아니지만 입력값을 제한
- if: 조건
    - 이벤트 필터로 부족하면 job / step 레벨에 `if:`
    - 예시
        ```
        jobs:
            crawl:
                if: github.ref == 'refs/heads/main'
        ```
        ```
        steps:
            - name: Run crawler
              if: github.event_name == 'schedule'
        ```
- matrix
    - 실행 전략
        - job 복제 전략
- continue-on-error
    - 실패 처리
        - job 레벨
        - step 레벨

### ⭐조건/실행 우선순위
1. 이벤트 필터터 (on + branches/paths/tags/typ)
1. Job 단위 조건 (job.if)
1. Step 단위 조건 (step.if)

## Job - 어떤 환경에서 무엇을 할 것인가?
- Job 이란?
    - 하나의 독립된 실행 단위 (하나의 가상 머신)
    - 예시
        ```
        jobs:
            build:
                runs-on: ubuntu-latest
        ```
    - 하나의 Job = 완전히 새로운 컴퓨터
    - 실패해도 다른 Job에 영향을 미치지 않음
- Job 구조
    - 트리구조 + 역할
        ```
        job - 하나의 Runner에서 실행되는 작업 단위
        │
        ├─ runs-on - Job이 실행될 Runner(실행 환경) 선택
        │
        ├─ needs - 이 Job이 의존하는 선행 Job 지정
        │
        ├─ if - Job 실행 여부를 결정하는 조건
        │
        ├─ env - Job 전체에 적용되는 환경 변수
        │
        ├─ permissions - GitHub API 접근 권한 범위 설정
        │
        ├─ timeout-minutes - Job 최대 실행 시간 제한
        │
        ├─ continue-on-error - Job 실패를 Workflow 실패로 처리할지 여부
        │
        ├─ concurrency - 동일 그룹 Job의 동시 실행 제어
        │
        ├─ strategy - Job을 여러 경우로 반복 실행하기 위한 전략
        │   │
        │   ├─ matrix - 여러 값 조합으로 Job을 반복 실행
        │   ├─ fail-fast - 하나 실패 시 나머지 Job 중단 여부
        │   └─ max-parallel - 동시에 실행할 Job 수 제한
        │
        ├─ container - Runner 위에서 사용할 메인 컨테이너 설정
        │   │
        │   ├─ image - 사용할 Docker 이미지
        │   ├─ env - 컨테이너 내부 환경 변수
        │   ├─ ports - 포트 매핑 설정
        │   ├─ options - docker run 옵션 전달
        │   └─ credentials - private registry 인증 정보
        │
        ├─ services - Job에서 함께 사용할 서비스 컨테이너 정의
        │   │
        │   └─ <service-name> - 서비스 컨테이너 식별자
        │       │
        │       ├─ image - 서비스 컨테이너 이미지
        │       ├─ ports - 서비스 포트 노출
        │       ├─ env - 서비스 환경 변수
        │       └─ options - docker run 옵션
        │
        ├─ defaults - Step들의 기본 실행 옵션 설정
        │   │
        │   └─ run - run 타입 Step에 대한 기본값
        │       ├─ shell - 기본 쉘 지정
        │       └─ working-directory - 기본 실행 디렉토리
        │
        ├─ outputs - 이 Job이 외부 Job으로 전달할 결과값 정의
        │
        └─ steps - Job 안에서 실제로 실행되는 명령들의 목록
            │
            └─ step - Job 안에서 순차 실행되는 최소 실행 단위
                │
                ├─ name - 사람이 읽는 Step 이름
                ├─ uses - 재사용 가능한 Action 실행
                ├─ run - 쉘 명령 실행
                ├─ with - Action에 전달할 입력값
                ├─ env - Step 전용 환경 변수
                ├─ if - Step 실행 조건
                ├─ id - Step 식별자 (outputs 참조용)
                ├─ continue-on-error - Step 실패 허용 여부
                ├─ timeout-minutes - Step 최대 실행 시간 제한
                ├─ working-directory - Step 실행 위치
                └─ shell - Step에서 사용할 쉘
        ```

### Runner - 어디서 실행되는가?
- Runner 란?
    - GitHub가 제공하는 가상 머신
    - 혹은 회사 내부 서버 (Self-hosted)
- 예시
    ```
    runs-on: ubuntu-latest
    ```
- 왜 Runner가 필요한가?
    - Job을 실행할 실제 컴퓨터가 필요

### Step - 구체적으로 어떤 단계로 무엇을 하는가?
- Step 이란?
    - Job 안에서 순서대로 실행되는 명령
    - 예시
        ```
        steps:
            - name: Checkout
            - name: Build
            - name: Test
        ```
- 왜 Step 단위인가?
    - 작업을 쪼개야
        - 실패 지점 파악 가능
        - 재사용 가능
        - 가독성 향상

#### Action - 이미 만들어진 도구
- Action 이란?
    - Step에서 사용하는 재사용 가능한 모듈
    - 자주 쓰는 작업을 표준화해서 재사용 가능하게 만든 모듈
    - 예시
        ```
        - uses: actions/checkout@v4
        ```
        - 이미 만들어져 있는 Action(재사용 가능한 작업 묶음)인 `checkout@v4`를 실행
- 구조
    ```
    uses: owner/repository@ref
    ```
    - owner: GitHub 사용자 또는 조직
    - repository: Action이 들어 있는 repo
    - @ref: 버전 (태그 / 브랜치 / 커밋)
- Action의 정체
    - 하나의 GitHub repository
        - 그 repo 안에
            - 실행 스크립트
            - Dockerfile 또는 JS 코드
            - action.yml (입력/출력 정의)
    - 실행 가능한 패키지화된 자동화 코드
- 왜 필요한가?
    - git clone
    - docker login
    - 캐시 설정
    - 등의 동일한 반복 작업을 매번 만들면 비효율적
- uses는 어디서 확인할 수 있나?
    - GitHub Marketplace
    - 공식 Actions
        | Action                     | 역할                  |
        | -------------------------- | ------------------- |
        | `actions/checkout`         | 코드 checkout         |
        | `actions/setup-node`       | Node.js 설치          |
        | `actions/setup-python`     | Python 설치           |
        | `actions/cache`            | 빌드 캐시               |
        | `docker/build-push-action` | Docker build & push |
- uses로 실행되는 Action의 종류
    - JavaScript Action
    - Docker Action
    - Composite Action
        - 여러 step 묶음
        - YAML 재사용
- `uses` vs `run` (언제 무엇을 사용?)
    | 상황                             | 권장     |
    | ------------------------------ | ------ |
    | 표준 작업 (checkout, setup, login) | `uses` |
    | 복잡한 인증 / 설정                    | `uses` |
    | 한두 줄 명령                        | `run`  |
    | 프로젝트 전용 로직                     | `run`  |
- `@ref`
    - 왜 버전을 고정해야 하나?
        - @main → 갑자기 깨질 수 있음
        - @v4 → 안정
- Action 선택 기준
    - 공식 or 유명한가?
        - actions/*
        - docker/*
        - 별점, 사용량
    - 유지보수 중인가?
        - 최근 커밋
        - 최신 GitHub Actions API 사용 여부
    - 최소 권한을 쓰는가?
        - README에 권한 설명 있음?
        - 과도한 token 요구 ❌
    - 입력/출력이 명확한가?
        - with 설명 잘 되어 있음

# Artifact 관리
- Artifact 란?
    - Artifact(아티팩트)는 소프트웨어 개발이나 데이터 처리 과정에서 코드 실행 결과로 생성되는 파일, 데이터, 모델, 보고서 등을 의미
    - 예시
        - CSV, JSON 파일 (result.csv, report.json)
        - 머신러닝 모델 파일 (model.pkl, model.h5)
        - 빌드된 실행 파일 (app.exe, app.jar)
    - 코드가 만들어내는 결과물

## Artifact가 생성되는 과정과 관리
1. 로컬 코드 실행
    - 예시
        ```
        import pandas as pd
        df = pd.DataFrame({'a':[1,2,3]})
        df.to_csv('result.csv', index=False)
        ```
        - result.csv가 artifact 임
    - 관리
        - 프로젝트 폴더 안에 output/ 또는 artifacts/ 폴더를 만들어 저장하면 추적 및 공유가 쉬움

1. Docker 환경에서 Artifact 다루기
    - Dockerfile 예시
        ```
        FROM python:3.11
        WORKDIR /app
        COPY . /app
        RUN pip install pandas
        CMD ["python", "generate_csv.py"]
        ```
    - 컨테이너 실행 후 artifact 확인
        ```
        docker build -t myapp .
        docker run --name myapp-container myapp
        ```
    - artifact를 로컬로 복사
        ```
        docker cp myapp-container:/app/result.csv ./result.csv
        ```
        - `myapp-container`: 컨테이너 이름
        - `/app/result.csv`: 컨테이너 내부 artifact 경로
        - `./result.csv`: 로컬로 내려받을 artifact
    - Docker 안에서 생성된 파일도 artifact이며, docker cp로 로컬로 가져올 수 있dma

1. CI/CD(GitHub Actions)에서 Artifact 활용
    - GitHub Actions 워크플로우 예시
        ```
        name: Build and Generate Artifact

        on: [push]

        jobs:
            build:
                runs-on: ubuntu-latest
                steps:
                - uses: actions/checkout@v3
                - name: Set up Python
                  uses: actions/setup-python@v4
                  with:
                    python-version: 3.11
                - name: Install dependencies
                  run: pip install pandas
                - name: Run script
                  run: python generate_csv.py
                - name: Upload artifact
                  uses: actions/upload-artifact@v3
                  with:
                    name: result-artifact
                    path: result.csv
        ```
        - python generate_csv.py → artifact 생성
        - actions/upload-artifact → GitHub Actions 서버에서 artifact를 저장하고, 나중에 다운로드 가능

# 환경변수 관리
- 환경변수란?
    - 환경변수는 코드 밖에서 프로그램에 값을 전달하는 방법
    - 운영체제(OS)가 관리
    - 프로그램은 `os.getenv("이름")`으로 읽기만 함
- 예시
    ```
    import os
    print(os.getenv("API_KEY"))
    ```

## .env
- 환경변수 파일의 형식
- .env는 로컬 개발용
    - 로컬에서 빠르게 개발하기 위한 용도
    - 실수로 유출되기 쉬움
    - 로컬에서 .env + python-dotenv 조합으로 사용

## Docker에서 환경변수를 다루는 방법
1. `-e` 옵션
- 컨테이너 실행 시 직접 환경변수 전달
- 예시
    ```
    docker run -e API_KEY=secret-value docker-test
    ```
- 특징
    | 장점        | 단점      |
    | --------- | ------- |
    | 간단함       | 자동화에 불편 |
    | 테스트용으로 좋음 | 값 노출 위험 |
- 로컬 테스트용으로 적합

1. --env-file (Docker가 .env를 쓰는 유일한 경우)
- Docker가 .env 파일을 읽어서 환경변수로 변환
- 예시
    ```
    docker run --env-file .env docker-test
    ```
- 특징
    | 장점            | 단점             |
    | ------------- | -------------- |
    | 로컬 개발에 편리     | CI/CD에서는 사용 불가 |
    | `.env` 재사용 가능 | GitHub에 없음     |
- 로컬 Docker 실행에 적합
- Dockerfile은 .env를 읽지 않음
    - `docker run` 단계에서만 가능

1. ARG + ENV (CI/CD에서 핵심)
- 이미지 빌드 시 값을 전달
- 빌드 결과물에 환경변수로 저장
- Dockerfile 예시
    ```
    ARG API_KEY
    ENV API_KEY=${API_KEY}
    ```
- 빌드 명령
    ```
    docker build --build-arg API_KEY=secret .
    ```
- 특징
    | 장점                    | 단점                |
    | --------------------- | ----------------- |
    | GitHub Actions와 궁합 좋음 | 이미지 히스토리에 남을 수 있음 |
- CI/CD 빌드 단계에서 사용

1. Docker에서의 보안 주의사항
- ARG는 빌드 로그 및 이미지 레이어에 남을 수 있음
- 그래서 빌드에는 비밀값을 쓰지 않음
- 실행(run) 단계에서 주입하는 구조를 주로 사용

## GitHub Actions에서 환경변수를 다루는 방법
1. secrets → env (가장 권장)
- GitHub Secrets를 환경변수로 매핑
- 예시
    ```
    jobs:
        build:
            runs-on: ubuntu-latest
            env:
                API_KEY: ${{ secrets.API_KEY }}

            steps:
                - run: python docker-test.py
    ```
- 특징
    | 장점    | 단점        |
    | ----- | --------- |
    | 가장 안전 | GitHub 전용 |
- Python 실행, 테스트 단계에 최적

1. step 단위 env
- 특정 step에서만 환경변수 사용
- 예시
    ```
    - name: Run app
      env:
        API_KEY: ${{ secrets.API_KEY }}
      run: python docker-test.py
    ```
- 최소 권한 원칙에 부합
- 가장 보안 친화적

1. Docker 실행 시 주입
- GitHub Actions → Docker 컨테이너로 전달
- 예시
    ```
    - name: Run container
      run: |
        docker run \
            -e API_KEY=${{ secrets.API_KEY }} \
            docker-test
    ```
- 운영 환경과 가장 유사

1. --build-arg (빌드용)
- 예시
    ```
    - name: Build
      run: |
        docker build \
            --build-arg API_KEY=${{ secrets.API_KEY }} \
            -t docker-test .

    ```

### GitHub Actions의 Secrets란?
- Secrets는 비밀번호, API 키, 토큰 같은 민감한 값을 코드에 직접 적지 않고 GitHub가 안전하게 보관해 주는 기능
- 예시
    - AWS_ACCESS_KEY
    - DATABASE_PASSWORD
    - API_TOKEN
- 이 값들은 저장소 코드에서는 보이지 않고, GitHub Actions 실행 중에만 사용 가능
- Secrets를 저장소에 추가하는 과정
    1. GitHub 저장소로 이동
        - GitHub에 로그인
        - 환경변수를 사용하고 싶은 Repository(저장소) 클릭
    1. Settings 메뉴 클릭
        - 저장소 상단 탭에서 Settings 클릭
    1. Secrets 설정 화면으로 이동
        - 왼쪽 메뉴에서 순서대로 클릭
            ```
            Security → Secrets and variables → Actions
            ```
    1. 새 Secret 추가
        - New repository secret 버튼 클릭 후 아래 항목 작성
            | 항목         | 설명               |
            | ---------- | ---------------- |
            | **Name**   | 환경변수 이름 (대문자 권장) |
            | **Secret** | 실제 값 (비밀번호, 키 등) |
            - 예시
                ```
                Name: DATABASE_PASSWORD
                Secret: my-super-secret-password
                ```
        - Save
            - Save한 시점부터 Secret 저장됨
- Secrets를 GitHub Actions Workflow에서 사용하는 방법
    - GitHub Actions는 .github/workflows/*.yml 파일에 적힌 자동화 시나리오
    - 기본 파일 위치
        ```
        .github/
        └── workflows/
            └── ci.yml
        ```
    - Secrets 불러오는 문법
        ```
        ${{ secrets.SECRET_NAME }}
        ```
    - Secrets를 환경변수로 설정하는 방법 (가장 흔함)
        - step 안에서 설정
            ```
            name: Example Workflow

            on: [push]

            jobs:
                build:
                    runs-on: ubuntu-latest

                    steps:
                        - name: 환경변수 설정 예제
                        run: echo "Hello World"
                        env:
                            DATABASE_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}
            ```
            - DATABASE_PASSWORD라는 환경변수를 GitHub Secrets에 저장된 값으로 설정
            - step 안에서 설정했으므로 해당 step 안에서만 사용 가능
        - job 전체에 설정 (여러 step에서 공통으로 사용할 때)
            ```
            jobs:
                build:
                    runs-on: ubuntu-latest
                    env:
                        DATABASE_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}

                    steps:
                      - name: 사용 예제
                        run: echo "비밀번호 길이: ${#DATABASE_PASSWORD}"
            ```
- 실제 사용 예시
    - Python
        - `*.yml`
            ```
            - name: Run script
            run: python main.py
            env:
                DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
            ```
        - `*.py`
            ```
            import os
            print(os.getenv("DB_PASSWORD"))
            ```

## 로컬, Docker, GitHub Actions 비교
- 비교 표
    | 구분    | 로컬          | Docker      | GitHub Actions |
    | ----- | ----------- | ----------- | -------------- |
    | 저장    | `.env`      | 없음          | GitHub Secrets |
    | 주입 시점 | 실행 전        | run / build | job / step     |
    | 코드 접근 | `os.getenv` | 동일          | 동일             |
    | 보안 수준 | 낮음          | 중           | 높음             |