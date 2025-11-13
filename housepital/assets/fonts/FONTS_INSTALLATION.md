# 📝 Fonts Installation Guide

## Required Fonts

This project uses two Google Fonts:
1. **Poppins** (Primary - for headings and buttons)
2. **Inter** (Secondary - for body text)

---

## Option 1: Quick Download Links

### Poppins
🔗 https://fonts.google.com/download?family=Poppins

Download these weights:
- Regular (400)
- Medium (500)
- SemiBold (600)
- Bold (700)

### Inter
🔗 https://fonts.google.com/download?family=Inter

Download these weights:
- Regular (400)
- Medium (500)
- SemiBold (600)
- Bold (700)

---

## Option 2: Direct Installation Steps

### Step 1: Visit Google Fonts

**For Poppins:**
1. Go to: https://fonts.google.com/specimen/Poppins
2. Click "Download family" button
3. Extract the ZIP file

**For Inter:**
1. Go to: https://fonts.google.com/specimen/Inter
2. Click "Download family" button
3. Extract the ZIP file

### Step 2: Find the Right Files

From the extracted folders, find and copy:

**Poppins:**
- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

**Inter:**
- `Inter-Regular.ttf`
- `Inter-Medium.ttf`
- `Inter-SemiBold.ttf`
- `Inter-Bold.ttf`

### Step 3: Create Fonts Folder

In your project, create the fonts folder:
```
housepital/
  assets/
    fonts/     <-- Create this folder
```

### Step 4: Copy Font Files

Place all 8 font files into `assets/fonts/`

### Step 5: Activate Fonts in pubspec.yaml

Open `pubspec.yaml` and **uncomment** the fonts section (lines ~83-103).

Change this:
```yaml
  # fonts:
  #   - family: Poppins
  #     fonts:
```

To this:
```yaml
  fonts:
    - family: Poppins
      fonts:
```

(Remove the `#` from all font lines)

### Step 6: Apply Changes

Run in terminal:
```bash
flutter pub get
flutter run
```

---

## Verification

After installation, the app will use:
- **Poppins** for headings and buttons (looks rounder, friendlier)
- **Inter** for body text (highly readable)

If fonts aren't working:
1. Check font files are in `assets/fonts/`
2. Check `pubspec.yaml` fonts section is uncommented
3. Run `flutter clean` then `flutter pub get`
4. Restart the app

---

## Note

The app will work even without custom fonts - it will use system defaults until you add them. Custom fonts will make it look more professional and match the branding perfectly!

---

**Font files NOT included in repo to keep it lightweight. Download them when ready to use custom typography! 🎨**
