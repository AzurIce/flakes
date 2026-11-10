# 与 ComfyUI v0.44.0 requirements.txt 对齐；wheel 哈希来自 PyPI SHA-256。
# 未覆盖的包继续使用 flake.lock 中 comfyui-nix 的固定版本。
{ base }:
base
// {
  comfyui = {
    version = "0.44.0";
    releaseDate = "2026-11-04T01:12:27Z";
    rev = "2c75dc1b379a59e0880619d029607af5169a62ef";
    hash = "sha256-iuuLmC1j4bsoLshCrO+RDcNO2JuvtoKzIqEGpmKNBN0=";
  };
  vendored = base.vendored // {
    frontendPackage = {
      version = "1.57.6";
      url = "https://files.pythonhosted.org/packages/79/f2/2f99e418fa31d7d73d23723d7fce0a4bba2d363ad0fb59ab973d78191ea3/comfyui_frontend_package-1.57.6-py3-none-any.whl";
      hash = "sha256-WTrx15dnzvw1h8hi3Ts9kP8AUwxfgwcVIvj5gHwXU0Y=";
    };
    workflowTemplates = {
      version = "0.11.101";
      url = "https://files.pythonhosted.org/packages/bb/b2/3861b3d803130ea92cf5c079fab88ca6b8cb6785d4a82227507852220adf/comfyui_workflow_templates-0.11.101-py3-none-any.whl";
      hash = "sha256-zjMs0SZ84/ELgF7ZHc4d72nPxlt2pH2qCVTRORygqME=";
    };
    workflowTemplatesCore = {
      version = "0.3.392";
      url = "https://files.pythonhosted.org/packages/ea/4a/afb588e9e43dfb7016ebe7f1eb9bb351174b75afd50c48a700a08212fedf/comfyui_workflow_templates_core-0.3.392-py3-none-any.whl";
      hash = "sha256-Q4cPrmXPuy0gnjArZfrEm7rc7T2rUPGLnW3JV25UU0Y=";
    };
    workflowTemplatesJson = {
      version = "0.1.127";
      url = "https://files.pythonhosted.org/packages/08/92/d5c2c87ce7847c667df98d22b565aef3a4658dc5588e64649deeca510eb1/comfyui_workflow_templates_json-0.1.127-py3-none-any.whl";
      hash = "sha256-o9xSq8OShG0wGg+hKeI6dwsuaDeZVd2UE/gUvdA+w/4=";
    };
    workflowTemplatesMediaAssets01 = {
      version = "0.1.48";
      url = "https://files.pythonhosted.org/packages/7c/4c/39858b7dd6036fae44e15baf6eb5e55671291d25b9e0931bc0956ce12055/comfyui_workflow_templates_media_assets_01-0.1.48-py3-none-any.whl";
      hash = "sha256-dzPtEoZ+lea4s5viC8xzV5wo6X5aRAhv+5d8wsHHjEM=";
    };
    workflowTemplatesMediaAssets02 = {
      version = "0.1.27";
      url = "https://files.pythonhosted.org/packages/91/c2/7e12e783c461aa67376051d42d49ec522164411855ec64bec2ef92cff584/comfyui_workflow_templates_media_assets_02-0.1.27-py3-none-any.whl";
      hash = "sha256-zEpHBgeEXe1tEkB++UtfL+1QCtAecnpgN83JEkqU+L8=";
    };
    embeddedDocs = {
      version = "0.5.16";
      url = "https://files.pythonhosted.org/packages/aa/73/565750a7eefe9ca0690aa855a48aaa4a00d71c6bb79886107e078be40030/comfyui_embedded_docs-0.5.16-py3-none-any.whl";
      hash = "sha256-W+qE7qadY3DDe3Jel+2b43KaQXtB0OF6d3CQAcuVm5Y=";
    };
    comfyKitchen = {
      version = "0.2.40";
      any = {
        url = "https://files.pythonhosted.org/packages/9c/2e/1c6c621a1cd2ba89ae12fe99e095faa50986c0e6485461170732adfcfa6d/comfy_kitchen-0.2.40-py3-none-any.whl";
        hash = "sha256-5YNPLOmTyNXqjAFlAVfGOXQrWijssNlSU3d/MbUkgJk=";
      };
      linuxX86_64 = {
        url = "https://files.pythonhosted.org/packages/5d/40/1871ee8c58eeef8d15cbf49a461eba0775303f2d9eb34c11af7c29e455c1/comfy_kitchen-0.2.40-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        hash = "sha256-63JmZMdyGJ5uznQodkh/E0mWWAi4VHQnkOkAHbt8D50=";
      };
    };
    comfyAimdo = {
      version = "0.6.0";
      any = {
        url = "https://files.pythonhosted.org/packages/e1/b7/4df602266532178ee08e267747a4a31aded7c81738a0c4482303ce004fa2/comfy_aimdo-0.6.0-py3-none-any.whl";
        hash = "sha256-D3HIk/AwMD3qM5/fbjAEFGYdrau7PwPT58WzxKYywPs=";
      };
      linuxX86_64 = {
        url = "https://files.pythonhosted.org/packages/21/7a/d349443e634d56ab3c1d5b279f0d4858e29905234de03171f840258e4a83/comfy_aimdo-0.6.0-cp39-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
        hash = "sha256-M2qWoKq+aQxZVYE6ejAT22cKWGkQreeYzaxLCGTrIqw=";
      };
    };
  };
}
