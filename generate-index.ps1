$root = Get-Location

# Folder dan file yang dikecualikan
$excludeFolders = @("icon")
$excludeFiles   = @("generate-index.ps1", "googlea503e79e4b70c07f.html", "404.html")

function Size-Format($bytes) {
    if ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { "{0:N2} KB" -f ($bytes / 1KB) }
    else { "$bytes B" }
}

function GenerateIndex($dir) {

    $items = Get-ChildItem $dir | Where-Object {
        -not ($_.PSIsContainer -and $excludeFolders -contains $_.Name) -and
        -not (-not $_.PSIsContainer -and $excludeFiles -contains $_.Name)
    }

    $rel = $dir.FullName.Replace($root.Path, "").Replace("\","/")
    if ($rel -eq "") { $rel = "/" }

    $title = "ZainDir - Java Game JAR Archive $rel"
    $description = "ZainDir is a classic Java JAR game archive. Directory: $rel"

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>$title</title>
<meta name="description" content="$description">
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
body {
  font-family: Arial, Helvetica, sans-serif;
  font-size:13px;
  background:#fff;
  color:#000;
  margin:20px;
}

#header { text-align:center; margin-bottom:10px; }
#header img { max-width:100%; height:auto; }

h1 {
  font-size:16px;
  border-bottom:1px solid #c0c0c0;
  padding-bottom:6px;
}

table {
  width:100%;
  border-collapse:collapse;
}

th {
  text-align:left;
  padding:4px 6px;
  border-bottom:1px solid #c0c0c0;
}

td {
  padding:4px 6px;
  white-space:nowrap;
}

td.size, td.date {
  text-align:right;
  color:#555;
}

tr:hover {
  background:#f5f5f5;
}

a {
  color:#00f;
  text-decoration:none;
}

a:hover {
  text-decoration:underline;
}

a.icon {
  padding-left:20px;
  background-repeat:no-repeat;
  background-position:left center;
}

a.file {
 background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAABnRSTlMAAAAAAABupgeRAAABEElEQVR42nRRx3HDMBC846AHZ7sP54BmWAyrsP588qnwlhqw/k4v5ZwWxM1hzmGRgV1cYqrRarXoH2w2m6qqiqKIR6cPtzc3xMSML2Te7XZZlnW7Pe/91/dX47WRBHuA9oyGmRknzGDjab1ePzw8bLfb6WRalmW4ip9FDVpYSWZgOp12Oh3nXJ7nxoJSGEciteP9y+fH52q1euv38WosqA6T2gGOT44vry7BEQtJkMAMMpa6JagAMcUfWYa4hkkzAc7fFlSjwqCoOUYAF5RjHZPVCFBOtSBGfgUDji3c3jpibeEMQhIMh8NwshqyRsBJgvF4jMs/YlVR5KhgNpuBLzk0OcUiR3CMhcPaOzsZiAAA/AjmaB3WZIkAAAAASUVORK5CYII=");
}

a.dir {
  background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABt0lEQVR42oxStZoWQRCs2cXdHTLcHZ6EjAwnQWIkJyQlRt4Cd3d3d1n5d7q7ju1zv/q+mh6taQsk8fn29kPDRo87SDMQcNAUJgIQkBjdAoRKdXjm2mOH0AqS+PlkP8sfp0h93iu/PDji9s2FzSSJVg5ykZqWgfGRr9rAAAQiDFoB1OfyESZEB7iAI0lHwLREQBcQQKqo8p+gNUCguwCNAAUQAcFOb0NNGjT+BbUC2YsHZpWLhC6/m0chqIoM1LKbQIIBwlTQE1xAo9QDGDPYf6rkTpPc92gCUYVJAZjhyZltJ95f3zuvLYRGWWCUNkDL2333McBh4kaLlxg+aTmyL7c2xTjkN4Bt7oE3DBP/3SRz65R/bkmBRPGzcRNHYuzMjaj+fdnaFoJUEdTSXfaHbe7XNnMPyqryPcmfY+zURaAB7SHk9cXSH4fQ5rojgCAVIuqCNWgRhLYLhJB4k3iZfIPtnQiCpjAzeBIRXMA6emAqoEbQSoDdGxFUrxS1AYcpaNbBgyQBGJEOnYOeENKR/iAd1npusI4C75/c3539+nbUjOgZV5CkAU27df40lH+agUdIuA/EAgDmZnwZlhDc0wAAAABJRU5ErkJggg==");
}

a.up {
  background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACM0lEQVR42myTA+w1RxRHz+zftmrbdlTbtq04qRGrCmvbDWp9tq3a7tPcub8mj9XZ3eHOGQdJAHw77/LbZuvnWy+c/CIAd+91CMf3bo+bgcBiBAGIZKXb19/zodsAkFT+3px+ssYfyHTQW5tr05dCOf3xN49KaVX9+2zy1dX4XMk+5JflN5MBPL30oVsvnvEyp+18Nt3ZAErQMSFOfelCFvw0HcUloDayljZkX+MmamTAMTe+d+ltZ+1wEaRAX/MAnkJdcujzZyErIiVSzCEvIiq4O83AG7LAkwsfIgAnbncag82jfPPdd9RQyhPkpNJvKJWQBKlYFmQA315n4YPNjwMAZYy0TgAweedLmLzTJSTLIxkWDaVCVfAbbiKjytgmm+EGpMBYW0WwwbZ7lL8anox/UxekaOW544HO0ANAshxuORT/RG5YSrjlwZ3lM955tlQqbtVMlWIhjwzkAVFB8Q9EAAA3AFJ+DR3DO/Pnd3NPi7H117rAzWjpEs8vfIqsGZpaweOfEAAFJKuM0v6kf2iC5pZ9+fmLSZfWBVaKfLLNOXj6lYY0V2lfyVCIsVzmcRV9Y0fx02eTaEwhl2PDrXcjFdYRAohQmS8QEFLCLKGYA0AeEakhCCFDXqxsE0AQACgAQp5w96o0lAXuNASeDKWIvADiHwigfBINpWKtAXJvCEKWgSJNbRvxf4SmrnKDpvZavePu1K/zu/due1X/6Nj90MBd/J2Cic7WjBp/jUdIuA8AUtd65M+PzXIAAAAASUVORK5CYII=");
}

.footer {
  margin-top:10px;
  font-size:11px;
  color:#555;
  border-top:1px solid #c0c0c0;
  padding-top:6px;
}

#searchBox {
  margin:10px 0;
  padding:6px;
  width:100%;
  font-size:13px;
}
</style>
</head>

<body>

<div id="header">
    <img src="icon/header.gif" alt="ZainDir - Java Game Archive">
</div>

<h1>Index of $rel</h1>

<input type="text" id="searchBox" placeholder="Search files or folders..." onkeyup="filterTable()">

<table id="fileTable">
<tr>
  <th>Name</th>
  <th class="size">Size</th>
  <th class="date">Last Modified</th>
</tr>
"@

    if ($dir.FullName -ne $root.Path) {
        $html += @"
<tr>
  <td><a href='../' class='icon up'>Parent Directory</a></td>
  <td class='size'>-</td>
  <td class='date'>-</td>
</tr>
"@
    }

    foreach ($item in $items | Sort-Object @{Expression="PSIsContainer";Descending=$true}, Name) {
        if ($item.Name -eq "index.html") { continue }
        $url = [uri]::EscapeUriString($item.Name)

        if ($item.PSIsContainer) {
            $html += @"
<tr>
  <td><a href='$url/' class='icon dir'>$($item.Name)/</a></td>
  <td class='size'>-</td>
  <td class='date'>$($item.LastWriteTime)</td>
</tr>
"@
        } else {
            $size = Size-Format $item.Length
            $html += @"
<tr>
  <td><a href='$url' class='icon file'>$($item.Name)</a></td>
  <td class='size'>$size</td>
  <td class='date'>$($item.LastWriteTime)</td>
</tr>
"@
        }
    }

$html += @"
</table>

<script>
function filterTable() {
    var input = document.getElementById('searchBox');
    var filter = input.value.toLowerCase();
    var table = document.getElementById('fileTable');
    var tr = table.getElementsByTagName('tr');
    for (var i = 1; i < tr.length; i++) {
        var td = tr[i].getElementsByTagName('td')[0];
        if (td) {
            tr[i].style.display = td.innerText.toLowerCase().indexOf(filter) > -1 ? '' : 'none';
        }
    }
}
</script>

<div class="footer">
ZainDir &copy; Classic Java Game Archive • Powered by Ari Project. | <i>Apache/2.4.41 (Ubuntu) /Npap.c Server at www.zaindir.github.io port 443</i>
</div>

</body>
</html>
"@

    $html | Set-Content -Encoding UTF8 (Join-Path $dir.FullName "index.html")

    foreach ($sub in Get-ChildItem $dir -Directory | Where-Object {
        -not ($excludeFolders -contains $_.Name)
    }) {
        GenerateIndex $sub
    }
}

GenerateIndex (Get-Item $root.Path)
