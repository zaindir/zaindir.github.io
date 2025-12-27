$root = Get-Location

$excludeFolders = @("icon")
$excludeFiles = @(
    "generate-index.ps1",
    "googlea503e79e4b70c07f.html",
    "404.html",
    "index.html"
)

$globalFiles = @()
$totalBytes = 0

function Size-Format($bytes) {
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { "{0:N2} KB" -f ($bytes / 1KB) }
    else { "$bytes B" }
}

function Get-Icon($name) {
    switch ([System.IO.Path]::GetExtension($name).ToLower()) {
        ".jar" { "jar.gif" }
        ".zip" { "zip.gif" }
        ".rar" { "rar.gif" }
        default { "file.gif" }
    }
}

# ===== SCAN ALL FILES =====
Get-ChildItem $root -Recurse -File | Where-Object {
    -not ($excludeFiles -contains $_.Name) -and
    -not ($excludeFolders -contains $_.Directory.Name)
} | ForEach-Object {

    $relPath = $_.FullName.Replace($root.Path,"").Replace("\","/")
    $globalFiles += @{
        name = $_.Name
        path = $relPath
        size = Size-Format $_.Length
        bytes = $_.Length
        icon = Get-Icon $_.Name
    }
    $totalBytes += $_.Length
}

$totalSize = Size-Format $totalBytes

# ===== HOMEPAGE =====
$json = $globalFiles | ConvertTo-Json -Compress

$homeHtml = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ZainDir - Java Game JAR Archive</title>
<meta name="description" content="ZainDir is a classic Java JAR game archive. Download free Java games for Sony Ericsson and Java phones.">
<meta name="robots" content="index,follow">

<style>
body { font-family:Arial; font-size:13px; background:#fff; }
h1 { font-size:16px; }
input { width:100%; padding:5px; font-size:13px; }
table { width:100%; border-collapse:collapse; }
th { border-bottom:1px solid #000; text-align:left; }
td { padding:4px; }
.page a { margin:0 3px; cursor:pointer; }
</style>
</head>

<body>
<img src="/icon/header.gif"><br>

<h1>Global Java Game Search</h1>

<input type="text" id="q" placeholder="Search JAR / ZIP / RAR files..." onkeyup="search()">

<table id="list">
<tr><th></th><th>File</th><th>Size</th></tr>
</table>

<div class="page" id="pages"></div>

<hr>
Total Archive Size: $totalSize<br>
ZainDir © Classic Java Game Archive
<script>
var files = $json;
var perPage = 50;
var current = 1;

function search(){
 current=1;
 render();
}

function render(){
 var q=document.getElementById('q').value.toLowerCase();
 var filtered = files.filter(f=>f.name.toLowerCase().includes(q));
 var table=document.getElementById('list');
 table.innerHTML='<tr><th></th><th>File</th><th>Size</th></tr>';
 var start=(current-1)*perPage;
 filtered.slice(start,start+perPage).forEach(f=>{
   table.innerHTML+=`<tr>
<td><img src="/icon/${f.icon}"></td>
<td><a href="${f.path}">${f.name}</a></td>
<td>${f.size}</td>
</tr>`;
 });
 pages(filtered.length);
}

function pages(total){
 var p=document.getElementById('pages');
 p.innerHTML='';
 var max=Math.ceil(total/perPage);
 for(let i=1;i<=max;i++){
  p.innerHTML+=`<a onclick="current=${i};render()">${i}</a>`;
 }
}

render();
</script>
</body>
</html>
"@

$homeHtml | Set-Content -Encoding UTF8 (Join-Path $root "index.html")
