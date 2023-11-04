Param(
    $acrname = "kizacr",    
    $imageprefix = "mt3gateway"
)

$imagename = "$($imageprefix)-gateway"
az acr build --registry $acrname --image "$($imagename):latest" --file ./Gateway/MT3Gateway-Gateway/Dockerfile .
$imagename = "$($imageprefix)-web"
az acr build --registry $acrname --image "$($imagename):latest" --file ./Gateway/MT3Gateway-Web/Dockerfile ./Gateway/MT3Gateway-Web/.
for (($i = 1); $i -lt 6; $i++) {
    $step = $i
    $imagename = "mt3gateway-step$($step)"
    az acr build --registry $acrname --image "$($imagename):latest" --file "./Gateway/MT3Gateway-Step$($step)/Dockerfile" .
}
$imagename = "mt3gateway-step2-nodejs"
$folder = "./Gateway/MT3Gateway-Step2-NodeJS/"
Set-Location $folder
az acr build --registry $acrname --image "$($imagename):latest" --file "Dockerfile" .
Set-Location ../..