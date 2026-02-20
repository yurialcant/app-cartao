/// Utilitários para formatação e validação de CPF
class CpfFormatter {
  /// Formata um CPF com pontos e hífen (XXX.XXX.XXX-XX)
  static String format(String cpf) {
    // Remove caracteres não numéricos
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanCpf.length != 11) return cpf;
    
    return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
  }
  
  /// Remove formatação do CPF (apenas números)
  static String unformat(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Verifica se o CPF está formatado
  static bool isFormatted(String cpf) {
    return cpf.contains('.') && cpf.contains('-');
  }
  
  /// Valida se o CPF é válido (algoritmo de validação)
  static bool isValid(String cpf) {
    final cleanCpf = unformat(cpf);
    
    if (cleanCpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCpf)) return false;
    
    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;
    
    if (int.parse(cleanCpf[9]) != digit1) return false;
    
    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;
    
    return int.parse(cleanCpf[10]) == digit2;
  }
}
