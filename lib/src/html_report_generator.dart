import 'dart:convert';
import 'dart:io';

String simplifyPath(String filePath) {
  final match = RegExp(r'.*?(lib[\\/].*)').firstMatch(filePath);
  if (match != null) {
    return match.group(1)!.replaceAll('\\', '/');
  }

  return filePath.replaceAll('\\', '/');
}

class HtmlReportGenerator {
  final Map<String, List<Map<String, dynamic>>> occurrences;

  HtmlReportGenerator(this.occurrences);

  Future<void> generate(String outputPath) async {
    final reportFile = File(outputPath);
    final htmlBuffer = StringBuffer();

    htmlBuffer.writeln('<!DOCTYPE html>');
    htmlBuffer.writeln('<html lang="en">');
    htmlBuffer.writeln('<head>');
    htmlBuffer.writeln('<meta charset="UTF-8">');
    htmlBuffer.writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    htmlBuffer.writeln('<title>Untranslated UI Texts Report</title>');

    htmlBuffer.writeln('<style>');
    htmlBuffer.writeln(':root {');
    htmlBuffer.writeln('  --primary-color: #007acc;');
    htmlBuffer.writeln('  --background-color: #f9f9f9;');
    htmlBuffer.writeln('  --border-color: #ccc;');
    htmlBuffer.writeln('  --header-bg: #eaeaea;');
    htmlBuffer.writeln('  --summary-bg: #dff0d8;');
    htmlBuffer.writeln('  --summary-border: #d6e9c6;');
    htmlBuffer.writeln('  --highlight-color: #ffff99 !important;');
    htmlBuffer.writeln('  --detail-bg-even: #f9f9f9;');
    htmlBuffer.writeln('  --detail-bg-odd: #ffffff;');
    htmlBuffer.writeln('  --toast-bg: rgba(0, 0, 0, 0.8);');
    htmlBuffer.writeln('  --toast-color: #fff;');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln(
        'body { font-family: Arial, sans-serif; margin: 20px; background-color: var(--background-color); color: #333; }');
    htmlBuffer.writeln('h1, h2, h3 { color: #333; }');
    htmlBuffer.writeln(
        'table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }');
    htmlBuffer.writeln(
        'th, td { border: 1px solid var(--border-color); padding: 10px; text-align: left; }');
    htmlBuffer.writeln('th { background-color: var(--header-bg); }');
    htmlBuffer.writeln('tr:nth-child(even) { background-color: #f2f2f2; }');
    htmlBuffer.writeln(
        '.clickable { color: var(--primary-color); font-weight: bold; cursor: pointer; }');
    htmlBuffer.writeln('.occurrence { margin-left: 20px; }');
    htmlBuffer
        .writeln('a { text-decoration: none; color: var(--primary-color); }');
    htmlBuffer.writeln(
        '#searchInput, #sortSelect { padding: 8px; margin-right: 10px; border: 1px solid var(--border-color); }');
    htmlBuffer.writeln(
        '.summary-box { background-color: var(--summary-bg); border: 1px solid var(--summary-border); padding: 10px; margin-top: 10px; }');
    htmlBuffer.writeln(
        '.highlight { background-color: var(--highlight-color); transition: background-color 1s ease; }');
    htmlBuffer.writeln(
        '.detail-item { padding: 5px; border-bottom: 1px dashed var(--border-color); }');
    htmlBuffer.writeln(
        '.detail-item:nth-child(odd) { background-color: var(--detail-bg-odd); }');
    htmlBuffer.writeln(
        '.detail-item:nth-child(even) { background-color: var(--detail-bg-even); }');
    htmlBuffer.writeln(
        '.copy-btn { background: transparent; border: none; cursor: pointer; margin-left: 5px; color: var(--primary-color); font-size: 1em; }');
    htmlBuffer.writeln('#copyToast {');
    htmlBuffer.writeln('  display: none;');
    htmlBuffer.writeln('  position: fixed;');
    htmlBuffer.writeln('  bottom: 20px;');
    htmlBuffer.writeln('  right: 20px;');
    htmlBuffer.writeln('  background-color: var(--toast-bg);');
    htmlBuffer.writeln('  color: var(--toast-color);');
    htmlBuffer.writeln('  padding: 10px 20px;');
    htmlBuffer.writeln('  border-radius: 4px;');
    htmlBuffer.writeln('  font-size: 14px;');
    htmlBuffer.writeln('  z-index: 9999;');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('@media (max-width: 600px) {');
    htmlBuffer.writeln('  body { margin: 10px; font-size: 14px; }');
    htmlBuffer.writeln('  th, td { padding: 8px; }');
    htmlBuffer.writeln(
        '  #searchInput, #sortSelect { width: 100%; margin-bottom: 10px; }');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('</style>');

    htmlBuffer.writeln('<script>');
    htmlBuffer.writeln('function filterAndSortTable() {');
    htmlBuffer.writeln('  var input = document.getElementById("searchInput");');
    htmlBuffer.writeln('  var filter = input.value.toLowerCase();');
    htmlBuffer.writeln('  var select = document.getElementById("sortSelect");');
    htmlBuffer.writeln('  var sortOrder = select.value;');
    htmlBuffer
        .writeln('  var table = document.getElementById("summaryTable");');
    htmlBuffer.writeln('  var tbody = table.getElementsByTagName("tbody")[0];');
    htmlBuffer
        .writeln('  var rows = Array.from(tbody.getElementsByTagName("tr"));');
    htmlBuffer.writeln('  if (sortOrder !== "default") {');
    htmlBuffer.writeln('    rows.sort(function(a, b) {');
    htmlBuffer
        .writeln('      var aCount = parseInt(a.cells[1].innerText) || 0;');
    htmlBuffer
        .writeln('      var bCount = parseInt(b.cells[1].innerText) || 0;');
    htmlBuffer.writeln(
        '      return sortOrder === "asc" ? aCount - bCount : bCount - aCount;');
    htmlBuffer.writeln('    });');
    htmlBuffer.writeln('  }');
    htmlBuffer
        .writeln('  rows.forEach(function(row) { tbody.appendChild(row); });');
    htmlBuffer.writeln('  rows.forEach(function(row) {');
    htmlBuffer.writeln('    var cell = row.getElementsByTagName("td")[0];');
    htmlBuffer.writeln('    if (cell) {');
    htmlBuffer
        .writeln('      var txtValue = cell.textContent || cell.innerText;');
    htmlBuffer.writeln(
        '      row.style.display = txtValue.toLowerCase().indexOf(filter) > -1 ? "" : "none";');
    htmlBuffer.writeln('    }');
    htmlBuffer.writeln('  });');
    htmlBuffer.writeln(
        '  var details = document.getElementsByClassName("detail-item");');
    htmlBuffer.writeln('  Array.from(details).forEach(function(item) {');
    htmlBuffer.writeln('    var text = item.textContent || item.innerText;');
    htmlBuffer.writeln(
        '    item.style.display = text.toLowerCase().indexOf(filter) > -1 ? "" : "none";');
    htmlBuffer.writeln('  });');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('function scrollToDetails(id) {');
    htmlBuffer.writeln('  var element = document.getElementById(id);');
    htmlBuffer.writeln('  if (element) {');
    htmlBuffer.writeln(
        '    element.scrollIntoView({ behavior: "smooth", block: "start" });');
    htmlBuffer.writeln('    element.classList.add("highlight");');
    htmlBuffer.writeln(
        '    setTimeout(function() { element.classList.remove("highlight"); }, 2000);');
    htmlBuffer.writeln('  }');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('function applyFilters() { filterAndSortTable(); }');
    htmlBuffer.writeln('function copyText(text) {');
    htmlBuffer
        .writeln('  navigator.clipboard.writeText(text).then(function() {');
    htmlBuffer.writeln('    showCopyToast("Copied: " + text);');
    htmlBuffer.writeln('  }).catch(function(err) {');
    htmlBuffer.writeln('    console.error("Failed to copy text: " + err);');
    htmlBuffer.writeln('  });');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('function showCopyToast(message) {');
    htmlBuffer.writeln('  var toast = document.getElementById("copyToast");');
    htmlBuffer.writeln('  toast.innerText = message;');
    htmlBuffer.writeln('  toast.style.display = "block";');
    htmlBuffer.writeln(
        '  setTimeout(function() { toast.style.display = "none"; }, 2000);');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('function exportCSV() {');
    htmlBuffer.writeln('  var csv = "File,Line,Text\\n";');
    htmlBuffer.writeln('  for (var file in reportData) {');
    htmlBuffer.writeln('    reportData[file].forEach(function(entry) {');
    htmlBuffer.writeln('      var row = [file, entry.line, entry.text];');
    htmlBuffer.writeln('      csv += row.join(",") + "\\n";');
    htmlBuffer.writeln('    });');
    htmlBuffer.writeln('  }');
    htmlBuffer.writeln('  var blob = new Blob([csv], { type: "text/csv" });');
    htmlBuffer.writeln('  var url = URL.createObjectURL(blob);');
    htmlBuffer.writeln('  var a = document.createElement("a");');
    htmlBuffer.writeln('  a.href = url;');
    htmlBuffer.writeln('  a.download = "untranslated_report.csv";');
    htmlBuffer.writeln('  a.click();');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('function exportJSON() {');
    htmlBuffer.writeln('  var jsonStr = JSON.stringify(reportData, null, 2);');
    htmlBuffer.writeln(
        '  var blob = new Blob([jsonStr], { type: "application/json" });');
    htmlBuffer.writeln('  var url = URL.createObjectURL(blob);');
    htmlBuffer.writeln('  var a = document.createElement("a");');
    htmlBuffer.writeln('  a.href = url;');
    htmlBuffer.writeln('  a.download = "untranslated_report.json";');
    htmlBuffer.writeln('  a.click();');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('function exportExcel() {');
    htmlBuffer.writeln(
        '  var xml = `<?xml version="1.0"?>\n<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet">\n`;');
    htmlBuffer.writeln('  xml += `  <Worksheet ss:Name="Report">\n`;');
    htmlBuffer.writeln('  xml += `    <Table>\n`;');
    htmlBuffer.writeln(
        '  xml += `      <Row><Cell><Data ss:Type="String">File</Data></Cell><Cell><Data ss:Type="String">Line</Data></Cell><Cell><Data ss:Type="String">Text</Data></Cell></Row>\n`;');
    htmlBuffer.writeln('  for (var file in reportData) {');
    htmlBuffer.writeln('    reportData[file].forEach(function(entry) {');
    htmlBuffer.writeln(
        '      xml += `<Row><Cell><Data ss:Type="String">` + file + `</Data></Cell><Cell><Data ss:Type="Number">` + entry.line + `</Data></Cell><Cell><Data ss:Type="String">` + entry.text + `</Data></Cell></Row>\n`;');
    htmlBuffer.writeln('    });');
    htmlBuffer.writeln('  }');
    htmlBuffer.writeln('  xml += `    </Table>\n  </Worksheet>\n</Workbook>`;');
    htmlBuffer
        .writeln('  var blob = new Blob([xml], { type: "application/xml" });');
    htmlBuffer.writeln('  var url = URL.createObjectURL(blob);');
    htmlBuffer.writeln('  var a = document.createElement("a");');
    htmlBuffer.writeln('  a.href = url;');
    htmlBuffer.writeln('  a.download = "untranslated_report.xls";');
    htmlBuffer.writeln('  a.click();');
    htmlBuffer.writeln('}');

    htmlBuffer.writeln('function downloadPDF() {');
    htmlBuffer.writeln('  const { jsPDF } = window.jspdf;');
    htmlBuffer.writeln('  html2canvas(document.body).then(canvas => {');
    htmlBuffer.writeln('    const imgData = canvas.toDataURL("image/png");');
    htmlBuffer.writeln('    const doc = new jsPDF("p", "pt", "a4");');
    htmlBuffer.writeln('    const imgProps = doc.getImageProperties(imgData);');
    htmlBuffer
        .writeln('    const pdfWidth = doc.internal.pageSize.getWidth();');
    htmlBuffer.writeln(
        '    const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;');
    htmlBuffer.writeln(
        '    doc.addImage(imgData, "PNG", 0, 0, pdfWidth, pdfHeight);');
    htmlBuffer.writeln('    doc.save("untranslated_report.pdf");');
    htmlBuffer.writeln('  });');
    htmlBuffer.writeln('}');
    htmlBuffer.writeln('</script>');

    htmlBuffer.writeln('<script>');
    htmlBuffer.writeln('var reportData = ' + jsonEncode(occurrences) + ';');
    htmlBuffer.writeln('</script>');

    htmlBuffer.writeln('</head>');
    htmlBuffer.writeln('<body>');

    htmlBuffer.writeln('<h1>Untranslated UI Texts Report</h1>');

    htmlBuffer.writeln('<div id="copyToast"></div>');

    htmlBuffer.writeln(
        '<div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:10px;">');
    htmlBuffer.writeln(
        '<input type="text" id="searchInput" onkeyup="applyFilters()" placeholder="Search files and texts...">');
    htmlBuffer.writeln('<select id="sortSelect" onchange="applyFilters()">');
    htmlBuffer
        .writeln('<option value="default" selected>Default Order</option>');
    htmlBuffer.writeln('<option value="asc">Sort by Count Ascending</option>');
    htmlBuffer
        .writeln('<option value="desc">Sort by Count Descending</option>');
    htmlBuffer.writeln('</select>');

    final totalFiles = occurrences.keys.length;
    final totalUntranslated =
        occurrences.values.fold(0, (prev, list) => prev + list.length);
    htmlBuffer.writeln('<h2>Summary</h2>');
    htmlBuffer.writeln('<table id="summaryTable">');
    htmlBuffer.writeln('<thead>');
    htmlBuffer.writeln('<tr><th>File</th><th>Untranslated Count</th></tr>');
    htmlBuffer.writeln('</thead>');
    htmlBuffer.writeln('<tbody>');
    occurrences.forEach((file, entries) {
      final simplePath = simplifyPath(file);
      final detailId = simplePath.replaceAll(RegExp(r'[\\/ ]'), '_');
      htmlBuffer.writeln('<tr>');
      htmlBuffer.writeln(
          '<td><a class="clickable" href="javascript:void(0)" onclick="scrollToDetails(\'$detailId\')">$simplePath</a></td>');
      htmlBuffer.writeln('<td>${entries.length}</td>');
      htmlBuffer.writeln('</tr>');
    });
    htmlBuffer.writeln('</tbody>');
    htmlBuffer.writeln('</table>');

    htmlBuffer.writeln('<div class="summary-box">');
    htmlBuffer.writeln('<p><strong>Total Files:</strong> $totalFiles</p>');
    htmlBuffer.writeln(
        '<p><strong>Total Untranslated:</strong> $totalUntranslated</p>');
    htmlBuffer.writeln('</div>');

    htmlBuffer.writeln(
        '<div style="margin-top:30px; border-top:1px solid var(--border-color); padding-top:10px;">');
    htmlBuffer.writeln('<h2>Export Options</h2>');
    // htmlBuffer.writeln('<button onclick="downloadPDF()">Download PDF</button>');
    htmlBuffer.writeln('<button onclick="exportCSV()">Export CSV</button>');
    htmlBuffer.writeln('<button onclick="exportJSON()">Export JSON</button>');
    htmlBuffer.writeln('<button onclick="exportExcel()">Export Excel</button>');
    htmlBuffer.writeln('</div>');

    htmlBuffer.writeln('<h2>Details</h2>');
    occurrences.forEach((file, entries) {
      final simplePath = simplifyPath(file);
      final detailId = simplePath.replaceAll(RegExp(r'[\\/ ]'), '_');
      htmlBuffer.writeln(
          '<h3 id="$detailId" class="file-path detail-item">$simplePath</h3>');
      htmlBuffer.writeln('<ul>');
      for (final entry in entries) {
        htmlBuffer.writeln(
            '<li class="detail-item">[Line ${entry['line']}]: <span class="text-content">${entry['text']}</span><button class="copy-btn" onclick="copyText(\'${entry['text']}\')">📋</button></li>');
      }
      htmlBuffer.writeln('</ul>');
    });

    htmlBuffer
        .writeln('<p>Report generated by Non-Translated UI Texts Finder.</p>');

    await reportFile.writeAsString(htmlBuffer.toString());
    print('✅ HTML report created: $outputPath');
    await openHtmlReport(outputPath);
  }
}

Future<void> openHtmlReport(String filePath) async {
  try {
    final absolutePath = File(filePath).absolute.path;
    final normalizedPath = absolutePath.replaceAll('\\', '/');
    final finalPath = 'file:///$normalizedPath';
    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', 'chrome', finalPath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-a', 'Google Chrome', finalPath]);
    } else if (Platform.isLinux) {
      await Process.run('google-chrome', [finalPath]);
    } else {
      print('Automatic opening is not supported on this OS.');
    }
  } catch (e) {
    print('Error opening report in Chrome: $e');
  }
}
