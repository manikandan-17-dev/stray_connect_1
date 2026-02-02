# 🔍 Troubleshooting: Reports Not Showing

## ✅ Fixes Applied

### 1. **Removed Firestore Index Requirement**
- **Before**: Query used `.orderBy('createdAt')` which requires a Firestore index
- **After**: Removed `.orderBy()` and sort manually in code
- **Why**: Avoids "index required" errors

### 2. **Added Comprehensive Debugging**
Every step now logs to console:
```
📊 My Reports - Connection State: waiting
⏳ Loading reports...
📋 Found 3 reports for user abc123
📄 Report 1: dog - injured
📄 Report 2: cat - sick
📄 Report 3: bird - abandoned
```

### 3. **Added Debug/Refresh Button**
- Tap the **refresh icon** in the app bar
- Manually checks Firestore
- Logs detailed information about each report

## 🧪 How to Diagnose

### Step 1: Open My Reports Screen
Navigate to the My Reports tab

### Step 2: Check Console Logs
Look for these messages:

**If loading:**
```
📊 My Reports - Connection State: waiting
⏳ Loading reports...
```

**If successful:**
```
📋 Found 3 reports for user abc123
📄 Report 1: dog - injured
```

**If empty:**
```
📭 No reports found
```

**If error:**
```
❌ Error loading reports: [error message]
```

### Step 3: Use Debug Button
1. Tap the **refresh icon** (top right)
2. Check console for:
```
🔍 Manual Firestore Check...
Current User: abc123
Email: user@example.com
✅ Query successful!
📊 Total reports found: 3
---
Report ID: xyz789
Animal: dog
Condition: injured
Status: pending
Has Image: true
Created: 2024-02-02T...
```

## 🔍 Common Issues & Solutions

### Issue 1: "No reports found"
**Possible Causes:**
- No reports submitted yet
- Reports submitted with different userId
- Firestore rules blocking read access

**Solutions:**
1. ✅ Submit a new report first
2. ✅ Check Firestore Console → reports collection
3. ✅ Verify userId matches in Firestore documents
4. ✅ Check Firestore security rules are published

### Issue 2: "Permission denied"
**Cause:** Firestore security rules not updated

**Solution:**
1. Go to Firebase Console
2. Firestore Database → Rules
3. Paste the updated rules from `firestore.rules`
4. Click "Publish"

### Issue 3: "Index required"
**Cause:** Query uses `.orderBy()` with `.where()`

**Solution:** ✅ Already fixed! Removed `.orderBy()` from query

### Issue 4: Reports exist but not showing
**Possible Causes:**
- userId field mismatch
- Wrong collection name
- Data format issues

**Solutions:**
1. Check Firestore Console:
   - Collection name: `reports` (not `animal_reports`)
   - Field name: `userId` (not `reportedBy`)
2. Use debug button to verify query
3. Check console logs for errors

## 📊 Verify in Firestore Console

### Step 1: Open Firebase Console
https://console.firebase.google.com

### Step 2: Navigate to Firestore
Firestore Database → Data tab

### Step 3: Check Reports Collection
Look for `reports` collection (not `animal_reports`)

### Step 4: Verify Document Structure
Each document should have:
```javascript
{
  userId: "abc123",              // Must match current user
  userEmail: "user@example.com",
  animalType: "dog",
  condition: "injured",
  emergencyLevel: 2.0,
  description: "...",
  imageBase64: "iVBORw0KG...",   // Base64 string
  location: GeoPoint(...),
  status: "pending",
  timestamp: Timestamp,
  createdAt: "2024-02-02T..."
}
```

### Step 5: Check userId
- Copy the `userId` from a report document
- Compare with current user's UID (shown in console logs)
- They MUST match exactly

## 🔧 Manual Test Steps

### 1. Submit a Test Report
1. Go to Report screen
2. Capture photo
3. Select animal type: Dog
4. Select condition: Injured
5. Click "SUBMIT REPORT"
6. Watch console for:
```
✅ Report saved successfully!
```

### 2. Check Firestore Console
1. Refresh Firestore Data tab
2. See new document in `reports` collection
3. Verify `userId` field exists and matches your user

### 3. Open My Reports
1. Navigate to My Reports tab
2. Should see loading spinner
3. Then see your report card with image

### 4. Use Debug Button
1. Tap refresh icon
2. Check console logs
3. Should show report details

## 📝 Console Log Examples

### Successful Load:
```
📊 My Reports - Connection State: waiting
⏳ Loading reports...
📊 My Reports - Connection State: active
📋 Found 1 reports for user abc123
📄 Report 1: dog - injured
```

### Empty State:
```
📊 My Reports - Connection State: active
📋 Found 0 reports for user abc123
📭 No reports found
```

### Error State:
```
📊 My Reports - Connection State: active
❌ Error loading reports: [permission-denied] Missing or insufficient permissions
```

### Debug Button Output:
```
🔍 Manual Firestore Check...
Current User: abc123
Email: user@example.com
✅ Query successful!
📊 Total reports found: 1
---
Report ID: xyz789
Animal: dog
Condition: injured
Status: pending
Has Image: true
Created: 2024-02-02T19:30:00.000Z
```

## ✅ Checklist

Before reporting an issue, verify:

- [ ] Firestore rules are published
- [ ] At least one report has been submitted
- [ ] Report was submitted by current logged-in user
- [ ] Collection name is `reports` (not `animal_reports`)
- [ ] Field name is `userId` (not `reportedBy`)
- [ ] Console shows no errors
- [ ] Debug button shows reports exist
- [ ] User is logged in
- [ ] Internet connection is active

## 🚀 Next Steps

1. **Run the app**
2. **Navigate to My Reports**
3. **Check console logs**
4. **Tap refresh/debug button**
5. **Report what you see in console**

The detailed logs will tell us exactly what's happening!

---

**All debugging tools are now in place. Run the app and check the console!** 🔍
