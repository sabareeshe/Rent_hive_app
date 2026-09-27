import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/my_listing.dart';
import '../providers/listings_provider.dart';
import '../widgets/image_picker_widget.dart';

class AddEditListingScreen extends ConsumerStatefulWidget {
  final String? listingId;

  const AddEditListingScreen({super.key, this.listingId});

  @override
  ConsumerState<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends ConsumerState<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceDayController;
  late TextEditingController _priceWeekController;
  late TextEditingController _priceMonthController;
  late TextEditingController _depositController;
  late TextEditingController _qtyController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String _selectedCategory = 'Electronics';
  ItemCondition _selectedCondition = ItemCondition.good;
  DateTime _availableFrom = DateTime.now();
  DateTime _availableTo = DateTime.now().add(const Duration(days: 30));
  List<String> _images = [];

  bool _isLoading = false;
  MyListing? _existingListing;

  final List<String> _categories = [
    'Electronics', 'Furniture', 'Cameras', 'Books', 'Sports',
    'Gaming', 'Vehicles', 'Tools', 'Home Appliances', 'Musical Instruments'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _priceDayController = TextEditingController();
    _priceWeekController = TextEditingController();
    _priceMonthController = TextEditingController();
    _depositController = TextEditingController();
    _qtyController = TextEditingController(text: '1');
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();

    if (widget.listingId != null) {
      _loadExistingListing();
    }
  }

  void _loadExistingListing() {
    // This assumes the listings are already loaded in the provider
    final listings = ref.read(myListingsProvider).value ?? [];
    try {
      _existingListing = listings.firstWhere((l) => l.id == widget.listingId);
      _titleController.text = _existingListing!.title;
      _descController.text = _existingListing!.description;
      _priceDayController.text = _existingListing!.pricePerDay.toString();
      _priceWeekController.text = _existingListing!.pricePerWeek.toString();
      _priceMonthController.text = _existingListing!.pricePerMonth.toString();
      _depositController.text = _existingListing!.securityDeposit.toString();
      _qtyController.text = _existingListing!.quantityAvailable.toString();
      _addressController.text = _existingListing!.pickupAddress;
      _cityController.text = _existingListing!.city;
      _stateController.text = _existingListing!.state;
      _pincodeController.text = _existingListing!.pincode;
      _selectedCategory = _existingListing!.category;
      _selectedCondition = _existingListing!.condition;
      _availableFrom = _existingListing!.availableFrom;
      _availableTo = _existingListing!.availableTo;
      _images = List.from(_existingListing!.images);
    } catch (e) {
      // Listing not found
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceDayController.dispose();
    _priceWeekController.dispose();
    _priceMonthController.dispose();
    _depositController.dispose();
    _qtyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _availableFrom, end: _availableTo),
    );
    if (picked != null) {
      setState(() {
        _availableFrom = picked.start;
        _availableTo = picked.end;
      });
    }
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final listing = MyListing(
      id: _existingListing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text,
      category: _selectedCategory,
      condition: _selectedCondition,
      pricePerDay: double.parse(_priceDayController.text),
      pricePerWeek: double.parse(_priceWeekController.text),
      pricePerMonth: double.parse(_priceMonthController.text),
      securityDeposit: double.parse(_depositController.text),
      quantityAvailable: int.parse(_qtyController.text),
      pickupAddress: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      availableFrom: _availableFrom,
      availableTo: _availableTo,
      images: _images,
      status: _existingListing?.status ?? ListingStatus.available,
      totalViews: _existingListing?.totalViews ?? 0,
      totalBookings: _existingListing?.totalBookings ?? 0,
    );

    if (_existingListing != null) {
      await ref.read(myListingsProvider.notifier).updateListing(listing);
    } else {
      await ref.read(myListingsProvider.notifier).addListing(listing);
    }

    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_existingListing != null ? 'Listing updated successfully!' : 'Listing added successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingListing != null ? 'Edit Listing' : 'Add Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePickerWidget(
                initialImages: _images,
                onImagesChanged: (images) {
                  setState(() {
                    _images = images;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Basic Information'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Item Title', hintText: 'e.g. Sony A7III Camera'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe your item...'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value.length < 20) return 'Description must be at least 20 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ItemCondition>(
                initialValue: _selectedCondition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: ItemCondition.values.map((c) {
                  final text = c.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim();
                  return DropdownMenuItem(value: c, child: Text(text[0].toUpperCase() + text.substring(1)));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCondition = val!),
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Pricing & Inventory'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price / Day', prefixText: '\$'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceWeekController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price / Week', prefixText: '\$'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceMonthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price / Month', prefixText: '\$'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Security Deposit', prefixText: '\$'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity Available'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Availability'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Availability Dates'),
                subtitle: Text('${_availableFrom.toLocal().toString().split(' ')[0]} - ${_availableTo.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.date_range),
                onTap: () => _selectDateRange(context),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Location'),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Pickup Address'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode/ZIP'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveListing,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(_existingListing != null ? 'Update Listing' : 'Publish Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
