# ⚠️ Snowsight Editor Issue - Encryption Error

## Problem

When trying to edit the Streamlit app code in Snowsight, you get:
```
Could not read/write file. Error: error getting primary blob file: : No encryption material
```

## Root Cause

This error occurs because apps deployed via **SnowCLI** store files in a stage that doesn't have the encryption configuration required by Snowsight's built-in code editor. This is a known limitation of the SnowCLI deployment method.

---

## ✅ Recommended Solution: Local Development + SnowCLI

**This is the professional workflow for Streamlit development:**

### Workflow

```bash
# 1. Edit code locally (use your favorite IDE)
cd /Users/cgavazenni/unipolstreamlit
code streamlit_app.py  # or nano, vim, etc.

# 2. Make your changes and save

# 3. Quick redeploy
./quick_deploy.sh

# Or manually:
snow streamlit deploy --replace --database INSURANCE_DB --schema CUSTOMER_MGMT
```

### Benefits
- ✅ **Full IDE features**: Syntax highlighting, autocomplete, linting
- ✅ **Version control**: Track changes with git
- ✅ **No encryption errors**: Works perfectly with SnowCLI
- ✅ **Fast iteration**: Edit and deploy in seconds
- ✅ **Local testing**: Can test locally before deploying (with setup)
- ✅ **Better debugging**: See errors immediately in your editor

### Recommended Setup

```bash
# Initialize git repository (if not done)
cd /Users/cgavazenni/unipolstreamlit
git init
git add .
git commit -m "Initial commit - Insurance Customer Management"

# Create .gitignore if needed
echo "*.pyc" >> .gitignore
echo "__pycache__/" >> .gitignore
echo ".DS_Store" >> .gitignore
```

---

## 🔄 Alternative: Recreate in Snowsight UI

If you **must** use Snowsight's editor, you need to recreate the app through the UI:

### Steps

1. **Copy your code**:
   ```bash
   # Mac
   cat /Users/cgavazenni/unipolstreamlit/streamlit_app.py | pbcopy
   
   # Or just open the file and copy manually
   ```

2. **Drop the SnowCLI-deployed app**:
   ```bash
   snow streamlit drop insurance_customer_management --database INSURANCE_DB --schema CUSTOMER_MGMT
   ```

3. **Create new app in Snowsight**:
   - Go to https://app.snowflake.com
   - Click **Streamlit** in left sidebar
   - Click **"+ Streamlit App"**
   - Fill in:
     - Name: `insurance_customer_management`
     - Location: `INSURANCE_DB.CUSTOMER_MGMT`
     - Warehouse: `COMPUTE_WH`
   - Delete default code
   - Paste your copied code
   - Click **"Run"**

4. **Now you can edit in Snowsight** ✅

### Drawbacks
- ❌ No local version control
- ❌ Limited editor features
- ❌ Can't use SnowCLI commands anymore
- ❌ Code only exists in Snowflake
- ❌ Harder to share code with team

---

## 🎯 Recommended Workflow Comparison

### Local Development (SnowCLI) ⭐ RECOMMENDED
```
Edit locally → Save → Deploy → Test → Repeat
     ↓           ↓        ↓       ↓
   VS Code    Ctrl+S  SnowCLI  Browser
```

**Time per iteration**: ~10 seconds  
**Suitable for**: Professional development, team projects

### Snowsight Editor
```
Open Snowsight → Edit → Save → Rerun → Repeat
       ↓           ↓      ↓       ↓
    Browser    Browser Browser Browser
```

**Time per iteration**: ~20-30 seconds  
**Suitable for**: Quick tweaks, demos, learning

---

## 🚀 Quick Commands

### Deploy After Local Changes
```bash
cd /Users/cgavazenni/unipolstreamlit
./quick_deploy.sh
```

### View Current Code
```bash
cat streamlit_app.py
```

### Edit with nano
```bash
nano streamlit_app.py
# Edit, then Ctrl+X, Y, Enter to save
```

### Edit with VS Code
```bash
code streamlit_app.py
```

### Check Deployment Status
```bash
snow streamlit list --database INSURANCE_DB --schema CUSTOMER_MGMT
```

### Get App URL
```bash
snow streamlit get-url insurance_customer_management --database INSURANCE_DB --schema CUSTOMER_MGMT
```

---

## 📚 What You Have Now

Your project is set up for professional local development:

```
unipolstreamlit/
├── streamlit_app.py          ← Edit this locally
├── setup_database.sql         ← Database schema
├── requirements.txt           ← Dependencies
├── snowflake.yml             ← SnowCLI config
├── deploy.sh                 ← Full deployment script
├── quick_deploy.sh           ← Quick redeploy script
└── [documentation files]
```

---

## 💡 Best Practice Recommendation

**Use Local Development with SnowCLI** because:

1. **Professional**: This is how real projects are developed
2. **Faster**: Edit and deploy in seconds
3. **Safer**: Version control protects your work
4. **Collaborative**: Easy to share with team via git
5. **No Issues**: No encryption errors or editor limitations

### Quick Start

```bash
# Edit
nano /Users/cgavazenni/unipolstreamlit/streamlit_app.py

# Deploy
cd /Users/cgavazenni/unipolstreamlit
./quick_deploy.sh

# Done! 🎉
```

---

## 🆘 If You Still Want Snowsight Editor

Follow the "Alternative: Recreate in Snowsight UI" steps above.

**Note**: You'll lose the ability to use SnowCLI commands and won't have local version control.

---

## Summary

| Method | Edit Location | Pros | Cons |
|--------|--------------|------|------|
| **SnowCLI** | Local IDE | Fast, git, full IDE, no errors | Need terminal |
| **Snowsight** | Browser | All-in-one, visual | Slow, no git, encryption issues with SnowCLI apps |

**Recommendation**: Use **SnowCLI with local editing** for best experience! 🚀

