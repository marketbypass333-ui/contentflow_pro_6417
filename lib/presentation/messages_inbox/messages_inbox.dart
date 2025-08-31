import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/conversation_card.dart';
import './widgets/platform_filter_chips.dart';
import './widgets/search_header.dart';

class MessagesInbox extends StatefulWidget {
  const MessagesInbox({Key? key}) : super(key: key);

  @override
  State<MessagesInbox> createState() => _MessagesInboxState();
}

class _MessagesInboxState extends State<MessagesInbox> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _filteredConversations = [];
  String _selectedPlatform = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeTimeago();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeTimeago() {
    timeago.setLocaleMessages('th', timeago.ThMessages());
  }

  Future<void> _loadConversations() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        _navigateToLogin();
        return;
      }

      // Load messages grouped by conversation/thread
      final response = await _supabaseService.client
          .from('messages')
          .select('*')
          .eq('profile_id', user.id)
          .order('created_at', ascending: false);

      // Group messages by thread_id or sender for conversation view
      final Map<String, List<Map<String, dynamic>>> groupedMessages = {};

      for (final message in response) {
        final String conversationKey =
            message['thread_id'] ?? message['sender_name'] ?? 'unknown';
        groupedMessages.putIfAbsent(conversationKey, () => []);
        groupedMessages[conversationKey]!
            .add(Map<String, dynamic>.from(message));
      }

      // Convert to conversation list with latest message info
      final List<Map<String, dynamic>> conversations = [];
      groupedMessages.forEach((threadId, messages) {
        final latestMessage =
            messages.first; // Already sorted by created_at desc
        final unreadCount =
            messages.where((m) => m['status'] == 'unread').length;

        conversations.add({
          'thread_id': threadId,
          'sender_name': latestMessage['sender_name'] ?? 'Unknown',
          'sender_avatar': latestMessage['sender_avatar'],
          'platform': latestMessage['platform'] ?? 'unknown',
          'latest_message': latestMessage['content'] ?? '',
          'latest_message_time': latestMessage['created_at'],
          'unread_count': unreadCount,
          'messages': messages,
        });
      });

      // Sort conversations by latest message time
      conversations.sort((a, b) {
        final DateTime timeA =
            DateTime.tryParse(a['latest_message_time']) ?? DateTime.now();
        final DateTime timeB =
            DateTime.tryParse(b['latest_message_time']) ?? DateTime.now();
        return timeB.compareTo(timeA);
      });

      setState(() {
        _conversations = conversations;
        _filteredConversations = conversations;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading conversations: $error');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('ไม่สามารถโหลดข้อความได้ กรุณาลองใหม่อีกครั้ง');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _filterConversations() {
    List<Map<String, dynamic>> filtered = _conversations;

    // Filter by platform
    if (_selectedPlatform != 'all') {
      filtered = filtered
          .where((conv) =>
              conv['platform'].toString().toLowerCase() ==
              _selectedPlatform.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((conv) {
        final senderName = conv['sender_name'].toString().toLowerCase();
        final message = conv['latest_message'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        return senderName.contains(query) || message.contains(query);
      }).toList();
    }

    setState(() {
      _filteredConversations = filtered;
    });
  }

  void _onPlatformFilterChanged(String platform) {
    setState(() {
      _selectedPlatform = platform;
    });
    _filterConversations();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterConversations();
  }

  Future<void> _refreshMessages() async {
    await _loadConversations();
  }

  void _openConversation(Map<String, dynamic> conversation) {
    // TODO: Navigate to conversation detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิดการสนทนากับ ${conversation['sender_name']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markAsRead(String threadId) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return;

      await _supabaseService.client
          .from('messages')
          .update({'status': 'read'})
          .eq('profile_id', user.id)
          .eq('thread_id', threadId)
          .eq('status', 'unread');

      // Update local state
      final updatedConversations = _conversations.map((conv) {
        if (conv['thread_id'] == threadId) {
          conv['unread_count'] = 0;
          // Update messages status
          for (final message in conv['messages']) {
            if (message['status'] == 'unread') {
              message['status'] = 'read';
            }
          }
        }
        return conv;
      }).toList();

      setState(() {
        _conversations = updatedConversations;
      });
      _filterConversations();
    } catch (error) {
      debugPrint('Error marking messages as read: $error');
    }
  }

  Future<void> _archiveConversation(String threadId) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return;

      await _supabaseService.client
          .from('messages')
          .update({'status': 'archived'})
          .eq('profile_id', user.id)
          .eq('thread_id', threadId);

      // Remove from local state
      setState(() {
        _conversations.removeWhere((conv) => conv['thread_id'] == threadId);
      });
      _filterConversations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('การสนทนาถูกเก็บถาวรแล้ว'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      debugPrint('Error archiving conversation: $error');
      _showErrorSnackbar('ไม่สามารถเก็บถาวรการสนทนาได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ข้อความ',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
            size: 5.w,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search header
                SearchHeader(
                  controller: _searchController,
                  onSearchChanged: _onSearchChanged,
                ),

                SizedBox(height: 2.h),

                // Platform filter chips
                PlatformFilterChips(
                  selectedPlatform: _selectedPlatform,
                  onPlatformChanged: _onPlatformFilterChanged,
                ),

                SizedBox(height: 2.h),

                // Conversations list
                Expanded(
                  child: _filteredConversations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _refreshMessages,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: _filteredConversations.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 1.h),
                            itemBuilder: (context, index) {
                              final conversation =
                                  _filteredConversations[index];
                              return ConversationCard(
                                conversation: conversation,
                                onTap: () => _openConversation(conversation),
                                onMarkAsRead: () =>
                                    _markAsRead(conversation['thread_id']),
                                onArchive: () => _archiveConversation(
                                    conversation['thread_id']),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'ไม่มีข้อความ';
    String subtitle = 'ข้อความจากโซเชียลมีเดียจะแสดงที่นี่';

    if (_searchQuery.isNotEmpty) {
      message = 'ไม่พบผลการค้นหา';
      subtitle = 'ลองค้นหาด้วยคำคอมอำหนดื่น';
    } else if (_selectedPlatform != 'all') {
      message = 'ไม่มีข้อความจากแพลตฟอร์มนี้';
      subtitle = 'เลือกแพลตฟอร์มอื่น หรือตรวจสอบการเชื่อมต่อ';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 20.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 3.h),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedPlatform != 'all') ...[
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedPlatform = 'all';
                    _searchController.clear();
                  });
                  _filterConversations();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
                child: Text(
                  'ล้างตัวกรอง',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}