import 'package:dio/dio.dart';

enum CpfRemoteStatus { invalid, firstAccess, hasAccount }

class CpfRemoteSource {
  final Dio _dio;
  
  CpfRemoteSource({Dio? dio}) : _dio = dio ?? Dio();

  Future<CpfRemoteStatus> checkCpf(String cpfMasked) async {
    try {
      // Simula uma chamada de API
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Lógica mockada para teste
      final cpf = cpfMasked.replaceAll(RegExp(r'[^\d]'), '');
      
      // CPFs para primeiro acesso
      final firstAccessCpfs = ['11144477735', '22255588846'];
      
      // CPFs para usuários existentes
      final existingCpfs = ['94691907009', '63254351096'];
      
      if (firstAccessCpfs.contains(cpf)) {
        return CpfRemoteStatus.firstAccess;
      } else if (existingCpfs.contains(cpf)) {
        return CpfRemoteStatus.hasAccount;
      } else {
        return CpfRemoteStatus.invalid;
      }
    } catch (e) {
      // Em caso de erro, retorna inválido
      return CpfRemoteStatus.invalid;
    }
  }
}
