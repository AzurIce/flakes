# ComfyUI —— 本地跑 MiniMax H3（utensils/comfyui-nix）
# 方案依据：Vault/_Logs/2026-08-28 MiniMax H3 本地运行方案调查 (zcode, GLM-5.3).md
# 关键点：
# - 模型目录放 NVMe（~/Files 所在盘）；/home 是 SATA 盘且仅剩 ~30G，勿放权重
# - 服务以 azurice 身份运行（dataDir 在家目录下，免 root 权限问题）
# - GGUF 等自定义节点已由模块捆绑；H3 走 safetensors 量化路线无需额外节点
{ ... }:
{
  services.comfyui = {
    enable = true;
    gpuSupport = "cuda"; # 4070 Ti SUPER (Ada)；全局 cudaCapabilities 已在 configuration.nix 设为 ["8.9"]
    enableManager = true; # Manager 装进 dataDir/.venv，不污染 nix store
    dataDir = "/home/azurice/Files/comfyui";
    user = "azurice";
    group = "users";
    createUser = false;
    # dataDir 所在盘是独立挂载点，等挂载完成再启动（requiresMounts 要 systemd 单元名）
    requiresMounts = [ "home-azurice-Files.mount" ];
    # Manager 下载节点/模型走本机代理
    environment = {
      http_proxy = "http://127.0.0.1:7890";
      https_proxy = "http://127.0.0.1:7890";
      no_proxy = "127.0.0.1,localhost";
    };
    # 16G 显存档：ComfyUI 默认动态 offload，先不加 --lowvram；OOM 时再开
    # extraArgs = [ "--lowvram" ];
  };
}
