
$workDir = "c:\Users\slash\Desktop\work\hassaniya work"
$translationFile = Join-Path $workDir "ar_to_hs_translation.jsonl"
$supportFile = Join-Path $workDir "hassaniya_customer_support.jsonl"

# Force UTF-8 output for console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Clear existing output files
if (Test-Path $translationFile) { Remove-Item $translationFile }
if (Test-Path $supportFile) { Remove-Item $supportFile }

# Helper to escape JSON string
function Escape-JsonString ($str) {
    if ([string]::IsNullOrEmpty($str)) { return "" }
    return $str -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", '' -replace "`t", '\t'
}

$files = Get-ChildItem -Path $workDir -Filter "part*.txt"

foreach ($file in $files) {
    Write-Host "Processing $($file.Name)..."
    # Read as UTF8
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    # Split conversations using regex
    # Matches: em dash (—), en dash (–), hyphens (---), underscores (___)
    # \u2014 is em dash, \u2013 is en dash
    $conversations = [regex]::Split($content, "(?:[\u2014\u2013]{3,}|-{3,}|_{3,})")

    foreach ($conv in $conversations) {
        if ([string]::IsNullOrWhiteSpace($conv)) { continue }

        $lines = $conv -split "\r?\n"
        $lastArLine = $null
        $supportConvLines = @()

        foreach ($line in $lines) {
            $trimmedLine = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($trimmedLine)) { continue }

            # AR Line: Expect format "AR: ..." or "1: AR: ..."
            if ($trimmedLine -match '(?i)^(\d*[:\s]*)?AR:\s*(.*)') {
                $lastArLine = $matches[2].Trim()
                continue
            }

            # HS Line: Expect format "HS: ..." or "1: HS: ..."
            if ($trimmedLine -match '(?i)^(\d*[:\s]*)?HS:\s*(.*)') {
                $hsText = $matches[2].Trim()

                # Translation Dataset
                if ($lastArLine) {
                    $arEscaped = Escape-JsonString $lastArLine
                    $hsEscaped = Escape-JsonString $hsText
                    $json = "{""messages"": [{""role"": ""user"", ""content"": ""Translate the following to Hassaniya: $arEscaped""}, {""role"": ""model"", ""content"": ""$hsEscaped""}]}"
                    Add-Content -Path $translationFile -Value $json -Encoding UTF8
                    $lastArLine = $null
                }

                # Support Dataset Collection
                $supportConvLines += $hsText
            }
        }

        # Support Dataset Generation
        if ($supportConvLines.Count -ge 2) {
            # Construct the conversation array manually to avoid complex JSON objects in PS
            $jsonParts = @()
            $jsonParts += "{""role"": ""system"", ""content"": ""You are a helpful customer support assistant who speaks Hassaniya.""}"
            
            for ($i = 0; $i -lt $supportConvLines.Count; $i++) {
                $role = if ($i % 2 -eq 0) { "user" } else { "model" }
                $contentEscaped = Escape-JsonString $supportConvLines[$i]
                $jsonParts += "{""role"": ""$role"", ""content"": ""$contentEscaped""}"
            }

            $middlePart = $jsonParts -join ", "
            $finalJson = "{""messages"": [$middlePart]}"
            Add-Content -Path $supportFile -Value $finalJson -Encoding UTF8
        }
    }
}

Write-Host "Done. Files saved to:"
Write-Host $translationFile
Write-Host $supportFile
