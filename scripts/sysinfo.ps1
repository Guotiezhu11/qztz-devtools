# sysinfo.ps1 —— 系统信息速查（OS / CPU / 内存 / 磁盘 / 网络）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File .\sysinfo.ps1
# 输出：本机关键环境信息，便于提 issue 或排查环境差异。

$ErrorActionPreference = 'SilentlyContinue'

Write-Host ''
Write-Host '=== 系统 ===' -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
  计算机名   = $env:COMPUTERNAME
  用户名     = $env:USERNAME
  系统       = $os.Caption
  版本       = $os.Version
  架构       = $os.OSArchitecture
  启动时间   = $os.LastBootUpTime
  运行时长   = ('{0:N1} 小时' -f ((Get-Date) - $os.LastBootUpTime).TotalHours)
} | Format-List

Write-Host '=== CPU ===' -ForegroundColor Cyan
Get-CimInstance Win32_Processor |
  Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
  Format-List

Write-Host '=== 内存 ===' -ForegroundColor Cyan
$total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$free  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
"总内存: $total GB   可用: $free GB   已用: $([math]::Round($total - $free, 2)) GB"

Write-Host ''
Write-Host '=== 磁盘 ===' -ForegroundColor Cyan
Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' |
  Select-Object DeviceID,
                @{n='总容量GB'; e={ [math]::Round($_.Size / 1GB, 1) }},
                @{n='可用GB';  e={ [math]::Round($_.FreeSpace / 1GB, 1) }},
                @{n='可用率';  e={ '{0:N1}%' -f ($_.FreeSpace / $_.Size * 100) }} |
  Format-Table -AutoSize

Write-Host '=== 网络 ===' -ForegroundColor Cyan
Get-NetIPConfiguration |
  Where-Object { $_.IPv4DefaultGateway } |
  Select-Object InterfaceAlias,
                @{n='IPv4'; e={ $_.IPv4Address.IPAddress }},
                @{n='网关';  e={ $_.IPv4DefaultGateway.NextHop }} |
  Format-Table -AutoSize

Write-Host '=== CPU 占用前 5 进程 ===' -ForegroundColor Cyan
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, Id,
  @{n='CPU秒'; e={ [math]::Round($_.CPU, 1) }},
  @{n='内存MB'; e={ [math]::Round($_.WorkingSet64 / 1MB, 1) }} |
  Format-Table -AutoSize

Write-Host ''
Write-Host '完成。' -ForegroundColor Green
