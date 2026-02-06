import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_service_icon.dart';
import '../../services/service_service.dart';

class ServiceListScreen extends StatefulWidget {
  final String? categoryId;
  final String? searchQuery;
  final String? providerId;

  const ServiceListScreen({
    super.key,
    this.categoryId,
    this.searchQuery,
    this.providerId,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      List<ServiceModel> fetched;
      if (widget.providerId != null) {
        fetched = await _serviceService.getProviderServices(widget.providerId!);
      } else if (widget.categoryId != null) {
        fetched = await _serviceService.getServicesByCategory(
          widget.categoryId!,
        );
      } else if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        fetched = await _serviceService.searchServices(widget.searchQuery!);
      } else {
        fetched = await _serviceService.getAllServices();
      }

      if (mounted) {
        setState(() {
          _services = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _services;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          widget.providerId != null
              ? 'My Listings'
              : (widget.searchQuery != null
                    ? 'Search: ${widget.searchQuery}'
                    : 'Premium Services'),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.primaryNavy,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppTheme.primaryNavy,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.premiumGold),
            )
          : results.isEmpty
          ? Center(
              child: Text(
                'No services found',
                style: TextStyle(
                  color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: widget.providerId != null
                      ? _buildManagedServiceCard(results[index])
                      : _buildServiceCardPremium(results[index]),
                );
              },
            ),
    );
  }

  Widget _buildServiceCardPremium(ServiceModel service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/service-details', arguments: service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryNavy, AppTheme.lightNavy],
                  ),
                ),
                child: Center(
                  child: AnimatedServiceIcon(
                    category: service.name.split(' ').first,
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${service.providerName}',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.premiumGold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'LKR ${service.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.premiumGold,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.premiumGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagedServiceCard(ServiceModel service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: service.isActive
              ? Colors.transparent
              : (isDark ? Colors.white10 : Colors.black12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(service.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: service.imageUrl == null || service.imageUrl!.isEmpty
                  ? Center(
                      child: AnimatedServiceIcon(
                        category: service.name.split(' ').first,
                        size: 30,
                      ),
                    )
                  : null,
            ),
            title: Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('LKR ${service.price.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? AppTheme.accentGreen.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.isActive ? 'Published' : 'Hidden',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: service.isActive
                          ? AppTheme.accentGreen
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await Navigator.pushNamed(
                    context,
                    '/edit-service',
                    arguments: service,
                  );
                  if (result == true) {
                    _fetchServices();
                  }
                } else if (value == 'delete') {
                  _confirmDelete(service);
                } else if (value == 'toggle') {
                  _toggleServiceStatus(service);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        service.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(service.isActive ? 'Unpublish' : 'Publish'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _serviceService.deleteService(service.id);
                _fetchServices();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleServiceStatus(ServiceModel service) async {
    try {
      await _serviceService.toggleServiceStatus(service.id, !service.isActive);
      _fetchServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !service.isActive ? 'Service published' : 'Service unpublished',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }
}
