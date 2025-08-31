import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/app_info_widget.dart';
import './widgets/connected_accounts_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/subscription_card_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({Key? key}) : super(key: key);

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  bool isDarkTheme = true;
  bool isThaiLanguage = true;
  bool isPushNotificationsEnabled = true;
  bool isTwoFactorEnabled = false;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "สมชาย วิชาการ",
    "email": "somchai.w@email.com",
    "avatar":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    "subscription": {
      "plan": "Pro Plan",
      "status": "แพ็กเกจโปร",
      "billing_cycle": "รายเดือน",
      "amount": "฿999",
      "next_billing": "15 ก.ย. 2024"
    },
    "app_version": "1.2.3",
    "build_number": "2024083114"
  };

  final List<ConnectedAccount> connectedAccounts = [
    ConnectedAccount(
      platformName: "Facebook",
      accountName: "@somchai.business",
      iconName: "facebook",
      platformColor: Color(0xFF1877F2),
      isActive: true,
    ),
    ConnectedAccount(
      platformName: "Instagram",
      accountName: "@somchai_official",
      iconName: "camera_alt",
      platformColor: Color(0xFFE4405F),
      isActive: true,
    ),
    ConnectedAccount(
      platformName: "Twitter",
      accountName: "@somchai_tweets",
      iconName: "alternate_email",
      platformColor: Color(0xFF1DA1F2),
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'การตั้งค่า',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              userName: userData["name"] as String,
              userEmail: userData["email"] as String,
              subscriptionStatus: (userData["subscription"]
                  as Map<String, dynamic>)["status"] as String,
              avatarUrl: userData["avatar"] as String,
              onEditPressed: _handleEditProfile,
              onAvatarTapped: _handleAvatarUpdate,
            ),

            SizedBox(height: 2.h),

            // Subscription Card
            SubscriptionCardWidget(
              currentPlan: (userData["subscription"]
                  as Map<String, dynamic>)["plan"] as String,
              billingCycle: (userData["subscription"]
                  as Map<String, dynamic>)["billing_cycle"] as String,
              nextBillingDate: (userData["subscription"]
                  as Map<String, dynamic>)["next_billing"] as String,
              amount: (userData["subscription"]
                  as Map<String, dynamic>)["amount"] as String,
              onManagePressed: _handleManageSubscription,
            ),

            SizedBox(height: 1.h),

            // Account Settings Section
            SettingsSectionWidget(
              title: 'บัญชี',
              items: [
                SettingsItem(
                  title: 'แก้ไขโปรไฟล์',
                  subtitle: 'อัปเดตข้อมูลส่วนตัวและรูปโปรไฟล์',
                  iconName: 'person',
                  iconColor: AppTheme.primary,
                  onTap: _handleEditProfile,
                ),
                SettingsItem(
                  title: 'เปลี่ยนรหัสผ่าน',
                  subtitle: 'อัปเดตรหัสผ่านเพื่อความปลอดภัย',
                  iconName: 'lock',
                  iconColor: AppTheme.warning,
                  onTap: _handleChangePassword,
                ),
                SettingsItem(
                  title: 'การแจ้งเตือน',
                  subtitle: 'จัดการการแจ้งเตือนและอีเมล',
                  iconName: 'notifications',
                  iconColor: AppTheme.success,
                  onTap: _handleNotificationSettings,
                ),
              ],
            ),

            // App Preferences Section
            SettingsSectionWidget(
              title: 'การตั้งค่าแอป',
              items: [
                SettingsItem(
                  title: 'ธีมมืด',
                  subtitle: 'ใช้ธีมมืดสำหรับการใช้งาน',
                  iconName: 'dark_mode',
                  iconColor: AppTheme.primary,
                  trailing: Switch.adaptive(
                    value: isDarkTheme,
                    onChanged: (value) {
                      setState(() {
                        isDarkTheme = value;
                      });
                    },
                    activeColor: AppTheme.primary,
                  ),
                ),
                SettingsItem(
                  title: 'ภาษา',
                  subtitle: isThaiLanguage ? 'ไทย' : 'English',
                  iconName: 'language',
                  iconColor: AppTheme.accentLight,
                  trailing: Switch.adaptive(
                    value: isThaiLanguage,
                    onChanged: (value) {
                      setState(() {
                        isThaiLanguage = value;
                      });
                    },
                    activeColor: AppTheme.primary,
                  ),
                ),
                SettingsItem(
                  title: 'การแจ้งเตือนแบบพุช',
                  subtitle: 'รับการแจ้งเตือนจากแอป',
                  iconName: 'push_pin',
                  iconColor: AppTheme.success,
                  trailing: Switch.adaptive(
                    value: isPushNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        isPushNotificationsEnabled = value;
                      });
                    },
                    activeColor: AppTheme.primary,
                  ),
                ),
              ],
            ),

            // Connected Accounts
            ConnectedAccountsWidget(
              accounts: connectedAccounts,
              onViewAllPressed: _handleViewAllAccounts,
            ),

            // Security Section
            SettingsSectionWidget(
              title: 'ความปลอดภัย',
              items: [
                SettingsItem(
                  title: 'การยืนยันตัวตนแบบสองขั้นตอน',
                  subtitle: isTwoFactorEnabled ? 'เปิดใช้งานแล้ว' : 'ปิดใช้งาน',
                  iconName: 'security',
                  iconColor: AppTheme.success,
                  trailing: Switch.adaptive(
                    value: isTwoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        isTwoFactorEnabled = value;
                      });
                      _handleTwoFactorToggle(value);
                    },
                    activeColor: AppTheme.primary,
                  ),
                ),
                SettingsItem(
                  title: 'อุปกรณ์ที่เข้าสู่ระบบ',
                  subtitle: 'จัดการอุปกรณ์ที่เข้าสู่ระบบ',
                  iconName: 'devices',
                  iconColor: AppTheme.textSecondary,
                  onTap: _handleLoggedDevices,
                ),
                SettingsItem(
                  title: 'ออกจากระบบ',
                  subtitle: 'ออกจากระบบบัญชีนี้',
                  iconName: 'logout',
                  iconColor: AppTheme.error,
                  onTap: _handleLogout,
                ),
              ],
            ),

            // Help Section
            SettingsSectionWidget(
              title: 'ความช่วยเหลือ',
              items: [
                SettingsItem(
                  title: 'คำถามที่พบบ่อย',
                  subtitle: 'หาคำตอบสำหรับคำถามทั่วไป',
                  iconName: 'help',
                  iconColor: AppTheme.primary,
                  onTap: _handleFAQ,
                ),
                SettingsItem(
                  title: 'ติดต่อฝ่ายสนับสนุน',
                  subtitle: 'ติดต่อทีมสนับสนุนลูกค้า',
                  iconName: 'support_agent',
                  iconColor: AppTheme.success,
                  onTap: _handleContactSupport,
                ),
                SettingsItem(
                  title: 'เงื่อนไขการใช้งาน',
                  subtitle: 'อ่านเงื่อนไขการใช้งาน',
                  iconName: 'description',
                  iconColor: AppTheme.textSecondary,
                  onTap: _handleTermsOfService,
                ),
                SettingsItem(
                  title: 'นโยบายความเป็นส่วนตัว',
                  subtitle: 'อ่านนโยบายความเป็นส่วนตัว',
                  iconName: 'privacy_tip',
                  iconColor: AppTheme.textSecondary,
                  onTap: _handlePrivacyPolicy,
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // App Info
            AppInfoWidget(
              appVersion: userData["app_version"] as String,
              buildNumber: userData["build_number"] as String,
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _handleEditProfile() {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิดหน้าแก้ไขโปรไฟล์'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _handleAvatarUpdate() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'เปลี่ยนรูปโปรไฟล์',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.primary,
                size: 24,
              ),
              title: Text(
                'ถ่ายรูป',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เปิดกล้องถ่ายรูป')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.success,
                size: 24,
              ),
              title: Text(
                'เลือกจากแกลเลอรี่',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เปิดแกลเลอรี่')),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleManageSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิด Stripe Billing Portal'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _handleChangePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เปิดหน้าเปลี่ยนรหัสผ่าน')),
    );
  }

  void _handleNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เปิดการตั้งค่าการแจ้งเตือน')),
    );
  }

  void _handleViewAllAccounts() {
    Navigator.pushNamed(context, '/account-connections');
  }

  void _handleTwoFactorToggle(bool enabled) {
    if (enabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            'เปิดใช้งาน 2FA',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'คุณต้องการเปิดใช้งานการยืนยันตัวตนแบบสองขั้นตอนหรือไม่?',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isTwoFactorEnabled = false;
                });
              },
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เปิดใช้งาน 2FA แล้ว')),
                );
              },
              child: Text('ยืนยัน'),
            ),
          ],
        ),
      );
    }
  }

  void _handleLoggedDevices() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('แสดงอุปกรณ์ที่เข้าสู่ระบบ')),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'ออกจากระบบ',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  void _handleFAQ() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เปิดหน้าคำถามที่พบบ่อย')),
    );
  }

  void _handleContactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เปิดหน้าติดต่อฝ่ายสนับสนุน')),
    );
  }

  void _handleTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เปิดเงื่อนไขการใช้งาน')),
    );
  }

  void _handlePrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เปิดนโยบายความเป็นส่วนตัว')),
    );
  }
}
