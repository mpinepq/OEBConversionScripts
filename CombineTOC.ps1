$TOCPath = Read-Host -Prompt 'Input path to TOC.XML: ';
$BOOKPath = Read-Host -Prompt 'Input path to BOOK.XML: ';
$DestinationPath = Read-Host -Prompt 'Input Destination Path: ';

$TOCFileContent += "<html><head><link rel='stylesheet' type='text/css' href='479.css' /></head><body>"
$TOCFileContent += [IO.File]::ReadAllText($($TOCPath));
$TOCFileContent = ($TOCFileContent -replace ".asp",".html");
$TOCFileContent = ($TOCFileContent -replace "(<\?xml.*?>)","");
$TOCFileContent = ($TOCFileContent -replace "(<toc>.*)","");
$TOCFileContent = ($TOCFileContent -replace "(<\/toc>)","");
Set-Content $($DestinationPath + "\EAN.html") -Value $TOCFileContent;

$BOOKXML = New-Object XML;
$BOOKXML.Load($BOOKPath);
$PageLinks = "<pages>";
$PageList = $BOOKXML.SelectNodes('Book/Page');
ForEach ($page in $PageList) {
	 $PageLinks += "<page><a href='{0}.html'>{0}.html</a></page></br>" -f $page.GetAttribute("id");
}
$PageLinks += "</pages></body></html>";
Add-Content -Path ($DestinationPath + "\EAN.html") -Value $PageLinks;