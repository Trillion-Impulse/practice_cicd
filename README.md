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