
properties{
	$testMessage = 'Executed Test!'
	$compileMessage = 'Executed Compile!'
	$cleanMessage = 'Executed Clean!'

	$solutionDirectory = (Get-Item $solutionFile).DirectoryName
	$outputDirectory = "..\.build"
	$temporaryOutputDirectory = "$outputDirectory\temp"
	$buildConfiguration = "Release"
	$buildPlatform = "Any CPU"
}

FormatTaskName "`r`n`r`n------------------- Executing {0} Task --------------------"

task default -depends Test

task Init -description "Initialises the build by removing previous artifacts and creating output directories" -requiredVariables outputDirectory,temporaryOutputDirectory `
{
	Assert ("Debug", "Release" -contains $buildConfiguration) `
	
"Invalid build configuration '$buildConfiguration'. Valid id values are 'Debug' or 'Release'"

	Assert ("x86", "x64", "Any CPU" -contains $buildPlatform) `
	
	"Invalid build Platform '$buildPlatform'. Valid values are 'x86', 'x64' or 'Any CPU'"

	# Remove previous build results (require if we re-run the script to avoid any compilation errors)
	if(Test-Path $outputDirectory) `
	{
		Write-Host "Remove output directory located at $outputDirectory"
		Remove-Item $outputDirectory -Force -Recurse
	}

	Write-Host "Creating output directory located at ..\.build"
	New-Item $outputDirectory -ItemType Directory | Out-Null

	Write-Host "Creating temproray directory located at $temporaryOutputDirectory"
	New-Item $temporaryOutputDirectory -ItemType Directory | Out-Null
}

task Clean -description "Remove temporary files" `
{
	Write-Host $cleanMessage
}

task Compile `
    -depends Init `
	-description "Compile the Code" `
	-requiredVariables solutionFile, buildConfiguration, buildPlatform, temporaryOutputDirectory `
{
	Write-Host "Building solution $solutionFile"
	Exec{
		msbuild $solutionFile "/p:Configuration=$buildConfiguration;Platform=$buildPlatform;OutDir=$temporaryOutputDirectory"
	}
	
}

task Test -depends Compile, Clean -description "Run unit tests" `
{
	Write-Host $testMessage
}
