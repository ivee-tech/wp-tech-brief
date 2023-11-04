Param(
    $acrname = "kizacr",    
    $imageprefix = "mt3gateway"
)
$acrname = $acrname + ".azurecr.io";
$imagename = "$($imageprefix)-gateway"
docker build -t "$($acrname)/$($imagename):latest" --file ./Gateway/MT3Gateway-Gateway/Dockerfile .
docker push "$($acrname)/$($imagename):latest"
$imagename = "$($imageprefix)-web"
docker build -t "$($acrname)/$($imagename):latest" --file ./Gateway/MT3Gateway-Web/Dockerfile ./Gateway/MT3Gateway-Web/.
docker push "$($acrname)/$($imagename):latest"
