{
  description = "Ollama CUDA (RTX 4070 sm_89 only) for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };

      ollama-cuda = pkgs.callPackage ({ lib
        , buildGoModule
        , fetchFromGitHub
        , buildEnv
        , makeBinaryWrapper
        , stdenv
        , addDriverRunpath
        , nix-update-script
        , cmake
        , gitMinimal
        , cudaPackages
        , autoAddDriverRunpath
        , versionCheckHook
        , writableTmpDirAsHomeHook
        }:

        assert stdenv.hostPlatform.isLinux;
        assert stdenv.hostPlatform.isx86_64;

        let
          # RTX 4070 (Ada) = SM 8.9
          cudaArchitectures = "89";

          cudaLibs = [
            cudaPackages.cuda_cudart
            cudaPackages.libcublas
            cudaPackages.cuda_cccl
          ];

          cudaMajorVersion = lib.versions.major cudaPackages.cuda_cudart.version;

          cudaToolkit = buildEnv {
            name = "cuda-merged-${cudaMajorVersion}";
            paths =
              map lib.getLib cudaLibs
              ++ [
                (lib.getOutput "static" cudaPackages.cuda_cudart)
                (lib.getBin (cudaPackages.cuda_nvcc.__spliced.buildHost or cudaPackages.cuda_nvcc))
              ];
          };

          cudaPath = lib.removeSuffix "-${cudaMajorVersion}" cudaToolkit;

          wrapperArgs = builtins.concatStringsSep " " ([
            "--suffix LD_LIBRARY_PATH : '${addDriverRunpath.driverLink}/lib'"
            "--suffix LD_LIBRARY_PATH : '${lib.makeLibraryPath (map lib.getLib cudaLibs)}'"
          ]);

          goBuild = buildGoModule.override { stdenv = cudaPackages.backendStdenv; };
        in
        goBuild (finalAttrs: {
          pname = "ollama";
          version = "0.17.4";

          src = fetchFromGitHub {
            owner = "ollama";
            repo = "ollama";
            rev = "cc90a035a0cc3ae9bd0c1dc95d42b620e8dcb0e2";
            hash = "sha256-9yJ8Jbgrgiz/Pr6Se398DLkk1U2Lf5DDUi+tpEIjAaI=";
          };

          vendorHash = "sha256-Lc1Ktdqtv2VhJQssk8K1UOimeEjVNvDWePE9WkamCos=";

          proxyVendor = true;

          env = {
            CUDA_PATH = cudaPath;
          };

          nativeBuildInputs = [
            cmake
            gitMinimal
            cudaPackages.cuda_nvcc
            makeBinaryWrapper
            autoAddDriverRunpath
          ];

          buildInputs = cudaLibs;

          postPatch = ''
            substituteInPlace version/version.go \
              --replace-fail 0.0.0 '${finalAttrs.version}'
            rm -rf app || true
          '';

          overrideModAttrs = (_final: _prev: {
            preBuild = "";
          });

          preBuild = ''
            cmake -B build \
              -DCMAKE_SKIP_BUILD_RPATH=ON \
              -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
              -DCMAKE_CUDA_ARCHITECTURES='${cudaArchitectures}'

            cmake --build build -j $NIX_BUILD_CORES
          '';

          postInstall = ''
            mkdir -p $out/lib
            cp -r build/lib/ollama $out/lib/
          '';

          postFixup = ''
            wrapProgram "$out/bin/ollama" ${wrapperArgs}
          '';

          ldflags = [
            "-X=github.com/ollama/ollama/version.Version=${finalAttrs.version}"
            "-X=github.com/ollama/ollama/server.mode=release"
          ];

          doInstallCheck = true;
          nativeInstallCheckInputs = [
            versionCheckHook
            writableTmpDirAsHomeHook
          ];
          versionCheckKeepEnvironment = "HOME";

          passthru = {
            updateScript = nix-update-script { };
          };

          meta = with lib; {
            description = "Ollama (CUDA, sm_89 only) for RTX 4070 on x86_64-linux";
            homepage = "https://github.com/ollama/ollama";
            changelog = "https://github.com/ollama/ollama/releases/tag/v${finalAttrs.version}";
            license = licenses.mit;
            platforms = [ "x86_64-linux" ];
            mainProgram = "ollama";
          };
        })
      ) {};
    in
    {
      packages.${system} = {
        default = ollama-cuda;
        ollama-cuda = ollama-cuda;
      };

      apps.${system}.default = {
        type = "app";
        program = "${ollama-cuda}/bin/ollama";
      };
    };
}
