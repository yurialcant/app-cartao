import 'package:flutter/material.dart';
import '../../core/config/app_version.dart';
import '../../core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';

/// Tela de splash com efeito de origami que se desdobra
/// 
/// Esta tela mostra:
/// - Efeito de papel dobrado se desdobrando
/// - Nome do aplicativo
/// - Versão atual em destaque
/// - Transição suave para a próxima tela
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ========================================
  // 🎭 ANIMAÇÕES DE ORIGAMI
  // ========================================
  
  late AnimationController _foldController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _versionController;
  
  late Animation<double> _foldAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _versionAnimation;
  
  // ========================================
  // ⏰ CONTROLE DE TEMPO
  // ========================================
  
  static const Duration _splashDuration = Duration(seconds: 4);
  static const Duration _foldDuration = Duration(milliseconds: 1500);
  static const Duration _fadeDuration = Duration(milliseconds: 800);
  static const Duration _scaleDuration = Duration(milliseconds: 600);
  static const Duration _versionDuration = Duration(milliseconds: 1000);
  
  @override
  void initState() {
    super.initState();
    
    // ========================================
    // 🎬 INICIALIZAÇÃO DAS ANIMAÇÕES
    // ========================================
    
    _foldController = AnimationController(
      duration: _foldDuration,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: _scaleDuration,
      vsync: this,
    );
    
    _versionController = AnimationController(
      duration: _versionDuration,
      vsync: this,
    );
    
    // ========================================
    // 🎨 CONFIGURAÇÃO DAS ANIMAÇÕES
    // ========================================
    
    _foldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _foldController,
      curve: Curves.easeInOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _versionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _versionController,
      curve: Curves.easeInOutBack,
    ));
    
    // ========================================
    // 🚀 INICIA SEQUÊNCIA DE ANIMAÇÕES
    // ========================================
    
    _startAnimationSequence();
    
    // ========================================
    // ⏰ AGENDA NAVEGAÇÃO
    // ========================================
    
    _scheduleNavigation();
  }
  
  @override
  void dispose() {
    _foldController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _versionController.dispose();
    super.dispose();
  }
  
  // ========================================
  // 🎬 SEQUÊNCIA DE ANIMAÇÕES
  // ========================================
  
  /// Inicia a sequência de animações em ordem
  void _startAnimationSequence() {
    // 1. Inicia o desdobramento do origami
    _foldController.forward();
    
    // 2. Após o desdobramento, inicia fade in
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
    
    // 3. Após o fade, inicia scale
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
    
    // 4. Por último, anima a versão
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        _versionController.forward();
      }
    });
  }
  
  /// Agenda a navegação para a próxima tela
  void _scheduleNavigation() {
    Future.delayed(_splashDuration, () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }
  
  /// Navega para a próxima tela baseada no estado da aplicação
  void _navigateToNextScreen() {
    // Por enquanto, sempre vai para welcome
    // Em uma implementação real, verificaria se o usuário já está logado
    context.go(RoutePaths.welcome);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================
      // 🎨 FUNDO GRADIENTE
      // ========================================
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Azul escuro
              Color(0xFF3B82F6), // Azul médio
              Color(0xFF60A5FA), // Azul claro
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ========================================
              // 🎭 EFEITO DE ORIGAMI
              // ========================================
              
              _buildOrigamiEffect(),
              
              // ========================================
              // 📱 CONTEÚDO PRINCIPAL
              // ========================================
              
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ========================================
                    // 🏷️ LOGO/NOME DO APP COM ORIGAMI
                    // ========================================
                    
                    _buildAppLogoWithOrigami(),
                    
                    const SizedBox(height: 40),
                    
                    // ========================================
                    // 🔄 INDICADOR DE CARREGAMENTO
                    // ========================================
                    
                    _buildLoadingIndicator(),
                    
                    const SizedBox(height: 24),
                    
                    // ========================================
                    // 📝 TEXTO DE CARREGAMENTO
                    // ========================================
                    
                    _buildLoadingText(),
                  ],
                ),
              ),
              
              // ========================================
              // 📱 INFORMAÇÕES ADICIONAIS
              // ========================================
              
              _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }
  
  // ========================================
  // 🎭 WIDGETS DE ORIGAMI
  // ========================================
  
  /// Efeito de origami em fundo
  Widget _buildOrigamiEffect() {
    return AnimatedBuilder(
      animation: _foldAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: OrigamiPainter(
            foldProgress: _foldAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  /// Logo do app com efeito de origami
  Widget _buildAppLogoWithOrigami() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ícone do app com efeito de origami
                  _buildOrigamiIcon(),
                  
                  const SizedBox(height: 24),
                  
                  // Nome do app
                  Text(
                    AppVersion.appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Ícone com efeito de origami
  Widget _buildOrigamiIcon() {
    return AnimatedBuilder(
      animation: _foldAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _foldAnimation.value * 0.5,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
                          child: Icon(
                Icons.art_track,
                size: 50,
                color: Colors.white,
              ),
          ),
        );
      },
    );
  }
  
  /// Indicador de carregamento
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
  
  /// Texto de carregamento
  Widget _buildLoadingText() {
    return Text(
      'Desdobrando origami...',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.7),
        fontStyle: FontStyle.italic,
      ),
    );
  }
  
  /// Informações adicionais na parte inferior
  Widget _buildAdditionalInfo() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // ========================================
          // 🏷️ VERSÃO EM DESTAQUE
          // ========================================
          
          AnimatedBuilder(
            animation: _versionAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _versionAnimation.value.clamp(0.0, 1.0),
                child: Opacity(
                  opacity: _versionAnimation.value.clamp(0.0, 1.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      AppVersion.displayVersion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // ========================================
          // 🔧 AMBIENTE DE EXECUÇÃO
          // ========================================
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppVersion.environment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // ========================================
          // 📅 DATA DE LANÇAMENTO
          // ========================================
          
          Text(
            'Lançado em ${AppVersion.releaseDate}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// 🎨 PAINTER PARA EFEITO DE ORIGAMI
// ========================================

/// CustomPainter que cria o efeito de origami se desdobrando
class OrigamiPainter extends CustomPainter {
  final double foldProgress;
  
  OrigamiPainter({required this.foldProgress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Cria linhas de dobra que se desdobram
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i;
      final y = size.height * (1 - foldProgress) * (i % 2 == 0 ? 0.3 : 0.7);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Adiciona mais linhas para criar o efeito de origami
    for (int i = 0; i < 6; i++) {
      final y = (size.height / 6) * i;
      final x = size.width * foldProgress * (i % 2 == 0 ? 0.2 : 0.8);
      
      path.lineTo(x, y);
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Adiciona linhas de dobra
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Linhas horizontais
    for (int i = 0; i < 4; i++) {
      final y = (size.height / 4) * i;
      final startX = 0.0;
      final endX = size.width * foldProgress;
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        linePaint,
      );
    }
    
    // Linhas verticais
    for (int i = 0; i < 4; i++) {
      final x = (size.width / 4) * i;
      final startY = 0.0;
      final endY = size.height * foldProgress;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        linePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
