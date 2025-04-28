{ pkgs, mkEnv, baseEnv, rust-bin }:

let
  # 개별 개발 환경 모듈
  environments = {
    # 기본 개발 환경
    rust = import ./rust.nix { inherit pkgs mkEnv rust-bin; };
    go = import ./go.nix { inherit pkgs mkEnv; };
    py = import ./py.nix { inherit pkgs mkEnv; };

    # 조합 환경들 - 이제 같은 수준에 평면적으로 배치
    fullstack = import ./fullstack.nix {
      inherit pkgs mkEnv;
      environments = self; # 재귀적 참조를 위한 self 전달
    };
  };

  # 재귀적 참조를 위한 self 정의
  self = environments;
  # 모든 환경 반환
in environments
