# Custom Toast Usage Guide

## Overview
Custom Toast is a lightweight, beautiful notification system that replaces SnackBars and Dialogs throughout the app.

## Features
- ✅ **Success** - Green background with check icon
- ❌ **Error** - Red background with error icon  
- ⚠️ **Warning** - Orange background with warning icon
- ℹ️ **Info** - Blue background with info icon

## Usage

### Import
```dart
import '../../../../core/widgets/custom_toast.dart';
```

### Basic Examples

#### Success Message
```dart
CustomToast.success(context, 'Registration successful!');
```

#### Error Message
```dart
CustomToast.error(context, 'Invalid credentials');
```

#### Warning Message
```dart
CustomToast.warning(context, 'Please fill all fields');
```

#### Info Message
```dart
CustomToast.info(context, 'Check your email for verification');
```

### Advanced Usage

#### Custom Duration
```dart
CustomToast.show(
  context,
  message: 'Custom message',
  type: ToastType.success,
  duration: Duration(seconds: 5),
);
```

## Colors Used
- **Success**: `AppColors.success500` (#43A048 - Medical Green)
- **Error**: `AppColors.error500` (#F44336 - Alert Red)
- **Warning**: `AppColors.warning500` (#FB8A00 - Medical Orange)
- **Info**: `AppColors.info` (#3498BB - Trust Blue)

## Design
- Floating at bottom with 16px margin
- Rounded corners (12px radius)
- White icon in colored circle
- Auto-dismiss after 3 seconds (4 for errors)
- Elevation shadow for depth

## Migration from SnackBar
Replace old code:
```dart
// Old
_showSnackBar('Success!', isError: false);
_showSnackBar('Error!', isError: true);

// New
CustomToast.success(context, 'Success!');
CustomToast.error(context, 'Error!');
```

## Best Practices
1. Keep messages short and clear
2. Use appropriate type for the situation
3. Don't stack multiple toasts
4. Success messages can be brief, errors should be descriptive
