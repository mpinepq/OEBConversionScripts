$path = Read-Host -Prompt 'Input path to titles: ';
$CSVPath = Read-Host -Prompt 'Input path to csv: ';

$CSV = Import-Csv $CSVPath -Header "Title_ID","EAN" | sort "Title_ID" -Unique;

	Function CreateTOCFromXML ($CSVData, $FolderData, $EANData, $ThisPathData, $PSItemData)
	{
			$links = "<html><body><h1>Table of Contents</h1><p style='text-indent:0pt'>";
				
			if ($CSVData.Where({$PSItemData.Title_ID -eq $FolderData.Name }).Title_ID -eq $FolderData.Name) {
				ECHO Creating "$ThisPathData\$EANData.html";
				Set-Content $($ThisPathData + "\" + $EANData + ".html") "";
			}
			
			$xmldata = New-Object XML;
			$xmldata.Load("$ThisPathData\book.xml");
			$list = $xmldata.SelectNodes('Book/Page');
			ForEach ($item in $list) {
				 $links += "<a href='{0}.html'>{0}.html</a><br/>" -f $item.GetAttribute("id");
			}
			$links += "</p></body></html>";
			$links.trim() | Add-Content $($ThisPath + "\" + $EANData + ".html");
			ECHO "Adding content to $ThisPathData\$EANData.html";
	}
   Get-ChildItem $path | Where {$_.PSIsContainer} | 
    Foreach {
			$Folder = $null;
			$ThisPath = $null;
			$Folder = $_;
			$EAN = $CSV.Where({$PSItem.Title_ID -eq $Folder.Name}).EAN;
			$EAN = $EAN.Trim();
			$ThisPath = $path + "\" + $Folder.Name;
			echo "Looking into $ThisPath";
			$TOCFile = Get-ChildItem $ThisPath | Where-Object {($_.Name -eq "toc.xml")};
			$TOCFileContent = [IO.File]::ReadAllText($($ThisPath + "\" + $TOCFile.Name));
			$TOCFileContent = ($TOCFileContent -replace ".asp#",".html#");
			$TOCFileContent = ($TOCFileContent -replace "(<\?xml.*?>)","");
			$TOCFileContent = ($TOCFileContent -replace "(<toc>.*)","");
			$TOCFileContent = ($TOCFileContent -replace "(<\/toc>)","");
			Set-Content $($ThisPath + "\" + $EAN + ".html") -Value $TOCFileContent;
			$oem_files = Get-ChildItem $ThisPath | Where-Object {($_.Extension -eq ".asp")};
			ForEach ($file in $oem_files) {
				$filenew = $file.Name;
				$filenew = $filenew.replace("asp","html");
				Rename-Item $($ThisPath + "\" + $file.Name) $filenew;
				$NewFilePath = $ThisPath + "\" + $filenew;
				$content = [IO.File]::ReadAllText($NewFilePath);
				$content = ($content -replace '(?smi)<%.*?%>','');
				$content = ($content -replace "<!--[\s\S]*?-->","");
				$content = ($content -replace ".asp",".html");
				Set-Content $NewFilePath -Value $content;
			}
	}
