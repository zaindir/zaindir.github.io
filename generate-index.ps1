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
    $description = "ZainDir is a classic Java JAR game archive. Download free Java games for Sony Ericsson and other Java phones. Directory: $rel"

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>$title</title>
<meta name="description" content="$description">
<meta name="keywords" content="java games jar, sony ericsson games, java phone games, mobile jar games, zaindir github io">
<meta name="robots" content="index, follow">
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
body {
    background:#ffffff;
    color:#000000;
    font-family: Arial, Helvetica, sans-serif;
    font-size:14px;
}
#container {
    max-width: 960px;
    margin: auto;
}
#header {
    text-align: center;
    margin-bottom: 10px;
}
#header img {
    max-width: 100%;
    height: auto;
}
h1 {
    font-size:18px;
    margin: 10px 0;
}
table {
    width:100%;
    border-collapse: collapse;
}
th {
    text-align:left;
    border-bottom:1px solid #000;
    padding:4px;
}
td {
    padding:4px;
}
a {
    text-decoration:none;
    color:#0000EE;
}
a:hover {
    text-decoration:underline;
}
.footer {
    font-size:12px;
    color:#555;
}
.icon {
    width:20px;
    height:20px;
}
</style>
</head>

<body>

<div id="container">

<div id="header">
    <img src="/icon/header.gif" alt="ZainDir - Java Game Archive">
</div>

<h1>Index of $rel</h1>

<table>
<tr>
<th class="icon"></th>
<th>Name</th>
<th>Size</th>
<th>Last Modified</th>
</tr>
"@

    if ($dir.FullName -ne $root.Path) {
        $html += @"
<tr>
<td><img src="/icon/parent.gif" class="icon" alt="Parent"></td>
<td><a href="../">Parent Directory</a></td>
<td>-</td>
<td>-</td>
</tr>
"@
    }

    foreach ($item in $items | Sort-Object @{Expression="PSIsContainer";Descending=$true}, Name) {

        if ($item.Name -eq "index.html") { continue }

        $url = [uri]::EscapeUriString($item.Name)

        if ($item.PSIsContainer) {
            $html += @"
<tr>
<td><img src="/icon/folder.gif" class="icon" alt="Folder"></td>
<td><a href="$url/">$($item.Name)/</a></td>
<td>-</td>
<td>$($item.LastWriteTime)</td>
</tr>
"@
        } else {
            $size = Size-Format $item.Length
            $html += @"
<tr>
<td><img src="/icon/file.gif" class="icon" alt="File"></td>
<td><a href="$url">$($item.Name)</a></td>
<td>$size</td>
<td>$($item.LastWriteTime)</td>
</tr>
"@
        }
    }

    $html += @"
</table>

<hr>

<div class="footer">
ZainDir &copy; Classic Java Game Archive • Powered by Ari Project.
</div>

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
