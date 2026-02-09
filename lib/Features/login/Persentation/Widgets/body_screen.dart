import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Config/Routes/app_router.dart';
import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Utils/show_message_snack_bar.dart';
import '../Cubit/authentication_cubit.dart';
import 'sections/background_container.dart';
import 'sections/header_section.dart';
import 'sections/login_action_section.dart';
import 'sections/login_layout_spec.dart';
import 'sections/onboarding_section.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen> {
  final List<OnboardingItemData> _items = AppList.onboardingItems;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthState(
    BuildContext context,
    AuthenticationState state,
  ) async {
    final message = state.message;
    if (state.success == null || message == null || message.isEmpty) return;

    final isSuccess = state.success == true;
    await showMessageSnackBar(
      context,
      title: message,
      type: isSuccess ? MessageType.success : MessageType.error,
    );

    if (!context.mounted || !isSuccess) return;
    if (state.requireRoleSelection) {
      AppRouter.pushToChooseRole(context);
    } else {
      AppRouter.pushToMainScreen(context);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    await showMessageSnackBar(
      context,
      title: LoginStrings.loadingGoogleSignIn,
      type: MessageType.loading,
      onLoading: () async =>
          await context.read<AuthenticationCubit>().loginByGoogle(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = LoginLayoutSpec.fromSize(MediaQuery.sizeOf(context));

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: _handleAuthState,
      child: Stack(
        children: [
          const Positioned.fill(child: BackgroundContainer()),
          SafeArea(
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  fillOverscroll: true,
                  hasScrollBody: true,
                  child: SizedBox.expand(
                    child: Padding(
                      padding: layout.outerPadding,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: layout.maxWidth),
                          child: Column(
                            children: [
                              LoginHeaderSection(compact: layout.compact),
                              SizedBox(height: layout.verticalGap),
                              Expanded(
                                child: LoginOnboardingSection(
                                  layout: layout,
                                  items: _items,
                                  currentPage: _currentPage,
                                  pageController: _pageController,
                                  onPageChanged: (index) {
                                    if (!mounted) return;
                                    setState(() => _currentPage = index);
                                  },
                                ),
                              ),
                              SizedBox(height: layout.verticalGap),
                              LoginActionSection(
                                layout: layout,
                                onGoogleSignInPressed: () =>
                                    _signInWithGoogle(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
