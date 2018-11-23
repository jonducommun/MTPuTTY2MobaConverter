function ParseNode {
    param(
        $configNode,
        [string]$outputText,
        [string]$actualPath,
        [ref][int]$bookmarkNr
    )

    $hostTemplate = "@@displayname@@=#109#0%@@hostname@@%22%%%-1%-1%%%22%%0%-1%0%%%-1%0%0%0%%1080%%0%0%1#MobaFont%10%0%0%0%15%248,248,242%39,40,34%255,128,0%0%-1%0%%xterm%-1%6%0,0,0%85,85,85%249,38,114%221,66,120%166,226,46%157,197,75%230,219,116%209,202,137%102,217,239%122,204,218%174,129,255%179,146,239%0,217,217%200,240,240%245,222,179%255,255,255%80%24%0%1%-1%<none>%%0#0#"
    
    if ($configNode.Type -eq 1) {
        #sono un commento?
        #il nodo è un host
        $outputText += $hostTemplate -replace "@@hostname@@", $configNode.ServerName `
                                 -replace "@@displayname@@", $configNode.DisplayName
        $outputText += "`r`n"
        
    }
    elseif ($configNode.Type -eq 0 ) {
        [string]$nodePath = $actualPath + "\" + $configNode.DisplayName
        $outputText += "`r`n[Bookmarks_" + $bookmarkNr.Value + "]`r`n"
        $outputText += "SubRep=$nodePath`r`n"
        $outputText += "ImgNum=41`r`n"

        $bookmarkNr.Value++

        foreach ($item in $configNode.Node) {
            $bookmarkTmp = $bookmarkNr.Value
            $outputText = ParseNode $item $outputText $nodePath ([ref]$bookmarkTmp)
            $bookmarkNr.Value = $bookmarkTmp
        }
    }

    return $outputText

}

[xml]$mtputtyConfFile =[xml](Get-Content .\mtputty.xml)
[System.Xml.XmlElement]$root = $mtputtyConfFile.get_DocumentElement()
[System.Xml.XmlElement]$node = $null

New-Variable -Name outputText
New-Variable -Name bookmarkNr -Value 1
$outputText += "[Bookmarks]`r`n"
$outputText += "SubRep=`r`n"
$outputText += "ImgNum=42`r`n"

foreach ($node in $root.Servers.Putty.Node) {

    $outputText = ParseNode $node $outputText $nodePath ([ref]$bookmarkNr)
	
}

$outputText