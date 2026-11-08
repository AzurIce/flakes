{ pkgs, ... }:

let
  alvrSource = pkgs.fetchFromGitHub {
    owner = "alvr-org";
    repo = "ALVR";
    rev = "e8ca92b15d7c93765f828ca245f26de678c7f154";
    fetchSubmodules = true;
    hash = "sha256-/SSItJltyVw407ZPk47i/WfHWeceSbJv1hg01tIiXds=";
  };
  # 与 nightly 的 prepare-deps 一致，包括 Vulkan RGBx → CUDA 通道数修复。
  alvrFfmpeg = pkgs.ffmpeg_8.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ map
      (name: alvrSource + "/alvr/xtask/patches/${name}")
      [
        "0001-lavu-hwcontext_vulkan-Fix-importing-RGBx-frames-to-C.patch"
        "0002-vaapi_encode-Force-enable-global-header.patch"
        "0003-vaapi_encode_h265-Set-vui_parameters_present_flag.patch"
        "0004-vaapi_encode-Allow-to-dynamically-change-bitrate-and.patch"
        "0005-vaapi_encode-Add-filler_data-option.patch"
        "0006-Add-AV_VAAPI_DRIVER_QUIRK_HEVC_ENCODER_ALIGN_64_16-f.patch"
        "0007-nvenc-honour-colorspace-and-range-for-RGB-input.patch"
        "0008-nvenc-honour-colorspace-and-range-for-RGB-input-AV1-UNTESTED.patch"
      ];
  });
  # 与官方 nightly.2026.11.06 对应的源码，包含 Linux Direct Mode 修复。
  # 复用 nixpkgs 的依赖与打包逻辑；新版已移除旧 compositor wrapper。
  alvrNightly = (pkgs.alvr.override { ffmpeg-alvr = alvrFfmpeg; }).overrideAttrs (_: {
    version = "21.0.0-dev14-nightly-2026-11-06";
    src = alvrSource;
    cargoHash = "sha256-Wj8FVh8X7biYf/Fnjz/9t7jRfG85j9W21Pae5RnXZVA=";
    patches = [ ../../patches/alvr-wired-reconnect.patch ];
    postPatch = ''
      # SteamVR 内的驱动也会调用 ADB，不能依赖用户 shell 的 PATH。
      substituteInPlace alvr/adb/src/commands.rs \
        --replace-fail 'let exe_name = afs::exec_fname("adb").to_owned();' \
          'let exe_name = "${pkgs.android-tools}/bin/adb".to_owned();'
      # 多台 ADB 设备同时在线时，先确认安装了匹配的 ALVR 客户端，
      # 再选择设备并建立转发，避免 NotePro 等非头显抢占串流端口。
      substituteInPlace alvr/adb/src/lib.rs \
        --replace-fail '.find(|s| !s.starts_with("127.0.0.1"))' \
          '.find(|s| !s.starts_with("127.0.0.1") && get_process_name(&self.adb_path, s, client_type).is_some())'
      # 纹理切换时先释放引用旧图像的编码器，再重建图像与帧对象。
      substituteInPlace alvr/server_openvr/cpp/platform/linux/OvrDirectModeComponent.cpp \
        --replace-fail '            enc.createImages(rendererCI);' \
          '            enc.shutdown();
            enc.createImages(rendererCI);'
      # 构造函数抛异常不会调用派生类析构函数，需显式清理 CUDA 引用。
      # 正常析构也先关闭 codec，确保它不再引用随后释放的帧资源。
      substituteInPlace alvr/server_openvr/cpp/platform/linux/EncodePipelineNvEnc.cpp \
        --replace-fail '    // The surface format has to follow the output image' \
          '    try {
    // The surface format has to follow the output image' \
        --replace-fail '    hw_frame = av_frame_alloc();' \
          '    hw_frame = av_frame_alloc();
    if (!hw_frame) {
        throw std::runtime_error("Failed to allocate CUDA frame");
    }
    } catch (...) {
        avcodec_free_context(&encoder_ctx);
        av_frame_free(&hw_frame);
        av_buffer_unref(&hw_ctx);
        throw;
    }' \
        --replace-fail 'alvr::EncodePipelineNvEnc::~EncodePipelineNvEnc() {' \
          'alvr::EncodePipelineNvEnc::~EncodePipelineNvEnc() {
    avcodec_free_context(&encoder_ctx);'
      # 临时黑屏诊断：记录实际提交层及纹理；marker 可在运行中关闭 warp 做对照。
      substituteInPlace alvr/server_openvr/cpp/platform/linux/OvrDirectModeComponent.cpp \
        --replace-fail '    m_submitLayer = 0;' '
    static unsigned long diagFrame = 0;
    if ((diagFrame++ % 360) == 0) {
        if (FILE* f = fopen("/tmp/alvr-directmode-diagnostic.log", "a")) {
            fprintf(f, "frame=%lu layers=%d sync=%llu state=%d\n", diagFrame, m_submitLayer, (unsigned long long)syncTexture, (int)m_encoderState.load());
            for (int l = 0; l < m_submitLayer; ++l) {
                for (int e = 0; e < 2; ++e) {
                    auto const& eye = m_submitLayers[l][e];
                    auto it = m_handleMap.find(eye.hTexture);
                    fprintf(f, " layer=%d eye=%d handle=%llu bounds=%g,%g,%g,%g", l, e, (unsigned long long)eye.hTexture, eye.bounds.uMin, eye.bounds.vMin, eye.bounds.uMax, eye.bounds.vMax);
                    if (it != m_handleMap.end()) {
                        auto const& r = *it->second.first;
                        fprintf(f, " pid=%u size=%ux%u format=%u slot=%u", r.pid, r.textDesc.nWidth, r.textDesc.nHeight, r.textDesc.nFormat, it->second.second);
                    }
                    fprintf(f, "\n");
                }
            }
            fclose(f);
        }
    }
    m_submitLayer = 0;' \
        --replace-fail 'if (enc.warpCapable()) {' \
          'if (enc.warpCapable() && access("/tmp/alvr-disable-warp", F_OK) != 0) {' \
        --replace-fail '            enc.present(job.leftIdx, job.rightIdx, stampTimestampNs, warpParams, job.waitFds);' '
            static unsigned long diagEncoded = 0;
            if ((diagEncoded++ % 360) == 0) {
                if (FILE* f = fopen("/tmp/alvr-directmode-diagnostic.log", "a")) {
                    fprintf(f, "encoded=%lu slots=%u,%u warp=%u timestamp=%llu -> %llu\n", diagEncoded, job.leftIdx, job.rightIdx, warpParams.enabled, (unsigned long long)job.targetTimestampNs, (unsigned long long)stampTimestampNs);
                    fclose(f);
                }
            }
            enc.present(job.leftIdx, job.rightIdx, stampTimestampNs, warpParams, job.waitFds);'
      substituteInPlace alvr/common/src/version.rs \
        --replace-fail 'Version::parse(env!("CARGO_PKG_VERSION"))' \
          'Version::parse(concat!(env!("CARGO_PKG_VERSION"), "+nightly.2026.11.06"))'
      # 使用 Nix 提供的依赖，避免 xtask 在构建时联网下载。
      mkdir -p deps/linux/ffmpeg/alvr_build/lib deps/linux/vulkan-headers
      ln -s ${pkgs.lib.getDev alvrFfmpeg}/include deps/linux/ffmpeg/alvr_build/include
      ln -s ${pkgs.lib.getDev alvrFfmpeg}/lib/pkgconfig deps/linux/ffmpeg/alvr_build/lib/pkgconfig
      ln -s ${pkgs.lib.getLib alvrFfmpeg}/lib/*.so* deps/linux/ffmpeg/alvr_build/lib/
      ln -s ${pkgs.vulkan-headers}/include deps/linux/vulkan-headers/include
      substituteInPlace alvr/server_openvr/build.rs \
        --replace-fail '.statik(true)' '.statik(false)'
    '';
    cargoBuildFlags = [ "-p" "alvr_dashboard" "-p" "alvr_server_openvr" ];
    # 直接安装 Cargo 产物；新 xtask 的目录布局已不同于 20.14.1。
    postBuild = "";
    postInstall = ''
      install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/libalvr_server_openvr.so \
        $out/lib64/alvr/bin/linux64/driver_alvr_server.so
      install -Dm644 alvr/xtask/resources/driver.vrdrivermanifest $out/lib64/alvr/driver.vrdrivermanifest
      install -Dm644 alvr/xtask/resources/alvr.desktop $out/share/applications/alvr.desktop
      install -Dm644 resources/ALVR-Icon.svg $out/share/icons/hicolor/scalable/apps/alvr.svg
    '';
    # wgpu 通过 dlopen 加载 Vulkan，不能依赖链接器保留其 RUNPATH。
    # 放在 shrink-rpath 之后，避免这个运行时依赖被清掉。
    postFixup = ''
      patchelf --add-rpath ${pkgs.lib.makeLibraryPath [ pkgs.vulkan-loader ]} $out/bin/alvr_dashboard
    '';
  });

  # 单独固定新版 GE-Proton，不为此更新整套 nixpkgs。
  geProton = pkgs.proton-ge-bin.overrideAttrs (_: {
    version = "GE-Proton11-12";
    toolName = "GE-Proton11-12-x86_64";
    steamDisplayName = "GE-Proton11-12";
    src = pkgs.fetchzip {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton11-12/GE-Proton11-12-x86_64.tar.gz";
      hash = "sha256-i20g9lDz7bR0SXWmvHZHztN4m8AHkcD0/OVGSC4ZzI8=";
    };
  });
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      geProton
      dwproton-bin
    ];
  };

  # Wine（nixpkgs staging，wow64）：跑 FFXIV 用，比 XIVLauncher 托管的 wine-xiv 8.5 新得多
  # umu-launcher：Steam 之外跑 Windows 游戏/启动器（umu-run），前缀在 ~/Games/umu/<GAMEID>
  environment.systemPackages = [
    pkgs.wineWow64Packages.staging
    pkgs.umu-launcher
  ];

  # ntsync：内核 6.14+ 的同步原语，wine 10+ 原生支持（帧 pacing 比 esync/fsync 稳）
  # /dev/ntsync 自 6.14（及 6.13.11 回补）起默认 0666，无需额外 udev 规则
  boot.kernelModules = [ "ntsync" ];

  # 32 位图形驱动（steam 通常已隐含开启，显式声明以保 wine 32 位组件可用）
  hardware.graphics.enable32Bit = true;
  services.wivrn = {
    enable = true;
    openFirewall = true;
    highPriority = true;

    # NVIDIA 硬件编码
    package = pkgs.wivrn.override {
      cudaSupport = true;
    };

    # 让 Steam 的运行容器找到 OpenXR runtime
    steam.importOXRRuntimes = true;
  };
  # 与 WiVRn 并存供对照测试；运行时只启动一套 VR runtime。
  # 20.14.1 与新版 SteamVR 有 303 兼容问题，固定包含修复的 nightly。
  programs.alvr = {
    package = alvrNightly;
    enable = true;
    openFirewall = true;
  };
}
