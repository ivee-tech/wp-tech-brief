Param(
    $acrname = "kizacr",    
    $imageprefix = "mt3chained"
)
$acrname = $acrname + ".azurecr.io";
$imagename = "$($imageprefix)-web"
docker build -t "$($acrname)/$($imagename):latest" --file ./Chained/MT3Chained-Web/Dockerfile ./Chained/MT3Chained-Web/.
docker push "$($acrname)/$($imagename):latest"
