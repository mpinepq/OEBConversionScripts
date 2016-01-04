$DBServer = Read-Host -Prompt 'DB server  name: ';
$OEBPath = Read-Host -Prompt 'OEB path: ';
$CSVPath = Read-Host -Prompt 'CSV path: ';
$DestPath = Read-Host -Prompt 'Destination path: ';
$SQLPath = Read-Host -Prompt 'SQL path: ';
try
{
	sqlcmd -S $DBServer -E -b -m -1 -i $SQLPath -h-1 -s "," -o $CSVPath;
}
catch
{
	$ErrorMessage = $_.Exception.Message;
	$FailedItem = $_.Exception.ItemName;
	echo "Error on: $FailedItem; Message: $ErrorMessage";
	Break;
}


$CSV = Import-Csv $CSVPath -Header "Title_ID","EAN" | sort "Title_ID" -Unique;
New-Item -ItemType directory -Path "$DestPath";
   Get-ChildItem $OEBPath | Where {$_.PSIsContainer} | 
			Where { $_.ToString() -ne "thumbs" } |
    Foreach {
			echo "$_";
			$parent = $_;
			Get-ChildItem "$($OEBPath + $parent)" | Where {$_.PSIsContainer} | 
				Foreach {
					$Folder = $_;
					if ($CSV.Where({$PSItem.Title_ID -eq $Folder }).Title_ID -eq $Folder) {
							$Match++;
							if (!(Test-Path 	$($DestPath + '\' + $Folder.Name))) {
									echo "copying too $($DestPath  + '\' + $Folder.Name)";
									echo $Folder.FullName;
									Copy-Item $Folder.FullName  $DestPath -Recurse -ErrorAction SilentlyContinue;
								}
								else
								{
									echo "skipped $($DestPath  + '\' + $Folder.Name)";
								}
						}
						else
						{
							$NoMatch++;
						}
				}
			 }

echo $DestPath;
echo "Match: $Match";
echo "No Match: $NoMatch";