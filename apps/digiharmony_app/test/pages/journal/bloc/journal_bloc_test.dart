import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// AppDatabase de test dont [conseilDuJour] lève toujours une exception,
/// pour vérifier la gestion d'erreur du JournalBloc (JB-9).
class _AppDatabaseConseilKo extends AppDatabase {
  _AppDatabaseConseilKo() : super.forTesting(NativeDatabase.memory());

  @override
  Future<Conseil> conseilDuJour(DateTime jour) {
    throw StateError('Erreur Drift simulée — conseil indisponible');
  }
}

/// Insère une entrée d'humeur dans la base de test.
Future<void> insertEntree(
  AppDatabase db,
  String code,
  DateTime at,
) {
  final jour = DateTime(at.year, at.month, at.day);
  return db
      .into(db.entreesHumeur)
      .insert(
        EntreesHumeurCompanion.insert(
          codeEmotion: code,
          valence: 1,
          creeLe: at,
          jour: jour,
        ),
      );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // Helper : crée un JournalBloc.
  JournalBloc buildBloc() => JournalBloc(database: db);

  group('JournalBloc — démarrage', () {
    // JB-1 : JournalDemarre → chargement puis pret.
    test('JB-1 : JournalDemarre → chargement puis pret', () async {
      final bloc = buildBloc()..add(const JournalDemarre());
      expect(
        await bloc.stream.firstWhere(
          (s) => s.status == JournalStatus.chargement,
        ),
        isNotNull,
      );
      expect(
        await bloc.stream.firstWhere((s) => s.status == JournalStatus.pret),
        isNotNull,
      );
      await bloc.close();
    });

    // JB-2 : sans entrée du jour → pret, humeurDuJour == null, conseil présent.
    test(
      'JB-2 : sans entrée du jour → humeurDuJour == null, conseil présent',
      () async {
        final bloc = buildBloc()..add(const JournalDemarre());
        final pret = await bloc.stream.firstWhere(
          (s) => s.status == JournalStatus.pret,
        );
        expect(pret.humeurDuJour, isNull);
        expect(pret.conseilDuJourCle, isNotNull);
        await bloc.close();
      },
    );

    // JB-3 : avec entrée du jour → humeurDuJour non null.
    test('JB-3 : avec entrée du jour → humeurDuJour peuplé', () async {
      await insertEntree(db, 'happy', DateTime.now());
      final bloc = buildBloc()..add(const JournalDemarre());
      final pret = await bloc.stream.firstWhere(
        (s) => s.status == JournalStatus.pret,
      );
      expect(pret.humeurDuJour, isNotNull);
      expect(pret.humeurDuJour!.codeEmotion, 'happy');
      await bloc.close();
    });
  });

  group('JournalBloc — vue', () {
    // JB-4 : JournalVueChangee → vueActive mise à jour.
    test('JB-4 : JournalVueChangee semaine → vueActive = semaine', () async {
      final bloc = buildBloc()..add(const JournalDemarre());
      await bloc.stream.firstWhere((s) => s.status == JournalStatus.pret);
      bloc.add(const JournalVueChangee(JournalVue.semaine));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.vueActive, JournalVue.semaine);
      await bloc.close();
    });
  });

  group('JournalBloc — navigation mois', () {
    // JB-5 : JournalMoisPrecedent → moisAffiche reculé, peutAvancerMois true.
    test(
      'JB-5 : MoisPrecedent → moisAffiche reculé, peutAvancerMois true',
      () async {
        final bloc = buildBloc()..add(const JournalDemarre());
        await bloc.stream.firstWhere((s) => s.status == JournalStatus.pret);
        final moisAvant = bloc.state.moisAffiche;
        bloc.add(const JournalMoisPrecedent());
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.moisAffiche.isBefore(moisAvant), isTrue);
        expect(bloc.state.peutAvancerMois, isTrue);
        await bloc.close();
      },
    );

    // JB-6 : JournalMoisSuivant au mois courant → no-op.
    test(
      'JB-6 : MoisSuivant au mois courant → no-op (peutAvancerMois false)',
      () async {
        final bloc = buildBloc()..add(const JournalDemarre());
        await bloc.stream.firstWhere((s) => s.status == JournalStatus.pret);
        expect(bloc.state.peutAvancerMois, isFalse);
        final moisAvant = bloc.state.moisAffiche;
        bloc.add(const JournalMoisSuivant());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.moisAffiche, moisAvant);
        await bloc.close();
      },
    );

    // JB-7 : MoisPrecedent puis MoisSuivant → avance + recalcul.
    test('JB-7 : MoisPrecedent puis MoisSuivant → avance + recalcul', () async {
      final bloc = buildBloc()..add(const JournalDemarre());
      await bloc.stream.firstWhere((s) => s.status == JournalStatus.pret);
      final moisCourant = bloc.state.moisAffiche;
      bloc.add(const JournalMoisPrecedent());
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.peutAvancerMois, isTrue);
      bloc.add(const JournalMoisSuivant());
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.moisAffiche, moisCourant);
      expect(bloc.state.peutAvancerMois, isFalse);
      await bloc.close();
    });
  });

  group('JournalBloc — réactivité', () {
    // JB-8 : nouvelle entrée jour courant → state ré-émis avec humeurDuJour.
    test(
      'JB-8 : nouvelle entrée → state ré-émis (humeurDuJour peuplé)',
      () async {
        final bloc = buildBloc()..add(const JournalDemarre());
        final pret = await bloc.stream.firstWhere(
          (s) => s.status == JournalStatus.pret,
        );
        expect(pret.humeurDuJour, isNull);
        await insertEntree(db, 'calm', DateTime.now());
        final avecHumeur = await bloc.stream
            .firstWhere((s) => s.humeurDuJour != null)
            .timeout(const Duration(seconds: 2));
        expect(avecHumeur.humeurDuJour!.codeEmotion, 'calm');
        await bloc.close();
      },
    );
  });

  group('JournalBloc — erreur Drift', () {
    // JB-9 : conseilDuJour throw → status == erreur.
    test(
      'JB-9 : conseilDuJour throw → status == JournalStatus.erreur',
      () async {
        final dbKo = _AppDatabaseConseilKo();
        addTearDown(dbKo.close);
        final bloc = JournalBloc(database: dbKo)..add(const JournalDemarre());
        final erreur = await bloc.stream
            .firstWhere((s) => s.status == JournalStatus.erreur)
            .timeout(const Duration(seconds: 2));
        expect(erreur.status, JournalStatus.erreur);
        await bloc.close();
      },
    );
  });
}
