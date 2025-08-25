import 'dart:async';
import 'package:brasil_fields/brasil_fields.dart';

/// =======================
/// MOCKS EDITÁVEIS
/// =======================
const Set<String> kMockFirstAccessCpfs = {
  '123.456.789-09', // válidos
  '987.654.321-00',
};

const Set<String> kMockHasAccountCpfs = {
  '946.919.070-09',
  '632.543.510-96',
};

const Duration kMockNetworkDelay = Duration(milliseconds: 450);

enum CpfStatus { invalid, firstAccess, hasAccount }

class CpfCheckResult {
  final CpfStatus status;
  final String cpf;
  const CpfCheckResult({required this.status, required this.cpf});
}

class CpfCheckService {
  Future<CpfCheckResult> checkCpf(String cpfInput) async {
    await Future.delayed(kMockNetworkDelay);

    final onlyDigits = UtilBrasilFields.removeCaracteres(cpfInput);

    if (!CPFValidator.isValid(onlyDigits)) {
      return CpfCheckResult(status: CpfStatus.invalid, cpf: cpfInput);
    }

    final masked = UtilBrasilFields.obterCpf(onlyDigits);

    if (kMockFirstAccessCpfs.contains(masked)) {
      return CpfCheckResult(status: CpfStatus.firstAccess, cpf: masked);
    }

    if (kMockHasAccountCpfs.contains(masked)) {
      return CpfCheckResult(status: CpfStatus.hasAccount, cpf: masked);
    }

    return CpfCheckResult(status: CpfStatus.invalid, cpf: masked);
  }
}
