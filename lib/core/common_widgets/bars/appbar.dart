import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/arrow_button.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final ValueChanged<String>? onSearch;
  final double titleFontSize;
  final List<Widget>? actions;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.onSearch,
    this.titleFontSize = 22,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    _animController.forward();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    _animController.reverse().then((_) {
      if (mounted) {
        _searchController.clear();
        widget.onSearch?.call('');
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.appBarColor;
    final Color textColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
      height: widget.preferredSize.height + MediaQuery.of(context).padding.top,
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: kToolbarHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _isSearching
                  // ── Search mode ─────────────────────────────────
                  ? Row(
                      key: const ValueKey('search'),
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            autofocus: true,
                            onChanged: widget.onSearch,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            cursorColor: AppColors.iconbar,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 18,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white54,
                                size: 28,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 22,
                          ),
                          onPressed: _closeSearch,
                        ),
                      ],
                    )
                  : Stack(
                      key: const ValueKey('title'),
                      alignment: Alignment.center,
                      children: [
                        // ── True center title ──────────────────────
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: textColor,
                                fontSize: widget.titleFontSize,
                              ),
                        ),
                        // ── Back button (left) ─────────────────────
                        if (widget.showBackButton)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ArrowButton(
                              direction: ArrowDirection.left,
                              onPressed: () {
                                if (widget.onBackPressed != null) {
                                  widget.onBackPressed!();
                                } else if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        // ── Search icon (right) ────────────────────
                        if (widget.onSearch != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: _openSearch,
                            ),
                          ),
                        // ── Custom actions (right) ─────────────────
                        if (widget.actions != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: widget.actions!,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

//---------------------- วิธีเรียกใช้ ----------------------//
/* appBar: AppBarWidget(
  title: "Learning Paths",
  onSearch: (query) => setState(() => _searchQuery = query),
),
*/
