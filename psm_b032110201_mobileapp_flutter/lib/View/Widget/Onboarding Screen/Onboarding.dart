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
        title: "Unlimited Questions",
        description: "High qualities questions and quizzes with hundreds of tests",
        image: "images/health_01.png"
    ),

    OnboardingInfo(
        title: "Interesting stories",
        description: "Reading top stories to learn and enhance your knowledge",
        image: "images/Network.png"
    ),

    OnboardingInfo(
        title: "Reading Books",
        description: "Reading new books with top content and excellent stories. "
                      "This is a good thing.",
        image: "images/Patient_02.png"
    ),

  ];
}