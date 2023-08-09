add-content -path "C:\Users\Abdelrahman Gaber\.ssh\config" -value @'
HOST ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
'@