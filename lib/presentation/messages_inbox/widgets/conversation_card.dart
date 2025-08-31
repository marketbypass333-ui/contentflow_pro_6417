import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConversationCard extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onArchive;

  const ConversationCard({
    Key? key,
    required this.conversation,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onArchive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String senderName = conversation['sender_name'] ?? 'Unknown';
    final String senderAvatar = conversation['sender_avatar'] ?? '';
    final String platform = conversation['platform'] ?? 'unknown';
    final String latestMessage = conversation['latest_message'] ?? '';
    final int unreadCount = conversation['unread_count'] ?? 0;
    final DateTime messageTime =
        DateTime.tryParse(conversation['latest_message_time']) ??
            DateTime.now();

    return Dismissible(
      key: Key(conversation['thread_id']),
      background: _buildSwipeActionBackground(
        color: Colors.green,
        icon: Icons.mark_email_read,
        text: 'อ่านแล้ว',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeActionBackground(
        color: Colors.red,
        icon: Icons.archive,
        text: 'เก็บถาวร',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read
          onMarkAsRead();
          return false; // Don't dismiss
        } else if (direction == DismissDirection.endToStart) {
          // Archive
          return await _showArchiveConfirmation(context);
        }
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(3.w),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: unreadCount > 0 ? Colors.blue.withAlpha(13) : Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              border: unreadCount > 0
                  ? Border.all(color: Colors.blue.withAlpha(51), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with platform indicator
                Stack(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getPlatformColor(platform).withAlpha(77),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: senderAvatar.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: senderAvatar,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[400],
                                    size: 6.w,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[400],
                                    size: 6.w,
                                  ),
                                ),
                              )
                            : Container(
                                color:
                                    _getPlatformColor(platform).withAlpha(26),
                                child: Icon(
                                  Icons.person,
                                  color: _getPlatformColor(platform),
                                  size: 6.w,
                                ),
                              ),
                      ),
                    ),
                    // Platform badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: _getPlatformColor(platform),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _getPlatformIcon(platform),
                          size: 3.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 3.w),

                // Conversation details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              senderName,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeago.format(messageTime, locale: 'th'),
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: unreadCount > 0
                                  ? AppTheme.primary
                                  : Colors.grey[600],
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              latestMessage,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: unreadCount > 0
                                    ? AppTheme.textPrimary
                                    : Colors.grey[700],
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            SizedBox(width: 2.w),
                            Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 5.w,
                                minHeight: 5.w,
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeActionBackground({
    required Color color,
    required IconData icon,
    required String text,
    required Alignment alignment,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3.w),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showArchiveConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
              title: Text(
                'เก็บถาวรการสนทนา',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              content: Text(
                'คุณแน่ใจหรือไม่ที่จะเก็บถาวรการสนทนานี้? คุณยังสามารถดูได้ในส่วนถาวร',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'ยกเลิก',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  child: Text(
                    'เก็บถาวร',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'youtube':
        return const Color(0xFFFF0000);
      default:
        return AppTheme.primary;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'linkedin':
        return Icons.work;
      case 'tiktok':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_arrow;
      default:
        return Icons.public;
    }
  }
}