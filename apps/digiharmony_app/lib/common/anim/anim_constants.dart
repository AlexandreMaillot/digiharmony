/// Constantes d'animation centralisées — source unique de vérité.
///
/// Modifier ces valeurs affecte toutes les animations de l'app.
/// Conçu pour des effets subtils sur un public mineur (DEC-003).
library;

import 'package:flutter/animation.dart';

/// Durée d'entrée standard (fadeIn + slideY).
const Duration dureeEntree = Duration(milliseconds: 400);

/// Délai de cascade entre items successifs.
const Duration decalageCascade = Duration(milliseconds: 70);

/// Offset de départ pour le slideY d'entrée (fraction de la hauteur du widget).
/// Valeur faible = mouvement subtil.
const double offsetEntree = 0.06;

/// Durée d'une transition de page douce.
const Duration dureeTransitionPage = Duration(milliseconds: 320);

/// Facteur de réduction au tap (scale).
const double scaleTap = 0.97;

/// Durée de l'animation count-up du compteur animé.
const Duration dureeCompteur = Duration(milliseconds: 600);

/// Courbe standard pour les entrées et transitions.
const Curve curveEntree = Curves.easeOutCubic;
