# ============================================================================
# Epson POS 打印机快速安装脚本
# 支持型号: TM-T20/T20II/T20III/T20X, TM-M30/M30II/M30III, TM-T88V/T88VI
# ============================================================================

#Requires -RunAsAdministrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Epson POS 打印机快速安装" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否已安装 APD6 驱动
Write-Host "检查已安装的 Epson 驱动..." -ForegroundColor Yellow
$epsonDrivers = Get-PrinterDriver | Where-Object {$_.Name -like "*EPSON*" -and $_.Name -like "*TM-*"}

if ($epsonDrivers.Count -eq 0) {
    Write-Host ""
    Write-Host "❌ 未找到 Epson POS 打印机驱动 (APD6)" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先安装 Epson Advanced Printer Driver 6 (APD6)：" -ForegroundColor Yellow
    Write-Host "  1. 访问: https://epson.com/Support/Point-of-Sale/" -ForegroundColor Gray
    Write-Host "  2. 搜索您的打印机型号（如 TM-T20II）" -ForegroundColor Gray
    Write-Host "  3. 下载并安装 APD6 驱动程序" -ForegroundColor Gray
    Write-Host "  4. 重新运行此脚本" -ForegroundColor Gray
    Write-Host ""
    Write-Host "按任意键退出..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "✓ 找到 $($epsonDrivers.Count) 个 Epson 驱动" -ForegroundColor Green
Write-Host ""

# 显示可用驱动
Write-Host "可用的 Epson 打印机驱动：" -ForegroundColor Cyan
for ($i = 0; $i -lt $epsonDrivers.Count; $i++) {
    Write-Host "  [$($i + 1)] $($epsonDrivers[$i].Name)" -ForegroundColor Gray
}
Write-Host ""

# 选择连接类型
Write-Host "请选择打印机连接方式：" -ForegroundColor Yellow
Write-Host "  [1] USB 连接（打印机已通过 USB 连接到电脑）" -ForegroundColor Gray
Write-Host "  [2] 网络连接（以太网/IP 地址）" -ForegroundColor Gray
Write-Host ""
$connectionType = Read-Host "输入选项 (1 或 2)"

if ($connectionType -eq "1") {
    # USB 连接
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  USB 打印机配置" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "请确保：" -ForegroundColor Yellow
    Write-Host "  ✓ 打印机已通过 USB 连接到电脑" -ForegroundColor Gray
    Write-Host "  ✓ 打印机电源已打开" -ForegroundColor Gray
    Write-Host ""
    
    # 检查 USB 设备
    $usbPrinters = Get-PnpDevice | Where-Object {$_.FriendlyName -like "*EPSON*" -and $_.FriendlyName -like "*TM-*"}
    
    if ($usbPrinters.Count -eq 0) {
        Write-Host "❌ 未检测到 USB 打印机" -ForegroundColor Red
        Write-Host ""
        Write-Host "请检查：" -ForegroundColor Yellow
        Write-Host "  1. USB 线是否连接牢固" -ForegroundColor Gray
        Write-Host "  2. 打印机电源是否打开" -ForegroundColor Gray
        Write-Host "  3. 尝试重新插拔 USB 线" -ForegroundColor Gray
        Write-Host ""
        Write-Host "按任意键退出..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    Write-Host "✓ 检测到 USB 打印机：$($usbPrinters[0].FriendlyName)" -ForegroundColor Green
    Write-Host ""
    Write-Host "USB 打印机通常会自动安装，请检查：" -ForegroundColor Yellow
    Write-Host "  Win + R → control printers" -ForegroundColor Gray
    Write-Host ""
    
    # 显示已安装的打印机
    $installedPrinters = Get-Printer | Where-Object {$_.Name -like "*EPSON*" -and $_.Name -like "*TM-*"}
    if ($installedPrinters.Count -gt 0) {
        Write-Host "已安装的 Epson 打印机：" -ForegroundColor Green
        $installedPrinters | ForEach-Object {
            Write-Host "  ✓ $($_.Name) - 状态: $($_.PrinterStatus)" -ForegroundColor Gray
        }
    }
    
} elseif ($connectionType -eq "2") {
    # 网络连接
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  网络打印机配置" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # 选择驱动
    Write-Host "请选择打印机型号（输入序号）：" -ForegroundColor Yellow
    $driverSelection = Read-Host "输入选项 (1-$($epsonDrivers.Count))"
    $selectedDriverIndex = [int]$driverSelection - 1
    
    if ($selectedDriverIndex -lt 0 -or $selectedDriverIndex -ge $epsonDrivers.Count) {
        Write-Host "❌ 无效的选择" -ForegroundColor Red
        exit 1
    }
    
    $DriverName = $epsonDrivers[$selectedDriverIndex].Name
    Write-Host "✓ 已选择驱动: $DriverName" -ForegroundColor Green
    Write-Host ""
    
    # 输入 IP 地址
    Write-Host "请输入打印机 IP 地址：" -ForegroundColor Yellow
    Write-Host "  提示：可以从打印机打印的网络配置单上找到" -ForegroundColor Gray
    Write-Host "  （关机后按住 FEED 按钮开机，释放后打印配置单）" -ForegroundColor Gray
    Write-Host ""
    $PrinterIP = Read-Host "IP 地址 (例如: 192.168.1.100)"
    
    # 验证 IP 格式
    if ($PrinterIP -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        Write-Host "❌ 无效的 IP 地址格式" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "测试打印机连接..." -ForegroundColor Yellow
    $pingResult = Test-NetConnection -ComputerName $PrinterIP -Port 9100 -WarningAction SilentlyContinue
    
    if (-not $pingResult.TcpTestSucceeded) {
        Write-Host "⚠ 警告：无法连接到打印机 IP: $PrinterIP" -ForegroundColor Yellow
        Write-Host "  请检查：" -ForegroundColor Gray
        Write-Host "    1. IP 地址是否正确" -ForegroundColor Gray
        Write-Host "    2. 打印机是否在同一网络" -ForegroundColor Gray
        Write-Host "    3. 网线是否连接" -ForegroundColor Gray
        Write-Host ""
        $continue = Read-Host "是否继续配置? (y/n)"
        if ($continue -ne "y") {
            exit 1
        }
    } else {
        Write-Host "✓ 成功连接到打印机" -ForegroundColor Green
    }
    
    Write-Host ""
    # 输入打印机名称
    Write-Host "请输入打印机名称：" -ForegroundColor Yellow
    Write-Host "  （将显示在 Windows 中的名称）" -ForegroundColor Gray
    $defaultName = "POS Receipt Printer"
    $PrinterName = Read-Host "打印机名称 (默认: $defaultName)"
    if ([string]::IsNullOrWhiteSpace($PrinterName)) {
        $PrinterName = $defaultName
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  开始安装..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # 添加打印机端口
    Write-Host "[1/3] 添加打印机端口..." -ForegroundColor Cyan
    $PortName = "IP_$PrinterIP"
    
    # 检查端口是否已存在
    $existingPort = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
    if ($existingPort) {
        Write-Host "      ✓ 端口已存在: $PortName" -ForegroundColor Green
    } else {
        try {
            Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP -ErrorAction Stop
            Write-Host "      ✓ 端口已创建: $PortName" -ForegroundColor Green
        } catch {
            Write-Host "      ❌ 无法创建端口: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
    
    # 添加打印机
    Write-Host "[2/3] 添加打印机..." -ForegroundColor Cyan
    try {
        Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName -ErrorAction Stop
        Write-Host "      ✓ 打印机已添加: $PrinterName" -ForegroundColor Green
    } catch {
        Write-Host "      ❌ 无法添加打印机: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    # 配置打印机
    Write-Host "[3/3] 配置打印机..." -ForegroundColor Cyan
    try {
        # 设置纸张大小为 80mm 收据纸
        Set-PrintConfiguration -PrinterName $PrinterName -PaperSize "Roll Paper 80 x 297 mm" -ErrorAction SilentlyContinue
        Write-Host "      ✓ 纸张大小已设置: 80mm" -ForegroundColor Green
    } catch {
        Write-Host "      ⚠ 警告：无法设置纸张大小" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ 安装完成！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # 显示安装信息
    Write-Host "打印机信息：" -ForegroundColor Cyan
    Write-Host "  名称: $PrinterName" -ForegroundColor Gray
    Write-Host "  驱动: $DriverName" -ForegroundColor Gray
    Write-Host "  IP 地址: $PrinterIP" -ForegroundColor Gray
    Write-Host "  端口: $PortName" -ForegroundColor Gray
    Write-Host ""
    
    # 询问是否设置为默认打印机
    Write-Host "是否设置为默认打印机? (y/n): " -ForegroundColor Yellow -NoNewline
    $setDefault = Read-Host
    if ($setDefault -eq "y") {
        Set-Printer -Name $PrinterName -Default
        Write-Host "✓ 已设置为默认打印机" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # 询问是否共享打印机
    Write-Host "是否共享此打印机给其他电脑? (y/n): " -ForegroundColor Yellow -NoNewline
    $shareIt = Read-Host
    if ($shareIt -eq "y") {
        $shareName = Read-Host "输入共享名称 (默认: POSPrinter)"
        if ([string]::IsNullOrWhiteSpace($shareName)) {
            $shareName = "POSPrinter"
        }
        Set-Printer -Name $PrinterName -Shared $true -ShareName $shareName
        Write-Host "✓ 打印机已共享为: \\$env:COMPUTERNAME\$shareName" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor Yellow
    Write-Host "  1. 打开控制面板 → 设备和打印机" -ForegroundColor Gray
    Write-Host "  2. 右键打印机 → 打印测试页" -ForegroundColor Gray
    Write-Host "  3. 或在 POS 软件中测试打印" -ForegroundColor Gray
    
} else {
    Write-Host "❌ 无效的选择" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "提示：" -ForegroundColor Cyan
Write-Host "  - 查看详细文档: docs\Epson_POS_Printer_Guide.md" -ForegroundColor Gray
Write-Host "  - 打印机设置: control printers" -ForegroundColor Gray
Write-Host "  - 网络配置工具: 使用 EpsonNet Config" -ForegroundColor Gray
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
