
# from : https://www.itprotoday.com/powershell/create-custom-are-you-sure-prompt-powershell
function AbortOrRetry(){
    $title = 'What should I do?'
    $prompt = 'Should I [A]bort or [R]etry?'
    $abort = New-Object System.Management.Automation.Host.ChoiceDescription '&Abort','Aborts the operation'
    $retry = New-Object System.Management.Automation.Host.ChoiceDescription '&Retry','Retries the operation'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($abort,$retry)
     
    $choice = $host.ui.PromptForChoice($title,$prompt,$options,0)
    return $choice
}

function AbortOrContinue(){
    $title = 'What should I do?'
    $prompt = 'Should I [A]bort or [C]ontinue?'
    $abort = New-Object System.Management.Automation.Host.ChoiceDescription '&Abort','Aborts the operation'
    $continue = New-Object System.Management.Automation.Host.ChoiceDescription '&Continue','Continues the operation'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($abort,$continue)
     
    $choice = $host.ui.PromptForChoice($title,$prompt,$options,0)
    return $choice
}


function KeepThisAccount(){
    $title = 'What should I do?'
    $prompt = 'Should I [K]eep this account or [C]hange the connected account?'
    $change = New-Object System.Management.Automation.Host.ChoiceDescription '&Change','Disconnect this account and change it'
    $keep = New-Object System.Management.Automation.Host.ChoiceDescription '&Keep','Keep this account connected'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($change,$keep)
     
    $choice = $host.ui.PromptForChoice($title,$prompt,$options,1)
    return $choice
}
