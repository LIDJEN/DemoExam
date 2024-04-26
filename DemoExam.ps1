$options = "V-1-Adm", "V-1-DB", "Oper-CA", "V-2-Client", "V-3-Adm", "V-3-DB"

# Show options
function ShowOptions {
    Write-Host "Выберите одну из следующих опций:"
    for ($i=0; $i -lt $options.Length; $i++) {
        Write-Host "$($i+1): $($options[$i])"
    }
}

# Comfirm selected
function ConfirmSelection {
    param (
        [string]$message = ""
    )
    if ($message -ne "") {
        Write-Host $message
    }
    $confirmation = Read-Host "(Y/n)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y" -or $confirmation -eq "") {
        return $true
    } else {
        return $false
    }
}

do {
    ShowOptions
    $selection = Read-Host "Введите номер вашего выбора"
    $machineName = $options[$selection-1]
} while (-not (ConfirmSelection -message "Вы выбрали: $machineName."))

Write-Host "Подтвержденный выбор: $machineName"
$abortTheMission=0
switch ($machineName) {
    "V-1-Adm" {
        $ipAddress = "172.20.30.11"
        $subnetMask = "26"
        Break
    }
    "V-1-DB" {
        $ipAddress = "172.20.30.10"
        $subnetMask = "26"
        Break
    }
    "Oper-CA" {
        $ipAddress = "172.20.30.15"
        $subnetMask = "26"
        Break
    }
    "V-2-Client" {
        $ipAddress = "192.168.90.10"
        $subnetMask = "28"
        Break
    }
    "V-3-Adm" {
        $ipAddress = "192.168.110.2"
        $subnetMask = "28"
        Break
    }
    "V-3-DB" {
        $ipAddress = "192.168.110.3"
        $subnetMask = "28"
        Break
    }
    default {
        Write-Host "КАК??`nКАК ТЫ ЭТОГО ДОБИЛСЯ"
        $abortTheMission=1
    }
}

if ($abortTheMission){
    Write-Host "Mission aborted`nExiting script"
    exit
}
if ($machineName -eq "V-1-DB" -or $machineName -eq "V-3-DB"){
    While (-not (ConfirmSelection -message "is DotNet installed?")){
        Write-Host "Install dotNet firstly"
    }
}

# Firewall off
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ipAddress -PrefixLength $subnetMask



# CHECK

$ipAddress = (Get-NetIPAddress -AddressFamily IPv4).IPAddress
Write-Host "IP-адрес: $ipAddress"


$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    $name = $profile.Name
    $status = $profile.Enabled
    Write-Host "Состояние брандмауэра ($name): $status"
}
if (ConfirmSelection -message "Адаптер находиться в сети NAT?"){
    switch ($machineName) {
        "V-1-Adm" {
            Write-Host "Lan 1"
        }
        "V-1-DB" {
            Write-Host "Lan 1"
        }
        "Oper-CA" {
            Write-Host "Lan 1"
        }
        "V-2-Client" {
            Write-Host "Lan 2"
        }
        "V-3-Adm" {
            Write-Host "Lan 3"
        }
        "V-3-DB" {
            Write-Host "Lan 3"
        }
        default {
            Write-Host "КАК??`nКАК ТЫ ЭТОГО ДОБИЛСЯ"
            $abortTheMission=1
        }
    }
}
# Continue
do {
    if ($machineName == "V-1-DB" or $machineName == "V-3-DB"){
        Write-Host "Сделай снимок"
        
    }
} while (-not (ConfirmSelection -message "Продолжить?"))


if ($machineName -eq "V-1-DB" -or $machineName -eq "V-3-DB"){
    $installerPath = "$env:USERPROFILE\Desktop\SQLEXPR_x64_RUS.exe"
    # Параметры установки
    $installParams = "/ACTION=Install /FEATURES=SQLEngine,RS /INSTANCENAME=WINCCSQL "
    $installParams += "/SECURITYMODE=SQL /SAPWD=xxXX1234 "
    $installParams += "/IACCEPTSQLSERVERLICENSETERMS "
    $installParams += "/FILESTREAMLEVEL=3 "
    $installParams += "/FILESTREAMSHARENAME='WINCCSQL'"

    Start-Process -FilePath $installerPath -ArgumentList $installParams -Wait -PassThru
    Write-Host "DataBase installed"
}