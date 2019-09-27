# Execute the file with the function(s) we want to test.
# Running each time ensures we have the most current copy in memory
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = "Mocks-PretendToDoSomething.ps1"
Set-Location $dir
. "$dir\$script"

# Original declaration without the tag
# Describe 'Unit Tests' {

Describe 'Unit Tests' -Tag 'Unit' {

  Context "Test script $script" {
    It "has a script $dir\$script file"{
      "$dir\$script" | Should -Exist
    }
    It "$script is valid PowerShell code"{
      $psFile = Get-Content -Path $dir\$script -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.count | Should -Be 0 
    }
    It "$script should have help block"{
      "$dir\$script" | Should -FileContentMatch "<#"
      "$dir\$script" | Should -FileContentMatch "#>"
    }
  }
    
  # Create a file name which doesn't exist
  $aFileThatDoesntExist = 'C:\blah\blah\blah\fooey.txt'

  # Test 1, make sure function returns false if file exists
  
  # Make test-path indicate the file already exists
  Mock Test-Path { return $true }
  
  # Calling with verbose can aid in testing
  $aTestResult = PretendToDoSomething $aFileThatDoesntExist -Verbose
  It 'Returns False if file already exists' {
    $aTestResult | Should -BeFalse
  }

  # Test 2, make sure function returns true if file doesn't exist

  # Make test-path indicate the file doesn't exist
  Mock Test-Path { return $false }
  Mock Out-File { }

  # Calling with verbose can aid in testing
  $aTestResult = PretendToDoSomething $aFileThatDoesntExist -Verbose
  It 'Returns True if file didnt exist and processed OK' {
    $aTestResult | Should -BeTrue
  }

}

# Original declaration without the tag
# Describe 'Integration Tests' {

Describe 'Integration Tests' -Tag 'Integration' {

  # Create a file name 
  # $myTestData = "$($TestDrive)\MyTestData.txt"

  # Create a file name (revised)
  $myTestDataFile = 'MyTestData.txt'
  $myTestData = "$($TestDrive)\$($myTestDataFile)"
  
  # Test using a file name that won't exist
  $aTestResult = PretendToDoSomething $myTestData -Verbose
  It 'Returns True if file didnt exist and processed OK' {
    $aTestResult | Should -BeTrue
  }

  # It "See if the output file $myTestData now exists" {
  #   $myTestData | Should -Exist
  # }

  # Exist test revised to show just the file name
  It "See if the output file $myTestDataFile now exists" {
    $myTestData | Should -Exist
  }

  # Added test to see if file exists
  $aTestResult = PretendToDoSomething $myTestData
  It "Returns False if $myTestDataFile existed" {
    $aTestResult | Should -BeFalse
  }

}

# Original declaration without the tag
# Describe 'Acceptance Tests' {

Describe 'Acceptance Tests' -Tag 'Acceptance' {

  # Setup a location and file name for testing
  $dir = "D:\OneDrive - Levi9 IT Services\PowerShellScripts\Pester"
  $testFile = 'AcceptanceTestData.txt'
  $testFilePath = "$dir\$testFile"

  # Ensure the file wasn't left over from a previous test
  if ($(Test-Path $testFilePath))
  {
    # Delete it, don't ask for confirmation
    Remove-Item $testFilePath -Force -ErrorAction SilentlyContinue
  }

  # Test using a file name that won't exist
  $aTestResult = PretendToDoSomething $testFilePath
  It 'Returns True if file didnt exist and processed OK' {
    $aTestResult | Should -BeTrue
  }

  # Test for the existence of the output file
  It "See if the output file $testFilePath now exists" {
    $testFilePath | Should -Exist
  }

  # Added test to see if file exists
  $aTestResult = PretendToDoSomething $testFilePath
  It "Returns False if $testFilePath existed" {
    $aTestResult | Should -BeFalse
  }

}