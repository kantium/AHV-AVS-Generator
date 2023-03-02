# AHV-AVS-Generator

This PowerShell module helps generating Swiss Social Security Number, known as "AHV" or "Numéro AVS"

## Usage

Get an AHV number:
`Get-RandomAHV`

Check an AHV number:
`Check-AHV "756.1234.1234.55"`

Get and checks numbers:
`Get-RandomAHV -Count 10 | Check-AHV`

Get a number with a wrong checksum:
`Get-RandomAHV -Wrong`

Check multiples AHV numbers:
```Check-AHV "756.XXXX.1234.55","756.1234.1234.55","756.1234.1234.56"
AHV               Valid ErrorMessage
---               ----- ------------
756.XXXX.1234.55  False Wrong format
756.1234.1234.55   True 
756.1234.1234.55  False CRC mismatch
```

