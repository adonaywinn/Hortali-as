import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/firestore_models.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== AUTENTICAÇÃO ==========
  
  static Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  static Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Erro ao fazer login anônimo: $e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
    } catch (e) {
      print('Erro ao criar usuário: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ========== USUÁRIOS ==========

  static Future<void> createUsuario(Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .set(usuario.toFirestore());
    } catch (e) {
      print('Erro ao criar usuário: $e');
      throw e;
    }
  }

  static Future<Usuario?> getUsuario(String usuarioId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .get();
      
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  static Future<void> updateUsuario(Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .update(usuario.toFirestore());
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      throw e;
    }
  }

  // ========== PLANTACOES ==========

  static Future<String> createPlantacao(Plantacao plantacao) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('plantacoes')
          .add(plantacao.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar plantação: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getTarefasPorUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tarefas')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataHora', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'usuarioId': data['usuarioId'],
          'plantacaoId': data['plantacaoId'],
          'titulo': data['titulo'],
          'descricao': data['descricao'],
          'dataHora': data['dataHora'],
          'tipo': data['tipo'],
          'concluida': data['concluida'],
          'recorrente': data['recorrente'],
          'prioridade': data['prioridade'],
        };
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar tarefas: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAlertasPorUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection('alertas')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataHora', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'usuarioId': data['usuarioId'],
          'plantacaoId': data['plantacaoId'],
          'titulo': data['titulo'],
          'descricao': data['descricao'],
          'dataHora': data['dataHora'],
          'tipo': data['tipo'],
          'prioridade': data['prioridade'],
          'lido': data['lido'],
        };
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar alertas: $e');
      return [];
    }
  }

  static Future<List<Plantacao>> getPlantacoesByUsuario(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('plantacoes')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataPlantio', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Plantacao.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar plantações: $e');
      return [];
    }
  }

  static Future<Plantacao?> getPlantacao(String plantacaoId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('plantacoes')
          .doc(plantacaoId)
          .get();
      
      if (doc.exists) {
        return Plantacao.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar plantação: $e');
      return null;
    }
  }

  static Future<void> updatePlantacao(Plantacao plantacao) async {
    try {
      await _firestore
          .collection('plantacoes')
          .doc(plantacao.id)
          .update(plantacao.toFirestore());
    } catch (e) {
      print('Erro ao atualizar plantação: $e');
      throw e;
    }
  }

  static Future<void> deletePlantacao(String plantacaoId) async {
    try {
      await _firestore
          .collection('plantacoes')
          .doc(plantacaoId)
          .delete();
    } catch (e) {
      print('Erro ao deletar plantação: $e');
      throw e;
    }
  }

  // ========== TAREFAS ==========

  static Future<String> createTarefa(TarefaFirestore tarefa) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('tarefas')
          .add(tarefa.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar tarefa: $e');
      throw e;
    }
  }

  static Future<List<TarefaFirestore>> getTarefasByUsuario(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tarefas')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataHora')
          .get();
      
      return querySnapshot.docs
          .map((doc) => TarefaFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      return [];
    }
  }

  static Future<List<TarefaFirestore>> getTarefasByPlantacao(String plantacaoId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tarefas')
          .where('plantacaoId', isEqualTo: plantacaoId)
          .orderBy('dataHora')
          .get();
      
      return querySnapshot.docs
          .map((doc) => TarefaFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar tarefas da plantação: $e');
      return [];
    }
  }

  static Future<void> updateTarefa(TarefaFirestore tarefa) async {
    try {
      await _firestore
          .collection('tarefas')
          .doc(tarefa.id)
          .update(tarefa.toFirestore());
    } catch (e) {
      print('Erro ao atualizar tarefa: $e');
      throw e;
    }
  }

  static Future<void> deleteTarefa(String tarefaId) async {
    try {
      await _firestore
          .collection('tarefas')
          .doc(tarefaId)
          .delete();
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
      throw e;
    }
  }

  // ========== ALERTAS ==========

  static Future<String> createAlerta(AlertaFirestore alerta) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('alertas')
          .add(alerta.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar alerta: $e');
      throw e;
    }
  }

  static Future<List<AlertaFirestore>> getAlertasByUsuario(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('alertas')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataHora', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => AlertaFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar alertas: $e');
      return [];
    }
  }

  static Future<void> marcarAlertaComoLido(String alertaId) async {
    try {
      await _firestore
          .collection('alertas')
          .doc(alertaId)
          .update({
        'lido': true,
        'dataLeitura': Timestamp.now(),
      });
    } catch (e) {
      print('Erro ao marcar alerta como lido: $e');
      throw e;
    }
  }

  // ========== CANTEIROS ==========

  static Future<String> createCanteiro(CanteiroFirestore canteiro) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('canteiros')
          .add(canteiro.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar canteiro: $e');
      throw e;
    }
  }

  static Future<List<CanteiroFirestore>> getCanteirosByUsuario(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('canteiros')
          .where('usuarioId', isEqualTo: usuarioId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CanteiroFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar canteiros: $e');
      return [];
    }
  }

  static Future<void> updateCanteiro(CanteiroFirestore canteiro) async {
    try {
      await _firestore
          .collection('canteiros')
          .doc(canteiro.id)
          .update(canteiro.toFirestore());
    } catch (e) {
      print('Erro ao atualizar canteiro: $e');
      throw e;
    }
  }

  // ========== STREAMS ==========

  static Stream<List<Plantacao>> streamPlantacoes(String usuarioId) {
    return _firestore
        .collection('plantacoes')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('dataPlantio', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Plantacao.fromFirestore(doc))
            .toList());
  }

  static Stream<List<TarefaFirestore>> streamTarefas(String usuarioId) {
    return _firestore
        .collection('tarefas')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('dataHora')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TarefaFirestore.fromFirestore(doc))
            .toList());
  }

  static Stream<List<AlertaFirestore>> streamAlertas(String usuarioId) {
    return _firestore
        .collection('alertas')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertaFirestore.fromFirestore(doc))
            .toList());
  }

  // ========== PLANTAS PERSONALIZADAS ==========

  static Future<String> createPlantaPersonalizada({
    required String usuarioId,
    required String categoria,
    required Map<String, dynamic> planta,
  }) async {
    try {
      final docRef = await _firestore
          .collection('plantas_personalizadas')
          .add({
        'usuarioId': usuarioId,
        'categoria': categoria,
        'planta': planta,
        'dataCriacao': FieldValue.serverTimestamp(),
        'ativo': true,
      });
      
      print('✅ Planta personalizada criada: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Erro ao criar planta personalizada: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPlantasPersonalizadas(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection('plantas_personalizadas')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('ativo', isEqualTo: true)
          .orderBy('dataCriacao', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'categoria': data['categoria'],
          'planta': data['planta'],
          'dataCriacao': data['dataCriacao'],
        };
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar plantas personalizadas: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPlantacoesPorUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection('plantacoes')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataPlantio', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'usuarioId': data['usuarioId'],
          'canteiroId': data['canteiroId'],
          'plantaId': data['plantaId'],
          'dataPlantio': data['dataPlantio'],
          'status': data['status'],
          'dadosPlanta': data['dadosPlanta'],
          'fotos': data['fotos'] ?? [],
          'observacoes': data['observacoes'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar plantações: $e');
      return [];
    }
  }


  static Future<List<Map<String, dynamic>>> getCanteirosPorUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection('canteiros')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('dataCriacao', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'usuarioId': data['usuarioId'],
          'nome': data['nome'],
          'tipo': data['tipo'],
          'largura': data['largura'],
          'comprimento': data['comprimento'],
          'observacoes': data['observacoes'],
          'dataCriacao': data['dataCriacao'],
          'status': data['status'],
        };
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar canteiros: $e');
      return [];
    }
  }

}
