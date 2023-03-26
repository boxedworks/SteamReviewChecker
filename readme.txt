===================
=== QUICK SETUP ===
===================

Follow these steps:

1. Place src.ps1 in a folder somewhere
2. Open src.ps1 in a text editor
3. Edit the top of the file to put your Steam games' app Ids and names and save it
4. Open Windows Task Scheduler (customizing this task is up to you but here is how I did it)
5. Right-click 'Task Scheduler Library' -> Click 'Create Task'
6. Name the task 'SteamReviewChecker'
7. Check 'Run with highest privileges'
8. Click the 'Triggers' tab
9. Click 'New...'
10. Click 'Begin the task:' dropdown -> select 'At log on'
11. Click 'OK' at the bottom
12. Click the 'Actions' tab
13. Click 'New...'
14. In the 'Program/script:' text box, enter 'PowerShell.exe'
15. In the 'Add arguments (optional):' text box, enter '-WindowStyle Hidden -File PATH_TO_SRC.PS1' replacing PATH_TO_SRC.PS1 with your file path to src.ps1
16. Click 'OK'
17. Click 'OK'
18. Right-click on the new task in the task list -> click 'Run'

If successful, you will see a Windows notification pop up in the bottom-right of your primary screen. This notification lets you know that setup is successful. If there is no notification, there are either some errors with the setup above or with your Windows PowerShell. Try opening the script in PowerShell ISE and running it manually yourself to see the erros. You probably need to change you PowerShell script execution policy: https://www.sqlshack.com/choosing-and-setting-a-powershell-execution-policy/ (you have to set it to Unrestricted).

-For help contact u/SimplyGuy on Reddit;

===================
=== AFTER SETUP ===
===================

After successful setup, if you followed my Task Scheduler setup, SteamReviewChecker will run at every logon and check if your Steam apps' reviews have increased. If they do increase, a Windows notification will pop up and tell you how many reviews you have received per game. If you want to change how often/when the task runs, you can edit the task itself in Windows Task Scheduler. If you want to change what happens when SteamReviewChecker detects a change in review number, you can edit the 'Register-ReviewsChanged' function in src.ps1. The rest is up to you.
