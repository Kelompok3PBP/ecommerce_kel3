import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamMember {
  final String name;
  final String nim;
  final String studentClass;
  final String githubAccount;
  final String imageAsset;

  TeamMember({
    required this.name,
    required this.nim,
    required this.studentClass,
    required this.githubAccount,
    required this.imageAsset,
  });
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const double webMaxContainerWidth = 1000;
  static const double webSubtitleSize = 16;

  static final List<TeamMember> members = [
    TeamMember(
      name: "Rayhan Fajri Alfarizqi",
      nim: "24111814050",
      studentClass: "S1 Informatika 2024 C",
      githubAccount: "Rayhanfajri",
      imageAsset: "assets/images/team/jri.jpeg",
    ),
    TeamMember(
      name: "Prima Miftakhul Rahma",
      nim: "24111814005",
      studentClass: "S1 Informatika 2024C",
      githubAccount: "PrimaRahma",
      imageAsset: "assets/images/team/rahma.jpeg",
    ),
    TeamMember(
      name: "Tia Fitrianingsih",
      nim: "24111814082",
      studentClass: "S1 Informatika 2024 C",
      githubAccount: "TiaaaFitria",
      imageAsset: "assets/images/team/tia.jpeg",
    ),
    TeamMember(
      name: "Rayhan Wahyu Satrio Wibowo",
      nim: "24111814046",
      studentClass: "S1 Informatika 2024 C",
      githubAccount: "RayhanWahyu9",
      imageAsset: "assets/images/team/bowo.jpeg",
    ),
    TeamMember(
      name: "Sukma Dwi Pangesti",
      nim: "24111814120",
      studentClass: "S1 Informatika 2024 C",
      githubAccount: "sukmaadp",
      imageAsset: "assets/images/team/sukma.jpeg",
    ),
    TeamMember(
      name: "Wafiq ulil abshor allabibi",
      nim: "24111814064",
      studentClass: "S1 Informatika 2024 C",
      githubAccount: "wafiqulil2603",
      imageAsset: "assets/images/team/wafiq.jpg",
    ),
  ];

  Future<void> _launchGroupGithub() async {
    final Uri url = Uri.parse("https://github.com/Kelompok3PBP");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 600;

    int crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: webMaxContainerWidth),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: isWeb
                    ? 140
                    : 18.h, // Tinggi header saat ditarik
                backgroundColor: theme.colorScheme.surface,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop())
                      context.pop();
                    else
                      context.go('/settings');
                  },
                ),
                // FlexibleSpaceBar memberikan kontrol penuh untuk posisi judul
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true, // <--- WAJIB TRUE AGAR DI TENGAH
                  titlePadding: const EdgeInsets.only(
                    bottom: 16,
                  ), // Jarak teks dari bawah
                  expandedTitleScale: 1.3, // Efek membesar saat ditarik
                  title: Text(
                    "PROFIL TIM PENGEMBANG",
                    style: TextStyle(
                      color: theme.colorScheme.primary, // Warna Merah/Gelap
                      fontWeight: FontWeight.bold,
                      fontSize: isWeb ? 20 : 14.sp, // Ukuran font responsif
                    ),
                  ),
                ),
              ),

              // ========================
              // SUB-HEADER + GITHUB KELOMPOK
              // ========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 24 : 5.w,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Kelompok 3 - S1 Informatika",
                        textAlign: TextAlign.center, // Rata Tengah
                        style: TextStyle(
                          fontSize: isWeb ? webSubtitleSize : 12.sp,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Kenalan dengan orang-orang hebat di balik aplikasi ini.",
                        textAlign: TextAlign.center, // Rata Tengah
                        style: TextStyle(
                          fontSize: isWeb ? 14 : 10.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: isWeb ? 260 : double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: _launchGroupGithub,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isWeb ? 16 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.group),
                          label: const Text(
                            "GitHub Kelompok",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ========================
              // GRID TEAM MEMBER
              // ========================
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 5.w,
                  vertical: 16,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: isWeb ? 0.75 : 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _MemberProfileCard(
                      member: members[index],
                      isWeb: isWeb,
                    ),
                    childCount: members.length,
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 5.h)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberProfileCard extends StatefulWidget {
  final TeamMember member;
  final bool isWeb;

  const _MemberProfileCard({required this.member, required this.isWeb});

  @override
  State<_MemberProfileCard> createState() => _MemberProfileCardState();
}

class _MemberProfileCardState extends State<_MemberProfileCard> {
  bool isHovered = false;

  Future<void> _launchGithub(String username) async {
    final Uri url = Uri.parse("https://github.com/$username");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double avatarSize = widget.isWeb ? 120 : 28.w;
    double nameSize = widget.isWeb ? 20 : 14.sp;
    double classSize = widget.isWeb ? 13 : 10.sp;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: isHovered
            ? (Matrix4.identity()..scale(1.03))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerLowest,
              theme.colorScheme.surfaceContainerLow,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.2),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? theme.colorScheme.primary.withOpacity(0.25)
                  : theme.colorScheme.shadow.withOpacity(0.08),
              blurRadius: isHovered ? 25 : 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isWeb ? 24 : 16),
          child: Column(
            children: [
              // FOTO PROFIL
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(
                        isHovered ? 0.45 : 0.20,
                      ),
                      blurRadius: isHovered ? 25 : 12,
                      spreadRadius: isHovered ? 4 : 2,
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(widget.member.imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // NAMA
              Text(
                widget.member.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 6),

              // KELAS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Text(
                  widget.member.studentClass,
                  style: TextStyle(
                    fontSize: classSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Divider(
                color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                indent: 20,
                endIndent: 20,
              ),

              const SizedBox(height: 12),

              // NIM
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Text(widget.member.nim),
                ],
              ),

              const SizedBox(height: 16),

              // TOMBOL GITHUB
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _launchGithub(widget.member.githubAccount),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.code),
                  label: const Text(
                    "GitHub Profile",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
