import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/planta.dart';
import 'data_sync_service.dart';

class PlantaService {
  static List<CategoriaPlantas> _categorias = [];
  static bool _loaded = false;

  static Future<List<CategoriaPlantas>> getCategorias() async {
    if (!_loaded) {
      await _loadData();
    }
    return _categorias;
  }

  static Future<List<Planta>> getAllPlantas() async {
    if (!_loaded) {
      await _loadData();
    }
    
    List<Planta> todasPlantas = [];
    for (var categoria in _categorias) {
      todasPlantas.addAll(categoria.plantas);
    }
    return todasPlantas;
  }

  static Future<List<Planta>> searchPlantas(String query) async {
    if (!_loaded) {
      await _loadData();
    }
    
    List<Planta> todasPlantas = await getAllPlantas();
    return todasPlantas.where((planta) {
      return planta.nome.toLowerCase().contains(query.toLowerCase()) ||
             planta.tipo.toLowerCase().contains(query.toLowerCase()) ||
             planta.cuidados.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static Future<Planta?> getPlantaByName(String nome) async {
    if (!_loaded) {
      await _loadData();
    }
    
    List<Planta> todasPlantas = await getAllPlantas();
    try {
      return todasPlantas.firstWhere((planta) => planta.nome == nome);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _loadData() async {
    try {
      print('🔄 Carregando dados das plantas...');
      
      // Carregar dados do JSON local
      final String jsonString = await rootBundle.loadString('assets/hortalicas.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _categorias = [];
      
      // Mapear as categorias do JSON
      Map<String, String> categoriaNames = {
        'hortalicas': 'Hortaliças Folhosas',
        'legumes_raizes': 'Legumes de Raiz',
        'ervas_temperos': 'Ervas e Temperos',
        'frutiferas': 'Frutíferas',
        'extras': 'Outros'
      };
      
      for (String key in jsonData.keys) {
        if (jsonData[key] is List) {
          String nomeCategoria = categoriaNames[key] ?? key;
          _categorias.add(CategoriaPlantas.fromJson(nomeCategoria, jsonData[key]));
        }
      }
      
      _loaded = true;
      print('✅ Dados das plantas carregados com sucesso! Total: ${_categorias.length} categorias');
      
      // Sincronizar com Firestore em background (não bloquear)
      DataSyncService.syncPlantDataToFirestore().catchError((e) {
        print('⚠️ Erro na sincronização com Firestore: $e');
      });
      
    } catch (e) {
      print('❌ Erro ao carregar dados: $e');
      _loaded = true; // Para evitar tentativas infinitas
    }
  }
}
