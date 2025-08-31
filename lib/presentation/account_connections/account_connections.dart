import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_health_section.dart';
import './widgets/connected_account_card.dart';
import './widgets/empty_state_widget.dart';
import './widgets/platform_card.dart';

class AccountConnections extends StatefulWidget {
  const AccountConnections({Key? key}) : super(key: key);

  @override
  State<AccountConnections> createState() => _AccountConnectionsState();
}

class _AccountConnectionsState extends State<AccountConnections>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _showBulkActions = false;
  final List<String> _selectedAccounts = [];

  // Mock data for connected accounts
  final List<Map<String, dynamic>> _connectedAccounts = [
    {
      'id': 1,
      'platform': 'Facebook',
      'accountName': 'My Business Page',
      'followers': 15420,
      'status': 'active',
      'logoUrl':
          'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=100&h=100&fit=crop',
      'lastSync': '2 นาทีที่แล้ว',
    },
    {
      'id': 2,
      'platform': 'Instagram',
      'accountName': '@mybusiness',
      'followers': 8750,
      'status': 'needs_refresh',
      'logoUrl':
          'https://images.unsplash.com/photo-1611262588024-d12430b98920?w=100&h=100&fit=crop',
      'lastSync': '1 ชั่วโมงที่แล้ว',
    },
    {
      'id': 3,
      'platform': 'Twitter',
      'accountName': '@MyBusiness',
      'followers': 3200,
      'status': 'disconnected',
      'logoUrl':
          'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=100&h=100&fit=crop',
      'lastSync': '3 วันที่แล้ว',
    },
  ];

  // Mock data for available platforms
  final List<Map<String, dynamic>> _availablePlatforms = [
    {
      'name': 'Facebook',
      'description': 'เชื่อมต่อเพจและโปรไฟล์',
      'logoUrl':
          'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=100&h=100&fit=crop',
      'isSupported': true,
    },
    {
      'name': 'Instagram',
      'description': 'จัดการโพสต์และสตอรี่',
      'logoUrl':
          'https://images.unsplash.com/photo-1611262588024-d12430b98920?w=100&h=100&fit=crop',
      'isSupported': true,
    },
    {
      'name': 'Twitter',
      'description': 'ทวีตและติดตามเทรนด์',
      'logoUrl':
          'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=100&h=100&fit=crop',
      'isSupported': true,
    },
    {
      'name': 'LinkedIn',
      'description': 'เครือข่ายทางธุรกิจ',
      'logoUrl':
          'https://images.unsplash.com/photo-1611944212129-29977ae1398c?w=100&h=100&fit=crop',
      'isSupported': true,
    },
    {
      'name': 'TikTok',
      'description': 'วิดีโอสั้นและเทรนด์',
      'logoUrl':
          'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=100&h=100&fit=crop',
      'isSupported': false,
    },
  ];

  // Mock health data
  final Map<String, dynamic> _healthData = {
    'apiUsage': 1250,
    'apiLimit': 5000,
    'rateUsage': 45,
    'rateLimit': 100,
    'lastSync': '31 สิงหาคม 2025, 14:08',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body:
          _connectedAccounts.isEmpty ? _buildEmptyState() : _buildMainContent(),
      floatingActionButton:
          _connectedAccounts.isNotEmpty ? _buildFloatingActionButton() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.textPrimary,
          size: 6.w,
        ),
      ),
      title: Text(
        'เชื่อมต่อบัญชี',
        style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_connectedAccounts.isNotEmpty) ...[
          IconButton(
            onPressed: _showHelpDialog,
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.textSecondary,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _toggleBulkActions,
            icon: CustomIconWidget(
              iconName: _showBulkActions ? 'close' : 'checklist',
              color:
                  _showBulkActions ? AppTheme.primary : AppTheme.textSecondary,
              size: 6.w,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      onGetStarted: () => _showPlatformSelection(),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        if (_showBulkActions) _buildBulkActionsBar(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildConnectedAccountsTab(),
              _buildAddAccountsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(1.w),
        labelColor: AppTheme.onPrimary,
        unselectedLabelColor: AppTheme.textSecondary,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'link',
                  color: _tabController.index == 0
                      ? AppTheme.onPrimary
                      : AppTheme.textSecondary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('เชื่อมต่อแล้ว (${_connectedAccounts.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'add_circle_outline',
                  color: _tabController.index == 1
                      ? AppTheme.onPrimary
                      : AppTheme.textSecondary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('เพิ่มบัญชี'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(
            'เลือกแล้ว ${_selectedAccounts.length} บัญชี',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _selectedAccounts.isNotEmpty ? _bulkRefreshTokens : null,
            child: Text('รีเฟรชทั้งหมด'),
          ),
          SizedBox(width: 2.w),
          TextButton(
            onPressed: _selectedAccounts.isNotEmpty ? _bulkDisconnect : null,
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text('ยกเลิกทั้งหมด'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsTab() {
    return RefreshIndicator(
      onRefresh: _refreshAccounts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            AccountHealthSection(healthData: _healthData),
            SizedBox(height: 2.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _connectedAccounts.length,
              itemBuilder: (context, index) {
                final account = _connectedAccounts[index];
                return ConnectedAccountCard(
                  account: account,
                  onManage: () => _manageAccount(account),
                  onRefresh: () => _refreshAccount(account),
                  onDisconnect: () => _disconnectAccount(account),
                );
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountsTab() {
    final supportedPlatforms =
        _availablePlatforms.where((p) => p['isSupported'] as bool).toList();
    final unsupportedPlatforms =
        _availablePlatforms.where((p) => !(p['isSupported'] as bool)).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'แพลตฟอร์มที่รองรับ',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: supportedPlatforms.length,
            itemBuilder: (context, index) {
              final platform = supportedPlatforms[index];
              return PlatformCard(
                platform: platform,
                onTap: () => _connectPlatform(platform),
              );
            },
          ),
          if (unsupportedPlatforms.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'เร็วๆ นี้',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
              ),
              itemCount: unsupportedPlatforms.length,
              itemBuilder: (context, index) {
                final platform = unsupportedPlatforms[index];
                return Opacity(
                  opacity: 0.5,
                  child: PlatformCard(
                    platform: platform,
                    onTap: () => _showComingSoonDialog(platform),
                  ),
                );
              },
            ),
          ],
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _tabController.animateTo(1);
      },
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.onPrimary,
      icon: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.onPrimary,
        size: 6.w,
      ),
      label: Text(
        'เพิ่มบัญชี',
        style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
          color: AppTheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Action methods
  void _showPlatformSelection() {
    _tabController.animateTo(1);
  }

  void _toggleBulkActions() {
    setState(() {
      _showBulkActions = !_showBulkActions;
      if (!_showBulkActions) {
        _selectedAccounts.clear();
      }
    });
  }

  Future<void> _refreshAccounts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('รีเฟรชข้อมูลบัญชีเรียบร้อยแล้ว'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _manageAccount(Map<String, dynamic> account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildAccountManagementSheet(account),
    );
  }

  Widget _buildAccountManagementSheet(Map<String, dynamic> account) {
    return Container(
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
          SizedBox(height: 3.h),
          Text(
            'จัดการ ${account['accountName']}',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildManagementOption(
            'รีเฟรชโทเค็น',
            'อัปเดตการเชื่อมต่อ',
            'refresh',
            () => _refreshAccount(account),
          ),
          _buildManagementOption(
            'ตั้งค่าการโพสต์',
            'กำหนดค่าเริ่มต้น',
            'settings',
            () => _configureAccount(account),
          ),
          _buildManagementOption(
            'ดูสถิติ',
            'ข้อมูลการใช้งาน',
            'analytics',
            () => _viewAccountStats(account),
          ),
          _buildManagementOption(
            'ยกเลิกการเชื่อมต่อ',
            'ลบบัญชีออกจากระบบ',
            'link_off',
            () => _disconnectAccount(account),
            isDestructive: true,
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildManagementOption(
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        size: 6.w,
      ),
      title: Text(
        title,
        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.darkTheme.textTheme.bodySmall,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _refreshAccount(Map<String, dynamic> account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('กำลังรีเฟรชโทเค็นสำหรับ ${account['accountName']}'),
        backgroundColor: AppTheme.warning,
      ),
    );
  }

  void _configureAccount(Map<String, dynamic> account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิดการตั้งค่าสำหรับ ${account['accountName']}'),
      ),
    );
  }

  void _viewAccountStats(Map<String, dynamic> account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('แสดงสถิติสำหรับ ${account['accountName']}'),
      ),
    );
  }

  void _disconnectAccount(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'ยกเลิกการเชื่อมต่อ',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'คุณต้องการยกเลิกการเชื่อมต่อกับ ${account['accountName']} หรือไม่?',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _connectedAccounts
                    .removeWhere((acc) => acc['id'] == account['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'ยกเลิกการเชื่อมต่อกับ ${account['accountName']} แล้ว'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text('ยกเลิกการเชื่อมต่อ'),
          ),
        ],
      ),
    );
  }

  void _connectPlatform(Map<String, dynamic> platform) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 2.h),
            Text(
              'กำลังเชื่อมต่อกับ ${platform['name']}',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เชื่อมต่อกับ ${platform['name']} สำเร็จ'),
          backgroundColor: AppTheme.success,
        ),
      );
    });
  }

  void _bulkRefreshTokens() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('กำลังรีเฟรชโทเค็นสำหรับ ${_selectedAccounts.length} บัญชี'),
        backgroundColor: AppTheme.warning,
      ),
    );
  }

  void _bulkDisconnect() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'ยกเลิกการเชื่อมต่อหลายบัญชี',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'คุณต้องการยกเลิกการเชื่อมต่อกับ ${_selectedAccounts.length} บัญชีหรือไม่?',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedAccounts.clear();
                _showBulkActions = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ยกเลิกการเชื่อมต่อหลายบัญชีแล้ว'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text('ยกเลิกการเชื่อมต่อ'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(Map<String, dynamic> platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'เร็วๆ นี้',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'การเชื่อมต่อกับ ${platform['name']} จะพร้อมใช้งานในเร็วๆ นี้',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'คำแนะนำการเชื่อมต่อ',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• เลือกแพลตฟอร์มที่ต้องการเชื่อมต่อ\n'
                '• เข้าสู่ระบบด้วยบัญชีของคุณ\n'
                '• อนุญาตการเข้าถึงข้อมูล\n'
                '• เริ่มจัดการเนื้อหาได้ทันที',
                style: AppTheme.darkTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }
}
