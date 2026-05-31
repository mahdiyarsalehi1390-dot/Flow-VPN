import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../services/vpn_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _AppBar(),
              const Spacer(),
              _StatusIndicator(),
              const SizedBox(height: 48),
              _ConnectButton(),
              const SizedBox(height: 32),
              _SessionInfo(),
              const Spacer(flex: 2),
              _ErrorBanner(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('VPN',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 4)),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VpnProvider>();
    final color = _statusColor(provider.status);
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: provider.isConnected ? 160 : 140,
          height: provider.isConnected ? 160 : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.25), width: 12),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: provider.isConnected ? 100 : 90,
              height: provider.isConnected ? 100 : 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                provider.isConnected ? Icons.shield : Icons.shield_outlined,
                color: color, size: 40,
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 2000.ms,
          color: color.withOpacity(provider.isConnected ? 0.3 : 0),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(provider.statusLabel,
            key: ValueKey(provider.statusLabel),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }

  Color _statusColor(VpnStatus status) => switch (status) {
    VpnStatus.connected     => const Color(0xFF4FFFB0),
    VpnStatus.connecting    => const Color(0xFFFFC947),
    VpnStatus.disconnecting => const Color(0xFFFFC947),
    VpnStatus.error         => const Color(0xFFFF5C5C),
    _                       => const Color(0xFF6B7280),
  };
}

class _ConnectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VpnProvider>();
    final isLoading = provider.status == VpnStatus.connecting ||
        provider.status == VpnStatus.disconnecting;
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => provider.toggleConnection(),
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.isConnected ? const Color(0xFF1F2937) : const Color(0xFF4FFFB0),
          foregroundColor: provider.isConnected ? const Color(0xFFFF5C5C) : const Color(0xFF0D0F14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: provider.isConnected ? const Color(0xFFFF5C5C) : Colors.transparent),
          ),
          disabledBackgroundColor: const Color(0xFF1F2937),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(provider.isConnected ? 'Disconnect' : 'Connect',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VpnProvider>();
    if (!provider.isConnected) return const SizedBox.shrink();
    return Text('Session: ${provider.sessionDurationFormatted}',
      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, letterSpacing: 1.5),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VpnProvider>();
    if (provider.errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C5C).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF5C5C).withOpacity(0.5)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFFF5C5C), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(provider.errorMessage!,
            style: const TextStyle(color: Color(0xFFFF5C5C), fontSize: 13))),
      ]),
    ).animate().fadeIn().slideY(begin: 0.3);
  }
}
