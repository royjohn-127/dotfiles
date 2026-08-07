#region conda initialize (lazy)
function conda {
    Remove-Item Function:\conda -ErrorAction SilentlyContinue
    If (Test-Path "C:\Users\rj\miniconda3\Scripts\conda.exe") {
        (& "C:\Users\rj\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
    }
    conda @args
}
#endregion