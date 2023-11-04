Param(
    $acrname = "scubakiz",    
    $imageprefix = "mt3chained"
)
$imagename = "$($imageprefix)-web"
docker build -t "$($acrname)/$($imagename):latest" --file ./Chained/MT3Chained-Web/Dockerfile ./Chained/MT3Chained-Web/.
docker push "$($acrname)/$($imagename):latest"
for (($i = 1); $i -lt 6; $i++) {
    $step = $i
    $imagename = "mt3chained-step$($step)"
    docker build -t "$($acrname)/$($imagename):latest" --file "./Chained/MT3Chained-Step$($step)/Dockerfile" .
    docker push "$($acrname)/$($imagename):latest"
}
$imagename = "mt3chained-step2-nodejs"
$folder = "./Chained/MT3Chained-Step2-NodeJS/"
Set-Location $folder
docker build -t "$($acrname)/$($imagename):latest" --file "Dockerfile" .
docker push "$($acrname)/$($imagename):latest"
Set-Location ../..