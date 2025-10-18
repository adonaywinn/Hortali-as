import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/planta.dart';

class DataSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _isDataSynced = false;

  /// Sincroniza os dados do hortalicas.json com o Firestore
  static Future<void> syncPlantDataToFirestore() async {
    if (_isDataSynced) return;

    try {
      // Carregar dados do JSON
      final String jsonString = await rootBundle.loadString('assets/hortalicas.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Sincronizar cada categoria
      for (String categoria in jsonData.keys) {
        final List<dynamic> plantas = jsonData[categoria];
        
        for (var plantaData in plantas) {
          final Planta planta = Planta.fromJson(plantaData);
          
          // Verificar se a planta já existe
          final docRef = _firestore
              .collection('plantas')
              .where('nome', isEqualTo: planta.nome)
              .where('categoria', isEqualTo: categoria);
          
          final querySnapshot = await docRef.get();
          
          if (querySnapshot.docs.isEmpty) {
            // Adicionar planta ao Firestore
            await _firestore.collection('plantas').add({
              'nome': planta.nome,
              'tipo': planta.tipo,
              'categoria': categoria,
              'luz': planta.luz,
              'rega': planta.rega,
              'temperatura': planta.temperatura,
              'soloIdeal': planta.soloIdeal,
              'espacamento': planta.espacamento,
              'germinacao': planta.germinacao,
              'colheita': planta.colheita,
              'cuidados': planta.cuidados,
              'observacao': planta.observacao,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      _isDataSynced = true;
      print('✅ Dados das plantas sincronizados com sucesso!');
    } catch (e) {
      print('❌ Erro ao sincronizar dados: $e');
    }
  }

  /// Busca todas as plantas do Firestore
  static Future<List<Planta>> getAllPlantsFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('plantas').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Planta(
          nome: data['nome'] ?? '',
          tipo: data['tipo'] ?? '',
          luz: data['luz'] ?? '',
          rega: data['rega'] ?? '',
          temperatura: data['temperatura'] ?? '',
          soloIdeal: data['soloIdeal'] ?? '',
          espacamento: data['espacamento'] ?? '',
          germinacao: data['germinacao'] ?? '',
          colheita: data['colheita'] ?? '',
          cuidados: data['cuidados'] ?? '',
          observacao: data['observacao'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar plantas do Firestore: $e');
      return [];
    }
  }

  /// Busca plantas por categoria
  static Future<List<Planta>> getPlantsByCategory(String categoria) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('plantas')
          .where('categoria', isEqualTo: categoria)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Planta(
          nome: data['nome'] ?? '',
          tipo: data['tipo'] ?? '',
          luz: data['luz'] ?? '',
          rega: data['rega'] ?? '',
          temperatura: data['temperatura'] ?? '',
          soloIdeal: data['soloIdeal'] ?? '',
          espacamento: data['espacamento'] ?? '',
          germinacao: data['germinacao'] ?? '',
          colheita: data['colheita'] ?? '',
          cuidados: data['cuidados'] ?? '',
          observacao: data['observacao'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar plantas por categoria: $e');
      return [];
    }
  }

  /// Busca plantas por nome (busca parcial)
  static Future<List<Planta>> searchPlants(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('plantas')
          .where('nome', isGreaterThanOrEqualTo: query)
          .where('nome', isLessThan: query + 'z')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Planta(
          nome: data['nome'] ?? '',
          tipo: data['tipo'] ?? '',
          luz: data['luz'] ?? '',
          rega: data['rega'] ?? '',
          temperatura: data['temperatura'] ?? '',
          soloIdeal: data['soloIdeal'] ?? '',
          espacamento: data['espacamento'] ?? '',
          germinacao: data['germinacao'] ?? '',
          colheita: data['colheita'] ?? '',
          cuidados: data['cuidados'] ?? '',
          observacao: data['observacao'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar plantas: $e');
      return [];
    }
  }

  /// Verifica se os dados já foram sincronizados
  static Future<bool> isDataSynced() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('plantas')
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Força a sincronização dos dados
  static Future<void> forceSync() async {
    _isDataSynced = false;
    await syncPlantDataToFirestore();
  }
}
