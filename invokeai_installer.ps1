Set-Location "$PSScriptRoot"
# pip����Դ
$pip_index_mirror = "https://mirrors.cloud.tencent.com/pypi/simple"
$pip_extra_index_mirror = "https://mirror.baidu.com/pypi/simple"
$pip_find_mirror = "https://mirror.sjtu.edu.cn/pytorch-wheels/cu118/torch_stable.html"
$pip_extra_index_mirror_cu121 = "https://mirror.sjtu.edu.cn/pytorch-wheels/cu121"
$pip_find_mirror_cu121 = "https://mirror.sjtu.edu.cn/pytorch-wheels/cu121/torch_stable.html"
# ��������
$env:PIP_INDEX_URL = $pip_index_mirror
$env:PIP_EXTRA_INDEX_URL = $pip_extra_index_mirror
$env:PIP_FIND_LINKS = $pip_find_mirror
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
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")][InvokeAI Installer]:: $msg"
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
    $url = "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/pypatchmatch/python-3.10.11-embed-amd64.zip"

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
        Read-Host | Out-Null
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
    $url = "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/pypatchmatch/get-pip.py"

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
            Read-Host | Out-Null
            exit 1
        }
    } else {
        Print-Msg "���� get-pip.py ʧ��"
        Print-Msg "Pip ��װʧ��, ��ֹ InvokeAI ��װ����, �ɳ����������� InvokeAI Installer ����ʧ�ܵİ�װ"
        Read-Host | Out-Null
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
        Read-Host | Out-Null
        exit 1
    }
}


# ��װxformers
function Reinstall-Xformers {
    $env:PIP_EXTRA_INDEX_URL = $pip_extra_index_mirror_cu121
    $env:PIP_FIND_LINKS = $pip_find_mirror_cu121
    $xformers_pkg = $(./InvokeAI/python/python.exe -m pip freeze | Select-String -Pattern "xformers") # ����Ƿ�װ��xformers
    $xformers_pkg_cu118 = $xformers_pkg | Select-String -Pattern "cu118" # ����Ƿ�汾Ϊcu118��
    $torch_ver = $(./InvokeAI/python/python.exe -m pip show torch | Select-String -Pattern "version") # ��ȡpytorch�汾��Ϣ
    $torch_ver = $torch_ver.ToString().Split(":")[1].Split("+")[0].Trim() # ��ȡpytorch�汾��

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
            switch ($torch_ver) { # �ж��ʺϰ�װ��xformers�汾
                1.12.1 {
                    $install_xformers_ver = "0.0.14"
                }
                1.13.1 {
                    $install_xformers_ver = "0.0.16"
                }
                2.0.0 {
                    $install_xformers_ver = "0.0.18"
                }
                2.0.1 {
                    $install_xformers_ver = "0.0.22"
                }
                2.1.1 {
                    $install_xformers_ver = "0.0.23"
                }
                2.1.1 {
                    $install_xformers_ver = "0.0.23"
                }
                2.1.2 {
                    $install_xformers_ver = "0.0.23.post1"
                }
                2.2.0 {
                    $install_xformers_ver = "0.0.24"
                }
                2.2.1 {
                    $install_xformers_ver = "0.0.25"
                }
                2.2.2 {
                    $install_xformers_ver = "0.0.25"
                }
                2.3.0 {
                    $install_xformers_ver = "0.0.26.post1"
                }
                Default {
                    $install_xformers_ver = ""
                }
            }

            if ($install_xformers_ver -eq "") {
                ./InvokeAI/python/python.exe -m pip install xformers --no-warn-script-location --no-cache-dir --no-deps
            } else {
                ./InvokeAI/python/python.exe -m pip install xformers==$install_xformers_ver --no-warn-script-location --no-cache-dir --no-deps
            }

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
    $url_1 = "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/pypatchmatch/libpatchmatch_windows_amd64.dll"
    $url_2 = "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/pypatchmatch/opencv_world460.dll"

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


# ���������ļ�
function Download-Config-File($url, $path) {
    $length = $url.split("/").length
    $name = $url.split("/")[$length - 1]
    if (!(Test-Path $path)) {
        Print-Msg "���� $name ��"
        Invoke-WebRequest -Uri $url.ToString() -OutFile "./InvokeAI/cache/$name"
        if ($?) {
            Move-Item -Path "./InvokeAI/cache/$name" -Destination "$path"
            Print-Msg "$name ���سɹ�"
        } else {
            Print-Msg "$name ����ʧ��"
        }
    } else {
        Print-Msg "$name �Ѵ���"
    }
}


# Ԥ����ģ�������ļ�
function Get-Model-Config-File {
    Print-Msg "Ԥ����ģ�������ļ���"
    New-Item -ItemType Directory -Path "./InvokeAI/invokeai/configs/stable-diffusion" -Force > $null
    New-Item -ItemType Directory -Path "./InvokeAI/invokeai/configs/controlnet" -Force > $null
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/sd_xl_base.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/sd_xl_base.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/sd_xl_inpaint.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/sd_xl_inpaint.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/sd_xl_refiner.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/sd_xl_refiner.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-finetune.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v1-finetune.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-finetune_style.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v1-finetune_style.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-inference-v.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v1-inference-v.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-inference.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v1-inference.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-inpainting-inference.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v1-inpainting-inference.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-m1-finetune.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v1-m1-finetune.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inference-v.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v2-inference-v.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inference.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v2-inference.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inpainting-inference-v.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v2-inpainting-inference-v.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inpainting-inference.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v2-inpainting-inference.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-midas-inference.yaml" "./InvokeAI/invokeai/configs/stable-diffusion/v2-midas-inference.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/controlnet/cldm_v15.yaml" "./InvokeAI/invokeai/configs/controlnet/cldm_v15.yaml"
    Download-Config-File "https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/controlnet/cldm_v21.yaml" "./InvokeAI/invokeai/configs/controlnet/cldm_v21.yaml"
    Print-Msg "ģ�������ļ��������"
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
    $python_path = "./InvokeAI/python/python.exe"
    if (Test-Path $python_path) {
        Print-Msg "Python �Ѱ�װ"
    } else {
        Print-Msg "Python δ��װ"
        Install-Python
    }

    Print-Msg "����Ƿ�װ Pip"
    ./InvokeAI/python/python.exe -c "import pip" 2> $null
    if ($?) {
        Print-Msg "Pip �Ѱ�װ"
    } else {
        Print-Msg "Pip δ��װ"
        Install-Pip
    }

    Print-Msg "����Ƿ�װ InvokeAI"
    $invokeai_path = "./InvokeAI/python/Scripts/invokeai-web.exe"
    if (Test-Path $invokeai_path) {
        Print-Msg "InvokeAI �Ѱ�װ"
    } else {
        Print-Msg "InvokeAI δ��װ"
        Install-InvokeAI
    }

    # Print-Msg "����Ƿ���Ҫ��װ xFormers"
    # Reinstall-Xformers

    Print-Msg "����Ƿ���Ҫ��װ PyPatchMatch"
    Install-PyPatchMatch

    Print-Msg "����Ƿ���Ҫ����ģ�������ļ�"
    Get-Model-Config-File
}


# �����ű�
function Write-Launch-Script {
    $content = "
Set-Location `"`$PSScriptRoot`"
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
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

`$env:PIP_INDEX_URL = `"$pip_index_mirror`"
`$env:PIP_EXTRA_INDEX_URL = `"$pip_extra_index_mirror`"
`$env:PIP_FIND_LINKS = `"$pip_find_mirror`"
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
`$req = `$?
if (`$req) {
    Print-Msg `"InvokeAI �����˳�`"
} else {
    Print-Msg `"InvokeAI �����쳣, ���˳�`"
}
Read-Host | Out-Null
"

    Set-Content -Path "./InvokeAI/launch.ps1" -Value $content
}


# ���½ű�
function Write-Update-Script {
    $content = "
Set-Location `"`$PSScriptRoot`"
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
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

# ��������
`$env:PIP_INDEX_URL = `"$pip_index_mirror`"
`$env:PIP_EXTRA_INDEX_URL = `"$pip_extra_index_mirror`"
`$env:PIP_FIND_LINKS = `"$pip_find_mirror`"
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
`$ver = `$(./python/python.exe -m pip freeze | Select-String -Pattern `"invokeai`" | Out-String).trim().split(`"==`")[2]
./python/python.exe -m pip install `"InvokeAI[xformers]`" --upgrade --no-warn-script-location --use-pep517
if (`$?) {
    `$ver_ = `$(./python/python.exe -m pip freeze | Select-String -Pattern `"invokeai`" | Out-String).trim().split(`"==`")[2]
    if (`$ver -eq `$ver_) {
        Print-Msg `"InvokeAI ��Ϊ���°棬��ǰ�汾��`$ver_`"
    } else {
        Print-Msg `"InvokeAI ���³ɹ����汾��`$ver -> `$ver_`"
    }
    Print-Msg `"�ð汾������־��https://github.com/invoke-ai/InvokeAI/releases/latest`"
} else {
    Print-Msg `"InvokeAI ����ʧ��`"
}
Read-Host | Out-Null
"

    Set-Content -Path "./InvokeAI/update.ps1" -Value $content
}


# ���ݿ��޸�
function Write-InvokeAI-DB-Fix-Script {
    $content = "
Set-Location `"`$PSScriptRoot`"
`$env:INVOKEAI_ROOT = `"`$PSScriptRoot/invokeai`"
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
}

Print-Msg `"�޸� InvokeAI ���ݿ���`"
./python/Scripts/invokeai-db-maintenance.exe --operation all --root `"`$PSScriptRoot/invokeai`"
Print-Msg `"�޸� InvokeAI ���ݿ����`"
Read-Host | Out-Null
"

    Set-Content -Path "$PSScriptRoot/InvokeAI/fix_db.ps1" -Value $content
}


# ��ȡ��װ�ű�
function Write-InvokeAI-Install-Script {
    $content = "
Set-Location `"`$PSScriptRoot`"
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
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
Read-Host | Out-Null
"

    Set-Content -Path "./InvokeAI/get_invokeai_installer.ps1" -Value $content
}


# ���⻷������ű�
function Write-Env-Activate-Script {
    $content = "
function global:prompt {
    `"`$(Write-Host `"[InvokeAI Env]`" -ForegroundColor Green -NoNewLine) `$(Get-Location)>`"
}

function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
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
`$env:PIP_INDEX_URL = `"$pip_index_mirror`"
`$env:PIP_EXTRA_INDEX_URL = `"$pip_extra_index_mirror`"
`$env:PIP_FIND_LINKS = `"$pip_find_mirror`"
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


# pytorch��װ�ű�
function Write-PyTorch-ReInstall-Script {
    $content = "
Set-Location `"`$PSScriptRoot`"
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
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

# ��������
`$env:PIP_INDEX_URL = `"$pip_index_mirror`"
`$env:PIP_EXTRA_INDEX_URL = `"$pip_extra_index_mirror`"
`$env:PIP_FIND_LINKS = `"$pip_find_mirror`"
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

Print-Msg `"�Ƿ����°�װ PyTorch (yes/no)?`"
Print-Msg `"��ʾ: ���� yes ȷ�ϻ� no ȡ�� (Ĭ��Ϊ no)`"
`$arg = Read-Host `"===========================================>`"
if (`$arg -eq `"yes`" -or `$arg -eq `"y`" -or `$arg -eq `"YES`" -or `$arg -eq `"Y`") {
    Print-Msg `"ж��ԭ�е� PyTorch`"
    ./python/python.exe -m pip uninstall torch torchvision torchaudio xformers -y
    Print-Msg `"���°�װ PyTorch`"
    ./python/python.exe -m pip install `"InvokeAI[xformers]`" --no-warn-script-location --use-pep517
    if (`$?) {
        Print-Msg `"���°�װ PyTorch �ɹ�`"
    } else {
        Print-Msg `"���°�װ PyTorch ʧ��, ���������� PyTorch ��װ�ű�`"
    }
} else {
    Print-Msg `"ȡ����װ PyTorch`"
}

Read-Host | Out-Null
"

    Set-Content -Path "./InvokeAI/reinstall_pytorch.ps1" -Value $content
}


# ����ģ�������ļ��ű�
function Wirte-Download-Config-Script {
    $content = "
Set-Location `"`$PSScriptRoot`"

# ��Ϣ���
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][InvokeAI Installer]:: `$msg`"
}

# ���������ļ�
function Download-Config-File(`$url, `$path) {
    `$length = `$url.split(`"/`").length
    `$name = `$url.split(`"/`")[`$length - 1]
    if (!(Test-Path `$path)) {
        Print-Msg `"���� `$name ��`"
        Invoke-WebRequest -Uri `$url.ToString() -OutFile `"./cache/`$name`"
        if (`$?) {
            Move-Item -Path `"./cache/`$name`" -Destination `"`$path`"
            Print-Msg `"`$name ���سɹ�`"
        } else {
            Print-Msg `"`$name ����ʧ��`"
        }
    } else {
        Print-Msg `"`$name �Ѵ���`"
    }
}


# Ԥ����ģ�������ļ�
function Get-Model-Config-File {
    Print-Msg `"Ԥ����ģ�������ļ���`"
    New-Item -ItemType Directory -Path `"./cache`" -Force > `$null
    New-Item -ItemType Directory -Path `"./invokeai/configs/stable-diffusion`" -Force > `$null
    New-Item -ItemType Directory -Path `"./invokeai/configs/controlnet`" -Force > `$null
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/sd_xl_base.yaml`" `"./invokeai/configs/stable-diffusion/sd_xl_base.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/sd_xl_inpaint.yaml`" `"./invokeai/configs/stable-diffusion/sd_xl_inpaint.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/sd_xl_refiner.yaml`" `"./invokeai/configs/stable-diffusion/sd_xl_refiner.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-finetune.yaml`" `"./invokeai/configs/stable-diffusion/v1-finetune.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-finetune_style.yaml`" `"./invokeai/configs/stable-diffusion/v1-finetune_style.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-inference-v.yaml`" `"./invokeai/configs/stable-diffusion/v1-inference-v.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-inference.yaml`" `"./invokeai/configs/stable-diffusion/v1-inference.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-inpainting-inference.yaml`" `"./invokeai/configs/stable-diffusion/v1-inpainting-inference.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v1-m1-finetune.yaml`" `"./invokeai/configs/stable-diffusion/v1-m1-finetune.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inference-v.yaml`" `"./invokeai/configs/stable-diffusion/v2-inference-v.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inference.yaml`" `"./invokeai/configs/stable-diffusion/v2-inference.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inpainting-inference-v.yaml`" `"./invokeai/configs/stable-diffusion/v2-inpainting-inference-v.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-inpainting-inference.yaml`" `"./invokeai/configs/stable-diffusion/v2-inpainting-inference.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/stable-diffusion/v2-midas-inference.yaml`" `"./invokeai/configs/stable-diffusion/v2-midas-inference.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/controlnet/cldm_v15.yaml`" `"./invokeai/configs/controlnet/cldm_v15.yaml`"
    Download-Config-File `"https://modelscope.cn/models/licyks/invokeai-core-model/resolve/master/configs/controlnet/cldm_v21.yaml`" `"./invokeai/configs/controlnet/cldm_v21.yaml`"
    Print-Msg `"ģ�������ļ��������`"
}

Get-Model-Config-File
Read-Host | Out-Null
"
    Set-Content -Path "./InvokeAI/download_config.ps1" -Value $content
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
fix_db.ps1���޸� InvokeAI ���ݿ�ű������ɾ�� InvokeAI ��ͼƬ���ڽ����г�����ЧͼƬ�����⡣
reinstall_pytorch.ps1����װ PyTorch �ű������ PyTorch �޷�����ʹ�û��� xFormers �汾��ƥ�䵼���޷����õ����⡣
download_config.ps1������ģ�������ļ�����ɾ�� invokeai �ļ��к�InvokeAI ����������ģ�������ļ��������޴��������¿�������ʧ�ܣ����Կ���ͨ���ýű��������ء�
help.txt�������ĵ���


Ҫ���� InvokeAI���� InvokeAI �ļ������ҵ� launch.ps1 �ű����Ҽ�����ű���ѡ��ʹ�� PowerShell ���У��ȴ� InvokeAI ������ɣ�������ɺ��ڿ���̨��ʾ���ʵ�ַ����ַΪ http://127.0.0.1:9090�����õ�ַ�����������ַ�����س������ InvokeAI ���档

InvokeAI Ĭ�ϵĽ�������ΪӢ�ģ��� InvokeAI ���½ǵĳ���ͼ�꣬��� Settings���� Language ѡ��ѡ��������ļ��ɽ�������������Ϊ���ġ�

ʹ�� InvokeAI ʱ�������Ķ����н̳̣��Ը�����˽Ⲣ����ʹ�� InvokeAI �ķ�����
��������ѧϰAI�����滭���˵����ſ� By Yuno779��https://docs.qq.com/doc/p/9a03673f4a0493b4cd76babc901a49f0e6d52140

�ű�Ϊ InvokeAI ������ HuggingFace ����Դ����������޷�ֱ�ӷ��� HuggingFace������ InvokeAI ��ģ�͹����޷��� HuggingFace ����ģ�͵����⡣
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
    Print-Msg "InvokeAI Installer ʹ���ĵ�: https://github.com/licyk/sd-webui-all-in-one/blob/main/invokeai_installer.md"
    Check-Install
    Print-Msg "��������ű����ĵ���"
    Write-Launch-Script
    Write-Update-Script
    Write-InvokeAI-DB-Fix-Script
    Write-InvokeAI-Install-Script
    Write-Env-Activate-Script
    Write-PyTorch-ReInstall-Script
    Wirte-Download-Config-Script
    Write-ReadMe
    Print-Msg "InvokeAI ��װ����, ��װ·��Ϊ $PSScriptRoot\InvokeAI"
    Print-Msg "���ڸ� InvokeAI �汾�ĸ�����־��https://github.com/invoke-ai/InvokeAI/releases/latest"
    Print-Msg "�����ĵ����� InvokeAI �ļ����в鿴, ˫�� help.txt �ļ����ɲ鿴"
    Print-Msg "�˳� InvokeAI Installer"
}


###################


Main
Read-Host | Out-Null
