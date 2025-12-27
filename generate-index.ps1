$root = Get-Location

# Exclude
$excludeFolders = @("icon")
$excludeFiles   = @(
    "generate-index.ps1",
    "googlea503e79e4b70c07f.html",
    "404.html",
    "index.html",
    "file-index.js"
)

$global:AllFiles = @()
$global:TotalBytes = 0

function Size-Format($bytes) {
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
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

    foreach ($f in $items | Where-Object { -not $_.PSIsContainer }) {
        $path = ($rel.TrimEnd("/") + "/" + $f.Name).Replace("//","/")
        $global:AllFiles += @{
            name = $f.Name
            path = $path
            size = Size-Format $f.Length
        }
        $global:TotalBytes += $f.Length
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>ZainDir - Java Game JAR Archive $rel</title>
<meta name="description" content="ZainDir is a classic Java JAR game archive. Download free Java games for Sony Ericsson and Java phones. Directory: $rel">
<meta name="robots" content="index, follow">
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
body { background:#fff; font-family:Arial; font-size:14px; }
#container { max-width:960px; margin:auto; }
#header img { max-width:100%; }
h1 { font-size:18px; }
table { width:100%; border-collapse:collapse; }
th { text-align:left; border-bottom:1px solid #000; }
td { padding:4px; }
a { color:#0000EE; text-decoration:none; }
a:hover { text-decoration:underline; }
.footer { font-size:12px; color:#555; }
#searchBox { width:100%; padding:6px; margin:8px 0; }
</style>
</head>

<body>
<div id="container">

<div id="header">
<img src="/icon/header.gif" alt="ZainDir Java Game Archive">
</div>

<h1>Index of $rel</h1>
"@

    if ($dir.FullName -eq $root.Path) {
        $html += @"
<input type="text" id="searchBox" placeholder="Search files only (global)...">
<div id="searchResults"></div>
<script src="/file-index.js"></script>
<script>
const box = document.getElementById('searchBox');
const res = document.getElementById('searchResults');

box.addEventListener('keyup', function(){
  let q = this.value.toLowerCase();
  if (q.length < 2) { res.innerHTML = ''; return; }
  let out = '<ul>';
  files.filter(f => f.name.toLowerCase().includes(q))
       .slice(0,50)
       .forEach(f => {
          out += `<li><a href="${f.path}">${f.name}</a> (${f.size})</li>`;
       });
  out += '</ul>';
  res.innerHTML = out;
});
</script>
"@
    }

    $html += @"
<table>
<tr><th>Name</th><th>Size</th></tr>
"@

    foreach ($item in $items | Sort-Object @{Expression="PSIsContainer";Descending=$true}, Name) {

        if ($item.PSIsContainer) {
            $html += "<tr><td><a href='$($item.Name)/'>$($item.Name)/</a></td><td>-</td></tr>"
        } else {
            $html += "<tr><td><a href='$($item.Name)'>$($item.Name)</a></td><td>$(Size-Format $item.Length)</td></tr>"
        }
    }

    $html += @"
</table>
<hr>
<div class="footer">
ZainDir © Java Game Archive • Total storage used: $(Size-Format $global:TotalBytes)
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

# Generate file-index.js
$js = "var files = " + ($global:AllFiles | ConvertTo-Json -Depth 5) + ";"
$js | Set-Content -Encoding UTF8 (Join-Path $root.Path "file-index.js")
