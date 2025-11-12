# Floating Reward Badge System Guide

## Overview

The **Floating Reward Badge** system provides delightful visual feedback when users earn rewards throughout the UniPerks app. This feature includes:

- ✨ Animated floating badges with sparkle effects
- 🎨 Customizable colors, sizes, and animations
- 🎯 Easy integration into any page
- 📱 Smooth 60 FPS animations
- 🎭 Multiple badge configurations for different reward types

---

## Quick Start

### 1. Import the Widget

```dart
import 'package:uniperks/widgets/floating_reward_badge.dart';
```

### 2. Wrap Your Page

Wrap your page widget with `FloatingRewardBadgeOverlay` and create a GlobalKey:

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey<FloatingRewardBadgeOverlayState> _overlayKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FloatingRewardBadgeOverlay(
      key: _overlayKey,
      child: Scaffold(
        // Your page content here
      ),
    );
  }
}
```

### 3. Show a Badge

Trigger a badge whenever you want to reward the user:

```dart
_overlayKey.currentState?.showRewardBadge(
  RewardBadgeConfig(
    icon: Icons.star,
    label: '+10',
    mainColor: Colors.amber,
    accentColor: Colors.orange,
  ),
);
```

---

## Current Implementations

### 1. Quiz System (`lib/pages/quiz_page.dart`)

**When**: User answers a question correctly
```dart
// Shows coins earned per question
_overlayKey.currentState?.showRewardBadge(
  RewardBadgeConfig(
    icon: Icons.star,
    label: '+$coinsEarned',
    mainColor: Colors.amber,
    accentColor: Colors.orange,
    size: RewardBadgeSize.medium,
    sparkleCount: 10,
  ),
);
```

**When**: User completes the entire quiz
```dart
// Shows total coins with celebration effect
_overlayKey.currentState?.showRewardBadge(
  RewardBadgeConfig(
    icon: Icons.emoji_events,
    label: 'Quiz Complete!\n+$score coins',
    mainColor: Colors.green,
    accentColor: Colors.lightGreen,
    size: RewardBadgeSize.large,
    sparkleCount: 15,
    displayDuration: const Duration(milliseconds: 2500),
  ),
);
```

### 2. Shopping Cart (`lib/pages/cart_page.dart`)

**When**: User completes a purchase (10% cashback)
```dart
// Shows cashback reward
_overlayKey.currentState?.showRewardBadge(
  RewardBadgeConfig(
    icon: Icons.card_giftcard,
    label: '🎉 Cashback!\n+$coinsEarned coins',
    mainColor: Colors.green,
    accentColor: Colors.lightGreen,
    size: RewardBadgeSize.large,
    sparkleCount: 15,
    displayDuration: const Duration(milliseconds: 2500),
  ),
);
```

---

## RewardBadgeConfig API

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `IconData` | **Required** | Main icon displayed in the badge center |
| `label` | `String` | **Required** | Text displayed below the icon (supports `\n`) |
| `mainColor` | `Color` | `Colors.amber` | Primary gradient color |
| `accentColor` | `Color` | `Colors.orange` | Secondary gradient color |
| `size` | `RewardBadgeSize` | `medium` | Badge size preset (small/medium/large) |
| `sparkleCount` | `int` | `8` | Number of sparkle particles (4-20 recommended) |
| `animationDuration` | `Duration` | `1500ms` | Total animation time |
| `displayDuration` | `Duration` | `2000ms` | How long badge stays on screen |

### Badge Sizes

```dart
enum RewardBadgeSize {
  small(60.0),   // Subtle rewards
  medium(80.0),  // Default, balanced
  large(100.0);  // Major achievements
}
```

---

## Customization Examples

### Achievement Unlocked
```dart
RewardBadgeConfig(
  icon: Icons.emoji_events,
  label: 'Achievement!',
  mainColor: Colors.purple,
  accentColor: Colors.purpleAccent,
  size: RewardBadgeSize.large,
  sparkleCount: 12,
)
```

### Streak Bonus
```dart
RewardBadgeConfig(
  icon: Icons.local_fire_department,
  label: '🔥 Streak!\n+5 Bonus',
  mainColor: Colors.orange,
  accentColor: Colors.deepOrange,
  size: RewardBadgeSize.medium,
  sparkleCount: 10,
)
```

### Level Up
```dart
RewardBadgeConfig(
  icon: Icons.trending_up,
  label: 'Level Up!\nLevel 5',
  mainColor: Colors.blue,
  accentColor: Colors.lightBlue,
  size: RewardBadgeSize.large,
  sparkleCount: 20,
  displayDuration: const Duration(milliseconds: 3000),
)
```

### Daily Login Reward
```dart
RewardBadgeConfig(
  icon: Icons.calendar_today,
  label: 'Daily Bonus\n+2 coins',
  mainColor: Colors.cyan,
  accentColor: Colors.teal,
  size: RewardBadgeSize.small,
  sparkleCount: 6,
)
```

### Special Offer
```dart
RewardBadgeConfig(
  icon: Icons.card_giftcard,
  label: '🎁 BONUS +50',
  mainColor: Colors.pink,
  accentColor: Colors.pinkAccent,
  size: RewardBadgeSize.large,
  sparkleCount: 20,
)
```

---

## Animation Behavior

### 1. Scale Animation (0-500ms)
- Starts at scale 0.0
- Pops in with bounce effect to 1.3x
- Settles at 1.0x scale
- Uses `Curves.easeOutBack` for spring effect

### 2. Float Animation (0-1500ms)
- Badge floats upward by 200 pixels
- Uses `Curves.easeOut` for natural deceleration

### 3. Fade Animation
- **0-300ms**: Fades in (0.0 → 1.0)
- **300-1200ms**: Fully visible
- **1200-1500ms**: Fades out (1.0 → 0.0)

### 4. Sparkle Animation
- Radiates outward from badge center
- Each sparkle follows a unique angle
- Randomized distance (40-80 pixels)
- Fades as it travels
- Continuous 1-second loop

### 5. Rotation Animation
- Subtle rotation (0 → 0.1 radians ≈ 5.7°)
- Adds life and dynamism to the badge

---

## Best Practices

### ✅ DO
- Use **medium size** for frequent rewards (correct answers, small purchases)
- Use **large size** for major achievements (quiz completion, level up)
- Keep `label` text short (1-2 lines max)
- Use emojis in labels for extra flair
- Match colors to the reward type (gold for coins, green for completion)
- Increase `sparkleCount` for more important rewards
- Test on different screen sizes

### ❌ DON'T
- Show multiple badges simultaneously (they'll overlap)
- Use badges for error messages (use SnackBar instead)
- Make `label` too long (will be hard to read)
- Set `displayDuration` too short (< 1500ms)
- Spam badges rapidly (wait for animation to complete)
- Use neon colors (too jarring)

---

## Performance Considerations

### Optimizations Built-In
- **Efficient Controllers**: Only 2 animation controllers per badge
- **Auto Disposal**: Badges self-remove after animation completes
- **Optimized Painting**: CustomPainter with minimal repaints
- **Sparkle Limits**: Recommended 4-20 sparkles for 60 FPS
- **Transform Layers**: Uses GPU-accelerated transforms

### Performance Tips
- Limit concurrent badges to **1 at a time**
- Keep `sparkleCount` ≤ 20
- Use `RewardBadgeSize.small` for frequent events
- Avoid showing badges during heavy UI operations

---

## Integration Checklist

When adding to a new page:

- [ ] Import `floating_reward_badge.dart`
- [ ] Add `GlobalKey<FloatingRewardBadgeOverlayState>` field
- [ ] Wrap main widget with `FloatingRewardBadgeOverlay`
- [ ] Pass the `_overlayKey` to the overlay
- [ ] Identify reward trigger points
- [ ] Choose appropriate badge config (colors, size, sparkles)
- [ ] Test badge visibility on different screen sizes
- [ ] Ensure badges don't overlap with critical UI
- [ ] Add null-safety check (`?.showRewardBadge`)

---

## Troubleshooting

### Badge Doesn't Appear
**Cause**: GlobalKey not properly connected
**Solution**: Ensure `key: _overlayKey` is set on `FloatingRewardBadgeOverlay`

```dart
// ❌ Wrong
FloatingRewardBadgeOverlay(
  child: Scaffold(...),
)

// ✅ Correct
FloatingRewardBadgeOverlay(
  key: _overlayKey,
  child: Scaffold(...),
)
```

### Badge Appears Behind Content
**Cause**: Overlay not wrapping the full page
**Solution**: Move `FloatingRewardBadgeOverlay` to wrap the entire Scaffold

```dart
// ❌ Wrong - inside Scaffold
Scaffold(
  body: FloatingRewardBadgeOverlay(...),
)

// ✅ Correct - wrapping Scaffold
FloatingRewardBadgeOverlay(
  child: Scaffold(...),
)
```

### Multiple Badges Overlap
**Cause**: Triggering badges too quickly
**Solution**: Add delay between badge triggers or track state

```dart
bool _isBadgeShowing = false;

void _showBadgeIfReady() {
  if (_isBadgeShowing) return;
  _isBadgeShowing = true;
  
  _overlayKey.currentState?.showRewardBadge(...);
  
  Future.delayed(Duration(milliseconds: 3500), () {
    _isBadgeShowing = false;
  });
}
```

### Badge Not Centered
**Cause**: This is normal - badge centers on screen
**Solution**: If you need custom positioning, modify `_FloatingRewardBadge` widget's `Positioned` properties

---

## Future Enhancements

Potential additions for the system:

1. **Custom Positioning**: Allow badges to appear at specific coordinates
2. **Sound Effects**: Play audio when badge appears
3. **Haptic Feedback**: Vibrate device on reward
4. **Badge Queue**: Automatically queue and display multiple badges in sequence
5. **Custom Animations**: Allow developers to provide custom animation curves
6. **Badge History**: Track and replay rewards in a "rewards feed"
7. **Multiplier Effects**: Show combo multipliers (2x, 3x coins)
8. **Particle Trails**: More advanced particle systems

---

## Code Architecture

### File Structure
```
lib/
├── widgets/
│   └── floating_reward_badge.dart  # Core badge system
├── pages/
│   ├── quiz_page.dart              # Quiz rewards
│   └── cart_page.dart              # Purchase rewards
```

### Class Hierarchy
```
FloatingRewardBadgeOverlay (StatefulWidget)
  └── FloatingRewardBadgeOverlayState
      └── Stack (contains badges)
          └── _FloatingRewardBadge (individual badge)
              └── _FloatingRewardBadgeState
                  ├── AnimationController (_mainController)
                  ├── AnimationController (_sparkleController)
                  └── CustomPainter (_AnimatedBorderPainter)
```

### Data Flow
```
User Action
    ↓
State Update (coins earned, quiz completed, etc.)
    ↓
_overlayKey.currentState?.showRewardBadge(config)
    ↓
FloatingRewardBadgeOverlayState adds badge to list
    ↓
Badge animates (1.5s animation + 2s display)
    ↓
Badge auto-removes after duration
```

---

## Testing

### Manual Testing Checklist
- [ ] Badge appears centered on screen
- [ ] Animation is smooth (no jank)
- [ ] Sparkles radiate outward
- [ ] Badge fades out smoothly
- [ ] Multiple badges don't crash app
- [ ] Works in portrait and landscape
- [ ] Label text is readable
- [ ] Icon is visible and correct
- [ ] Colors match expectation

### Edge Cases to Test
- Very long label text
- Very high sparkleCount (30+)
- Rapid badge triggering
- Device rotation during animation
- Low-end device performance
- Dark mode compatibility

---

## Related Files

- `lib/widgets/floating_reward_badge.dart` - Core implementation
- `lib/pages/quiz_page.dart` - Quiz reward integration
- `lib/pages/cart_page.dart` - Shopping reward integration
- `lib/services/user_coins_service.dart` - Coin balance management

---

## Credits & License

**Floating Reward Badge System**  
Created for UniPerks app  
Implements Material Design principles with custom animations  
Uses Flutter's animation framework and CustomPainter API

---

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review the code examples
3. Inspect existing implementations in `quiz_page.dart` and `cart_page.dart`
4. Ensure Flutter SDK is up to date

**Happy Rewarding! 🎉**
