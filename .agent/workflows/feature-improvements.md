---
description: QuickServe Feature Improvements - Service Provider & Customer Enhancements
---

# QuickServe Feature Improvements Implementation Plan

## 🎯 Overview
This document outlines the step-by-step implementation of new features for both Service Providers and Customers.

---

## 📦 SERVICE PROVIDER FEATURES

### Feature 1: Category-based Service Display
**Description:** When adding a service, it should display in the appropriate category. When selecting that service, the image should be displayed.

**Files to modify:**
- `lib/screens/services/service_list_screen.dart` - Filter services by category
- `lib/screens/services/service_detail_screen.dart` - Display service image properly
- `lib/services/service_service.dart` - Add category filtering method

**Database changes:** None (already have category_id in services table)

**Status:** ⏳ Pending

---

### Feature 2: Image Crop Feature
**Description:** When adding an image to a service, provide a proper crop feature to match the display size (4:3 ratio).

**Required packages:**
```yaml
image_cropper: ^5.0.1
```

**Files to modify:**
- `lib/screens/services/add_service_screen.dart` (or create if doesn't exist)
- `pubspec.yaml` - Add image_cropper package

**Implementation:**
- Use image_cropper package
- Set aspect ratio to 4:3
- Allow user to crop before uploading

**Status:** ⏳ Pending

---

### Feature 3: Real-time Notifications for New Orders
**Description:** When an order comes in, service provider gets a real-time notification. Notification page should show updates in real-time with mark as read functionality.

**Required packages:**
```yaml
# Already have supabase_flutter which supports realtime
```

**Files to modify/create:**
- `lib/screens/notifications/notifications_screen.dart` - Add realtime listener
- `lib/services/notification_service.dart` - Create notification service
- `lib/models/notification_model.dart` - Create notification model

**Database changes:**
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  booking_id UUID REFERENCES bookings(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- 'new_order', 'order_confirmed', 'order_cancelled'
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Implementation:**
- Use Supabase Realtime subscriptions
- Listen to bookings table changes
- Auto-create notification when new booking created
- Mark as read functionality

**Status:** ⏳ Pending

---

### Feature 4: Order Management Page for Service Providers
**Description:** Service providers need a page showing incoming orders with options to:
- Confirm order
- Cancel order  
- Put order on hold
Customer should get notification when provider updates order status.

**Files to modify/create:**
- `lib/screens/provider/provider_orders_screen.dart` - Create new screen
- `lib/services/booking_service.dart` - Add status update methods
- `lib/models/booking_model.dart` - Ensure all statuses supported

**Database changes:**
Update bookings table to support 'on_hold' status:
```sql
ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_status_check;
ALTER TABLE bookings ADD CONSTRAINT bookings_status_check 
  CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'on_hold'));
```

**UI Requirements:**
- Tab view: Pending | Confirmed | On Hold | Completed | Cancelled
- Each order card shows: Customer name, service, date, amount
- Three action buttons: Confirm, Hold, Cancel
- Send notification to customer on status change

**Status:** ⏳ Pending

---

### Feature 5: Enhanced Profile Management
**Description:** Multiple profile enhancements needed.

#### 5a. Profile Editing
**Files to modify:**
- `lib/screens/profile/edit_profile_screen.dart` - Create new screen
- `lib/screens/profile/profile_screen.dart` - Add edit button
- `lib/services/auth_service.dart` - Already has update method

**Status:** ⏳ Pending

---

#### 5b. Order History in Profile
**Files to modify:**
- `lib/screens/profile/order_history_screen.dart` - Create new screen
- `lib/screens/profile/profile_screen.dart` - Add link to order history
- `lib/services/booking_service.dart` - Add method to get user's order history

**Status:** ⏳ Pending

---

#### 5c. Help & Support Page
**Files to create:**
- `lib/screens/settings/help_support_screen.dart`

**Contact Information:**
- Email: ravindukushan78@gmail.com
- Phone: 0704126703

**Features:**
- Display contact info
- Email button (opens email app)
- Call button (opens phone dialer)
- WhatsApp button (optional)
- FAQ section

**Status:** ⏳ Pending

---

#### 5d. Remove Payment Method for Service Providers
**Files to modify:**
- `lib/screens/settings/settings_screen.dart` - Show payment option only for customers
- Check user role before showing payment method option

**Status:** ⏳ Pending

---

## 🛒 CUSTOMER FEATURES
*(User didn't complete this section - to be added later)*

---

## 📊 Implementation Priority

**Phase 1 - Critical (Implement First):**
1. Feature 4: Order Management Page for Providers ⭐⭐⭐
2. Feature 3: Real-time Notifications ⭐⭐⭐
3. Feature 1: Category-based Service Display ⭐⭐

**Phase 2 - Important:**
4. Feature 5c: Help & Support Page ⭐⭐
5. Feature 5a: Profile Editing ⭐⭐
6. Feature 5b: Order History ⭐⭐

**Phase 3 - Enhancement:**
7. Feature 2: Image Crop Feature ⭐
8. Feature 5d: Hide Payment for Providers ⭐

---

## 🔧 Technical Requirements

**New Packages to Add:**
```yaml
dependencies:
  image_cropper: ^5.0.1
  url_launcher: ^6.2.2  # For email/phone links in Help & Support
```

**Database Migrations Needed:**
1. Create notifications table
2. Update bookings status constraint to include 'on_hold'
3. Add indexes for better performance

---

## 📝 Notes
- All features should maintain the existing premium UI/UX design
- Use existing theme colors and components
- Test each feature thoroughly before moving to next
- Ensure proper error handling
- Add loading states for all async operations

---

**Created:** 2026-02-04  
**Last Updated:** 2026-02-04
