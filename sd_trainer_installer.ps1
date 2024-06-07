# pip����Դ
$pip_index_mirror = "https://mirrors.cloud.tencent.com/pypi/simple"
$pip_extra_index_mirror = "https://mirror.baidu.com/pypi/simple"
$pip_find_mirror = "https://mirror.sjtu.edu.cn/pytorch-wheels/torch_stable.html"
$pip_extra_index_mirror_cu121 = "https://mirror.sjtu.edu.cn/pytorch-wheels/cu121"
$pip_find_mirror_cu121 = "https://mirror.sjtu.edu.cn/pytorch-wheels/cu121/torch_stable.html"
# github����Դ�б�
$github_mirror_list = @(
    "https://mirror.ghproxy.com/https://github.com",
    "https://ghproxy.net/https://github.com",
    "https://gitclone.com/github.com",
    "https://gh-proxy.com/https://github.com",
    "https://ghps.cc/https://github.com",
    "https://gh.idayer.com/https://github.com"
)
# pytorch�汾
$pytorch_ver = "torch==2.3.0+cu118 torchvision==0.18.0+cu118 torchaudio==2.3.0+cu118"
$xformers_ver = "xformers==0.0.26.post1+cu118"
# ��������
$env:PIP_INDEX_URL = $pip_index_mirror
$env:PIP_EXTRA_INDEX_URL = $pip_extra_index_mirror
$env:PIP_FIND_LINKS = $pip_find_mirror
$env:PIP_DISABLE_PIP_VERSION_CHECK = 1
$env:PIP_TIMEOUT = 30
$env:PIP_RETRIES = 5
$env:CACHE_HOME = "$PSScriptRoot/SD-Trainer/cache"
$env:HF_HOME = "$PSScriptRoot/SD-Trainer/cache/huggingface"
$env:MATPLOTLIBRC = "$PSScriptRoot/SD-Trainer/cache"
$env:MODELSCOPE_CACHE = "$PSScriptRoot/SD-Trainer/cache/modelscope/hub"
$env:MS_CACHE_HOME = "$PSScriptRoot/SD-Trainer/cache/modelscope/hub"
$env:SYCL_CACHE_DIR = "$PSScriptRoot/SD-Trainer/cache/libsycl_cache"
$env:TORCH_HOME = "$PSScriptRoot/SD-Trainer/cache/torch"
$env:U2NET_HOME = "$PSScriptRoot/SD-Trainer/cache/u2net"
$env:XDG_CACHE_HOME = "$PSScriptRoot/SD-Trainer/cache"
$env:PIP_CACHE_DIR = "$PSScriptRoot/SD-Trainer/cache/pip"
$env:PYTHONPYCACHEPREFIX = "$PSScriptRoot/SD-Trainer/cache/pycache"



# ��Ϣ���
function Print-Msg ($msg) {
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")][SD-Trainer Installer]:: $msg"
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
    $url = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2Fpython-3.10.11-amd64.zip"

    # ����python
    Print-Msg "�������� Python"
    Invoke-WebRequest -Uri $url -OutFile "./SD-Trainer/python-3.10.11-amd64.zip"
    if ($?) { # ����Ƿ����سɹ�����ѹ
        # ����python�ļ���
        if (!(Test-Path "./SD-Trainer/python")) {
            New-Item -ItemType Directory -Force -Path ./SD-Trainer/python > $null
        }
        # ��ѹpython
        Print-Msg "���ڽ�ѹ Python"
        Expand-Archive -Path "./SD-Trainer/python-3.10.11-amd64.zip" -DestinationPath "./SD-Trainer/python" -Force
        Remove-Item -Path "./SD-Trainer/python-3.10.11-amd64.zip"
        Print-Msg "Python ��װ�ɹ�"
    } else {
        Print-Msg "Python ��װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
        Read-Host | Out-Null
        exit 1
    }
}


# ���ز���ѹgit
function Install-Git {
    $url = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2FPortableGit-2.45.2-64-bit.zip"
    Print-Msg "�������� Git"
    Invoke-WebRequest -Uri $url -OutFile "./SD-Trainer/PortableGit-2.45.2-64-bit.zip"
    if ($?) { # ����Ƿ����سɹ�����ѹ
        # ����git�ļ���
        if (!(Test-Path "./SD-Trainer/git")) {
            New-Item -ItemType Directory -Force -Path ./SD-Trainer/git > $null
        }
        # ��ѹgit
        Print-Msg "���ڽ�ѹ Git"
        Expand-Archive -Path "./SD-Trainer/PortableGit-2.45.2-64-bit.zip" -DestinationPath "./SD-Trainer/git" -Force
        Remove-Item -Path "./SD-Trainer/PortableGit-2.45.2-64-bit.zip"
        Print-Msg "Git ��װ�ɹ�"
    } else {
        Print-Msg "Git ��װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
        Read-Host | Out-Null
        exit 1
    }
}


# ����aria2
function Install-Aria2 {
    $url = "https://modelscope.cn/api/v1/models/licyks/invokeai-core-model/repo?Revision=master&FilePath=pypatchmatch%2Faria2c.exe"
    Print-Msg "�������� Aria2"
    Invoke-WebRequest -Uri $url -OutFile "./SD-Trainer/cache/aria2c.exe"
    if ($?) {
        Move-Item -Path "./SD-Trainer/cache/aria2c.exe" -Destination "./SD-Trainer/git/bin/aria2c.exe"
        Print-Msg "Aria2 ���سɹ�"
    } else {
        Print-Msg "Aria2 ����ʧ��"
    }
}


# github�������
function Test-Github-Mirror {
    if (Test-Path "./disable_gh_mirror.txt") { # ����github����Դ
        Print-Msg "��⵽���ش��� disable_gh_mirror.txt Github ����Դ�����ļ�, ���� Github ����Դ"
    } else {
        $env:GIT_CONFIG_GLOBAL = "$PSScriptRoot/SD-Trainer/.gitconfig" # ����git�����ļ�·��
        if (Test-Path "$PSScriptRoot/SD-Trainer/.gitconfig") {
            Remove-Item -Path "$PSScriptRoot/SD-Trainer/.gitconfig" -Force
        }

        if (Test-Path "./gh_mirror.txt") { # ʹ���Զ���github����Դ
            $github_mirror = Get-Content "./gh_mirror.txt"
            ./SD-Trainer/git/bin/git.exe config --global url."$github_mirror".insteadOf "https://github.com"
            Print-Msg "��⵽���ش��� gh_mirror.txt Github ����Դ�����ļ�, �Ѷ�ȡ Github ����Դ�����ļ������� Github ����Դ"
        } else { # �Զ������þ���Դ��ʹ��
            $status = 0
            ForEach($i in $github_mirror_list) {
                Print-Msg "���� Github ����Դ: $i"
                if (Test-Path "./SD-Trainer/github-mirror-test") {
                    Remove-Item -Path "./SD-Trainer/github-mirror-test" -Force -Recurse
                }
                ./SD-Trainer/git/bin/git.exe clone $i/licyk/empty ./SD-Trainer/github-mirror-test --quiet
                if ($?) {
                    Print-Msg "�� Github ����Դ����"
                    $github_mirror = $i
                    $status = 1
                    break
                } else {
                    Print-Msg "����Դ������, ��������Դ���в���"
                }
            }
            if (Test-Path "./SD-Trainer/github-mirror-test") {
                Remove-Item -Path "./SD-Trainer/github-mirror-test" -Force -Recurse
            }
            if ($status -eq 0) {
                Print-Msg "�޿��� Github ����Դ, ȡ��ʹ�� Github ����Դ"
                Remove-Item -Path env:GIT_CONFIG_GLOBAL -Force
            } else {
                Print-Msg "���� Github ����Դ"
                ./SD-Trainer/git/bin/git.exe config --global url."$github_mirror".insteadOf "https://github.com"
            }
        }
    }
}


# ��װsd-trainer
function Install-SD-Trainer {
    $status = 0
    if (!(Test-Path "./SD-Trainer/lora-scripts")) {
        $status = 1
    } else {
        $items = Get-ChildItem "./SD-Trainer/lora-scripts" -Recurse
        if ($items.Count -eq 0) {
            $status = 1
        }
    }

    if ($status -eq 1) {
        Print-Msg "�������� SD-Trainer"
        ./SD-Trainer/git/bin/git.exe clone --recurse-submodules https://github.com/Akegarasu/lora-scripts ./SD-Trainer/lora-scripts
        if ($?) { # ����Ƿ����سɹ�
            Print-Msg "SD-Trainer ��װ�ɹ�"
        } else {
            Print-Msg "SD-Trainer ��װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
            Read-Host | Out-Null
            exit 1
        }
    } else {
        Print-Msg "SD-Trainer �Ѱ�װ"
    }

    Print-Msg "��װ SD-Trainer ��ģ����"
    ./SD-Trainer/git/bin/git.exe -C ./SD-Trainer/lora-scripts submodule init
    ./SD-Trainer/git/bin/git.exe -C ./SD-Trainer/lora-scripts submodule update
    if ($?) {
        Print-Msg "SD-Trainer ��ģ�鰲װ�ɹ�"
    } else {
        Print-Msg "SD-Trainer ��ģ�鰲װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
        Read-Host | Out-Null
        exit 1
    }
}


# ��װpytorch
function Install-PyTorch {
    Print-Msg "����Ƿ���Ҫ��װ PyTorch"
    ./SD-Trainer/python/python.exe -m pip show torch --quiet 2> $null
    if (!($?)) {
        Print-Msg "��װ PyTorch ��"
        ./SD-Trainer/python/python.exe -m pip install $pytorch_ver.ToString().Split() --no-warn-script-location
        if ($?) {
            Print-Msg "PyTorch ��װ�ɹ�"
        } else {
            Print-Msg "PyTorch ��װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
            Read-Host | Out-Null
            exit 1
        }
    } else {
        Print-Msg "PyTorch �Ѱ�װ, �����ٴΰ�װ"
    }

    Print-Msg "����Ƿ���Ҫ��װ xFormers"
    ./SD-Trainer/python/python.exe -m pip show xformers --quiet 2> $null
    if (!($?)) {
        ./SD-Trainer/python/python.exe -m pip install $xformers_ver --no-deps --no-warn-script-location
        if ($?) {
            Print-Msg "xFormers ��װ�ɹ�"
        } else {
            Print-Msg "xFormers ��װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
            Read-Host | Out-Null
            exit 1
        }
    } else {
        Print-Msg "xFormers �Ѱ�װ, �����ٴΰ�װ"
    }
}

# ��װsd-trainer����
function Install-SD-Trainer-Dependence {
    Set-Location "$PSScriptRoot/SD-Trainer/lora-scripts/sd-scripts"
    Print-Msg "��װ SD-Trainer �ں�������"
    ../../python/python.exe -m pip install --upgrade -r requirements.txt --no-warn-script-location
    if ($?) {
        Print-Msg "SD-Trainer �ں�������װ�ɹ�"
    } else {
        Print-Msg "SD-Trainer �ں�������װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
        Set-Location "$PSScriptRoot"
        Read-Host | Out-Null
        exit 1
    }

    Set-Location "$PSScriptRoot/SD-Trainer/lora-scripts"
    Print-Msg "��װ SD-Trainer ������"
    ../python/python.exe -m pip install --upgrade -r requirements.txt --no-warn-script-location
    if ($?) {
        Print-Msg "SD-Trainer ������װ�ɹ�"
    } else {
        Print-Msg "SD-Trainer ������װʧ��, ��ֹ SD-Trainer ��װ����, �ɳ����������� SD-Trainer Installer ����ʧ�ܵİ�װ"
        Set-Location "$PSScriptRoot"
        Read-Host | Out-Null
        exit 1
    }
    Set-Location "$PSScriptRoot"
}



# ��װ
function Check-Install {
    if (!(Test-Path "./SD-Trainer")) {
        New-Item -ItemType Directory -Path "./SD-Trainer" > $null
    }

    if (!(Test-Path "./SD-Trainer/cache")) {
        New-Item -ItemType Directory -Path "./SD-Trainer/cache" > $null
    }

    if (!(Test-Path "./SD-Trainer/models")) {
        New-Item -ItemType Directory -Path "./SD-Trainer/models" > $null
    }

    Print-Msg "����Ƿ�װ Python"
    $pythonPath = "./SD-Trainer/python/python.exe"
    if (Test-Path $pythonPath) {
        Print-Msg "Python �Ѱ�װ"
    } else {
        Print-Msg "Python δ��װ"
        Install-Python
    }

    Print-Msg "����Ƿ�װ Git"
    $gitPath = "./SD-Trainer/git/bin/git.exe"
    if (Test-Path $gitPath) {
        Print-Msg "Git �Ѱ�װ"
    } else {
        Print-Msg "Git δ��װ"
        Install-Git
    }

    Print-Msg "����Ƿ�װ Aria2"
    $aria2Path = "./SD-Trainer/git/bin/aria2c.exe"
    if (Test-Path $aria2Path) {
        Print-Msg "Aria2 �Ѱ�װ"
    } else {
        Print-Msg "Aria2 δ��װ"
        Install-Aria2
    }

    Test-Github-Mirror
    Install-SD-Trainer
    Install-PyTorch
    Install-SD-Trainer-Dependence
}


# �����ű�
function Write-Launch-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][SD-Trainer Installer]:: `$msg`"
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
if (!(Test-Path `"`$PSScriptRoot/disable_hf_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/hf_mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/hf_mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� hf_mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_hf_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

if (Test-Path `"`$PSScriptRoot/launch_args.txt`") {
    `$args = Get-Content `"`$PSScriptRoot/launch_args.txt`"
    Print-Msg `"��⵽���ش��� launch_args.txt �������������ļ�, �Ѷ�ȡ���������������ļ���Ӧ����������`"
    Print-Msg `"ʹ�õ���������: `$args`"
}

`$py_path = `"`$PSScriptRoot/python`"
`$py_scripts_path = `"`$PSScriptRoot/python/Scripts`"
`$git_path = `"`$PSScriptRoot/git/bin`"
`$Env:PATH = `"`$py_path`$([System.IO.Path]::PathSeparator)`$py_scripts_path`$([System.IO.Path]::PathSeparator)`$git_path`$([System.IO.Path]::PathSeparator)`$Env:PATH`" # ��python��ӵ���������
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

Print-Msg `"���� SD-Trainer ��`"
Set-Location `"`$PSScriptRoot/lora-scripts`"
../python/python gui.py `$args.ToString().Split()
Set-Location `"`$PSScriptRoot`"
Print-Msg `"SD-Trainer �ѽ�������`"
Read-Host | Out-Null
"

    Set-Content -Path "./SD-Trainer/launch.ps1" -Value $content
}


# ���½ű�
function Write-Update-Script {
    $content = "
`$github_mirror_list = @(
    `"https://mirror.ghproxy.com/https://github.com`",
    `"https://ghproxy.net/https://github.com`",
    `"https://gitclone.com/github.com`",
    `"https://gh-proxy.com/https://github.com`",
    `"https://ghps.cc/https://github.com`",
    `"https://gh.idayer.com/https://github.com`"
)

function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][SD-Trainer Installer]:: `$msg`"
}

function Fix-Git-Point-Off-Set {
    param(
        `$path
    )
    if (Test-Path `"`$path/.git`") {
        git -C `"`$path`" symbolic-ref HEAD > `$null 2> `$null
        if (!(`$?)) {
            Print-Msg `"��⵽���ַ�֧����, �����޸���`"
            git -C `"`$path`" remote prune origin # ɾ�����÷�֧
            git -C `"`$path`" submodule init # ��ʼ��git��ģ��
            `$branch = `$(git -C `"`$path`" branch -a | Select-String -Pattern `"/HEAD`").ToString().Split(`"/`")[3] # ��ѯԶ��HEAD��ָ��֧
            git -C `"`$path`" checkout `$branch # �л�������֧
            git -C `"`$path`" reset --recurse-submodules --hard origin/`$branch # ���˵�Զ�̷�֧�İ汾
            git -C `"`$path`" reset --recurse-submodules --hard HEAD # ���˰汾,���git pull�쳣
            git -C `"`$path`" restore --recurse-submodules --source=HEAD :/ # ���ù�����
        }
    }
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

# github ����Դ
if (Test-Path `"`$PSScriptRoot/disable_gh_mirror.txt`") { # ����github����Դ
    Print-Msg `"��⵽���ش��� disable_gh_mirror.txt Github ����Դ�����ļ�, ���� Github ����Դ`"
} else {
    `$env:GIT_CONFIG_GLOBAL = `"`$PSScriptRoot/.gitconfig`" # ����git�����ļ�·��
    if (Test-Path `"`$PSScriptRoot/.gitconfig`") {
        Remove-Item -Path `"`$PSScriptRoot/.gitconfig`" -Force
    }

    if (Test-Path `"`$PSScriptRoot/gh_mirror.txt`") { # ʹ���Զ���github����Դ
        `$github_mirror = Get-Content `"`$PSScriptRoot/gh_mirror.txt`"
        ./git/bin/git.exe config --global url.`"`$github_mirror`".insteadOf `"https://github.com`"
        Print-Msg `"��⵽���ش��� gh_mirror.txt Github ����Դ�����ļ�, �Ѷ�ȡ Github ����Դ�����ļ������� Github ����Դ`"
    } else { # �Զ������þ���Դ��ʹ��
        `$status = 0
        ForEach(`$i in `$github_mirror_list) {
            Print-Msg `"���� Github ����Դ: `$i`"
            if (Test-Path `"./github-mirror-test`") {
                Remove-Item -Path `"./github-mirror-test`" -Force -Recurse
            }
            ./git/bin/git.exe clone `$i/licyk/empty ./github-mirror-test --quiet
            if (`$?) {
                Print-Msg `"�� Github ����Դ����`"
                `$github_mirror = `$i
                `$status = 1
                break
            } else {
                Print-Msg `"����Դ������, ��������Դ���в���`"
            }
        }
        if (Test-Path `"./github-mirror-test`") {
            Remove-Item -Path `"./github-mirror-test`" -Force -Recurse
        }
        if (`$status -eq 0) {
            Print-Msg `"�޿��� Github ����Դ, ȡ��ʹ�� Github ����Դ`"
            Remove-Item -Path env:GIT_CONFIG_GLOBAL -Force
        } else {
            Print-Msg `"���� Github ����Դ`"
            ./git/bin/git.exe config --global url.`"`$github_mirror`".insteadOf `"https://github.com`"
        }
    }
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

Print-Msg `"���� SD-Trainer ��`"
Fix-Git-Point-Off-Set `"./lora-scripts`"
`$ver = `$(./git/bin/git.exe -C lora-scripts show -s --format=`"%h %cd`" --date=format:`"%Y-%m-%d %H:%M:%S`")
./git/bin/git.exe -C lora-scripts reset --hard --recurse-submodules
./git/bin/git.exe -C lora-scripts pull --recurse-submodules
if (`$?) {
    `$ver_ = `$(./git/bin/git.exe -C lora-scripts show -s --format=`"%h %cd`" --date=format:`"%Y-%m-%d %H:%M:%S`")
    if (`$ver -eq `$ver_) {
        Print-Msg `"SD-Trainer ��Ϊ���°棬��ǰ�汾��`$ver`"
    } else {
        Print-Msg `"SD-Trainer ���³ɹ����汾��`$ver -> `$ver_`"
    }
} else {
    Print-Msg `"SD-Trainer ����ʧ��`"
}

Print-Msg `"�˳� SD-Trainer ���½ű�`"
Read-Host | Out-Null
"

    Set-Content -Path "./SD-Trainer/update.ps1" -Value $content
}



# ��ȡ��װ�ű�
function Write-SD-Trainer-Install-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][SD-Trainer Installer]:: `$msg`"
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
if (!(Test-Path `"`$PSScriptRoot/disable_hf_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/hf_mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/hf_mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� hf_mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_hf_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

# ���õ�����Դ
`$urls = @(`"https://github.com/licyk/sd-webui-all-in-one/raw/main/sd_trainer_installer.ps1`", `"https://gitlab.com/licyk/sd-webui-all-in-one/-/raw/main/sd_trainer_installer.ps1`", `"https://github.com/licyk/sd-webui-all-in-one/releases/download/sd_trainer_installer/sd_trainer_installer.ps1`", `"https://gitee.com/licyk/sd-webui-all-in-one/releases/download/sd_trainer_installer/sd_trainer_installer.ps1`")
`$count = `$urls.Length
`$i = 0

ForEach (`$url in `$urls) {
    Print-Msg `"�����������µ� SD-Trainer Installer �ű�`"
    Invoke-WebRequest -Uri `$url -OutFile `"./cache/sd_trainer_installer.ps1`"
    if (`$?) {
        if (Test-Path `"../sd_trainer_installer.ps1`") {
            Print-Msg `"ɾ��ԭ�е� SD-Trainer Installer �ű�`"
            Remove-Item `"../sd_trainer_installer.ps1`" -Force
        }
        Move-Item -Path `"./cache/sd_trainer_installer.ps1`" -Destination `"../sd_trainer_installer.ps1`"
        `$parentDirectory = Split-Path `$PSScriptRoot -Parent
        Print-Msg `"���� SD-Trainer Installer �ű��ɹ�, �ű�·��Ϊ `$parentDirectory\sd_trainer_installer.ps1`"
        break
    } else {
        Print-Msg `"���� SD-Trainer Installer �ű�ʧ��`"
        `$i += 1
        if (`$i -lt `$count) {
            Print-Msg `"�������� SD-Trainer Installer �ű�`"
        }
    }
}

Print-Msg `"�˳� SD-Trainer Installer ���ؽű�`"
Read-Host | Out-Null
"

    Set-Content -Path "./SD-Trainer/get_sd_trainer_installer.ps1" -Value $content
}

# ��װpytorch�ű�
function Write-PyTorch-Reinstall-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][SD-Trainer Installer]:: `$msg`"
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

`$to_exit = 0
while (`$True) {
    Print-Msg `"PyTorch �汾�б�`"
    `$go_to = 0

    `$content = `"
-----------------------------------------------------
- 1��Torch 1.12.1 (CUDA11.3)+ xFormers 0.0.14
- 2��Torch 1.13.1 (CUDA11.7)+ xFormers 0.0.16
- 3��Torch 2.0.0 (CUDA11.8) + xFormers 0.0.18
- 4��Torch 2.0.1 (CUDA11.8) + xFormers 0.0.22
- 5��Torch 2.1.1 (CUDA11.8) + xFormers 0.0.23
- 6��Torch 2.1.2 (CUDA11.8) + xFormers 0.0.23.post1
- 7��Torch 2.2.0 (CUDA11.8) + xFormers 0.0.24
- 8��Torch 2.2.1 (CUDA11.8) + xFormers 0.0.25
- 9��Torch 2.2.2 (CUDA11.8) + xFormers 0.0.25.post1
- 10��Torch 2.3.0 (CUDA11.8) + xFormers 0.0.26.post1
-----------------------------------------------------
    `"

    Write-Host `$content
    Print-Msg `"��ѡ�� PyTorch �汾`"
    Print-Msg `"��ʾ: �������ֺ�س�, �������� exit �˳� PyTroch ��װ�ű�`"
    `$arg = Read-Host `"===========================================>`"

    switch (`$arg) {
        1 {
            `$torch_ver = `"torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==1.12.1+cu113`"
            `$xformers_ver = `"xformers==0.0.14`"
            `$go_to = 1
        }
        2 {
            `$torch_ver = `"torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==1.13.1+cu117`"
            `$xformers_ver = `"xformers==0.0.18`"
            `$go_to = 1
        }
        3 {
            `$torch_ver = `"torch==2.0.0+cu118 torchvision==0.15.1+cu118 torchaudio==2.0.0+cu118`"
            `$xformers_ver = `"xformers==0.0.14`"
            `$go_to = 1
        }
        4 {
            `$torch_ver = `"torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.1+cu118`"
            `$xformers_ver = `"xformers==0.0.22`"
            `$go_to = 1
        }
        5 {
            `$torch_ver = `"torch==2.1.1+cu118 torchvision==0.16.1+cu118 torchaudio==2.1.1+cu118`"
            `$xformers_ver = `"xformers==0.0.23+cu118`"
            `$go_to = 1
        }
        6 {
            `$torch_ver = `"torch==2.1.2+cu118 torchvision==0.16.2+cu118 torchaudio==2.1.2+cu118`"
            `$xformers_ver = `"xformers==0.0.23.post1+cu118`"
            `$go_to = 1
        }
        7 {
            `$torch_ver = `"torch==2.2.0+cu118 torchvision==0.17.0+cu118 torchaudio==2.2.0+cu118`"
            `$xformers_ver = `"xformers==0.0.24+cu118`"
            `$go_to = 1
        }
        8 {
            `$torch_ver = `"torch==2.2.1+cu118 torchvision==0.17.1+cu118 torchaudio==2.2.1+cu118`"
            `$xformers_ver = `"xformers==0.0.25+cu118`"
            `$go_to = 1
        }
        9 {
            `$torch_ver = `"torch==2.2.2+cu118 torchvision==0.17.2+cu118 torchaudio==2.2.2+cu118`"
            `$xformers_ver = `"xformers==0.0.25.post1+cu118`"
            `$go_to = 1
        }
        10 {
            `$torch_ver = `"torch==2.3.0+cu118 torchvision==0.18.0+cu118 torchaudio==2.3.0+cu118`"
            `$xformers_ver = `"xformers==0.0.26.post1+cu118`"
            `$go_to = 1
        }
        exit {
            Print-Msg `"�˳� PyTorch ��װ�ű�`"
            `$to_exit = 1
            `$go_to = 1
        }
        Default {
            Print-Msg `"��������, ������`"
        }
    }

    if (`$go_to -eq 1) {
        break
    }
}

if (`$to_exit -eq 1) {
    Read-Host | Out-Null
    exit 0
}

Print-Msg `"�Ƿ�ѡ���ǿ����װ? (ͨ������²���Ҫ)`"
Print-Msg `"��ʾ: ���� yes ȷ�ϻ� no ȡ�� (Ĭ��Ϊ no)`"
`$use_force_reinstall = Read-Host `"===========================================>`"

if (`$use_force_reinstall -eq `"yes`" -or `$use_force_reinstall -eq `"y`" -or `$use_force_reinstall -eq `"YES`" -or `$use_force_reinstall -eq `"Y`") {
    `$force_reinstall_arg = `"--force-reinstall`"
    `$force_reinstall_status = `"����`"
} else {
    `$force_reinstall_arg = `"`"
    `$force_reinstall_status = `"����`"
}

Print-Msg `"��ǰ��ѡ��`"
Print-Msg `"PyTorch: `$torch_ver`"
Print-Msg `"xFormers: `$xformers_ver`"
Print-Msg `"��ǿ����װ: `$force_reinstall_status`"
Print-Msg `"�Ƿ�ȷ�ϰ�װ?`"
Print-Msg `"��ʾ: ���� yes ȷ�ϻ� no ȡ�� (Ĭ��Ϊ no)`"
`$install_torch = Read-Host `"===========================================>`"

if (`$install_torch -eq `"yes`" -or `$install_torch -eq `"y`" -or `$install_torch -eq `"YES`" -or `$install_torch -eq `"Y`") {
    Print-Msg `"��װ PyTorch ��`"
    ./python/python.exe -m pip install `$torch_ver.ToString().Split() `$force_reinstall_arg --no-warn-script-location
    if (`$?) {
        Print-Msg `"��װ PyTorch �ɹ�`"
    } else {
        Print-Msg `"��װ PyTorch ʧ��, ��ֹ��װ����`"
        Read-Host | Out-Null
        exit 1
    }
    Print-Msg `"��װ xFormers ��`"
    ./python/python.exe -m pip install `$xformers_ver `$force_reinstall_arg --no-deps --no-warn-script-location
    if (`$?) {
        Print-Msg `"��װ xFormers �ɹ�`"
    } else {
        Print-Msg `"��װ xFormers ʧ��, ��ֹ��װ����`"
        Read-Host | Out-Null
        exit 1
    }
} else {
    Print-Msg `"ȡ����װ PyTorch`"
}

Print-Msg `"�˳� PyTorch ��װ�ű�`"
Read-Host | Out-Null
"

    Set-Content -Path "./SD-Trainer/reinstall_pytorch.ps1" -Value $content
}


# ģ�����ؽű�
function Write-Doenload-Model-Script {
    $content = "
function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][SD-Trainer Installer]:: `$msg`"
}

`$to_exit = 0
while (`$True) {
    `$go_to = 0
    Print-Msg `"�����ص�ģ���б�`"
    `$content = `"
-----------------------------------------------------
- 1��v1-5-pruned-emaonly (SD 1.5)
- 2��animefull-final-pruned (SD 1.5)
- 3��v2-1_768-ema-pruned (SD 2.1)
- 4��wd-1-4-anime_e2 (SD 2.1)
- 5��wd-mofu-fp16 (SD 2.1)
- 6��sd_xl_base_1.0_0.9vae (SDXL)
- 7��animagine-xl-3.0 (SDXL)
- 8��animagine-xl-3.1 (SDXL)
- 9��kohaku-xl-delta-rev1 (SDXL)
- 10��kohakuXLEpsilon_rev1 (SDXL)
- 11��ponyDiffusionV6XL_v6 (SDXL)
- 12��kohaku-xl-epsilon-rev2 (SDXL)
- 13��pdForAnime_v20 (SDXL)
- 14��starryXLV52_v52 (SDXL)
- 15��heartOfAppleXL_v20 (SDXL)
- 16��heartOfAppleXL_v30 (SDXL)
- 17��vae-ft-ema-560000-ema-pruned (SD 1.5 VAE)
- 18��vae-ft-mse-840000-ema-pruned (SD 1.5 VAE)
- 19��sdxl_fp16_fix_vae (SDXL VAE)
- 20��sdxl_vae (SDXL VAE)
-----------------------------------------------------
`"

    Write-Host `$content
    Print-Msg `"��ѡ��Ҫ���ص�ģ��`"
    Print-Msg `"��ʾ: �������ֺ�س�, �������� exit �˳�ģ�����ؽű�`"
    `$arg = Read-Host `"===========================================>`"

    switch (`$arg) {
        1 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sd_1.5%2Fv1-5-pruned-emaonly.safetensors`"
            `$model_name = `"v1-5-pruned-emaonly.safetensors`"
            `$go_to = 1
        }
        2 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sd_1.5%2Fanimefull-final-pruned.safetensors`"
            `$model_name = `"animefull-final-pruned.safetensors`"
            `$go_to = 1
        }
        3 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sd_2.1%2Fv2-1_768-ema-pruned.safetensors`"
            `$model_name = `"v2-1_768-ema-pruned.safetensors`"
            `$go_to = 1
        }
        4 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sd_2.1%2Fwd-1-4-anime_e2.ckpt`"
            `$model_name = `"wd-1-4-anime_e2.ckpt`"
            `$go_to = 1
        }
        5 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sd_2.1%2Fwd-mofu-fp16.safetensors`"
            `$model_name = `"wd-mofu-fp16.safetensors`"
            `$go_to = 1
        }
        6 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2Fsd_xl_base_1.0_0.9vae.safetensors`"
            `$model_name = `"sd_xl_base_1.0_0.9vae.safetensors`"
            `$go_to = 1
        }
        7 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2Fanimagine-xl-3.0.safetensors`"
            `$model_name = `"animagine-xl-3.0.safetensors`"
            `$go_to = 1
        }
        8 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2Fanimagine-xl-3.1.safetensors`"
            `$model_name = `"animagine-xl-3.1.safetensors`"
            `$go_to = 1
        }
        9 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2Fkohaku-xl-delta-rev1.safetensors`"
            `$model_name = `"kohaku-xl-delta-rev1.safetensors`"
            `$go_to = 1
        }
        10 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2FkohakuXLEpsilon_rev1.safetensors`"
            `$model_name = `"kohakuXLEpsilon_rev1.safetensors`"
            `$go_to = 1
        }
        11 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2FponyDiffusionV6XL_v6StartWithThisOne.safetensors`"
            `$model_name = `"ponyDiffusionV6XL_v6.safetensors`"
            `$go_to = 1
        }
        12 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2Fkohaku-xl-epsilon-rev2.safetensors`"
            `$model_name = `"kohaku-xl-epsilon-rev2.safetensors`"
            `$go_to = 1
        }
        13 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2FpdForAnime_v20.safetensors`"
            `$model_name = `"pdForAnime_v20.safetensors`"
            `$go_to = 1
        }
        14 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2FstarryXLV52_v52.safetensors`"
            `$model_name = `"starryXLV52_v52.safetensors`"
            `$go_to = 1
        }
        15 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2FheartOfAppleXL_v20.safetensors`"
            `$model_name = `"heartOfAppleXL_v20.safetensors`"
            `$go_to = 1
        }
        16 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-model/repo?Revision=master&FilePath=sdxl_1.0%2FheartOfAppleXL_v30.safetensors`"
            `$model_name = `"heartOfAppleXL_v30.safetensors`"
            `$go_to = 1
        }
        17 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-vae/repo?Revision=master&FilePath=sd_1.5%2Fvae-ft-ema-560000-ema-pruned.safetensors`"
            `$model_name = `"vae-ft-ema-560000-ema-pruned.safetensors`"
            `$go_to = 1
        }
        18 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-vae/repo?Revision=master&FilePath=sd_1.5%2Fvae-ft-mse-840000-ema-pruned.safetensors`"
            `$model_name = `"vae-ft-mse-840000-ema-pruned.safetensors`"
            `$go_to = 1
        }
        19 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-vae/repo?Revision=master&FilePath=sdxl_1.0%2Fsdxl_fp16_fix_vae.safetensors`"
            `$model_name = `"sdxl_fp16_fix_vae.safetensors`"
            `$go_to = 1
        }
        20 {
            `$url = `"https://modelscope.cn/api/v1/models/licyks/sd-vae/repo?Revision=master&FilePath=sdxl_1.0%2Fsdxl_vae.safetensors`"
            `$model_name = `"sdxl_vae.safetensors`"
            `$go_to = 1
        }
        exit {
            Print-Msg `"�˳�ģ�����ؽű�`"
            `$to_exit = 1
            `$go_to = 1
        }
        Default {
            Print-Msg `"��������, ������`"
        }
    }

    if (`$go_to -eq 1) {
        break
    }
}

if (`$to_exit -eq 1) {
    Print-Msg `"�˳�ģ�����ؽű�`"
    Read-Host | Out-Null
    exit 0
}

Print-Msg `"��ǰѡ��Ҫ���ص�ģ��: `$model_name`"
Print-Msg `"�Ƿ�ȷ������ģ��?`"
Print-Msg `"��ʾ: ���� yes ȷ�ϻ� no ȡ�� (Ĭ��Ϊ no)`"
`$download_model = Read-Host `"===========================================>`"

if (`$download_model -eq `"yes`" -or `$download_model -eq `"y`" -or `$download_model -eq `"YES`" -or `$download_model -eq `"Y`") {
    Print-Msg `"ģ�ͽ������� `$PSScriptRoot\models Ŀ¼��`"
    Print-Msg `"���� `$model_name ģ����`"
    ./git/bin/aria2c --console-log-level=error -c -x 16 -s 16 `$url -d ./models -o `$model_name
    if (`$?) {
        Print-Msg `"`$model_name ģ�����سɹ�`"
    } else {
        Print-Msg `"`$model_name ģ������ʧ��`"
    }
}

Print-Msg `"�˳�ģ�����ؽű�`"
Read-Host | Out-Null
"

    Set-Content -Path "./SD-Trainer/download_models.ps1" -Value $content
}


# ���⻷������ű�
function Write-Env-Activate-Script {
    $content = "
function global:prompt {
    `"`$(Write-Host `"[SD-Trainer Env]`" -ForegroundColor Green -NoNewLine) `$(Get-Location)>`"
}

function Print-Msg (`$msg) {
    Write-Host `"[`$(Get-Date -Format `"yyyy-MM-dd HH:mm:ss`")][SD-Trainer Installer]:: `$msg`"
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
if (!(Test-Path `"`$PSScriptRoot/disable_hf_mirror.txt`")) { # ����Ƿ�������Զ�����huggingface����Դ
    if (Test-Path `"`$PSScriptRoot/hf_mirror.txt`") { # ���ش���huggingface����Դ����
        `$hf_mirror_value = Get-Content `"`$PSScriptRoot/hf_mirror.txt`"
        `$env:HF_ENDPOINT = `$hf_mirror_value
        Print-Msg `"��⵽���ش��� hf_mirror.txt �����ļ�, �Ѷ�ȡ�����ò����� HuggingFace ����Դ`"
    } else { # ʹ��Ĭ������
        `$env:HF_ENDPOINT = `"https://hf-mirror.com`"
        Print-Msg `"ʹ��Ĭ�� HuggingFace ����Դ`"
    }
} else {
    Print-Msg `"��⵽���ش��� disable_hf_mirror.txt ����Դ�����ļ�, �����Զ����� HuggingFace ����Դ`"
}

# github ����Դ
if (Test-Path `"`$PSScriptRoot/disable_gh_mirror.txt`") { # ����github����Դ
    Print-Msg `"��⵽���ش��� disable_gh_mirror.txt Github ����Դ�����ļ�, ���� Github ����Դ`"
} else {
    `$env:GIT_CONFIG_GLOBAL = `"`$PSScriptRoot/.gitconfig`" # ����git�����ļ�·��
    if (Test-Path `"`$PSScriptRoot/.gitconfig`") {
        Remove-Item -Path `"`$PSScriptRoot/.gitconfig`" -Force
    }

    if (Test-Path `"`$PSScriptRoot/gh_mirror.txt`") { # ʹ���Զ���github����Դ
        `$github_mirror = Get-Content `"`$PSScriptRoot/gh_mirror.txt`"
        ./git/bin/git.exe config --global url.`"`$github_mirror`".insteadOf `"https://github.com`"
        Print-Msg `"��⵽���ش��� gh_mirror.txt Github ����Դ�����ļ�, �Ѷ�ȡ Github ����Դ�����ļ������� Github ����Դ`"
    }
}

# ��������
`$py_path = `"`$PSScriptRoot/python`"
`$py_scripts_path = `"`$PSScriptRoot/python/Scripts`"
`$git_path = `"`$PSScriptRoot/git/bin`"
`$Env:PATH = `"`$py_path`$([System.IO.Path]::PathSeparator)`$py_scripts_path`$([System.IO.Path]::PathSeparator)`$git_path`$([System.IO.Path]::PathSeparator)`$Env:PATH`" # ��python��ӵ���������
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

Print-Msg `"���� SD-Trainer Env`"
Print-Msg `"���������Ϣ���� SD-Trainer Installer ��Ŀ��ַ�鿴: https://github.com/licyk/sd-webui-all-in-one/blob/main/sd_trainer_installer.md`"
"

    Set-Content -Path "./SD-Trainer/activate.ps1" -Value $content
}


# �����ĵ�
function Write-ReadMe {
    $content = "==================================
SD-Trainer Installer created by licyk
����������https://space.bilibili.com/46497516
Github��https://github.com/licyk
==================================

���ǹ��� SD-Trainer �ļ�ʹ���ĵ���

ʹ�� SD-Trainer Installer ���а�װ����װ�ɹ��󣬽��ڵ�ǰĿ¼���� SD-Trainer �ļ��У�����Ϊ�ļ����в�ͬ�ļ� / �ļ��е����á�

cache�������ļ��У������� Pip / HuggingFace �Ȼ����ļ���
python��Python �Ĵ��·������ע�⣬���𽫸� Python �ļ�����ӵ���������������ܵ��²��������
git��Git �Ĵ��·����
lora-scripts��SD-Trainer ��ŵ��ļ��С�
models��ʹ��ģ�����ؽű�����ģ��ʱģ�͵Ĵ��λ�á�
activate.ps1�����⻷������ű���ʹ�øýű��������⻷���󼴿�ʹ�� Python��Pip��Git �����
get_sd_trainer_installer.ps1����ȡ���µ� SD-Trainer Installer ��װ�ű������к󽫻����� SD-Trainer �ļ���ͬ����Ŀ¼������ invokeai_installer.ps1 ��װ�ű���
update.ps1������ SD-Trainer �Ľű�����ʹ�øýű����� SD-Trainer��
launch.ps1������ SD-Trainer �Ľű���
reinstall_pytorch.ps1�����°�װ PyTorch �Ľű����� PyTorch �����������Ҫ�л� PyTorch �汾ʱ��ʹ�á�
download_model.ps1������ģ�͵Ľű������ص�ģ�ͽ������ models �ļ����С�
help.txt�������ĵ���


Ҫ���� SD-Trainer������ SD-Trainer �ļ������ҵ� launch.ps1 �ű����Ҽ�����ű���ѡ��ʹ�� PowerShell ���У��ȴ� SD-Trainer ������ɣ�������ɺ��Զ������������ SD-Trainer ���档

�ű�Ϊ SD-Trainer������ ������ HuggingFace ����Դ����������޷�ֱ�ӷ��� HuggingFace �����⣬���� SD-Trainer �޷��� HuggingFace ����ģ�͡�
������Զ��� HuggingFace ����Դ�������ڱ��ش��� hf_mirror.txt �ļ������ļ�����д HuggingFace ����Դ�ĵ�ַ�󱣴棬�ٴ������ű�ʱ���Զ���ȡ���á�
�����Ҫ���� HuggingFace ����Դ���򴴽� disable_hf_mirror.txt �ļ��������ű�ʱ���������� HuggingFace ����Դ��

����Ϊ���õ� HuggingFace ����Դ��ַ��
https://hf-mirror.com
https://huggingface.sukaka.top

Ϊ�˽������ Github �ٶ��������⣬�ű�Ĭ������ Github ����Դ�������� SD-Trainer Installer ���� SD-Trainer ���½ű�ʱ���Զ����Կ��õ� Github ����Դ�����á�
������Զ��� Github ����Դ�������ڱ��ش��� gh_mirror.txt �ļ������ı�����д Github ����Դ�ĵ�ַ�󱣴棬�ٴ������ű�ʱ���Զ���ȡ���á�
�����Ҫ���� Github ����Դ���򴴽� disable_gh_mirror.txt �ļ��������ű�ʱ���������� Github ����Դ��

����Ϊ���õ� Github ����Դ��
https://mirror.ghproxy.com/https://github.com
https://ghproxy.net/https://github.com
https://gitclone.com/github.com
https://gh-proxy.com/https://github.com
https://ghps.cc/https://github.com
https://gh.idayer.com/https://github.com

��ҪΪ�ű����ô������ڴ�������д�ϵͳ����ģʽ���ɣ������ڱ��ش��� proxy.txt �ļ������ļ�����д�����ַ�󱣴棬�ٴ������ű��ǽ��Զ���ȡ���á�
���Ҫ�����Զ����ô��������ڱ��ش��� disable_proxy.txt �ļ��������ű�ʱ�������Զ����ô���

���� SD-Trainer �����������������ں� launch.ps1 �ű�ͬ����Ŀ¼����һ�� launch_args.txt �ļ������ļ���д���������������� SD-Trainer �����ű�ʱ���Զ���ȡ���ļ��ڵ�����������Ӧ�á�

������ϸ�İ���������������Ӳ鿴��
SD-Trainer Installer ʹ�ð�����https://github.com/licyk/sd-webui-all-in-one/blob/main/sd_trainer_installer.md
SD-Trainer ��Ŀ��ַ��https://github.com/Akegarasu/lora-scripts

�Ƽ����������� UP ����
����ʥ�ߣ�https://space.bilibili.com/219296
�������~��https://space.bilibili.com/507303431

һЩѵ��ģ�͵Ľ̳̣�
https://civitai.com/articles/124/lora-analogy-about-lora-trainning-and-using
https://civitai.com/articles/143/some-shallow-understanding-of-lora-training-lora
https://civitai.com/articles/632/why-this-lora-can-not-bring-good-result-lora
https://civitai.com/articles/726/an-easy-way-to-make-a-cosplay-lora-cosplay-lora
https://civitai.com/articles/2135/lora-quality-improvement-some-experiences-about-datasets-and-captions-lora
https://civitai.com/articles/2297/ways-to-make-a-character-lora-that-is-easier-to-change-clothes-lora
"
    Set-Content -Path "./SD-Trainer/help.txt" -Value $content
}


# ������
function Main {
    Print-Msg "���� SD-Trainer ��װ����"
    Print-Msg "��ʾ: ������ĳ������ִ��ʧ��, �ɳ����ٴ����� SD-Trainer Installer"
    Check-Install
    Print-Msg "��������ű����ĵ���"
    Write-Launch-Script
    Write-Update-Script
    Write-SD-Trainer-Install-Script
    Write-PyTorch-Reinstall-Script
    Write-Doenload-Model-Script
    Write-Env-Activate-Script
    Write-ReadMe
    Print-Msg "SD-Trainer ��װ����, ��װ·��Ϊ $PSScriptRoot\SD-Trainer"
    Print-Msg "�����ĵ����� SD-Trainer �ļ����в鿴, ˫�� help.txt �ļ����ɲ鿴"
    Print-Msg "�˳� SD-Trainer Installer"
}


###################


Main
Read-Host | Out-Null
