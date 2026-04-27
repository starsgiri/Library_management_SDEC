# Overdue + Renewal Feature - Deployment Guide

## What was added
- **Field**: `Renewal_Count__c` on Book_Issue__c (tracks renewals per issue, max 2)
- **Apex methods**: 
  - `syncOverdueIssues()` - Auto-marks issued books with past due dates as Overdue
  - `renewBook(issueId)` - Extends due date by 7 days, increments renewal count
- **UI enhancements**: 
  - Renew Book action in Active Issues table
  - Renewal count column visible in Active & History tables
  - Client-side validation prevents renewing non-Issued books
- **Tests**: 4 new test cases covering sync, renewal success, max limit, and wrong status

## Pre-Deployment Checklist
- [ ] Salesforce CLI installed (`sf` or `sfdx`)
- [ ] Authenticated org connection
- [ ] Target Salesforce org is NOT production (use scratch org or dev org)
- [ ] Backed up any custom data

## Deployment Steps

### Step 1: Navigate to project
```powershell
cd c:\Users\manya\Library_management_SDEC\PE_4_project
```

### Step 2: Authenticate (if not already authenticated)
```powershell
sf org login web -a myOrg
```
Or for legacy CLI:
```powershell
sfdx force:auth:web:login -a myOrg
```

### Step 3: Deploy metadata
```powershell
sf project deploy start
```
Or for legacy:
```powershell
sfdx force:source:push
```

### Step 4: Assign permission set
```powershell
sf org assign permset -n Library_Admin -o myOrg
```
Or for legacy:
```powershell
sfdx force:user:permset:assign -n Library_Admin -u myOrg
```

### Step 5: Run tests (optional but recommended)
```powershell
sf apex run test -n LibraryControllerTest -r human
```
Or for legacy:
```powershell
sfdx force:apex:test:run -n LibraryControllerTest -r human -w 10
```

### Step 6: Open org
```powershell
sf org open -o myOrg
```

## Verification Checklist

After deployment, verify in Salesforce org:

1. Navigate to **Library Management** app → **Circulation** tab
2. Create a test issue (Issue Book action)
3. In Active Issues table, you should see:
   - [ ] New "Renewals" column showing 0
   - [ ] "Renew Book" action available in row
4. Click "Renew Book"
   - [ ] Should see success toast with new due date
   - [ ] Renewal count should increment to 1
   - [ ] Due date should be +7 days from original
5. Try renewing again
   - [ ] Should increment to 2
6. Try renewing third time
   - [ ] Should show error "Maximum renewal limit reached (2)"
7. Return the book
   - [ ] Should move to Issue History with Returned status
   - [ ] Can no longer renew returned books

## Rollback (if needed)
```powershell
sf project deploy start --metadata-dir ./manifest/package.xml --delete-metadata
```

## Troubleshooting

### CLI not found
If `sf` or `sfdx` command not found:
1. Install Salesforce CLI: https://developer.salesforce.com/tools/sfdxcli
2. Restart PowerShell
3. Verify: `sf --version`

### Authentication fails
- Check org credentials
- Try: `sf org list --all` to see authenticated orgs
- Re-authenticate if needed: `sf org logout -o myOrg` then login again

### Deployment fails
- Check for syntax errors: lint locally with `npm run lint` (requires npm install)
- Review error output for specific file/line issues
- Ensure Book_Issue__c object exists and is accessible

### Tests fail
- Ensure test data setup is compatible with your org data model
- Check for existing test data conflicts
- Run individual test: `sf apex run test -n LibraryControllerTest::testSyncOverdueIssues`

## Support
For questions about Salesforce CLI:
- https://developer.salesforce.com/tools/sfdxcli
- https://salesforce.stackexchange.com/

Enjoy your new renewal feature! 📚
