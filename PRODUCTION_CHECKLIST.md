# SSHA Production Checklist

## 1. Qualité Logicielle
- [ ] Exécuter `bash -n ssha install.sh tests/verify_checksum.sh tests/smoke.sh` sans erreur.
- [ ] Exécuter `shellcheck -S error -x ssha install.sh tests/verify_checksum.sh tests/smoke.sh` sans erreur bloquante.
- [ ] Exécuter `tests/verify_checksum.sh` et vérifier que `ssha.sha256` correspond au binaire.
- [ ] Exécuter `tests/smoke.sh` localement et obtenir `FAIL=0`.
- [ ] Vérifier que la CI GitHub Actions est verte sur `ubuntu-latest` et `macos-latest`.

## 2. Sécurité
- [ ] Vérifier les permissions: `~/.ssha` en `700`, fichiers secrets en `600`.
- [ ] Vérifier que les secrets ne sont jamais affichés en clair dans les logs CI.
- [ ] Vérifier la migration d'un fichier maître legacy (`hash=`) vers le format `verifier=` en environnement de test.
- [ ] Vérifier qu'un secret sans `mac=` est remis au format signé via `ssha -m`.
- [ ] Vérifier la stratégie de sauvegarde/restauration et le rejet d'archives malicieuses.

## 3. Installation / Release
- [ ] Publier une release taggée Git (`vX.Y.Z`) correspondant au hash attendu.
- [ ] Régénérer `ssha.sha256` avec `scripts/update_sha256.sh` pour la version publiée.
- [ ] Vérifier que `install.sh` récupère la release taggée attendue (`SSHA_INSTALL_VERSION`).
- [ ] Publier `ssha`, `ssha.sha256` et `install.sh` dans la release.
- [ ] Tester l'installation sur un hôte Linux et un hôte macOS propres.

## 4. Opérations
- [ ] Tester un scénario de reprise: backup -> suppression config -> restore.
- [ ] Tester la migration (`-m`) avec au moins un vrai cas legacy v1 et un secret incomplet sans `mac=`.
- [ ] Tester au moins un serveur en mode mot de passe et un serveur en mode clé privée.
- [ ] Définir une procédure de rollback (version N-1 et checksum associés).
- [ ] Définir un canal de remontée d'incidents et un SLA interne.

## 5. Critère Go/No-Go
- [ ] Go prod uniquement si toutes les cases ci-dessus sont validées.
