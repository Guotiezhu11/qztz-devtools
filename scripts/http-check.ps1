# http-check.ps1 —— 批量检测 URL 的可达性与响应时间
# 用法：
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\http-check.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\http-check.ps1 -Urls https://a.com,https://b.com
# 说明：默认检测一组常用开发服务地址，可自行传入列表。

param(
  [string[]]$Urls = @(
    'https://github.com',
    'https://api.github.com',
    'https://registry.npmjs.org',
    'https://pypi.org',
    'https://stackoverflow.com'
  ),
  [int]$TimeoutSec = 10
)

$ErrorActionPreference = 'Continue'

# 兼容两种传参方式：
#   -File 传入时多个值可能被合并成一个字符串，这里按逗号再拆一次
$Urls = @($Urls | ForEach-Object { $_ -split ',' } | Where-Object { $_ -and $_.Trim() } | ForEach-Object { $_.Trim() })

$rows = foreach ($u in $Urls) {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec $TimeoutSec -MaximumRedirection 3
    $sw.Stop()
    [pscustomobject]@{
      URL    = $u
      状态   = $r.StatusCode
      耗时ms = [math]::Round($sw.Elapsed.TotalMilliseconds)
      结果   = 'OK'
    }
  } catch {
    $sw.Stop()
    $code = $null
    if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    [pscustomobject]@{
      URL    = $u
      状态   = $(if ($code) { $code } else { '—' })
      耗时ms = [math]::Round($sw.Elapsed.TotalMilliseconds)
      结果   = 'FAIL: ' + ($_.Exception.Message -split "`n")[0]
    }
  }
}

$rows | Format-Table -AutoSize

$ok = ($rows | Where-Object { $_.结果 -eq 'OK' }).Count
Write-Host ("可达 {0} / {1}" -f $ok, $rows.Count) -ForegroundColor $(if ($ok -eq $rows.Count) { 'Green' } else { 'Yellow' })
