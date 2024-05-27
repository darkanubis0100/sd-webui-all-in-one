# ��������
$env:PIP_INDEX_URL = "https://mirrors.cloud.tencent.com/pypi/simple"
$env:PIP_EXTRA_INDEX_URL = "https://mirror.baidu.com/pypi/simple"
$env:PIP_FIND_LINKS = "https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html"
$env:PIP_DISABLE_PIP_VERSION_CHECK = 1
$env:PIP_TIMEOUT = 30
$env:PIP_RETRIES = 5
$env:CACHE_HOME = "$PSScriptRoot/InvokeAI/cache"
$env:HF_HOME = "$PSScriptRoot/InvokeAI/cache/huggingface"
$env:MATPLOTLIBRC = "$PSScriptRoot/InvokeAI/cache"
$env:MODELSCOPE_CACHE = "$PSScriptRoot/InvokeAI/cache/modelscope/hub"
$env:MS_CACHE_HOME = "$PSScriptRoot/InvokeAI/cache/modelscope/hub"
$env:SYCL_CACHE_DIR = "$PSScriptRoot/InvokeAI/cache/libsycl_cache"
$env:TORCH_HOME = "$PSScriptRoot/InvokeAI/cache/torch"
$env:U2NET_HOME = "$PSScriptRoot/InvokeAI/cache/u2net"
$env:XDG_CACHE_HOME = "$PSScriptRoot/InvokeAI/cache"
$env:PIP_CACHE_DIR = "$PSScriptRoot/InvokeAI/cache/pip"
$env:PYTHONPYCACHEPREFIX = "$PSScriptRoot/InvokeAI/cache/pycache"
$env:INVOKEAI_ROOT = "$PSScriptRoot/InvokeAI/invokeai"


# ��Ϣ���
function Print-Msg ($msg) {
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")][InvokeAI-Installer]:: $msg"
}

Print-Msg "��ʼ����"

# ��������
$env:NO_PROXY = "localhost,127.0.0.1,::1"
if (!(Test-Path "$PSScriptRoot/disable_proxy.txt")) { # ����Ƿ�����Զ����þ���Դ
    $internet_setting = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    if (Test-Path "$PSScriptRoot/proxy.txt") { # ���ش��ڴ�������
        $proxy_value = Get-Content "$PSScriptRoot/proxy.txt"
        $env:HTTP_PROXY = $proxy_value
        $env:HTTPS_PROXY = $proxy_value
        Print-Msg "��⵽���ش��� proxy.txt ���������ļ�, �Ѷ�ȡ���������ļ������ô���"
    } elseif ($internet_setting.ProxyEnable -eq 1) { # ϵͳ�����ô���
        $env:HTTP_PROXY = "http://$($internet_setting.ProxyServer)"
        $env:HTTPS_PROXY = "http://$($internet_setting.ProxyServer)"
        Print-Msg "��⵽ϵͳ�����˴���, �Ѷ�ȡϵͳ�еĴ������ò����ô���"
    }
} else {
    Print-Msg "��⵽���ش��� disable_proxy.txt ���������ļ�, �����Զ����ô���"
}


# ���ز���ѹpython
function Install-Python {
    # $url = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip"
    # $url = "https://gitee.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/python-3.10.11-embed-amd64.zip"
    $url = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2Fpython-3.10.11-embed-amd64.zip"

    # ����python
    Print-Msg "�������� Python"
    Invoke-WebRequest -Uri $url -OutFile "./InvokeAI/python-3.10.11-embed-amd64.zip"
    if ($?) { # ����Ƿ����سɹ�����ѹ
        # ����python�ļ���
        if (!(Test-Path "./InvokeAI/python")) {
            New-Item -ItemType Directory -Force -Path ./InvokeAI/python > $null
        }
        # ��ѹpython
        Print-Msg "���ڽ�ѹ Python"
        Expand-Archive -Path "./InvokeAI/python-3.10.11-embed-amd64.zip" -DestinationPath "./InvokeAI/python" -Force
        Remove-Item -Path "./InvokeAI/python-3.10.11-embed-amd64.zip"
        Modify-PythonPath
        Print-Msg "Python ��װ�ɹ�"
    } else {
        Print-Msg "Python ��װʧ��, ��ֹ InvokeAI ��װ����, �ɳ����������� InvokeAI Installer ����ʧ�ܵİ�װ"
        pause
        exit 1
    }
}


# �޸�python310._pth�ļ�������
function Modify-PythonPath {
    Print-Msg "�޸� python310._pth �ļ�����"
    $content = @("python310.zip", ".", "", "# Uncomment to run site.main() automatically", "import site")
    Set-Content -Path "./InvokeAI/python/python310._pth" -Value $content
}


# ����python��pipģ��
function Install-Pip {
    # $url = "https://bootstrap.pypa.io/get-pip.py"
    # $url = "https://gitee.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/get-pip.py"
    $url = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2Fget-pip.py"

    # ����get-pip.py
    Print-Msg "�������� get-pip.py"
    Invoke-WebRequest -Uri $url -OutFile "./InvokeAI/get-pip.py"
    if ($?) { # ����Ƿ����سɹ�
        # ִ��get-pip.py
        Print-Msg "ͨ�� get-pip.py ��װ Pip ��"
        ./InvokeAI/python/python.exe ./InvokeAI/get-pip.py --no-warn-script-location
        if ($?) { # ����Ƿ�װ�ɹ�
            Remove-Item -Path "./InvokeAI/get-pip.py"
            Print-Msg "Pip ��װ�ɹ�"
        } else {
            Remove-Item -Path "./InvokeAI/get-pip.py"
            Print-Msg "Pip ��װʧ��, ��ֹ InvokeAI ��װ����, �ɳ����������� InvokeAI Installer ����ʧ�ܵİ�װ"
            pause
            exit 1
        }
    } else {
        Print-Msg "���� get-pip.py ʧ��"
        Print-Msg "Pip ��װʧ��, ��ֹ InvokeAI ��װ����, �ɳ����������� InvokeAI Installer ����ʧ�ܵİ�װ"
        pause
        exit 1
    }
}


# ��װinvokeai
function Install-InvokeAI {
    # ����InvokeAI
    Print-Msg "�������� InvokeAI"
    ./InvokeAI/python/python.exe -m pip install "InvokeAI[xformers]"  --no-warn-script-location --use-pep517
    if ($?) { # ����Ƿ����سɹ�
        Print-Msg "InvokeAI ��װ�ɹ�"
    } else {
        Print-Msg "InvokeAI ��װʧ��, ��ֹ InvokeAI ��װ����, �ɳ����������� InvokeAI Installer ����ʧ�ܵİ�װ"
        pause
        exit 1
    }
}


# ��װxformers
function Reinstall-Xformers {
    $env:PIP_EXTRA_INDEX_URL="https://mirror.sjtu.edu.cn/pytorch-wheels/cu121"
    $env:PIP_FIND_LINKS="https://mirror.sjtu.edu.cn/pytorch-wheels/cu121/torch_stable.html"
    $pip_cmd = "$PSScriptRoot/InvokeAI/python/pip.exe"
    $xformers_pkg = $(./InvokeAI/python/Scripts/pip.exe freeze | Select-String -Pattern "xformers") # ����Ƿ�װ��xformers
    $xformers_pkg_cu118 = $xformers_pkg | Select-String -Pattern "cu118" # ����Ƿ�汾Ϊcu118��

    if (Test-Path "./InvokeAI/cache/xformers.txt") {
        # ��ȡxformers.txt�ļ�������
        Print-Msg "��ȡ�ϴε� xFormers �汾��¼"
        $xformers_ver = Get-Content "./InvokeAI/cache/xformers.txt"
    }

    for ($i = 1; $i -le 3; $i++) {
        if ($xformers_ver) { # ���ش��ڰ汾��¼���ϴΰ�װxformersδ��ɣ�
            Print-Msg "��װ: $xformers_ver"
            ./InvokeAI/python/python.exe -m pip uninstall xformers -y
            ./InvokeAI/python/python.exe -m pip install $xformers_ver --no-warn-script-location --no-cache-dir --no-deps
            if ($?) {
                Remove-Item -Path "./InvokeAI/cache/xformers.txt"
                Print-Msg "��װ xFormers �ɹ�"
                break
            } else {
                Print-Msg "��װ xFormers ʧ��"
            }
        } elseif ($xformers_pkg) { # �Ѱ�װ��xformers
            if ($xformers_pkg_cu118) { # ȷ��xformers�Ƿ�Ϊcu118�İ汾
                Print-Msg "��⵽�Ѱ�װ�� xFormers Ϊ CU118 �İ汾, ��������װ"
                $xformers_pkg = $xformers_pkg.ToString().Split("+")[0]
                $xformers_pkg > ./InvokeAI/cache/xformers.txt # ���汾��Ϣ���ڱ��أ����ڰ�װʧ��ʱ�ָ�
                ./InvokeAI/python/python.exe -m pip uninstall xformers -y
                ./InvokeAI/python/python.exe -m pip install $xformers_pkg --no-warn-script-location --no-cache-dir --no-deps
                if ($?) {
                    Remove-Item -Path "./InvokeAI/cache/xformers.txt"
                    Print-Msg "��װ xFormers �ɹ�"
                    break
                } else {
                    Print-Msg "��װ xFormers ʧ��"
                }
            } else {
                Print-Msg "������װ xFormers"
                break
            }
        } else {
            Print-Msg "δ��װ xFormers, ���԰�װ��"
            ./InvokeAI/python/python.exe -m pip install xformers --no-warn-script-location --no-cache-dir --no-deps
            if ($?) { # ����Ƿ����سɹ�
                Print-Msg "��װ xFormers �ɹ�"
                break
            } else {
                Print-Msg "��װ xFormers ʧ��"
            }
        }

        if ($i -ge 3) { # �������Դ���ʱ������ʾ
            Print-Msg "xFormers δ�ܳɹ���װ, ����ܵ���ʹ�� InvokeAI ʱ�Դ�ռ��������, �ɳ����������� InvokeAI Installer ����ʧ�ܵİ�װ"
            break
        } else {
            Print-Msg "�������°�װ xFormers ��"
        }
    }
}


# ����pypatchmatch
function Install-PyPatchMatch {
    # PyPatchMatch
    # https://github.com/invoke-ai/PyPatchMatch/releases/download/0.1.1/libpatchmatch_windows_amd64.dll
    # https://github.com/invoke-ai/PyPatchMatch/releases/download/0.1.1/opencv_world460.dll
    # $url_1 = "https://gitee.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/libpatchmatch_windows_amd64.dll"
    # $url_2 = "https://gitee.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/opencv_world460.dll"
    $url_1 = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2Flibpatchmatch_windows_amd64.dll"
    $url_2 = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2Fopencv_world460.dll"

    if (!(Test-Path "./InvokeAI/python/Lib/site-packages/patchmatch/libpatchmatch_windows_amd64.dll")) {
        Print-Msg "���� libpatchmatch_windows_amd64.dll ��"
        Invoke-WebRequest -Uri $url_1 -OutFile "./InvokeAI/cache/libpatchmatch_windows_amd64.dll"
        if ($?) {
            Move-Item -Path "./InvokeAI/cache/libpatchmatch_windows_amd64.dll" -Destination "./InvokeAI/python/Lib/site-packages/patchmatch/libpatchmatch_windows_amd64.dll"
            Print-Msg "���� libpatchmatch_windows_amd64.dll �ɹ�"
        } else {
            Print-Msg "���� libpatchmatch_windows_amd64.dll ʧ��"
        }
    } else {
        Print-Msg "�������� libpatchmatch_windows_amd64.dll"
    }

    if (!(Test-Path "./InvokeAI/python/Lib/site-packages/patchmatch/opencv_world460.dll")) {
        Print-Msg "���� opencv_world460.dll ��"
        Invoke-WebRequest -Uri $url_2 -OutFile "./InvokeAI/cache/opencv_world460.dll"
        if ($?) {
            Move-Item -Path "./InvokeAI/cache/opencv_world460.dll" -Destination "./InvokeAI/python/Lib/site-packages/patchmatch/opencv_world460.dll"
            Print-Msg "���� opencv_world460.dll �ɹ�"
        } else {
            Print-Msg "���� opencv_world460.dll ʧ��"
        }
    } else {
        Print-Msg "�������� opencv_world460.dll"
    }
}


# ��װ
function Check-Install {
    if (!(Test-Path "./InvokeAI")) {
        New-Item -ItemType Directory -Path "./InvokeAI" > $null
    }

    if (!(Test-Path "./InvokeAI/cache")) {
        New-Item -ItemType Directory -Path "./InvokeAI/cache" > $null
    }

    Print-Msg "����Ƿ�װ Python"
    $pythonPath = "./InvokeAI/python/python.exe"
    if (Test-Path $pythonPath) {
        Print-Msg "Python �Ѱ�װ"
    } else {
        Print-Msg "Python δ��װ"
        Install-Python
    }

    Print-Msg "����Ƿ�װ Pip"
    $pipPath = "./InvokeAI/python/Scripts/pip.exe"
    if (Test-Path $pipPath) {
        Print-Msg "Pip �Ѱ�װ"
    } else {
        Print-Msg "Pip δ��װ"
        Install-Pip
    }

    Print-Msg "����Ƿ�װ InvokeAI"
    $invokeaiPath = "./InvokeAI/python/Scripts/invokeai-web.exe"
    if (Test-Path $invokeaiPath) {
        Print-Msg "InvokeAI �Ѱ�װ"
    } else {
        Print-Msg "InvokeAI δ��װ"
        Install-InvokeAI
    }

    Print-Msg "����Ƿ���Ҫ��װ xFormers"
    Reinstall-Xformers

    Print-Msg "����Ƿ���Ҫ��װ PyPatchMatch"
    Install-PyPatchMatch
}


# �����ű�
function Write-Launch-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI-Installer]:: `$msg`"
}
Print-Msg `"��ʼ����`"

# ��������
`$env:NO_PROXY = `"localhost,127.0.0.1,::1`"
if (!(Test-Path `"`$PSScriptRoot/disable_proxy.txt`")) { # ����Ƿ�����Զ����þ���Դ
    `$internet_setting = Get-ItemProperty -Path `"HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings`"
    if (Test-Path `"`$PSScriptRoot/proxy.txt`") { # ���ش��ڴ�������
        `$proxy_value = Get-Content `"`$PSScriptRoot/proxy.txt`"
        `$env:HTTP_PROXY = `$proxy_value
        `$env:HTTPS_PROXY = `$proxy_value
        Print-Msg `"��⵽���ش��� proxy.txt ���������ļ�, �Ѷ�ȡ���������ļ������ô���`"
    } elseif (`$internet_setting.ProxyEnable -eq 1) { # ϵͳ�����ô���
        `$env:HTTP_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        `$env:HTTPS_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        Print-Msg `"��⵽ϵͳ�����˴���, �Ѷ�ȡϵͳ�еĴ������ò����ô���`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_proxy.txt ���������ļ�, �����Զ����ô���`"
}

# Huggingface ����Դ
if (!(Test-Path `"`$PSScriptRoot/disable_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

`$env:PIP_INDEX_URL = `"https://mirrors.cloud.tencent.com/pypi/simple`"
`$env:PIP_EXTRA_INDEX_URL = `"https://mirror.baidu.com/pypi/simple`"
`$env:PIP_FIND_LINKS = `"https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html`"
`$env:PIP_DISABLE_PIP_VERSION_CHECK = 1
`$env:PIP_TIMEOUT = 30
`$env:PIP_RETRIES = 5
`$env:CACHE_HOME = `"`$PSScriptRoot/cache`"
`$env:HF_HOME = `"`$PSScriptRoot/cache/huggingface`"
`$env:MATPLOTLIBRC = `"`$PSScriptRoot/cache`"
`$env:MODELSCOPE_CACHE = `"`$PSScriptRoot/cache/modelscope/hub`"
`$env:MS_CACHE_HOME = `"`$PSScriptRoot/cache/modelscope/hub`"
`$env:SYCL_CACHE_DIR = `"`$PSScriptRoot/cache/libsycl_cache`"
`$env:TORCH_HOME = `"`$PSScriptRoot/cache/torch`"
`$env:U2NET_HOME = `"`$PSScriptRoot/cache/u2net`"
`$env:XDG_CACHE_HOME = `"`$PSScriptRoot/cache`"
`$env:PIP_CACHE_DIR = `"`$PSScriptRoot/cache/pip`"
`$env:PYTHONPYCACHEPREFIX = `"`$PSScriptRoot/cache/pycache`"
`$env:INVOKEAI_ROOT = `"`$PSScriptRoot/invokeai`"

Print-Msg `"��ʹ��������� http://127.0.0.1:9090 ��ַ������ InvokeAI �Ľ���`"
Print-Msg `"��ʾ: ���������, ��������ܻ���ʾ����ʧ�ܣ�������Ϊ InvokeAI δ�������, �����ڵ����� PowerShell �в鿴 InvokeAI ����������, �ȴ� InvokeAI ������ɺ�ˢ���������ҳ����`"
Print-Msg `"��ʾ����� PowerShell ���泤ʱ�䲻�������� InvokeAI δ���������Գ��԰��¼��λس���`"
Start-Sleep -Seconds 2
Print-Msg `"����������򿪵�ַ��`"
Start-Process `"http://127.0.0.1:9090`"
Print-Msg `"���� InvokeAI ��`"
./python/Scripts/invokeai-web.exe --root `"`$PSScriptRoot/invokeai`"
Print-Msg `"InvokeAI �ѽ�������`"
pause
"

    Set-Content -Path "./InvokeAI/launch.ps1" -Value $content
}


# ���½ű�
function Write-Update-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI-Installer]:: `$msg`"
}

# ��������
`$env:NO_PROXY = `"localhost,127.0.0.1,::1`"
if (!(Test-Path `"`$PSScriptRoot/disable_proxy.txt`")) { # ����Ƿ�����Զ����þ���Դ
    `$internet_setting = Get-ItemProperty -Path `"HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings`"
    if (Test-Path `"`$PSScriptRoot/proxy.txt`") { # ���ش��ڴ�������
        `$proxy_value = Get-Content `"`$PSScriptRoot/proxy.txt`"
        `$env:HTTP_PROXY = `$proxy_value
        `$env:HTTPS_PROXY = `$proxy_value
        Print-Msg `"��⵽���ش��� proxy.txt ���������ļ�, �Ѷ�ȡ���������ļ������ô���`"
    } elseif (`$internet_setting.ProxyEnable -eq 1) { # ϵͳ�����ô���
        `$env:HTTP_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        `$env:HTTPS_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        Print-Msg `"��⵽ϵͳ�����˴���, �Ѷ�ȡϵͳ�еĴ������ò����ô���`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_proxy.txt ���������ļ�, �����Զ����ô���`"
}

# Huggingface ����Դ
if (!(Test-Path `"`$PSScriptRoot/disable_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

# ��������
`$env:PIP_INDEX_URL = `"https://mirrors.cloud.tencent.com/pypi/simple`"
`$env:PIP_EXTRA_INDEX_URL = `"https://mirror.baidu.com/pypi/simple`"
`$env:PIP_FIND_LINKS = `"https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html`"
`$env:PIP_DISABLE_PIP_VERSION_CHECK = 1
`$env:PIP_TIMEOUT = 30
`$env:PIP_RETRIES = 5
`$env:CACHE_HOME = `"`$PSScriptRoot/cache`"
`$env:HF_HOME = `"`$PSScriptRoot/cache/huggingface`"
`$env:MATPLOTLIBRC = `"`$PSScriptRoot/cache`"
`$env:MODELSCOPE_CACHE = `"`$PSScriptRoot/cache/modelscope/hub`"
`$env:MS_CACHE_HOME = `"`$PSScriptRoot/cache/modelscope/hub`"
`$env:SYCL_CACHE_DIR = `"`$PSScriptRoot/cache/libsycl_cache`"
`$env:TORCH_HOME = `"`$PSScriptRoot/cache/torch`"
`$env:U2NET_HOME = `"`$PSScriptRoot/cache/u2net`"
`$env:XDG_CACHE_HOME = `"`$PSScriptRoot/cache`"
`$env:PIP_CACHE_DIR = `"`$PSScriptRoot/cache/pip`"
`$env:PYTHONPYCACHEPREFIX = `"`$PSScriptRoot/cache/pycache`"
`$env:INVOKEAI_ROOT = `"`$PSScriptRoot/invokeai`"

Print-Msg `"���� InvokeAI ��`"
./python/Scripts/pip.exe install invokeai --upgrade --no-warn-script-location --use-pep517
if (`$?) {
    Print-Msg `"InvokeAI ���³ɹ�`"
    Print-Msg `"InvokeAI ������־��https://github.com/invoke-ai/InvokeAI/releases/latest`"
} else {
    Print-Msg `"InvokeAI ����ʧ��`"
}
pause
"

    Set-Content -Path "./InvokeAI/update.ps1" -Value $content
}


# ���ݿ��޸�
function Write-InvokeAI-DB-Fix-Script {
    $content = "
`$env:INVOKEAI_ROOT = `"`$PSScriptRoot/invokeai`"
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI-Installer]:: `$msg`"
}

Print-Msg `"�޸� InvokeAI ���ݿ���`"
./python/Scripts/invokeai-db-maintenance.exe --operation all --root `"`$PSScriptRoot/invokeai`"
Print-Msg `"�޸� InvokeAI ���ݿ����`"
pause
"

    Set-Content -Path "$PSScriptRoot/InvokeAI/fix_db.ps1" -Value $content
}


# ��ȡ��װ�ű�
function Write-InvokeAI-Install-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI-Installer]:: `$msg`"
}

# ��������
`$env:NO_PROXY = `"localhost,127.0.0.1,::1`"
if (!(Test-Path `"`$PSScriptRoot/disable_proxy.txt`")) { # ����Ƿ�����Զ����þ���Դ
    `$internet_setting = Get-ItemProperty -Path `"HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings`"
    if (Test-Path `"`$PSScriptRoot/proxy.txt`") { # ���ش��ڴ�������
        `$proxy_value = Get-Content `"`$PSScriptRoot/proxy.txt`"
        `$env:HTTP_PROXY = `$proxy_value
        `$env:HTTPS_PROXY = `$proxy_value
        Print-Msg `"��⵽���ش��� proxy.txt ���������ļ�, �Ѷ�ȡ���������ļ������ô���`"
    } elseif (`$internet_setting.ProxyEnable -eq 1) { # ϵͳ�����ô���
        `$env:HTTP_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        `$env:HTTPS_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        Print-Msg `"��⵽ϵͳ�����˴���, �Ѷ�ȡϵͳ�еĴ������ò����ô���`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_proxy.txt ���������ļ�, �����Զ����ô���`"
}

# Huggingface ����Դ
if (!(Test-Path `"`$PSScriptRoot/disable_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

# ���õ�����Դ
`$urls = @(`"https://github.com/licyk/sd-webui-all-in-one/raw/main/invokeai_installer.ps1`", `"https://gitlab.com/licyk/sd-webui-all-in-one/-/raw/main/invokeai_installer.ps1`", `"https://github.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/invokeai_installer.ps1`", `"https://gitee.com/licyk/sd-webui-all-in-one/releases/download/invokeai_installer/invokeai_installer.ps1`")
`$count = `$urls.Length
`$i = 0

ForEach (`$url in `$urls) {
    Print-Msg `"�����������µ� InvokeAI Installer �ű�`"
    Invoke-WebRequest -Uri `$url -OutFile `"./cache/invokeai_installer.ps1`"
    if (`$?) {
        if (Test-Path `"../invokeai_installer.ps1`") {
            Print-Msg `"ɾ��ԭ�е� InvokeAI Installer �ű�`"
            Remove-Item `"../invokeai_installer.ps1`" -Force
        }
        Move-Item -Path `"./cache/invokeai_installer.ps1`" -Destination `"../invokeai_installer.ps1`"
        `$parentDirectory = Split-Path `$PSScriptRoot -Parent
        Print-Msg `"���� InvokeAI Installer �ű��ɹ�, �ű�·��Ϊ `$parentDirectory\invokeai_installer.ps1`"
        break
    } else {
        Print-Msg `"���� InvokeAI Installer �ű�ʧ��`"
        `$i += 1
        if (`$i -lt `$count) {
            Print-Msg `"�������� InvokeAI Installer �ű�`"
        }
    }
}
pause
"

    Set-Content -Path "./InvokeAI/get_invokeai_installer.ps1" -Value $content
}


# ���⻷������ű�
function Write-Env-Activate-Script {
    $content = "
function global:prompt {
    `"`$(Write-Host `"[InvokeAI-Env]`" -ForegroundColor Green -NoNewLine) `$(Get-Location)>`"
}

function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI-Installer]:: `$msg`"
}

# ��������
`$env:NO_PROXY = `"localhost,127.0.0.1,::1`"
if (!(Test-Path `"`$PSScriptRoot/disable_proxy.txt`")) { # ����Ƿ�����Զ����þ���Դ
    `$internet_setting = Get-ItemProperty -Path `"HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings`"
    if (Test-Path `"`$PSScriptRoot/proxy.txt`") { # ���ش��ڴ�������
        `$proxy_value = Get-Content `"`$PSScriptRoot/proxy.txt`"
        `$env:HTTP_PROXY = `$proxy_value
        `$env:HTTPS_PROXY = `$proxy_value
        Print-Msg `"��⵽���ش��� proxy.txt ���������ļ�, �Ѷ�ȡ���������ļ������ô���`"
    } elseif (`$internet_setting.ProxyEnable -eq 1) { # ϵͳ�����ô���
        `$env:HTTP_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        `$env:HTTPS_PROXY = `"http://`$(`$internet_setting.ProxyServer)`"
        Print-Msg `"��⵽ϵͳ�����˴���, �Ѷ�ȡϵͳ�еĴ������ò����ô���`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_proxy.txt ���������ļ�, �����Զ����ô���`"
}

# Huggingface ����Դ
if (!(Test-Path `"`$PSScriptRoot/disable_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

# ��������
`$py_path = `"`$PSScriptRoot/python`"
`$py_scripts_path = `"`$PSScriptRoot/python/Scripts`"
`$Env:PATH = `"`$py_path`$([System.IO.Path]::PathSeparator)`$py_scripts_path`$([System.IO.Path]::PathSeparator)`$Env:PATH`" # ��python��ӵ���������
`$env:PIP_INDEX_URL = `"https://mirrors.cloud.tencent.com/pypi/simple`"
`$env:PIP_EXTRA_INDEX_URL = `"https://mirror.baidu.com/pypi/simple`"
`$env:PIP_FIND_LINKS = `"https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html`"
`$env:PIP_DISABLE_PIP_VERSION_CHECK = 1
`$env:PIP_TIMEOUT = 30
`$env:PIP_RETRIES = 5
`$env:CACHE_HOME = `"`$PSScriptRoot/cache`"
`$env:HF_HOME = `"`$PSScriptRoot/cache/huggingface`"
`$env:MATPLOTLIBRC = `"`$PSScriptRoot/cache`"
`$env:MODELSCOPE_CACHE = `"`$PSScriptRoot/cache/modelscope/hub`"
`$env:MS_CACHE_HOME = `"`$PSScriptRoot/cache/modelscope/hub`"
`$env:SYCL_CACHE_DIR = `"`$PSScriptRoot/cache/libsycl_cache`"
`$env:TORCH_HOME = `"`$PSScriptRoot/cache/torch`"
`$env:U2NET_HOME = `"`$PSScriptRoot/cache/u2net`"
`$env:XDG_CACHE_HOME = `"`$PSScriptRoot/cache`"
`$env:PIP_CACHE_DIR = `"`$PSScriptRoot/cache/pip`"
`$env:PYTHONPYCACHEPREFIX = `"`$PSScriptRoot/cache/pycache`"
`$env:INVOKEAI_ROOT = `"`$PSScriptRoot/invokeai`"

Print-Msg `"���� InvokeAI Env`"
Print-Msg `"���������Ϣ���� InvokeAI Installer ��Ŀ��ַ�鿴: https://github.com/licyk/sd-webui-all-in-one/blob/main/invokeai_installer.md`"
"

    Set-Content -Path "./InvokeAI/activate.ps1" -Value $content
}


# �����ĵ�
function Write-ReadMe {
    $content = "==================================
InvokeAI Installer created by licyk
����������https://space.bilibili.com/46497516
Github��https://github.com/licyk
==================================

���ǹ��� InvokeAI �ļ�ʹ���ĵ���

ʹ�� InvokeAI Installer ���а�װ����װ�ɹ��󣬽��ڵ�ǰĿ¼���� InvokeAI �ļ��У�����Ϊ�ļ����в�ͬ�ļ� / �ļ��е����á�

cache�������ļ��У������� Pip / HuggingFace �Ȼ����ļ���
python��Python �Ĵ��·����InvokeAI ��װ��λ���ڴ˴��������Ҫ��װ InvokeAI���ɽ����ļ���ɾ������ʹ�� InvokeAI Installer ���²��� InvokeAI����ע�⣬���𽫸� Python �ļ�����ӵ���������������ܵ��²��������
invokeai��InvokeAI ���ģ�͡�ͼƬ�ȵ��ļ��С�
activate.ps1�����⻷������ű���ʹ�øýű��������⻷���󼴿�ʹ�� Python��Pip��InvokeAI �����
get_invokeai_installer.ps1����ȡ���µ� InvokeAI Installer ��װ�ű������к󽫻����� InvokeAI �ļ���ͬ����Ŀ¼������ invokeai_installer.ps1 ��װ�ű���
update.ps1������ InvokeAI �Ľű�����ʹ�øýű����� InvokeAI��
launch.ps1������ InvokeAI �Ľű���
fix-db.ps1���޸� InvokeAI ���ݿ�ű������ɾ�� InvokeAI ��ͼƬ���ڽ����г�����ЧͼƬ�����⡣
help.txt�������ĵ���


Ҫ���� InvokeAI���� InvokeAI �ļ������ҵ� launch.ps1 �ű����Ҽ�����ű���ѡ��ʹ�� PowerShell ���У��ȴ� InvokeAI ������ɣ�������ɺ��ڿ���̨��ʾ���ʵ�ַ����ַΪ http://127.0.0.1:9090�����õ�ַ�����������ַ�����س������ InvokeAI ���档

InvokeAI Ĭ�ϵĽ�������ΪӢ�ģ��� InvokeAI ���½ǵĳ���ͼ�꣬��� Settings���� Language ѡ��ѡ��������ļ��ɽ�������������Ϊ���ġ�

ʹ�� InvokeAI ʱ�������Ķ����н̳̣��Ը�����˽Ⲣ����ʹ�� InvokeAI �ķ�����
��������ѧϰAI�����滭���˵����ſ� By Yuno779��https://docs.qq.com/doc/p/9a03673f4a0493b4cd76babc901a49f0e6d52140

�ű�Ϊ InvokeAI ������ HuggingFace ����Դ����������޷�ֱ�ӷ��� HuggingFace �����⣬���� InvokeAI ��ģ�͹����޷��� HuggingFace ����ģ�͡�
������Զ��� HuggingFace ����Դ�������ڱ��ش��� mirror.txt �ļ������ļ�����д HuggingFace ����Դ�ĵ�ַ�󱣴棬�ٴ������ű�ʱ���Զ���ȡ���á�
�����Ҫ���� HuggingFace ����Դ���򴴽� disable_mirror.txt �ļ��������ű�ʱ���������� HuggingFace ����Դ��

����Ϊ���õ� HuggingFace ����Դ��ַ��
https://hf-mirror.com
https://huggingface.sukaka.top

��ҪΪ�ű����ô������ڴ�������д�ϵͳ����ģʽ���ɣ������ڱ��ش��� proxy.txt �ļ������ļ�����д�����ַ�󱣴棬�ٴ������ű��ǽ��Զ���ȡ���á�
���Ҫ�����Զ����ô��������ڱ��ش��� disable_proxy.txt �ļ��������ű�ʱ�������Զ����ô���

������ϸ�İ���������������Ӳ鿴��
InvokeAI Installer ʹ�ð�����https://github.com/licyk/sd-webui-all-in-one/blob/main/invokeai_installer.md
InvokeAI �ٷ��ĵ���https://invoke-ai.github.io/InvokeAI
InvokeAI �ٷ���Ƶ�̳̣�https://www.youtube.com/@invokeai
Reddit ������https://www.reddit.com/r/invokeai
"
    Set-Content -Path "./InvokeAI/help.txt" -Value $content
}


# ������
function Main {
    Print-Msg "���� InvokeAI ��װ����"
    Print-Msg "��ʾ: ������ĳ������ִ��ʧ��, �ɳ����ٴ����� InvokeAI Installer"
    Check-Install
    Print-Msg "��������ű����ĵ���"
    Write-Launch-Script
    Write-Update-Script
    Write-InvokeAI-DB-Fix-Script
    Write-InvokeAI-Install-Script
    Write-Env-Activate-Script
    Write-ReadMe
    Print-Msg "InvokeAI ��װ����, ��װ·��Ϊ $PSScriptRoot\InvokeAI"
    Print-Msg "���ڸ� InvokeAI �汾�ĸ�����־��https://github.com/invoke-ai/InvokeAI/releases/latest"
    Print-Msg "�����ĵ����� InvokeAI �ļ����в鿴, ˫�� help.txt �ļ����ɲ鿴"
    Print-Msg "�˳� InvokeAI Installer"
}


###################


Main
pause
