const perPage = 20;
let currentPage = 1;
let rows = [];
let filteredRows = [];

document.getElementById('search').addEventListener('keyup', applySearch);

/* CSV parser aman (Windows CRLF, quote, koma) */
function parseCSV(text) {
    const result = [];
    let row = [];
    let value = '';
    let inQuotes = false;

    for (let i = 0; i < text.length; i++) {
        const c = text[i];

        if (c === '"') {
            inQuotes = !inQuotes;
        } else if (c === ',' && !inQuotes) {
            row.push(value);
            value = '';
        } else if ((c === '\n' || c === '\r') && !inQuotes) {
            if (row.length || value) {
                row.push(value);
                result.push(row);
                row = [];
                value = '';
            }
        } else {
            value += c;
        }
    }
    return result;
}

function clean(t) {
    return t.replace(/\r/g, '').trim();
}

function applySearch() {
    const q = document.getElementById('search').value.toLowerCase();
    currentPage = 1;

    filteredRows = q === ''
        ? rows
        : rows.filter(r => clean(r[0]).toLowerCase().indexOf(q) !== -1);

    render();
}

function render() {
    const start = (currentPage - 1) * perPage;
    const end = start + perPage;
    const slice = filteredRows.slice(start, end);
    const tbody = document.getElementById('data');
    tbody.innerHTML = '';

    slice.forEach(r => {
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td>' + clean(r[0]) + '</td>' +
            '<td>' + clean(r[1]) + '</td>' +
            '<td><a href="' + encodeURI(clean(r[2])) + '">Download</a></td>';
        tbody.appendChild(tr);
    });

    renderPagination();
}

function renderPagination() {
    const pageCount = Math.ceil(filteredRows.length / perPage);
    const p = document.getElementById('pagination');
    p.innerHTML = '';

    if (pageCount <= 1) return;

    if (currentPage > 1) {
        p.innerHTML += '<a href="#" onclick="currentPage--;render();return false;">Prev</a> ';
    }

    const max = 10;
    let s = Math.max(1, currentPage - 4);
    let e = Math.min(pageCount, s + max - 1);
    s = Math.max(1, e - max + 1);

    if (s > 1) p.innerHTML += '... ';

    for (let i = s; i <= e; i++) {
        if (i === currentPage) {
            p.innerHTML += '<b>' + i + '</b> ';
        } else {
            p.innerHTML += '<a href="#" onclick="currentPage=' + i + ';render();return false;">' + i + '</a> ';
        }
    }

    if (e < pageCount) p.innerHTML += '... ';

    if (currentPage < pageCount) {
        p.innerHTML += '<a href="#" onclick="currentPage++;render();return false;">Next</a>';
    }
}

fetch('241225.csv')
.then(r => r.text())
.then(text => {
    rows = parseCSV(text).slice(1); // buang header
    filteredRows = rows;
    render();
});
