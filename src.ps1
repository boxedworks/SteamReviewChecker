
# 1. Set your SteamAppId(s) and game (nick)name
$s_appIds = @{
  954010  = "Definitely Sneaky But Not Sneaky"
  1550400 = "Rocket Cave Adventure"
};

# 2. Use default behavior or customize what happens when reviews go up
function Register-ReviewsChanged {
  param(
    [int] $appId, [string] $appName,
    [int] $reviewsLast, [int] $reviewsCurrent, [int] $reviewsDifference,
    [DateTime] $dateCheckedLast, [DateTime] $dateCheckedCurrent
  )

  #Write-Host "$appName has gotten $reviewsDifference new review(s) since $($dateCheckedLast.ToShortDateString())" -ForegroundColor Green;
  Invoke-WindowsNotification "SteamReviewChecker" "$appName has gotten $reviewsDifference new review(s) since $($dateCheckedLast.ToShortDateString())";
}

### PROGRAMMING SHIT
## Functions
# Get a game's review count
function Get-ReviewCount{
  param(
    [int] $appId
  )

  $dataWeb = (Invoke-WebRequest -Uri "https://store.steampowered.com/app/$appId").RawContent;
  $reviewsCount = 0;
  [int]::TryParse((
    $dataWeb -split "`n" | ? { $_ -ilike "*reviewCount*" } | % { ($_ -split """")[3]; }),
    [ref] $reviewsCount
  ) | Out-Null;

  return $reviewsCount;
}

# Save all games review counts to file
function Write-ReviewsToFile {
  param(
    [System.Collections.Hashtable] $reviewsBuffered
  )

  $dataWrite = "" + (Get-Date) + "`n";
  $s_appIds.Keys | % {
    $reviewsCount = if($null -eq $reviewsBuffered) { Get-ReviewCount $_; } else { $reviewsBuffered[$_]; };
    $dataWrite += "$_,$reviewsCount`n";
  }
  $dataWrite | Out-File -FilePath $s_dirData;
}

# Windows notification; taken from https://gist.github.com/balazsbotond/87ce12b77fbeb742b0663628efb32984
function Invoke-WindowsNotification {
  param(
    [string] $notificationTitle,
    [string] $notificationMessage
  )

  $ErrorActionPreference = "Stop";
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null;
  $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText01);
  $toastXml = [xml] $template.GetXml();
  $toastXml.GetElementsByTagName("text").AppendChild($toastXml.CreateTextNode($notificationMessage)) > $null;
  $xml = New-Object Windows.Data.Xml.Dom.XmlDocument;
  $xml.LoadXml($toastXml.OuterXml);
  $toast = [Windows.UI.Notifications.ToastNotification]::new($xml);
  $toast.Tag = "Test1";
  $toast.Group = "Test2";
  $toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(5);
  $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($notificationTitle);
  $notifier.Show($toast);
}

## Logic
# Get dirs
$s_dirScript = "$PSScriptRoot";
$s_dirData = "$s_dirScript\src.data";

# Check for first run, create data file
if(-not (Test-Path -Path $s_dirData)){
  Write-ReviewsToFile;

  #Write-Host "$($s_appIds.Count) apps have been set up" -ForegroundColor Green;
  Invoke-WindowsNotification "SteamReviewChecker" "$($s_appIds.Count) apps have been set up";
  return;
}

# Else, load previous data
$_reviewCounts = @{};
$_iter = 0;
$_dateLast = $null;
$_dateCurrent = Get-Date;
(Get-Content -Path $s_dirData) -split "`n" | % {
  if($_iter++ -eq 0){
    $_dateLast = [DateTime]::Parse($_);
    return;
  }

  $dataSplit = $_ -split ",";
  if($dataSplit.Count -ne 2){ return; }
  $appId = [int]::Parse($dataSplit[0]);
  $reviewsLast = [int]::Parse($dataSplit[1]);

  $reviewsCurrent = Get-ReviewCount $appId;

  # Number of reviews has gone up!
  if($reviewsLast -lt $reviewsCurrent){
    Register-ReviewsChanged $appId $s_appIds[$appId] $reviewsLast $reviewsCurrent ($reviewsCurrent - $reviewsLast) $_dateLast $_dateCurrent;
  }

  $_reviewCounts.Add($appId, $reviewsCurrent);
}

# Save review counts for next run
Write-ReviewsToFile $_reviewCounts;