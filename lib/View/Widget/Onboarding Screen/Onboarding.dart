class OnboardingInfo{
  final String title;
  final String description;
  final String image;

  OnboardingInfo({
    required this.title,
    required this.description,
    required this.image
  });
}

class OnboardingData{
  List<OnboardingInfo> items = [
    OnboardingInfo(
        title: "Health Checking",
        description: "Checking your health remotely regardless of space and time",
        image: "images/health_01.png"
    ),

    OnboardingInfo(
        title: "People Connection",
        description: "Socialize your life with your friends and family",
        image: "images/Network.png"
    ),

    OnboardingInfo(
        title: "Symptom Checking",
        description: "Provide sufficient assessment to detect you symptom",
        image: "images/Patient_02.png"
    ),

  ];
}