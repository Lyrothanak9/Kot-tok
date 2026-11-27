import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../providers/profile_provider.dart';

/// Optional model if you want to display additional saved accounts below the main card.
class LinkedAccountItem {
  final String email;
  final String initials;
  final int? badgeCount;
  final VoidCallback? onTap;

  const LinkedAccountItem({
    required this.email,
    required this.initials,
    this.badgeCount,
    this.onTap,
  });
}

class AccountCardDialog extends StatelessWidget {
  final VoidCallback? onManageAccount;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onAddAccount;
  final VoidCallback? onSignedOut;
  final List<LinkedAccountItem> otherAccounts;

  const AccountCardDialog({
    super.key,
    this.onManageAccount,
    this.onEditAvatar,
    this.onAddAccount,
    this.onSignedOut,
    this.otherAccounts = const [],
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onManageAccount,
    VoidCallback? onEditAvatar,
    VoidCallback? onAddAccount,
    VoidCallback? onSignedOut,
    List<LinkedAccountItem> otherAccounts = const [],
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider(
        create: (_) => ProfileProvider(),
        child: AccountCardDialog(
          onManageAccount: onManageAccount,
          onEditAvatar: onEditAvatar,
          onAddAccount: onAddAccount,
          onSignedOut: onSignedOut,
          otherAccounts: otherAccounts,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _handleSignOut(BuildContext context, ProfileProvider provider) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.signOut();
      if (navigator.canPop()) {
        navigator.pop();
      }
      onSignedOut?.call();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final initials = _getInitials(provider.fullName);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Header ("Account User" + Close Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Account User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF3C4043), size: 22),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Main Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Avatar with Camera Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF5F5F5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: provider.avatarUrl != null && provider.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    provider.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _buildInitialsAvatar(initials),
                                  )
                                : _buildInitialsAvatar(initials),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: 0,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                if (onEditAvatar != null) {
                                  Navigator.pop(context);
                                  onEditAvatar!();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: Color(0xFF3C4043),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // User Full Name
                    Text(
                      provider.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202124),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // User Email
                    Text(
                      provider.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Manage Account Pill Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onManageAccount?.call();
                      },
                      child: const Text(
                        'Manage your Account',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Optional Secondary Accounts List
              ...otherAccounts.map(
                (account) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFFCE8E6),
                    child: Text(
                      account.initials,
                      style: const TextStyle(
                        color: Color(0xFFC5221F),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    account.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF202124),
                    ),
                  ),
                  trailing: account.badgeCount != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${account.badgeCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F6368),
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    account.onTap?.call();
                  },
                ),
              ),

              // 4. Add Another Account Row
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Color(0xFF3C4043),
                  size: 22,
                ),
                title: const Text(
                  'Add another account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202124),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddAccount?.call();
                },
              ),
              const SizedBox(height: 12),

              // 5. Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: provider.isSigningOut ? null : () => _handleSignOut(context, provider),
                  icon: provider.isSigningOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout, size: 19),
                  label: Text(
                    provider.isSigningOut ? 'Signing out...' : 'Sign out',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 6. Footer Links
              const Text(
                'Privacy Policy  •  Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5F6368),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
