# 🔧 QuickServe - Setup කරන්නේ කොහොමද (Sinhala Guide)

## ⚠️ දැනට තිබෙන ගැටලු සහ විසඳුම්

### 1️⃣ **Supabase Database Connection එක නැහැ**

**ගැටලුව:** 
- ඔබගේ `supabase_config.dart` file එකේ තියෙන credentials වැරදියි
- App එක Supabase database එකට connect වෙන්නේ නැහැ
- Customer signup කරද්දී database error එකක් ආවා

**විසඳුම:**

#### පියවර 1: Supabase Project එකක් හදාගන්න (නැත්නම් login වෙන්න)
1. [https://supabase.com](https://supabase.com) වෙබ් අඩවියට යන්න
2. "Start your project" button එක click කරන්න
3. ඔබගේ Google/GitHub account එකෙන් login වෙන්න
4. "New Project" click කරලා project එකක් create කරන්න
   - Project Name: `quickserve` (හෝ ඔබ කැමති නමක්)
   - Database Password: ශක්තිමත් password එකක් දාන්න (මතක තියාගන්න!)
   - Region: `Southeast Asia (Singapore)` select කරන්න (වේගයෙන් තමයි)
   - "Create new project" click කරන්න

#### පියවර 2: API Credentials ගන්න
1. ඔබගේ Supabase project එක open වුණාම වමේ sidebar එකේ **Settings** icon එක click කරන්න
2. **API** tab එක click කරන්න
3. දැන් මේ 2 values copy කරගන්න:
   - **Project URL** - මෙය `https://xxxxxx.supabase.co` වගේ එකක් වෙයි
   - **anon public** key - මෙය `eyJ` ගානේ ලොකු string එකක් වෙයි

#### පියවර 3: Config File එකේ දාන්න
1. Visual Studio Code එකේ මේ file එක open කරන්න:
   ```
   lib/config/supabase_config.dart
   ```

2. මේ විදියට update කරන්න:
   ```dart
   static const String supabaseUrl = 'YOUR_URL_HERE';  // ඔබේ Project URL එක paste කරන්න
   static const String supabaseAnonKey = 'YOUR_KEY_HERE';  // ඔබේ anon key එක paste කරන්න
   ```

#### පියවර 4: Database Tables Create කරන්න
1. Supabase dashboard එකේ වමේ sidebar එකේ **SQL Editor** icon එක click කරන්න
2. **"+ New Query"** button එක click කරන්න
3. මේ project එකේ තියෙන `supabase_setup.sql` file එක open කරලා **සම්පූර්ණ** content එක copy කරන්න
4. Supabase SQL Editor එකේ paste කරන්න
5. **"RUN"** button එක click කරන්න (හෝ Ctrl+Enter press කරන්න)
6. ✅ "Success. No rows returned" කියලා message එකක් ආවනම් හරියට setup වෙලා තියෙනවා!

---

## 2️⃣ **App එක Run කරන්නේ කොහොමද?**

### පූර්ව අවශ්‍යතා:
- ✅ Flutter SDK installed (version 3.9.2+)
- ✅ Android Studio හෝ VS Code installed
- ✅ Physical phone එකක් හෝ emulator එකක් තියෙනවා
- ✅ USB Debugging enabled (physical phone එක use කරනවා නම්)

### Run කරන විදිය:

#### Option 1: Visual Studio Code එකෙන්
1. ඔබගේ phone එක USB cable එකෙන් connect කරන්න (හෝ emulator එක start කරන්න)
2. VS Code එකේ status bar එකේ device එක select වෙලා තියෙනවද බලන්න
3. `F5` key එක press කරන්න හෝ "Run > Start Debugging" click කරන්න

#### Option 2: Terminal එකෙන් (පහසුම!)
```bash
cd "c:\Projects\Quick serve\quick_serve"
flutter pub get
flutter run
```

Build එක complete වෙන්න මිනිත්තු 2-3ක් විතර ගතවෙයි (first time එකට).

---

## 3️⃣ **Database එක open කරන්න ඕන ද App එක use කරද්දී?**

**උත්තරය: නෑ! 😊**

App එක run වුණාට පස්සේ:
- Supabase database එක **automatically** cloud එකේ run වෙනවා
- ඔබ Supabase dashboard එක close කරලා තිබ්බත් app එක වැඩ කරයි
- Database එක 24/7 online තියෙනවා Supabase servers එකේ
- ඔබට කරන්න ඕන වෙන්නේ credentials ඔබ විතරක් setup කරන එකයි (පියවර 1-4)

**ඔබට Supabase Dashboard එක open කරන්න ඕන වෙන්නේ:**
- Database tables බලන්න / edit කරන්න
- User accounts බලන්න
- Logs check කරන්න
- New data add කරන්න manually (testing වලට)

---

## 4️⃣ **Common Errors සහ විසඳුම්**

### Error: "Invalid API key"
**විසඳුම:** ඔබේ `supabase_config.dart` එකේ anon key එක correct විදියට copy කරලා තියෙනවද check කරන්න. Key එක `eyJ` ගානේ start විය යුතුයි.

### Error: "Table doesn't exist"
**විසඳුම:** `supabase_setup.sql` script එක ඔබ run කරලා නැහැ. පියවර 1.4 follow කරන්න.

### Error: "Lost connection to device"
**විසඳුම:** 
- Phone එකේ Developer Options > USB Debugging enable කරලා තියෙනවද බලන්න
- USB cable එක හොඳින් connect වෙලා තියෙනවද check කරන්න
- `flutter devices` command එක run කරලා device එක detect වෙනවද බලන්න

### Error: "Database error: Failed to create user profile"
**විසඳුම:** 
- Supabase SQL Editor එකේ `supabase_setup.sql` script එක run කරන්න
- `users` table එක create වෙලා තියෙනවද verify කරන්න (Supabase > Table Editor)

---

## 5️⃣ **Testing කරන්නේ කොහොමද?**

App එක open වුණාට පස්සේ:

1. **Signup Test:**
   - "Create Account" button එක click කරන්න
   - Full name, email, password fill කරන්න
   - "Customer" හෝ "Provider" select කරන්න
   - "Create Account" click කරන්න
   - ✅ Home screen එකට redirect වුණාම success!

2. **Login Test:**
   - Logout කරන්න (Settings > Logout)
   - ඔබ create කළ email/password use කරලා login වෙන්න
   - ✅ Login වුණාම success!

3. **Database Check:**
   - Supabase dashboard > Table Editor > `users` table
   - ඔබ create කළ user එක list එකේ පෙන්නන්න ඕන

---

## 📞 **තවත් උදව් ඕන නම්:**

- Supabase documentation: https://supabase.com/docs
- Flutter documentation: https://flutter.dev/docs
- Project README: `README.md` file එක check කරන්න

---

**සාර්ථකත්වය සහිත app build එකක් සැරසෙනසේක! 🚀**
