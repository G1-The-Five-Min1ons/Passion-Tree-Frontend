import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/how_to_use_popup.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class HeartStatus extends StatefulWidget {
    final int count;
    final double size;

    const HeartStatus({
        super.key,
        this.count = 5,
        this.size = 24,
    });

    @override
    State<HeartStatus> createState() => _HeartStatusState();
}

class _HeartStatusState extends State<HeartStatus> {
    int _currentCount = 5;

    @override
    void initState() {
        super.initState();
        _loadHeartCount();
    }

    Future<void> _loadHeartCount() async {
        final heartCount = await getIt<IAuthRepository>().getHeartCount();
        if (mounted) {
            setState(() {
                _currentCount = heartCount;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              ...List.generate(widget.count, (index) {
                final String iconPath = index < _currentCount
                ? 'assets/icons/Pixel_heart.png'
                : 'assets/icons/heart-gray.png';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Image.asset(
                    iconPath,
                    width: widget.size,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                );
              }),
                GestureDetector(
                onTap: () {
                  HowToUsePopup.show(context);
                },
                  child: Transform.translate(
                    offset: const Offset(0, 5),
                    child: Image.asset(
                      'assets/icons/Info.png',
                      width: 36,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,
                    ),
                  ),
                ),
            ],
        );
    }
}