function Get-RandomAHV {
    
    Param(
        [Parameter(Mandatory = $false)]
        [int] $Count = 1,
        [Parameter(Mandatory = $false)]
        [switch] $Wrong = $false

    )

    1..$Count | % {

        # Start with the 756 Swiss ISO code and append 9 random digits
        $RndArray = @(7,5,6)+@(1..9 | % {Get-Random -Minimum 0 -Maximum 10}) 

        # Sum the 12 digits. Even indexed digits are multiplied by tree
        $Sum = ($RndArray | % -Begin {$i=0} -Process { if ( $i%2 -eq 0 ) { $RndArray[$i] } else { $RndArray[$i]*3 }; $i++; } | Measure-Object -Sum).sum
        
        if ($Wrong) { $Sum += 1 }

        # Apply a 10 modulo to get the checksum digit
        $Checksum = (((10 - $Sum) % 10) + 10) % 10

        # Join the digits in the valid format (756.XXXX.XXXX.XX) and append the checksum at the end
        $AHV = (($RndArray[0..2] -join "") + "." + ($RndArray[3..6] -join "") + "." + ($RndArray[7..10] -join "") + "." + ($RndArray[11..12] -join "")) + $Checksum

        $AHV
    }
}

function Check-AHV {

    [CmdletBinding()]

    param(
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$AHV
    )

    Begin {
        #Write-Host "Initialize stuff in Begin block"
    }
    Process 
    {
        foreach($Number in $AHV) {

            $Result = [PSCustomObject]@{
                AHV = $Number
                Valid = $false
                ErrorMessage = ""
            }
        
            #Write-Host $Number

            # Check if the format is valid (756.XXXX.XXXX.XX)
            if ($Number -match '^756.\d{4}.\d{4}.\d{2}$') {
        
                $DigitArray = ($Number -replace "[^0-9]" , '').ToCharArray() | % {[int]::Parse($_)}
        
                # Sum the 12 digits. Even indexed digits are multiplied by tree
                $Sum = ($DigitArray[0..11] | % -Begin {$i=0} -Process { if ( $i%2 -eq 0 ) { $DigitArray[$i] } else { $DigitArray[$i]*3 }; $i++; } | Measure-Object -Sum).sum
                
                # Apply a 10 modulo to get the checksum digit
                $Checksum = (((10 - $Sum) % 10) + 10) % 10
                
                #  CHeck if the last digit matches the calculated checksum
                if ($Checksum -eq $DigitArray[12]) {
                    $Result.Valid = $true
                }
                else {
                    $Result.ErrorMessage ="CRC mismatch"
                }
            }
            else {
                $Result.ErrorMessage ="Wrong format"
            }

            $Result
        }
    }
    End {
        #Write-Host "Final work in End block"
        
    }
}



#Get-RandomAHV -Count 3 
Get-RandomAHV -Count 5 | Select -First 2 | Check-AHV

for ($num = 1 ; $num -le 10 ; $num++){
    Check-AHV $(Get-RandomAHV)
}

Check-AHV "123.4564.4567.44"
Check-AHV "756.4564.4567.49"
Check-AHV "756.4564.4567.33"
Check-AHV "7564564456744"
Check-AHV "756.4c64.4567.44"
Check-AHV "756.0000.0000.01"
Check-AHV "756.000.0000.01"
Check-AHV "756.0000.000.01"
Check-AHV "756.0000.0000.1"
Check-AHV "756.0000.0000.0x"
Check-AHV "756.4564.4567.49", "123.4564.4567.44"

" 756.0000.000.01", "756.4564.4567.49 ", "756.4564.4567.49" | Check-AHV

$a = Get-RandomAHV
Write-Host -ForegroundColor Yellow $a
$a | Check-AHV
Check-AHV $a

Check-AHV $a,$a
$a,$a,$a | Check-AHV

Check-AHV $(Get-RandomAHV -Wrong)

