# ============================================================
#  Bulk-Create-Users.ps1
#  Creates Active Directory users across departmental OUs
#  Lab: corp.lab domain
#  Author: Troy Morris
# ============================================================

# --- Configuration ---
$Domain      = "corp.lab"
$DomainDN    = "DC=corp,DC=lab"
$Password    = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$UPNSuffix   = "@corp.lab"

# --- User list: Name, SamAccountName, Department/OU ---
# Add or remove entries here as needed.
$Users = @(
    @{ First="John";    Last="Smith";    Sam="jsmith";    OU="Finance" }
    @{ First="Brenda";  Last="Williams"; Sam="bwilliams"; OU="Finance" }
    @{ First="Carlos";  Last="Reyes";    Sam="creyes";    OU="Sales"   }
    @{ First="Dana";    Last="Lee";      Sam="dlee";      OU="Sales"   }
    @{ First="Troy";    Last="Morris";   Sam="tmorris";   OU="IT"      }
    @{ First="Aisha";   Last="Khan";     Sam="akhan";     OU="IT"      }
    @{ First="Maria";   Last="Gomez";    Sam="mgomez";    OU="HR"      }
    @{ First="Kevin";   Last="Brown";    Sam="kbrown";    OU="HR"      }
)

# --- Create each user ---
foreach ($u in $Users) {

    $DisplayName = "$($u.First) $($u.Last)"
    $UPN         = "$($u.Sam)$UPNSuffix"
    $TargetOU    = "OU=$($u.OU),$DomainDN"

    # Skip if the user already exists (makes the script safe to re-run)
    if (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue) {
        Write-Host "SKIP: $($u.Sam) already exists." -ForegroundColor Yellow
        continue
    }

    try {
        New-ADUser `
            -Name              $DisplayName `
            -GivenName         $u.First `
            -Surname           $u.Last `
            -SamAccountName    $u.Sam `
            -UserPrincipalName $UPN `
            -DisplayName       $DisplayName `
            -Department        $u.OU `
            -Path              $TargetOU `
            -AccountPassword   $Password `
            -Enabled           $true `
            -ChangePasswordAtLogon $false

        Write-Host "CREATED: $DisplayName ($($u.Sam)) in $($u.OU)" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR creating $($u.Sam): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nDone. Run 'Get-ADUser -Filter *' to verify." -ForegroundColor Cyan
