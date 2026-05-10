import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/controller/home_screen_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  static bool _popupCheckedThisSession = false;

  // ─── Brand Palette ───────────────────────────────────────────────
  static const Color _c1 = Color(0xFF9B59B6);  // purple
  static const Color _c2 = Color(0xFF00BCD4);  // cyan
  static const Color _bg = Color(0xFF080C18);  // deep navy
  static const Color _surface = Color(0xFF0F1422);
  static const Color _card = Color(0xFF141928);
  static const Color _cardBorder = Color(0xFF1E2438);

  // ─── Gradients ───────────────────────────────────────────────────
  static const LinearGradient _brandGrad = LinearGradient(
    colors: [_c1, _c2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient _subtleGrad = LinearGradient(
    colors: [Color(0xFF1A1E2E), Color(0xFF0F1422)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: GetBuilder<HomeController>(
            builder: (ctrl) {
              _showConfigPopupIfNeeded();
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 100,
                    pinned: true,
                    flexibleSpace: _Header(ctrl: ctrl),
                  ),
                  SliverToBoxAdapter(child: _SearchBar(ctrl: ctrl)),
                  SliverToBoxAdapter(child: _CategoryPills(ctrl: ctrl)),
                  SliverToBoxAdapter(child: _CommunityCard(screen: this)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    sliver: _PromptsGrid(ctrl: ctrl, screen: this),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Popup ───────────────────────────────────────────────────────
  void _showConfigPopupIfNeeded() {
    if (_popupCheckedThisSession) return;
    _popupCheckedThisSession = true;

    final link = AppConfig.popupAds.trim();
    if (link.isEmpty) return;

    final msg = AppConfig.popupMessage.trim().isEmpty
        ? 'A new update is available. Tap below to open it.'
        : AppConfig.popupMessage.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen ?? false) return;
      Get.dialog(
        _AnnouncementDialog(message: msg, link: link, screen: this),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.6),
      );
    });
  }

  // ─── URL helpers (kept public so widgets can use) ─────────────────
  Future<void> openExternalUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (url.trim().isEmpty || uri == null) {
      _snack('Link not available', 'Please check back later.');
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    _snack('Unable to open link', 'Please try again later.');
  }

  Future<void> openSocialLink(String appUrl, String webUrl) async {
    final appUri = Uri.parse(appUrl);
    final webUri = Uri.parse(webUrl);
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }
    _snack('Unable to open link', 'Please try again later.');
  }

  static void _snack(String title, String msg) {
    Get.snackbar(
      title, msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A1E2E),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: Colors.white.withOpacity(0.1),
      borderWidth: 1,
      duration: const Duration(seconds: 3),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANNOUNCEMENT DIALOG
// ═══════════════════════════════════════════════════════════════════
class _AnnouncementDialog extends StatelessWidget {
  final String message;
  final String link;
  final HomeScreen screen;

  const _AnnouncementDialog({
    required this.message,
    required this.link,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF141928), Color(0xFF0F1422)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: HomeScreen._c1.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top accent strip ──────────────────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: HomeScreen._brandGrad,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon + title row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              HomeScreen._c1.withOpacity(0.3),
                              HomeScreen._c2.withOpacity(0.15),
                            ],
                          ),
                          border: Border.all(
                            color: HomeScreen._c2.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: HomeScreen._c2,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Announcement',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              'From PromptMera',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: const Color(0xFF94A3B8),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Later',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: HomeScreen._brandGrad,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: HomeScreen._c1.withOpacity(0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              await screen.openExternalUrl(link);
                              if (Get.isDialogOpen ?? false) Get.back();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.open_in_new_rounded, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Open Now',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final HomeController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HomeScreen._bg,
            HomeScreen._bg.withOpacity(0.92),
            HomeScreen._bg.withOpacity(0.0),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Logo mark
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: HomeScreen._brandGrad,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: HomeScreen._c1.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        HomeScreen._brandGrad.createShader(bounds),
                    child: const Text(
                      'PromptMera',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    ctrl.showFavoritesOnly
                        ? '${ctrl.favorites.length} Saved prompts'
                        : 'Smart AI Prompts',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            // Favorites toggle
            _IconChip(
              icon: ctrl.showFavoritesOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              active: ctrl.showFavoritesOnly,
              onTap: () => ctrl.toggleFavoritesView(),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _IconChip({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: active
              ? HomeScreen._brandGrad
              : const LinearGradient(
              colors: [Color(0xFF1A1E2E), Color(0xFF141928)]),
          border: Border.all(
            color: active
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: active
              ? [
            BoxShadow(
              color: HomeScreen._c1.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : const Color(0xFF6B7280),
          size: 18,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SEARCH BAR
// ═══════════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final HomeController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: HomeScreen._card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomeScreen._cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          onChanged: ctrl.updateSearchQuery,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search prompts, categories...',
            hintStyle: const TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: ShaderMask(
                shaderCallback: (b) => HomeScreen._brandGrad.createShader(b),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            suffixIcon: ctrl.searchQuery.isNotEmpty
                ? GestureDetector(
              onTap: () => ctrl.updateSearchQuery(''),
              child: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFF4B5563),
                  size: 18,
                ),
              ),
            )
                : null,
            suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CATEGORY PILLS
// ═══════════════════════════════════════════════════════════════════
class _CategoryPills extends StatelessWidget {
  final HomeController ctrl;
  const _CategoryPills({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: ctrl.categories.length,
        itemBuilder: (_, i) {
          final cat = ctrl.categories[i];
          final selected = ctrl.selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => ctrl.updateCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                height: 36,
                decoration: BoxDecoration(
                  gradient: selected
                      ? HomeScreen._brandGrad
                      : const LinearGradient(
                      colors: [Color(0xFF141928), Color(0xFF0F1422)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : HomeScreen._cardBorder,
                    width: 1,
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: HomeScreen._c1.withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COMMUNITY CARD
// ═══════════════════════════════════════════════════════════════════
class _CommunityCard extends StatelessWidget {
  final HomeScreen screen;
  const _CommunityCard({required this.screen});

  @override
  Widget build(BuildContext context) {
    final tg = AppConfig.telegram.trim();
    final ig = AppConfig.instraggram.trim();
    final wa = AppConfig.whatsapplink.trim();

    final tgDeep = tg.startsWith('tg://')
        ? tg
        : 'tg://resolve?domain=${tg.isNotEmpty ? tg : 'promptseen'}';
    final tgWeb = tg.startsWith('http')
        ? tg
        : 'https://t.me/${tg.isNotEmpty ? tg : 'promptseen'}';
    final igDeep = ig.startsWith('instagram://')
        ? ig
        : 'instagram://user?username=${ig.isNotEmpty ? ig : 'promptseen'}';
    final igWeb = ig.startsWith('http')
        ? ig
        : 'https://instagram.com/${ig.isNotEmpty ? ig : 'promptseen'}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1430), Color(0xFF0C1228), Color(0xFF0F1825)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: HomeScreen._c1.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow orb
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HomeScreen._c2.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Badge icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            HomeScreen._c1.withOpacity(0.35),
                            HomeScreen._c2.withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: HomeScreen._c2.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.diversity_3_rounded,
                        color: HomeScreen._c2,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join Our Community',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Daily drops & exclusive AI prompts',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Telegram + Instagram
                Row(
                  children: [
                    Expanded(
                      child: _SocialBtn(
                        label: 'Telegram',
                        icon: Icons.send_rounded,
                        color: const Color(0xFF229ED9),
                        onTap: () =>
                            screen.openSocialLink(tgDeep, tgWeb),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SocialBtn(
                        label: 'Instagram',
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFFE1306C),
                        onTap: () =>
                            screen.openSocialLink(igDeep, igWeb),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // WhatsApp
                SizedBox(
                  width: double.infinity,
                  child: _SocialBtn(
                    label: 'WhatsApp Channel',
                    icon: Icons.chat_bubble_rounded,
                    color: const Color(0xFF25D366),
                    onTap: () => screen.openExternalUrl(wa),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROMPTS GRID WITH LAZY LOADING
// ═══════════════════════════════════════════════════════════════════
class _PromptsGrid extends StatefulWidget {
  final HomeController ctrl;
  final HomeScreen screen;

  const _PromptsGrid({required this.ctrl, required this.screen});

  @override
  State<_PromptsGrid> createState() => _PromptsGridState();
}

class _PromptsGridState extends State<_PromptsGrid> {
  // Lazy loading variables
  late ScrollController _scrollController;
  int _visibleCount = 10; // Initially load 10 items
  static const int _itemsPerBatch = 10; // Load 10 more items per scroll

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more items when user scrolls near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      setState(() {
        _visibleCount = (_visibleCount + _itemsPerBatch)
            .clamp(0, widget.ctrl.getFilteredPrompts().length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ctrl.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(HomeScreen._c2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading Prompts...',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final prompts = widget.ctrl.getFilteredPrompts();
    final visiblePrompts = prompts.take(_visibleCount).toList();

    if (prompts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeScreen._card,
                  border: Border.all(color: HomeScreen._cardBorder, width: 1),
                ),
                child: Icon(
                  widget.ctrl.showFavoritesOnly
                      ? Icons.favorite_border_rounded
                      : Icons.search_off_rounded,
                  color: const Color(0xFF374151),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.ctrl.showFavoritesOnly
                    ? 'No favourites yet'
                    : 'No prompts found',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.ctrl.showFavoritesOnly
                    ? 'Tap the heart on any prompt to save it'
                    : 'Try a different search or category',
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
            (ctx, i) {
          // Show loading indicator for upcoming items
          if (i >= visiblePrompts.length) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation(HomeScreen._c2),
                ),
              ),
            );
          }

          return _PromptCard(
            prompt: visiblePrompts[i],
            ctrl: widget.ctrl,
            screen: widget.screen,
          );
        },
        childCount: visiblePrompts.length +
            (visiblePrompts.length < prompts.length ? 1 : 0),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROMPT CARD WITH ENHANCED CACHED NETWORK IMAGE
// ═══════════════════════════════════════════════════════════════════
class _PromptCard extends StatelessWidget {
  final dynamic prompt;
  final HomeController ctrl;
  final HomeScreen screen;

  const _PromptCard({
    required this.prompt,
    required this.ctrl,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    final fav = ctrl.isFavorite(prompt.id);

    return GestureDetector(
      onTap: () {
        final AdController adController = Get.find();
        adController.showInterstitialAd();
        Get.toNamed('/detail', arguments: prompt);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: fav
                ? HomeScreen._c1.withOpacity(0.5)
                : HomeScreen._cardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: fav
                  ? HomeScreen._c1.withOpacity(0.25)
                  : Colors.black.withOpacity(0.35),
              blurRadius: fav ? 24 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ── Image with Lazy Loading ──────────────────────────
              Positioned.fill(
                child: _EnhancedCachedNetworkImage(
                  imageUrl: prompt.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // ── Gradient overlay ──────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.82),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Fav button ────────────────────────────────────
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => ctrl.toggleFavorite(prompt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: fav
                          ? HomeScreen._brandGrad
                          : const LinearGradient(
                        colors: [
                          Color(0x66000000),
                          Color(0x44000000),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(fav ? 0.3 : 0.15),
                        width: 1,
                      ),
                      boxShadow: fav
                          ? [
                        BoxShadow(
                          color: HomeScreen._c1.withOpacity(0.5),
                          blurRadius: 12,
                        ),
                      ]
                          : [],
                    ),
                    child: Icon(
                      fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),
              // ── Bottom content ────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prompt.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                prompt.categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFCBD5E1),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => ctrl.sharePrompt(prompt),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.45),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.share_rounded,
                                color: Color(0xFFCBD5E1),
                                size: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ENHANCED CACHED NETWORK IMAGE WIDGET
// ═══════════════════════════════════════════════════════════════════
class _EnhancedCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const _EnhancedCachedNetworkImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      // ✅ Placeholder while loading
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      // ✅ Error widget if loading fails
      errorWidget: (context, url, error) {
        debugPrint('❌ Image Error: $url - $error');
        return _buildErrorPlaceholder();
      },
      // ✅ Fade in animation duration
      fadeInDuration: const Duration(milliseconds: 500),
      fadeOutDuration: const Duration(milliseconds: 300),
      // ✅ Memory cache duration (keep in memory for 7 days)
      cacheManager: null, // Uses default cache manager
    );
  }

  // Placeholder while image loads
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: HomeScreen._card,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation(HomeScreen._c2.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(
                color: HomeScreen._c2.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error placeholder
  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: HomeScreen._card,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: HomeScreen._c1.withOpacity(0.4),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Default placeholder if URL is empty
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: HomeScreen._card,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: HomeScreen._cardBorder,
          size: 40,
        ),
      ),
    );
  }
}