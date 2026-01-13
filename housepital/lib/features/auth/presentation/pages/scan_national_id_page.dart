import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/custom_popup.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';

class ScanNationalIDPage extends StatefulWidget {
  final bool isFrontSide;
  final String? frontImageBase64; // Pass front image when scanning back

  const ScanNationalIDPage({
    super.key,
    this.isFrontSide = true,
    this.frontImageBase64,
  });

  @override
  State<ScanNationalIDPage> createState() => _ScanNationalIDPageState();
}

class _ScanNationalIDPageState extends State<ScanNationalIDPage>
    with TickerProviderStateMixin {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  bool _isUploading = false;

  // Repository
  late final ProfileRepositoryImpl _profileRepository;

  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _scanLineController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initRepository();
    _initAnimations();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initRepository() {
    final apiService = ApiService();
    final remoteDataSource = ProfileRemoteDataSourceImpl(
      apiService: apiService,
    );
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Future<String> _imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _isProcessing = true;
        });

        // Process the image
        await _processAndProceed();
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.error(context, 'Failed to open camera');
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _isProcessing = true;
        });

        // Process the image
        await _processAndProceed();
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.error(context, 'Failed to open gallery');
      }
    }
  }

  Future<void> _processAndProceed() async {
    if (_imageFile == null) return;

    try {
      // Convert image to base64
      final base64Image = await _imageToBase64(_imageFile!);

      // If this is the front side, proceed to back side with the image data
      if (widget.isFrontSide) {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          setState(() => _isProcessing = false);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      ScanNationalIDPage(
                        isFrontSide: false,
                        frontImageBase64: base64Image,
                      ),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      } else {
        // This is the back side - upload both images to server
        setState(() {
          _isProcessing = false;
          _isUploading = true;
        });

        try {
          // Upload front image
          await _profileRepository.uploadIdDocument(
            side: 'front',
            imageBase64: widget.frontImageBase64!,
          );

          // Upload back image
          await _profileRepository.uploadIdDocument(
            side: 'back',
            imageBase64: base64Image,
          );

          if (mounted) {
            setState(() => _isUploading = false);
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.verifyingIdentity,
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploading = false);
            // Still proceed but show warning
            CustomPopup.warning(
              context,
              'Could not save ID images. You can upload them later.',
            );
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.verifyingIdentity,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isUploading = false;
        });
        CustomPopup.error(context, 'Failed to process image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(size),

          // Main Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      children: [
                        // App Bar
                        _buildAppBar(),

                        // Progress Indicator
                        _buildProgressIndicator(),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),

                                // Header
                                _buildHeader(),

                                const SizedBox(height: 32),

                                // ID Card Frame
                                _buildIDCardFrame(),

                                const SizedBox(height: 32),

                                // Instructions
                                _buildInstructions(),

                                const SizedBox(height: 32),

                                // Buttons
                                _buildButtons(),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Processing Overlay
          if (_isProcessing) _buildProcessingOverlay(),

          // Uploading Overlay
          if (_isUploading) _buildUploadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top gradient
            Container(
              height: size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary500,
                    AppColors.primary400,
                    AppColors.primary300.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Floating icons
            ..._buildFloatingIcons(size),

            // Bottom curve - positioned below the progress indicator
            Positioned(
              top: size.height * 0.22,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.78,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingIcons(Size size) {
    final icons = [
      Icons.credit_card_rounded,
      Icons.badge_rounded,
      Icons.qr_code_scanner_rounded,
      Icons.verified_user_rounded,
      Icons.fingerprint_rounded,
    ];

    return List.generate(icons.length, (index) {
      final progress = (_floatingController.value + index * 0.2) % 1.0;
      final x = math.sin(progress * math.pi * 2 + index) * 30;
      final y = math.cos(progress * math.pi * 2 + index) * 20;

      return Positioned(
        top: 80 + index * 25.0 + y,
        left: (size.width / (icons.length + 1)) * (index + 1) - 15 + x,
        child: Opacity(
          opacity: 0.15,
          child: Icon(
            icons[index],
            size: 30 + (index % 3) * 10.0,
            color: Colors.white,
          ),
        ),
      );
    });
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'Identity Verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Placeholder for balance
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepDot(1, true, 'Info'),
              _buildStepLine(true),
              _buildStepDot(2, true, 'Medical'),
              _buildStepLine(true),
              _buildStepDot(3, true, 'ID'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, bool isActive, String label) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale =
                isActive && step == 3
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child:
                      step < 3
                          ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary500,
                            size: 20,
                          )
                          : Text(
                            '$step',
                            style: TextStyle(
                              color:
                                  isActive
                                      ? AppColors.primary500
                                      : Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isFrontSide
                    ? Icons.credit_card_rounded
                    : Icons.flip_rounded,
                color: AppColors.primary500,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isFrontSide ? 'Scan Front Side' : 'Scan Back Side',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Step ${widget.isFrontSide ? "1" : "2"} of 2',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Progress bar for front/back
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Front side indicator
              Expanded(
                child: _buildSideIndicator(
                  'Front',
                  Icons.credit_card_rounded,
                  true,
                  !widget.isFrontSide,
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),

              // Back side indicator
              Expanded(
                child: _buildSideIndicator(
                  'Back',
                  Icons.flip_rounded,
                  !widget.isFrontSide,
                  false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideIndicator(
    String label,
    IconData icon,
    bool isActive,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color:
            isCompleted
                ? AppColors.success500.withValues(alpha: 0.1)
                : isActive
                ? AppColors.primary500.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCompleted
                  ? AppColors.success500
                  : isActive
                  ? AppColors.primary500
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCompleted)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success500,
              size: 20,
            )
          else
            Icon(
              icon,
              color: isActive ? AppColors.primary500 : Colors.grey.shade400,
              size: 20,
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
              color:
                  isCompleted
                      ? AppColors.success700
                      : isActive
                      ? AppColors.primary700
                      : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIDCardFrame() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final borderColor =
            _imageFile != null
                ? AppColors.success500
                : Color.lerp(
                  AppColors.primary500,
                  AppColors.primary300,
                  _pulseController.value,
                )!;

        return Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              children: [
                // Image or placeholder
                if (_imageFile != null)
                  Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated icon
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.1),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.isFrontSide
                                      ? Icons.credit_card_rounded
                                      : Icons.flip_rounded,
                                  size: 48,
                                  color: AppColors.primary500,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        Text(
                          widget.isFrontSide
                              ? 'Position Front Side of ID'
                              : 'Position Back Side of ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Keep the card within the frame',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Corner markers
                ..._buildCornerMarkers(),

                // Scan line animation
                if (_imageFile == null)
                  AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanLineController.value * 200,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary500.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerMarkers() {
    const cornerSize = 30.0;
    const borderWidth = 4.0;
    const color = AppColors.primary500;

    return [
      // Top left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: borderWidth),
              left: BorderSide(color: color, width: borderWidth),
            ),
          ),
        ),
      ),
      // Top right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: borderWidth),
              right: BorderSide(color: color, width: borderWidth),
            ),
          ),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: borderWidth),
              left: BorderSide(color: color, width: borderWidth),
            ),
          ),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: borderWidth),
              right: BorderSide(color: color, width: borderWidth),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildInstructions() {
    final instructions = [
      {
        'icon': Icons.light_mode_rounded,
        'text': 'Ensure good lighting',
        'color': AppColors.warning500,
      },
      {
        'icon': Icons.straighten_rounded,
        'text': 'Keep ID flat and aligned',
        'color': AppColors.info500,
      },
      {
        'icon': Icons.blur_off_rounded,
        'text': 'Avoid blur and reflections',
        'color': AppColors.error500,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips for best results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...instructions.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item['text'] as String,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Take Photo Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _takePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary500.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_rounded, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Take Photo',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Upload from Gallery Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _uploadFromGallery,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary500,
              side: const BorderSide(color: AppColors.primary500, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library_rounded, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Upload from Gallery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated processing indicator
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing Image...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upload icon with animation
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.success500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.success500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Uploading Documents...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Securely saving your ID',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'End-to-end encrypted',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
