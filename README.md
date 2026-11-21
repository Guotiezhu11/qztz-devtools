# qztz devtools

一组我自己在开发与日常排障中维护的 Windows 小工具（PowerShell 编写），持续更新。

## 包含的工具

| 脚本 | 用途 |
|---|---|
| [`scripts/sysinfo.ps1`](scripts/sysinfo.ps1) | 系统信息速查：OS / CPU / 内存 / 磁盘 / 网络 / CPU 占用前 5 进程 |
| [`scripts/http-check.ps1`](scripts/http-check.ps1) | 批量检测 URL 可达性与响应耗时，用于排查网络与依赖服务状态 |

## 使用方法

不需要安装任何依赖，Windows 自带 PowerShell 即可运行。

```powershell
# 1. 克隆仓库
git clone https://github.com/Guotiezhu11/qztz-devtools.git
cd qztz-devtools

# 2. 系统信息速查
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\sysinfo.ps1

# 3. 检查常用开发服务是否可达
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\http-check.ps1

# 也可以只检测指定的地址（逗号分隔）
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\http-check.ps1 -Urls "https://github.com,https://registry.npmjs.org"
```

## 设计说明

- **零依赖**：只用系统内置的 CIM / NetTCPIP 模块，不引入第三方包。
- **只读操作**：`sysinfo.ps1` 只读取系统信息，不修改任何配置。
- **兼容老系统**：脚本以 UTF-8 BOM 保存，Windows PowerShell 5.1 也能正确解析中文。
- **参数兼容**：`http-check.ps1` 同时支持 `-Urls a,b` 与 `-Urls "a,b"` 两种传参方式（`-File` 调用时参数会被合并，脚本内部会再按逗号拆分）。

## 开发进度

| 日期 | 变更 |
|---|---|
| 2026-11-20 | 仓库创建，加入 `sysinfo.ps1`、`http-check.ps1` |

## 许可

MIT
