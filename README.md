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