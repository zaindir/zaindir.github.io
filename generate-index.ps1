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
 background-image: url(data:image/png;base64,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);
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
