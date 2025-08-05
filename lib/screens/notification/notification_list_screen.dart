import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dateFormat = DateFormat('M월 d일');
  
  final List<String> _selectedNotifications = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        notificationProvider.loadNotifications(
          userId: authProvider.user!.id,
          refresh: true,
        );
        notificationProvider.loadUnreadCount(authProvider.user!.id);
        notificationProvider.startRealTimeNotifications(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer2<NotificationProvider, AuthProvider>(
        builder: (context, notificationProvider, authProvider, child) {
          return Column(
            children: [
              if (_isSelectionMode) _buildSelectionToolbar(notificationProvider),
              _buildFilterTabs(notificationProvider),
              Expanded(
                child: _buildNotificationList(notificationProvider, authProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (_isSelectionMode) {
            return Text('${_selectedNotifications.length}개 선택됨');
          }
          return Row(
            children: [
              const Text('알림'),
              if (notificationProvider.unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${notificationProvider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSelectedNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markSelectedAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _exitSelectionMode(),
          ),
        ] else ...[
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 8),
                    Text('모두 읽음'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'select_mode',
                child: Row(
                  children: [
                    Icon(Icons.checklist, size: 20),
                    SizedBox(width: 8),
                    Text('선택 모드'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('알림 설정'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('새로고침'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionToolbar(NotificationProvider notificationProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _selectAll(),
            icon: const Icon(Icons.select_all, size: 18),
            label: const Text('전체 선택'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _exitSelectionMode(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(NotificationProvider notificationProvider) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => _applyFilter(index, notificationProvider),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('전체'),
                if ((notificationProvider.notifications?.length ?? 0) > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${notificationProvider.notifications!.length})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('읽지 않음'),
                if (notificationProvider.unreadCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: '중요'),
          const Tab(text: '보관됨'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider notificationProvider, AuthProvider authProvider) {
    if (notificationProvider.isLoadingNotifications) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notificationProvider.notificationsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(notificationProvider.notificationsError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshNotifications(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final notifications = notificationProvider.getFilteredNotifications();
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '알림이 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyMessage(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, notificationProvider);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, NotificationProvider notificationProvider) {
    final isSelected = _selectedNotifications.contains(notification.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isUnread ? 2 : 1,
      color: notification.isUnread ? Colors.blue.withOpacity(0.02) : null,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, notificationProvider),
        onLongPress: () => _enterSelectionMode(notification.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleNotificationSelection(notification.id),
                ),
                const SizedBox(width: 8),
              ],
              
              // 알림 타입 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  notification.typeIcon,
                  color: notification.typeColor,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 알림 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: notification.typeColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            notification.typeDisplayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: notification.typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    
                    // 액션 버튼들
                    if (notification.actions != null && notification.actions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: notification.actions!.take(2).map((action) => 
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: TextButton(
                              onPressed: () => _handleActionTap(action, notification),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: action.isPrimary 
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : null,
                              ),
                              child: Text(
                                action.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: action.isPrimary 
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.unreadCount == 0) return const SizedBox();
        
        return FloatingActionButton.extended(
          onPressed: () => _markAllAsRead(),
          icon: const Icon(Icons.done_all),
          label: const Text('모두 읽음'),
          backgroundColor: Theme.of(context).primaryColor,
        );
      },
    );
  }

  void _applyFilter(int index, NotificationProvider notificationProvider) {
    switch (index) {
      case 0: // 전체
        notificationProvider.clearFilters();
        break;
      case 1: // 읽지 않음
        notificationProvider.setStatusFilter(NotificationStatus.unread);
        break;
      case 2: // 중요
        notificationProvider.setPriorityFilter(NotificationPriority.high);
        break;
      case 3: // 보관됨
        notificationProvider.setStatusFilter(NotificationStatus.archived);
        break;
    }
    
    _refreshNotifications();
  }

  String _getEmptyMessage() {
    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0:
        return '새로운 알림이 도착하면 여기에 표시됩니다';
      case 1:
        return '읽지 않은 알림이 없습니다';
      case 2:
        return '중요한 알림이 없습니다';
      case 3:
        return '보관된 알림이 없습니다';
      default:
        return '';
    }
  }

  Future<void> _refreshNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications(
            userId: authProvider.user!.id,
            refresh: true,
          );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'select_mode':
        _enterSelectionMode();
        break;
      case 'settings':
        context.push('/notification/settings');
        break;
      case 'refresh':
        _refreshNotifications();
        break;
    }
  }

  void _handleNotificationTap(AppNotification notification, NotificationProvider notificationProvider) {
    if (_isSelectionMode) {
      _toggleNotificationSelection(notification.id);
      return;
    }

    // 읽지 않은 알림이면 읽음 처리
    if (notification.isUnread) {
      notificationProvider.markAsRead(notification.id);
    }

    // 액션이 있으면 첫 번째 액션 실행, 없으면 상세 화면으로 이동
    if (notification.actions != null && notification.actions!.isNotEmpty) {
      _handleActionTap(notification.actions!.first, notification);
    } else {
      _showNotificationDetail(notification);
    }
  }

  void _handleActionTap(NotificationAction action, AppNotification notification) {
    final params = action.params ?? {};
    if (notification.data != null) {
      notification.data!.forEach((key, value) {
        params[key] = value.toString();
      });
    }
    
    String route = action.route;
    if (params.isNotEmpty) {
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$route?$queryString';
    }
    
    context.push(route);
  }

  void _showNotificationDetail(AppNotification notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    notification.typeIcon,
                    color: notification.typeColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                notification.message,
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알림 정보',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('타입: ', style: TextStyle(color: Colors.grey[600])),
                        Text(notification.typeDisplayName),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('우선순위: ', style: TextStyle(color: Colors.grey[600])),
                        Text(_getPriorityName(notification.priority)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('수신 시간: ', style: TextStyle(color: Colors.grey[600])),
                        Text('${_dateFormat.format(notification.createdAt)} ${_timeFormat.format(notification.createdAt)}'),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (notification.actions != null && notification.actions!.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...notification.actions!.map((action) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleActionTap(action, notification);
                        },
                        icon: Icon(action.isPrimary ? Icons.arrow_forward : Icons.open_in_new),
                        label: Text(action.label),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action.isPrimary 
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          foregroundColor: action.isPrimary 
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return '낮음';
      case NotificationPriority.normal:
        return '보통';
      case NotificationPriority.high:
        return '높음';
      case NotificationPriority.urgent:
        return '긴급';
    }
  }

  void _enterSelectionMode([String? initialId]) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications.clear();
      if (initialId != null) {
        _selectedNotifications.add(initialId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  void _toggleNotificationSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  void _selectAll() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final notifications = notificationProvider.getFilteredNotifications();
    
    setState(() {
      _selectedNotifications.clear();
      _selectedNotifications.addAll(notifications.map((n) => n.id));
    });
  }

  Future<void> _deleteSelectedNotifications() async {
    if (_selectedNotifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 삭제'),
        content: Text('선택한 ${_selectedNotifications.length}개의 알림을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final success = await notificationProvider.deleteMultiple(_selectedNotifications);
      
      if (success) {
        _exitSelectionMode();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택한 알림이 삭제되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림 삭제에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedNotifications.isEmpty) return;

    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final success = await notificationProvider.markMultipleAsRead(_selectedNotifications);
    
    if (success) {
      _exitSelectionMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 알림을 읽음 처리했습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('읽음 처리에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final success = await notificationProvider.markAllAsRead(authProvider.user!.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 알림을 읽음 처리했습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('읽음 처리에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
