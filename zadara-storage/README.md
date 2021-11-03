# Monitoring Zadara VPSA with Powershell and InluxDB

## Introduction

Monitor-VPSA is a function that collect some data from a VPSA using powershell.

## Architecture

## Requirements

- Tested on Windows Server 2016.
- VPSA API version: [20.12-sp1](http://vpsa-api.zadarastorage.com/20.12-sp1).
- A InfluxDB Server up and running. 

- Install InfluxDB module. Check the article on [PowershellGallery](https://www.powershellgallery.com/packages/Influx/1.0.94).

In case of problems installing InfluxDB module, you can run this workaround on powershell as administrator.

```powershell
PS> [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

More information [here](https://answers.microsoft.com/en-us/windows/forum/all/trying-to-install-program-using-powershell-and/4c3ac2b2-ebd4-4b2a-a673-e283827da143).

## How to use

- Create a readonly user on VPSA interface and get his token.
- Copy monitor-vpsa.ps1 to the server that has VPSA Access.
- Execute the function and then:
  
```powershell
PS> Monitor-VPSA -token "XXX-XX" -uri "https://xxx.xxx.xxx.xxx/api/" -influxServer "XXXX"
```

- Params
  - **token**: Token created on VPSA interface.
  - **uri**: Address of VPSA storage API.
  - **influxServer**: Address of VPSA Server.

### Tips

You can put the function on a telegraf conf, adding the following input:

```conf
[[inputs.exec]]

  interval = "1m"

  commands = [
    'powershell.exe -file "X:\XXX\Monitor-VPSA.ps1"'
  ]

  timeout = "2m"
```

At the end of file X:\XXX\Monitor-VPSA.ps1, add a line calling the function.