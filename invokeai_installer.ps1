# ��������
$env:PIP_INDEX_URL = "https://mirror.baidu.com/pypi/simple"
$env:PIP_EXTRA_INDEX_URL="https://mirrors.bfsu.edu.cn/pypi/web/simple"
$env:PIP_FIND_LINKS="https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html"
$env:PIP_DISABLE_PIP_VERSION_CHECK = 1
$env:CACHE_HOME="./InvokeAI/cache"
$env:HF_HOME="./InvokeAI/cache/huggingface"
$env:MATPLOTLIBRC="./InvokeAI/cache"
$env:MODELSCOPE_CACHE="./InvokeAI/cache/modelscope/hub"
$env:MS_CACHE_HOME="./InvokeAI/cache/modelscope/hub"
$env:SYCL_CACHE_DIR="./InvokeAI/cache/libsycl_cache"
$env:TORCH_HOME="./InvokeAI/cache/torch"
$env:U2NET_HOME="./InvokeAI/cache/u2net"
$env:XDG_CACHE_HOME="./InvokeAI/cache"
$env:PIP_CACHE_DIR="./InvokeAI/cache/pip"
$env:PYTHONPYCACHEPREFIX="./InvokeAI/cache/pycache"

# ��Ϣ���
function Print-Msg ($msg){
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")][InvokeAI-Installer]:: $msg"
}


# �޸�python310._pth�ļ�������
function Modify-PythonPath {
    Print-Msg "�޸� python310._pth �ļ�����"
    $content = @("python310.zip", ".", "", "# Uncomment to run site.main() automatically", "import site")
    Set-Content -Path "./InvokeAI/python/python310._pth" -Value $content
}


# ���ز���ѹpython
function Install-Python {
    $url = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip"

    # ����python
    Print-Msg "�������� Python"
    Invoke-WebRequest -Uri $url -OutFile "./InvokeAI/python-3.10.11-embed-amd64.zip"
    if ($?){ # ����Ƿ����سɹ�����ѹ
        # ����python�ļ���
        if (Test-Path "./InvokeAI/python"){}else{
            New-Item -ItemType Directory -Force -Path ./InvokeAI/python > $null
        }
        # ��ѹpython
        Print-Msg "���ڽ�ѹ Python"
        Expand-Archive -Path "./InvokeAI/python-3.10.11-embed-amd64.zip" -DestinationPath "./InvokeAI/python"
        Remove-Item -Path "./InvokeAI/python-3.10.11-embed-amd64.zip"
        Modify-PythonPath
        return $true
    }else {
        Print-Msg "���� Python ʧ��"
        return $false
    }
}


# ����python��pipģ��
function Install-Pip {
    $url = "https://bootstrap.pypa.io/get-pip.py"

    # ����get-pip.py
    Print-Msg "�������� get-pip.py"
    Invoke-WebRequest -Uri $url -OutFile "./InvokeAI/get-pip.py"
    if ($?){ # ����Ƿ����سɹ�
        # ִ��get-pip.py
        Print-Msg "ͨ�� get-pip.py ��װ Pip ��"
        ./InvokeAI/python/python.exe ./InvokeAI/get-pip.py --no-warn-script-location
        if ($?){ # ����Ƿ�װ�ɹ�
            Remove-Item -Path "./InvokeAI/get-pip.py"
            return $true
        }else {
            Remove-Item -Path "./InvokeAI/get-pip.py"
            return $false
        }
    }else {
        Print-Msg "���� get-pip.py ʧ��"
        return $false
    }
}


# ��װinvokeai
function Install-InvokeAI {
    # ����InvokeAI
    Print-Msg "�������� InvokeAI"
    ./InvokeAI/python/python.exe -m pip install "InvokeAI[xformers]"  --no-warn-script-location --use-pep517
    if ($?){ # ����Ƿ����سɹ�
        return $true
    }else {
        return $false
    }
}


# ��װxformers
function Reinstall-Xformers {
    $env:PIP_EXTRA_INDEX_URL="https://mirror.sjtu.edu.cn/pytorch-wheels/cu121"
    $env:PIP_FIND_LINKS="https://mirror.sjtu.edu.cn/pytorch-wheels/cu121/torch_stable.html"
    $pip_cmd = "$PSScriptRoot/InvokeAI/python/pip.exe"
    $xformers_pkg = $(./InvokeAI/python/Scripts/pip.exe freeze | Select-String -Pattern "xformers") # ����Ƿ�װ��xformers
    $xformers_pkg_cu118 = $xformers_pkg | Select-String -Pattern "cu118" # ����Ƿ�汾Ϊcu118��

    if (Test-Path "./InvokeAI/cache/xformers.txt"){
        # ��ȡxformers.txt�ļ�������
        Print-Msg "��ȡ�ϴε� xFormers �汾��¼"
        $xformers_ver = Get-Content "./InvokeAI/cache/xformers.txt"
    }

    if ($xformers_ver) { # ���ش��ڰ汾��¼���ϴΰ�װxformersιδ��ɣ�
        Print-Msg "��װ: $xformers_ver"
        ./InvokeAI/python/python.exe -m pip uninstall xformers -y
        ./InvokeAI/python/python.exe -m pip install $xformers_ver --no-warn-script-location --no-cache-dir
        if ($?){
            Remove-Item -Path "./InvokeAI/cache/xformers.txt"
            Print-Msg "��װ xFormers �ɹ�"
        }else {
            Print-Msg "��װ xFormers ʧ��, ����ܵ���ʹ�� InvokeAI ʱ�Դ�ռ��������"
        }
    }elseif ($xformers_pkg){ # �Ѱ�װ��xformers
        if ($xformers_pkg_cu118){ # ȷ��xformers�Ƿ�Ϊcu118�İ汾
            Print-Msg "��⵽�Ѱ�װ�� xFormers Ϊ CU118 �İ汾, ��������װ"
            $xformers_pkg = $xformers_pkg.ToString().Split("+")[0]
            $xformers_pkg > ./InvokeAI/cache/xformers.txt # ���汾��Ϣ���ڱ��أ����ڰ�װʧ��ʱ�ָ�
            ./InvokeAI/python/python.exe -m pip uninstall xformers -y
            ./InvokeAI/python/python.exe -m pip install $xformers_pkg --no-warn-script-location --no-cache-dir
            if ($?){
                Remove-Item -Path "./InvokeAI/cache/xformers.txt"
                Print-Msg "��װ xFormers �ɹ�"
            }else {
                Print-Msg "��װ xFormers ʧ��, ����ܵ���ʹ�� InvokeAI ʱ�Դ�ռ��������"
            }
        }else{
            Print-Msg "������װ xFormers"
        }
    }else{
        Print-Msg "δ��װ xFormers, ���԰�װ��"
        ./InvokeAI/python/python.exe -m pip install xformers --no-warn-script-location --no-cache-dir
        if ($?){ # ����Ƿ����سɹ�
            Print-Msg "��װ xFormers �ɹ�"
        }else {
            Print-Msg "��װ xFormers ʧ��, ����ܵ���ʹ�� InvokeAI ʱ�Դ�ռ��������"
        }
    }
}


# ��װ
function Check-Install {
    if (Test-Path "./InvokeAI"){}else{
        New-Item -ItemType Directory -Path "./InvokeAI" > $null
    }
    Print-Msg "����Ƿ�װ�� Python"
    $pythonPath = "./InvokeAI/python/python.exe"
    if (Test-Path $pythonPath) {
        Print-Msg "Python �Ѱ�װ"
    }else {
        Print-Msg "Python δ��װ"
        if (Install-Python){ # ����Ƿ�װ�ɹ�
            Print-Msg "Python ��װ�ɹ�"
        }else {
            Print-Msg "Python ��װʧ��, ��ֹ InvokeAI ��װ����"
            pause
            exit 1
        }
    }

    Print-Msg "����Ƿ�װ Pip"
    $pipPath = "./InvokeAI/python/Scripts/pip.exe"
    if (Test-Path $pipPath) {
        Print-Msg "Pip �Ѱ�װ"
    }else {
        Print-Msg "Pip δ��װ"
        if (Install-Pip){ # ����Ƿ�װ�ɹ�
            Print-Msg "Pip ��װ�ɹ�"
        }else {
            Print-Msg "Pip ��װʧ��, ��ֹ InvokeAI ��װ����"
            pause
            exit 1
        }
    }

    Print-Msg "����Ƿ�װ InvokeAI"
    $invokeaiPath = "./InvokeAI/python/Scripts/invokeai-web.exe"
    if (Test-Path $invokeaiPath) {
        Print-Msg "InvokeAI �Ѱ�װ"
    }else {
        Print-Msg "InvokeAI δ��װ"
        if (Install-InvokeAI){ # ����Ƿ�װ�ɹ�
            Print-Msg "InvokeAI ��װ�ɹ�"
        }else {
            Print-Msg "InvokeAI ��װʧ��, ��ֹ InvokeAI ��װ����"
            pause
            exit 1
        }
    }

    Print-Msg "����Ƿ���Ҫ��װ xFormers"
    Reinstall-Xformers
}


# �����ű�
function Write-Launch-Script {
    $content = @(
        "`$env:PIP_INDEX_URL = `"https://mirror.baidu.com/pypi/simple`""
        "`$env:PIP_FIND_LINKS = `"https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html`""
        "`$env:HF_ENDPOINT = `"https://hf-mirror.com`" # Huggingface ����Դ, ����ʹ���������Դʱ����ע�͵�"
        "`$env:PIP_DISABLE_PIP_VERSION_CHECK = 1"
        "`$env:CACHE_HOME = `"./invokeai/cache`""
        "`$env:HF_HOME = `"./invokeai/cache/huggingface`""
        "`$env:MATPLOTLIBRC = `"./invokeai/cache`""
        "`$env:MODELSCOPE_CACHE = `"./invokeai/cache/modelscope/hub`""
        "`$env:MS_CACHE_HOME = `"./invokeai/cache/modelscope/hub`""
        "`$env:SYCL_CACHE_DIR = `"./invokeai/cache/libsycl_cache`""
        "`$env:TORCH_HOME = `"./invokeai/cache/torch`""
        "`$env:U2NET_HOME = `"./invokeai/cache/u2net`""
        "`$env:XDG_CACHE_HOME = `"./invokeai/cache`""
        "`$env:PIP_CACHE_DIR = `"./invokeai/cache/pip`""
        "`$env:PYTHONPYCACHEPREFIX = `"./invokeai/cache/pycache`""
        "Write-Host `"���� InvokeAI ��`""
        "./python/Scripts/invokeai-web.exe --root invokeai"
    )

    Set-Content -Path "./InvokeAI/launch.ps1" -Value $content
}


# ���½ű�
function Write-Update-Script {
    $content = @(
        "`$env:PIP_INDEX_URL = `"https://mirror.baidu.com/pypi/simple`""
        "`$env:PIP_FIND_LINKS = `"https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html`""
        "`$env:CACHE_HOME = `"./invokeai/cache`""
        "`$env:HF_HOME = `"./invokeai/cache/huggingface`""
        "`$env:MATPLOTLIBRC = `"./invokeai/cache`""
        "`$env:MODELSCOPE_CACHE = `"./invokeai/cache/modelscope/hub`""
        "`$env:MS_CACHE_HOME = `"./invokeai/cache/modelscope/hub`""
        "`$env:SYCL_CACHE_DIR = `"./invokeai/cache/libsycl_cache`""
        "`$env:TORCH_HOME = `"./invokeai/cache/torch`""
        "`$env:U2NET_HOME = `"./invokeai/cache/u2net`""
        "`$env:XDG_CACHE_HOME = `"./invokeai/cache`""
        "`$env:PIP_CACHE_DIR = `"./invokeai/cache/pip`""
        "`$env:PYTHONPYCACHEPREFIX = `"./invokeai/cache/pycache`""
        "Write-Host `"���� InvokeAI ��`""
        "./python/Scripts/pip.exe install invokeai --upgrade --no-warn-script-location --use-pep517"
        "Write-Host `"InvokeAI �������`""
        "pause"
    )

    Set-Content -Path "./InvokeAI/update.ps1" -Value $content
}


# ���ݿ��޸�
function Write-InvokeAI-DB-Fix-Script {
    $content = @(
        "Write-Host `"�޸� InvokeAI ���ݿ���`""
        "./python/Scripts/invokeai-db-maintenance.exe --operation all --root invokeai"
        "Write-Host `"�޸� InvokeAI ���ݿ����`""
        "pause"
    )

    Set-Content -Path "./InvokeAI/fix-db.ps1" -Value $content
}


# ��ȡ��װ�ű�
function Write-InvokeAI-Install-Script {
    $content = "
`$url = `"https://github.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/invokeai_installer.ps1`"
Write-Host `":: �������� InvokeAI Installer �ű�`"
Invoke-WebRequest -Uri `$url -OutFile `"../invokeai_installer.ps1`"
if (`$?){
    Write-Host `":: ���� InvokeAI Installer �ű��ɹ�`"
}else{
    Write-Host `":: ���� InvokeAI Installer �ű�ʧ��`"
}
pause
    "

    Set-Content -Path "./InvokeAI/get_invokeai_installer.ps1" -Value $content
}


# ���⻷������ű�
function Write-Env-Activate-Script {
    $content = "
function global:prompt {
    `"`$(Write-Host `"[InvokeAI-Env]`" -ForegroundColor Green -NoNewLine) `$(Get-Location) > `"
}

# ��������
`$py_path = `"`$PSScriptRoot/python`"
`$py_scripts_path = `"`$PSScriptRoot/python/Scripts`"
`$Env:PATH = `"`$py_path`$([System.IO.Path]::PathSeparator)`$py_scripts_path`$([System.IO.Path]::PathSeparator)`$Env:PATH`" # ��python��ӵ���������
`$env:PIP_INDEX_URL = `"https://mirror.baidu.com/pypi/simple`"
`$env:PIP_FIND_LINKS = `"https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html`"
`$env:HF_ENDPOINT = `"https://hf-mirror.com`" # Huggingface ����Դ, ����ʹ���������Դʱ����ע�͵�
`$env:CACHE_HOME = `"`$PSScriptRoot/invokeai/cache`"
`$env:HF_HOME = `"`$PSScriptRoot/invokeai/cache/huggingface`"
`$env:MATPLOTLIBRC = `"`$PSScriptRoot/invokeai/cache`"
`$env:MODELSCOPE_CACHE = `"`$PSScriptRoot/invokeai/cache/modelscope/hub`"
`$env:MS_CACHE_HOME = `"`$PSScriptRoot/invokeai/cache/modelscope/hub`"
`$env:SYCL_CACHE_DIR = `"`$PSScriptRoot/invokeai/cache/libsycl_cache`"
`$env:TORCH_HOME = `"`$PSScriptRoot/invokeai/cache/torch`"
`$env:U2NET_HOME = `"`$PSScriptRoot/invokeai/cache/u2net`"
`$env:XDG_CACHE_HOME = `"`$PSScriptRoot/invokeai/cache`"
`$env:PIP_CACHE_DIR = `"`$PSScriptRoot/invokeai/cache/pip`"
`$env:PYTHONPYCACHEPREFIX = `"`$PSScriptRoot/invokeai/cache/pycache`"

Write-Host `":: ���� InvokeAI-Env`"
Write-Host `":: �����ĵ����� help.txt �ļ��в鿴`"
Write-Host `":: ���������Ϣ������Ŀ��ַ�鿴: https://github.com/licyk/sd-webui-all-in-one/blob/main/invokeai_installer.md`"
"

    Set-Content -Path "./InvokeAI/activate.ps1" -Value $content
}

# �����ĵ�
function Write-ReadMe {
    $content = "
����������https://space.bilibili.com/46497516
��ϸ��ʹ�ð�����https://github.com/licyk/sd-webui-all-in-one/blob/main/invokeai_installer.md

���ǹ��� InvokeAI ��ʹ���ĵ���

ʹ�� InvokeAI Installer ���а�װ����װ�ɹ��󣬽��ڵ�ǰĿ¼���� InvokeAI �ļ��У�����Ϊ�ļ����в�ͬ�ļ� / �ļ��е����á�

- cache�������ļ��У������� Pip / HuggingFace �Ȼ����ļ���
- python��Python �Ĵ��·����InvokeAI ��װ��λ���ڴ˴��������Ҫ��װ InvokeAI���ɽ����ļ���ɾ������ʹ�� InvokeAI Installer ���²��� InvokeAI����ע�⣬���𽫸� Python �ļ�����ӵ���������������ܵ��²��������
- invokeai��InvokeAI ���ģ�͡�ͼƬ�ȵ��ļ��С�
- activate.ps1�����⻷������ű���ʹ�øýű��������⻷��������ʹ�� InvokeAI��
- get_invokeai_installer.ps1����ȡ���µ� InvokeAI Installer ��װ�ű������к󽫻����� InvokeAI �ļ���ͬ����Ŀ¼������ invokeai_installer.ps1 ��װ�ű���
- update.ps1������ InvokeAI �Ľű�����ʹ�øýű����� InvokeAI��
- launch.ps1������ InvokeAI �Ľű���
- fix-db.ps1���޸� InvokeAI ���ݿ�ű������ɾ�� InvokeAI ��ͼƬ���ڽ����г�����ЧͼƬ�����⡣
- help.txt�������ĵ���ʹ�ø��ļ��鿴�����ĵ���

ʹ�� InvokeAI ǰ�������Ķ����н̳̣��Ը�����˽Ⲣ����ʹ�� InvokeAI �ķ�����
��������ѧϰAI�����滭���˵����ſ� By Yuno779��https://docs.qq.com/doc/p/9a03673f4a0493b4cd76babc901a49f0e6d52140

�ű�Ϊ InvokeAI ������ HuggingFace ����Դ����������޷�ֱ�ӷ��� HuggingFace �����⣬���� InvokeAI ��ģ�͹����޷��� HuggingFace ����ģ�͡�
����Լ��д�������ʹ�� HuggingFace ����Դ�����Խ� launcher.ps1 �е� `$env:HF_ENDPOINT = `"https://hf-mirror.com`" ��һ��ע�͵����ɡ�
    "
    Set-Content -Path "./InvokeAI/help.txt" -Value $content
}


# ������
function Main {
    Print-Msg "���� InvokeAI ��װ����"
    Check-Install    
    Print-Msg "��������ű����ĵ���"
    Write-Launch-Script
    Write-Update-Script
    Write-InvokeAI-DB-Fix-Script
    Write-InvokeAI-Install-Script
    Write-Env-Activate-Script
    Write-ReadMe
    Print-Msg "InvokeAI ��װ����, ��װ·��Ϊ $PSScriptRoot\InvokeAI"
    Print-Msg "�����ĵ����� InvokeAI �ļ����в鿴, ˫�� help.txt �ļ����ɲ鿴"
}


# ����������
Main

pause
