import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/presentation/blocs/discovery_bloc.dart';
import 'package:multi_agent_llm/presentation/widgets/connection_status.dart';

class OllamaDiscoverScreen extends StatefulWidget {
  const OllamaDiscoverScreen({super.key});

  @override
  State<OllamaDiscoverScreen> createState() => _OllamaDiscoverScreenState();
}

class _OllamaDiscoverScreenState extends State<OllamaDiscoverScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '11434');

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(LoadSavedInstances());
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Scan button
              _buildScanSection(context, state),
              const SizedBox(height: 24),

              // Manual connection
              _buildManualSection(context, state),
              const SizedBox(height: 24),

              // Discovered instances
              if (state.instances.isNotEmpty) ...[
                _buildSectionHeader(context, 'Discovered Instances', Icons.lan),
                const SizedBox(height: 8),
                ...state.instances.map((instance) => ConnectionStatusCard(
                  instance: instance,
                  onRemove: () {
                    context.read<DiscoveryBloc>().add(RemoveInstance(instance.ip));
                  },
                  onTest: () {
                    context.read<DiscoveryBloc>().add(TestConnection(
                      ip: instance.ip,
                      port: instance.port,
                    ));
                  },
                )),
              ],

              // Scan progress
              if (state.isScanning) ...[
                const SizedBox(height: 16),
                _buildScanProgress(context, state),
              ],

              // Test result
              if (state.testResult != null) ...[
                const SizedBox(height: 16),
                _buildTestResult(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildScanSection(BuildContext context, DiscoveryState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wifi_find,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Network Scan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Scan your local network for Ollama instances on port 11434',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isScanning ? null : () {
                  context.read<DiscoveryBloc>().add(const StartScan());
                },
                icon: state.isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(state.isScanning ? 'Scanning...' : 'Scan Network'),
              ),
            ),
            if (state.isScanning) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.read<DiscoveryBloc>().add(StopScan()),
                child: const Text('Stop Scan'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualSection(BuildContext context, DiscoveryState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_link,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Manual Connection',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address',
                      hintText: '192.168.1.100',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '11434',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_ipController.text.isNotEmpty) {
                    context.read<DiscoveryBloc>().add(AddManualInstance(
                      ip: _ipController.text,
                      port: int.tryParse(_portController.text) ?? 11434,
                    ));
                    _ipController.clear();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Instance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanProgress(BuildContext context, DiscoveryState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: state.totalToScan > 0
                  ? state.scannedCount / state.totalToScan
                  : null,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scanning: ${state.scannedCount}/${state.totalToScan} IPs',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(BuildContext context, DiscoveryState state) {
    final isSuccess = state.testResult!.contains('success');
    return Card(
      color: isSuccess
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.testResult!,
                style: GoogleFonts.inter(
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
