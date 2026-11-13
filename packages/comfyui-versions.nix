# 与 ComfyUI v0.45.0 requirements.txt 对齐；wheel 哈希来自 PyPI SHA-256。
# 未覆盖的包继续使用 flake.lock 中 comfyui-nix 的固定版本。
{ base }:
base
// {
  comfyui = {
    version = "0.45.0";
    releaseDate = "2026-11-10T15:59:14Z";
    rev = "989d93d0d968e704c589ce0146bb18c77f6b50cc";
    hash = "sha256-2F43abzhKX/fKdmPa+bhS9/hB0q4SqzpVYThKlNwYMU=";
  };
  vendored = base.vendored // {
    frontendPackage = {
      version = "1.58.5";
      url = "https://files.pythonhosted.org/packages/b4/a4/601b1471318e8c72d08d8a715417ef71056729fda0148b3e509091ba3e15/comfyui_frontend_package-1.58.5-py3-none-any.whl";
      hash = "sha256-0etH5aO3GwGR5CsGM8ZuuLNixGwizQA2Uk/R9ayQls4=";
    };
    workflowTemplates = {
      version = "0.11.105";
      url = "https://files.pythonhosted.org/packages/54/4e/c0acdbdd708ca5bfa6f187c73fa1412c550cba724ececff8246a35385ef3/comfyui_workflow_templates-0.11.105-py3-none-any.whl";
      hash = "sha256-CBVFqvLs10zulE3u+GvF/AtdwW3eafX7DG8wV0rbQRo=";
    };
    workflowTemplatesCore = {
      version = "0.3.396";
      url = "https://files.pythonhosted.org/packages/f8/70/7cb403e33d0a55a04eda749864c2dc8a61809663f5dda5c3a874af5a8954/comfyui_workflow_templates_core-0.3.396-py3-none-any.whl";
      hash = "sha256-MaTyY9jPW/EwX4hrjQyhQ4hI0XG9o0hJxj4R7WQWOco=";
    };
    workflowTemplatesJson = {
      version = "0.1.131";
      url = "https://files.pythonhosted.org/packages/5a/7b/eea1e5a7efbd956866fcaa34e7b5a059dc315b5001fc53dc0db74372c7c5/comfyui_workflow_templates_json-0.1.131-py3-none-any.whl";
      hash = "sha256-dKWmGeafpZ+IZEkmJrdlxuSpmZSWqjeVoJDXm+Sq2GM=";
    };
    workflowTemplatesMediaAssets01 = {
      version = "0.1.48";
      url = "https://files.pythonhosted.org/packages/7c/4c/39858b7dd6036fae44e15baf6eb5e55671291d25b9e0931bc0956ce12055/comfyui_workflow_templates_media_assets_01-0.1.48-py3-none-any.whl";
      hash = "sha256-dzPtEoZ+lea4s5viC8xzV5wo6X5aRAhv+5d8wsHHjEM=";
    };
    workflowTemplatesMediaAssets02 = {
      version = "0.1.30";
      url = "https://files.pythonhosted.org/packages/db/05/71be274827559eea9b233ca00c6fd0be836584df9ea30fd68abea7e3b0d9/comfyui_workflow_templates_media_assets_02-0.1.30-py3-none-any.whl";
      hash = "sha256-qfiE/7JbyAW8XQvC+W4DPH9lFjTh7rGIV/4srzdnbdg=";
    };
    embeddedDocs = {
      version = "0.5.16";
      url = "https://files.pythonhosted.org/packages/aa/73/565750a7eefe9ca0690aa855a48aaa4a00d71c6bb79886107e078be40030/comfyui_embedded_docs-0.5.16-py3-none-any.whl";
      hash = "sha256-W+qE7qadY3DDe3Jel+2b43KaQXtB0OF6d3CQAcuVm5Y=";
    };
    comfyKitchen = {
      version = "0.2.41";
      any = {
        url = "https://files.pythonhosted.org/packages/98/50/25c120039731b874daeec5aa771e0787a8acd074aeb2a3354e005a91f067/comfy_kitchen-0.2.41-py3-none-any.whl";
        hash = "sha256-Gb3X+KqjXFEu9pOTA43cpR8DC8q/anaU/fFmC8roxmo=";
      };
      linuxX86_64 = {
        url = "https://files.pythonhosted.org/packages/11/8b/672ecbe36e5e59c559fb8f7ffcce935e283184b08a88313da99d3d3cc0d9/comfy_kitchen-0.2.41-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        hash = "sha256-yhbUxPTN2Pt2r3JhufzEWWshEVEQd9181/SIS18mhq8=";
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
