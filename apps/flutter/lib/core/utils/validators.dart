/// Utilitários para validação de dados
class Validators {
  /// Valida se uma string não está vazia
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
  
  /// Valida se uma string tem o comprimento mínimo
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }
  
  /// Valida se uma string tem o comprimento máximo
  static bool hasMaxLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }
  
  /// Valida se uma string tem o comprimento exato
  static bool hasExactLength(String? value, int length) {
    return value != null && value.length == length;
  }
  
  /// Valida se uma string contém apenas números
  static bool isNumeric(String? value) {
    return value != null && RegExp(r'^\d+$').hasMatch(value);
  }
  
  /// Valida se uma string é um email válido
  static bool isEmail(String? value) {
    if (value == null) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    return emailRegex.hasMatch(value);
  }
  
  /// Valida se uma string é um telefone válido (formato brasileiro)
  static bool isPhone(String? value) {
    if (value == null) return false;
    
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Telefone deve ter 10 ou 11 dígitos (com DDD)
    return cleanPhone.length >= 10 && cleanPhone.length <= 11;
  }
  
  /// Valida se uma string é um CPF válido
  static bool isCpf(String? value) {
    if (value == null) return false;
    
    final cleanCpf = value.replaceAll(RegExp(r'[^\d]'), '');
    
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
  
  /// Valida se uma senha atende aos requisitos de segurança
  static bool isStrongPassword(String? password) {
    if (password == null) return false;
    
    // Deve ter entre 6 e 8 caracteres
    if (password.length < 6 || password.length > 8) return false;
    
    // Deve ter pelo menos uma letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    
    // Deve ter pelo menos um número
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    
    // Deve ter pelo menos um caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    
    return true;
  }
  
  /// Obtém mensagens de erro para validação de senha
  static List<String> getPasswordErrors(String? password) {
    final errors = <String>[];
    
    if (password == null || password.isEmpty) {
      errors.add('Senha é obrigatória');
      return errors;
    }
    
    if (password.length < 6) {
      errors.add('Senha deve ter pelo menos 6 caracteres');
    }
    
    if (password.length > 8) {
      errors.add('Senha deve ter no máximo 8 caracteres');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Senha deve ter pelo menos uma letra maiúscula');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Senha deve ter pelo menos um número');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Senha deve ter pelo menos um caractere especial');
    }
    
    return errors;
  }
}
