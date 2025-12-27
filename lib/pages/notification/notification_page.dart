import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  int _currentPage = 1;
  bool _hasMore = true; // Assume true initially

  // Warna yang digunakan untuk dark mode agar mirip screenshot
  static const Color _darkBackground = Color(0xFF3B2A33);
  static const Color _darkTextPrimary = Color(0xFF0B0B0B);
  static const Color _darkTextSecondary = Color(0xFFB8AEB3);
  static const Color _dotTeal = Color(0xFF11BFAF);
  static const Color _dividerColor = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isMoreLoading &&
        _hasMore) {
      _loadMoreNotifications();
    }
  }

  Future<void> _fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      if (mounted) setState(() => _isLoading = true);
      _currentPage = 1;
    }

    try {
      final items =
          await _notificationService.getNotifications(page: _currentPage);
      if (mounted) {
        setState(() {
          if (refresh) {
            _notifications = items;
          } else {
            _notifications.addAll(items);
          }
          _isLoading = false;
          // If we got fewer items than limit (10), we reached the end
          _hasMore = items.length == 10;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    setState(() => _isMoreLoading = true);
    _currentPage++;
    try {
      final items =
          await _notificationService.getNotifications(page: _currentPage);
      if (mounted) {
        setState(() {
          _notifications.addAll(items);
          _hasMore = items.length == 10;
          _isMoreLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMoreLoading = false);
        // Don't show snackbar on load more fail, just stop loading
      }
    }
  }

  Future<void> _markAsRead(NotificationItem item) async {
    setState(() {
      final index =
          _notifications.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });

    try {
      await _notificationService.markAsRead(item.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
        setState(() {
          final index =
              _notifications.indexWhere((element) => element.id == item.id);
          if (index != -1) {
            _notifications[index] =
                _notifications[index].copyWith(isRead: false);
          }
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    setState(() {
      _notifications =
          _notifications.map((e) => e.copyWith(isRead: true)).toList();
    });
    try {
      await _notificationService.markAllRead();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read: $e')),
        );
      }
      await _fetchNotifications(refresh: true);
    }
  }

  Future<void> _deleteAll() async {
    try {
      await _notificationService.deleteAll();
      setState(() => _notifications.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications deleted')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notifications: $e')),
        );
      }
    }
  }

  String _timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    final backgroundColor = isDark ? _darkBackground : Colors.white;
    final appBarBackground = Colors.white;
    final timeColor = isDark ? const Color(0xFF9E9E9E) : Colors.grey;
    final descriptionColor = isDark ? _darkTextSecondary : Colors.grey;
    final headingColor = isDark ? _darkTextPrimary : Colors.black;
    final divider = Divider(
      color: isDark ? _dividerColor.withOpacity(0.9) : const Color(0xFFEAEAEA),
      thickness: 1,
      height: 28,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'read_all') _markAllRead();
              if (value == 'delete_all') _deleteAll();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'read_all',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem<String>(
                value: 'delete_all',
                child: Text('Delete all'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchNotifications(refresh: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Text(
                      "No notifications yet",
                      style: TextStyle(color: descriptionColor),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    itemCount: _notifications.length + (_isMoreLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = _notifications[index];
                      return _buildNotificationItem(
                        headingColor,
                        descriptionColor,
                        timeColor,
                        title: item.title,
                        time: _timeAgo(item.createdAt),
                        description: item.body,
                        isNew: !item.isRead,
                        divider: divider,
                        onRead: !item.isRead ? () => _markAsRead(item) : null,
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildNotificationItem(
    Color headingColor,
    Color descriptionColor,
    Color timeColor, {
    required String title,
    required String time,
    required String description,
    required bool isNew,
    required Widget divider,
    VoidCallback? onRead,
  }) {
    Widget content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // dot / spacer
              if (isNew)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: _dotTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                const SizedBox(width: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title and time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: headingColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: timeColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: descriptionColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Divider
        divider,
      ],
    );

    if (isNew && onRead != null) {
      return Slidable(
        key: ValueKey(title + time), // Simple key
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onRead(),
              backgroundColor: _dotTeal,
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Read',
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
