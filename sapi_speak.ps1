# SAPI 5 speech helper for soa_daemon.py on Windows. Reads one JSON command per
# line from stdin: {"t":"say","text":"...","interrupt":true} or {"t":"stop"}.
param([int]$Rate = 0, [string]$Voice = '', [string]$Language = '')

$sapi = New-Object -ComObject SAPI.SpVoice
$sapi.Rate = $Rate

if ($Voice -or $Language) {
    foreach ($token in $sapi.GetVoices()) {
        if ($Voice -and $token.GetDescription() -notlike "*$Voice*") { continue }
        if ($Language) {
            # The attribute is a list of hex LCIDs, e.g. "415" or "409;9".
            $match = $false
            foreach ($lcid in $token.GetAttribute('Language').Split(';')) {
                try {
                    $culture = [System.Globalization.CultureInfo]::GetCultureInfo([Convert]::ToInt32($lcid, 16))
                    if ($culture.TwoLetterISOLanguageName -eq $Language) { $match = $true }
                } catch {}
            }
            if (-not $match) { continue }
        }
        $sapi.Voice = $token
        break
    }
}

# SpeechVoiceSpeakFlags: 1 = async, 2 = purge before speak, 16 = text is not XML
while ($null -ne ($line = [Console]::In.ReadLine())) {
    try { $msg = $line | ConvertFrom-Json } catch { continue }
    if ($msg.t -eq 'say') {
        $flags = 17
        if ($msg.interrupt) { $flags = 19 }
        [void]$sapi.Speak([string]$msg.text, $flags)
    } elseif ($msg.t -eq 'stop') {
        [void]$sapi.Speak('', 19)
    }
}
