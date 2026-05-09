import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promptseen/Admob/Admob_service.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  final pageController = PageController();

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Find Powerful',
      titleHighlight: 'AI Prompts',
      description: 'Discover thousands of trending AI photo prompts for cinematic portraits, anime art, Instagram photos, and creative edits.',
      images: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC0buLWg1cWGPfEoWi_Yjy8Gzr8EIpSXrTY8RWVxg-o7C4CPM0q6t6dru7gnHmrFwDNQXAsZ9mP6kCiOja6Ew895x9tN7U03dj7RzVEkhKXxgdl5lJ3KeykgdL9CPcNOkpqMespQAeccoWb7B9mDCWGuZMvT_F-DZ_rYiU4lESB6Rv0jxWR3foV-hpz9v0w8pVU3Qf0LOQZryQAUa7AkBJC4Yq9mkyikNAogjSGbmVO2NP6wslb3BWBbzprU014oWzdTzyUmUJN8WRv',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAPK_LWfu1qniSxxqUaycatxJK96KAYciKTu5rIfN55zzYqGZxwd7uBoEuwJ56AHdTzE0IeTBAJ3Z3aO_Xa3tRp9MTvMMTAd-gFR7LDrZ_l95imyHU2-xv840NcdOlalCPz5ELUm0P_z7sXXshefWorYbRqpfMU8pG4a-ji8Fuzc8l_TV88jPgRyBsvCrbOBsx--_PzkW-xNiRwSY6FOfqD9Yfz_UnhvrunTAsutpx6_2EYbOb2eOxDN6SEsMLTII5Nza22MSYmrCTT',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCRDuaZ3DmwalEvePdxN3B3UlgdNzgpL-GkkP9hMJxsmelQKRmMURbinZOR2bn8J8MUOiEUMYYvMw9Js4WLE11j9Y1_DN5XzT1yYtTchUXg9ZOU-_I_RNtYxlQUwED679gvvuMxkayCnWdCqRdZkN-II7YIfwvLh2zox2yRScakdmNSzWWzbt9V3mcMd_dUAruOfHw7BM5YlsP7dVAgkcTIk4RZINMY_dhdPu7XhBbH25r292WplG8BoU40CkDbJaTrwDFbygM4-svr',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBIBNtdlTY2mJEVS1onp8X0JwZmpCsbz_3pYaA3GXQyO7EKov-FaPzN6EmeqIUj_ULaAFdLDVn-qyAwxEQY7MOtYIcHLY9llasrkZyRQjube3TFzviuAWph77r5hKsVpuQ6kz-FNaH7TrMAQT26gaPcRsY4K2rlqAcxe6NCzE3pxDJVyUCB_35KKGYssuRqi9N5fepqCyiO2OvqOtwg7If_aGYLCzzsOTR9ZWX-TAhPbbeGJ5oslxzgCY84yWbv-HV4napbeSdzTKb9',
      ],
    ),
    OnboardingPage(
      title: 'Generate',
      titleHighlight: 'Trending',
      description: 'Create viral AI photos easily using powerful prompts. Just copy the prompt and generate stunning images instantly.',
      images: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBKFdaglPRCgeY3TkUv0YB1ook_yyP7g6iKSp696hKN43_2T9ooR9yYFVNXwezccZUpXMsBbQwRAzqLUjwTkAmvufoNpsT4s4OdrXhyOwToAfnfxl8uARfqRNAD6E90HKGwf-qIwJvfJmEqlAwIGQ7TbM6CqsieYAZ2jWPnmShq9bSWuV6lxUg4wRtFXsTLuovz2CweiZ_WRq0Hr0xwnZSfnxlkaw8hV6dCqt8MtGt3I80kvLalTllUtOqbcIJCP5vStkdKrWet8pwK'
      ],
    ),
    OnboardingPage(
      title: 'Generate Trending',
      titleHighlight: 'AI Images',
      description: 'Create viral AI photos easily using powerful prompts. Just copy the prompt and generate stunning images instantly.',
      images: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCUKp_atf__VK7iWK-WVYVFyL_JOWV3qVREdGbolzS96C5IF-D_nFUrGtgCWUzqAhV63u7nLXDv0DJ_3OsnIacidUbkbKPfuQhCYSr-diOi4TEUmH4-lI4LuhZD35LgQp9n0H-QUnJ4RC9h2k7jRdLQ6oswmIfMaoPOGzxWbNXjlazZEOzaBPqwvqLhNeAXiNpZNobIcmE9JNbtPtZ-atmz42TDpLrBvtNcekg-yGesUgPIO52oJg3Jy7rt0Oen1icB-CnhWJ0Nf-xv',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDpG1U4714Ft20CoN3I3IuB073pWmsoA7j2y-hxTofnEnxNpCyQVM5fKKzsGHJ_sUMqpfm-AJi3GduACQwiEFB3nk-nZFWX9httqzE6_FS5asYtgMAlxUutlPeBI5a_Va6SlkRbGIHwkX9e8dxRbVRdxWfgva_f_m6Jji4PogrwZ2K5WYZd-HQwSe3d5uhuMAQpm-HIamiZNyIOUEqkP8KYD6FH5SffX2wZKyIypDNNzVOTItq-DyL0EvnjivFHYuKv-TANPfpbN6na',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAQBRts-dRmyq3A8KdnRO5vNG_SuIKSHProRGYDWWbdF-22C1yOpYA2Gv2pNylvMfCP8zs9duKMFmVxWwv-Om7JyBbs5PAQGOsUmrcDHD_b9EApniEQShD9kJgJbU_Yec7uKFWSc5oa79_dTLQrB6IB9Ubj1vuDH-iNUmm8lHJQmOWBzqmK0da7DMLnVPjM_IpPgkF2buz-JNedV65GMUVzdIzvuEIj7bhHbeVcqmZjhwnZ_NKXOjRnwl8mKk8d9GYk-undf3LiPwqw'
      ],
    ),
  ];

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to home
      final AdController controller = Get.find();
      controller.showInterstitialAd();
      print("ddddddddddddd");
      Get.offNamed('/home');
    }
  }

  void skipOnboarding() {
    Get.offNamed('/home');
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String titleHighlight;
  final String description;
  final List<String> images;

  OnboardingPage({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.images,
  });
}