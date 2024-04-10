# Set the directory path where Adobe InDesign 2021-2022-2023-2024 fonts are located
$fontsDirectory = "C:\Path\To\Adobe InDesign 2021\Fonts"

# Function to recursively search for font files (OTF and TTF), sort the results, and remove duplicates
function Get-UniqueFonts {
    param (
        [string]$directory
    )

    # Initialize an empty array to store font names
    $fontNames = @()

    # Get all files in the current directory
    $files = Get-ChildItem -Path $directory -File

    foreach ($file in $files) {
        # Check if the file is a font file (OTF or TTF)
        if ($file.Extension -eq ".otf" -or $file.Extension -eq ".ttf") {
            $fontNames += $file.Name
        }
    }

    # Recursively search in subdirectories
    $subDirectories = Get-ChildItem -Path $directory -Directory
    foreach ($subDirectory in $subDirectories) {
        $fontNames += Get-UniqueFonts -directory $subDirectory.FullName
    }

    # Sort the font names alphabetically
    $fontNames = $fontNames | Sort-Object

    # Remove duplicate font names and keep only the first occurrence of each font
    $uniqueFonts = $fontNames | Get-Unique

    return $uniqueFonts
}

# Call the Get-UniqueFonts function with the provided fonts directory
$uniqueFonts = Get-UniqueFonts -directory $fontsDirectory

# Print the unique font names
$uniqueFonts | ForEach-Object { Write-Output $_ }