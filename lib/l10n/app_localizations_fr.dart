// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Falousna';

  @override
  String get appTagline => 'Sachez où va votre argent';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionSkip => 'Passer';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionFilter => 'Filtrer';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionSeeAll => 'Voir tout';

  @override
  String get actionLearnMore => 'En savoir plus';

  @override
  String get actionTryAgain => 'Réessayer';

  @override
  String get actionStartNow => 'Commencer';

  @override
  String get actionGetStarted => 'C\'est parti';

  @override
  String get navHome => 'Accueil';

  @override
  String get navTransactions => 'Opérations';

  @override
  String get navAdd => 'Ajouter';

  @override
  String get navBudget => 'Budget';

  @override
  String get navMore => 'Plus';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'C\'est parti';

  @override
  String onboardingPageOf(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get onb1Title => 'Sachez où va votre argent';

  @override
  String get onb1Body =>
      'Enregistrez vos revenus et dépenses en quelques secondes et voyez clairement où part votre argent chaque mois.';

  @override
  String get onb2Title => 'Un budget adapté à vos revenus';

  @override
  String get onb2Body =>
      'Revenu journalier, variable ou mensuel ? Choisissez votre cycle budgétaire : hebdomadaire, mensuel, ou les deux.';

  @override
  String get onb3Title => 'Vos données restent chez vous';

  @override
  String get onb3Body =>
      'Aucune donnée n\'est envoyée à un serveur sauf si vous le demandez vous-même. L\'application fonctionne entièrement hors ligne.';

  @override
  String get consentTitle => 'Votre vie privée d\'abord';

  @override
  String get consentIntro =>
      'Avant de commencer, lisez ceci attentivement. Nous ne collectons aucune information sans votre consentement.';

  @override
  String get consentPoint1Title => 'Vos données restent sur votre appareil';

  @override
  String get consentPoint1Body =>
      'Toutes vos opérations financières sont enregistrées sur votre téléphone ou ordinateur. Elles n\'en sortent que si vous activez la synchronisation vous-même.';

  @override
  String get consentPoint2Title => 'Nous ne vendons jamais vos données';

  @override
  String get consentPoint2Body =>
      'Pas de publicité, pas de traceurs, aucun partage avec un tiers commercial.';

  @override
  String get consentPoint3Title => 'Vous gardez le contrôle total';

  @override
  String get consentPoint3Body =>
      'Vous pouvez exporter toutes vos données ou les supprimer définitivement à tout moment, depuis l\'application.';

  @override
  String get consentCheckboxLabel =>
      'J\'ai lu et j\'accepte la politique de confidentialité et les conditions d\'utilisation';

  @override
  String get consentAccept => 'J\'accepte et je continue';

  @override
  String get consentDecline => 'Je refuse et je quitte';

  @override
  String get consentReadPrivacy => 'Lire la politique de confidentialité';

  @override
  String get consentReadTerms => 'Lire les conditions d\'utilisation';

  @override
  String get consentMustAccept =>
      'Vous devez accepter la politique et les conditions pour continuer';

  @override
  String get consentDeclineTitle => 'Êtes-vous sûr ?';

  @override
  String get consentDeclineBody =>
      'Sans votre consentement, nous ne pouvons pas faire fonctionner l\'application, car la loi nous interdit de traiter des données sans votre autorisation. Rien ne sera collecté.';

  @override
  String get consentDeclineConfirm => 'Oui, fermer l\'application';

  @override
  String get consentDeclineCancel => 'Non, je vais lire et accepter';

  @override
  String consentVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get consentRecordedNote =>
      'Votre consentement a été enregistré avec date et heure précises. Vous pouvez le consulter dans : Paramètres ← Légal et confidentialité ← Historique de mes consentements.';

  @override
  String get authChooseTitle => 'Comment souhaitez-vous commencer ?';

  @override
  String get authChooseSubtitle =>
      'Vous pouvez utiliser toute l\'application sans compte. Le compte est optionnel — il sert uniquement à sauvegarder vos données dans le cloud et à les utiliser sur plusieurs appareils.';

  @override
  String get authTryWithoutAccount => 'Essayer sans compte';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authLoginWithGoogle => 'Continuer avec Google';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authNoAccountYet => 'Pas encore de compte ?';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get authEmailLabel => 'Adresse e-mail';

  @override
  String get authEmailHint => 'exemple@mail.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => '8 caractères minimum';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authDisplayNameLabel => 'Nom affiché (optionnel)';

  @override
  String get authDisplayNameHint => 'Comment souhaitez-vous être appelé ?';

  @override
  String get authResetPasswordTitle => 'Récupérer le mot de passe';

  @override
  String get authResetPasswordBody =>
      'Saisissez votre e-mail et nous vous enverrons un lien de réinitialisation.';

  @override
  String get authResetPasswordSend => 'Envoyer le lien';

  @override
  String get authGuestBadge => 'Mode sans compte';

  @override
  String get authGuestLimitNote =>
      'Vous utilisez l\'application en local. Vos données sont enregistrées uniquement sur cet appareil — ni sauvegarde ni synchronisation.';

  @override
  String get authUpgradeToAccount =>
      'Créez un compte pour sauvegarder vos données';

  @override
  String get authComingSoonPhase3 =>
      'La création de compte sera disponible après la configuration du serveur (Phase 3)';

  @override
  String get setupTitle => 'Configuration rapide';

  @override
  String get setupSubtitle =>
      'Trois étapes seulement — toutes optionnelles. Vous pourrez les modifier plus tard dans les Paramètres.';

  @override
  String get setupStepLanguage => 'Langue';

  @override
  String get setupStepIncome => 'Type de revenu';

  @override
  String get setupStepCategories => 'Catégories';

  @override
  String get setupLanguageArabic => 'العربية';

  @override
  String get setupLanguageFrench => 'Français';

  @override
  String get setupIncomeDaily => 'Revenu journalier';

  @override
  String get setupIncomeDailyHint =>
      'Je travaille à la journée ou à la mission';

  @override
  String get setupIncomeVariable => 'Revenu variable';

  @override
  String get setupIncomeVariableHint =>
      'Freelance, commerce ou activité indépendante';

  @override
  String get setupIncomeFixed => 'Revenu mensuel fixe';

  @override
  String get setupIncomeFixedHint =>
      'Salaire en fin de mois ou à un jour précis';

  @override
  String get setupIncomeDailyResult =>
      'Nous réglerons votre budget en hebdomadaire — la méthode la plus adaptée au revenu journalier.';

  @override
  String get setupIncomeVariableResult =>
      'Nous réglerons votre budget en hebdomadaire avec une vue mensuelle consolidée.';

  @override
  String get setupIncomeFixedResult =>
      'Nous réglerons votre budget en mensuel. Vous pourrez définir le jour de début de votre mois budgétaire.';

  @override
  String get setupCategoriesTitle =>
      'Choisissez les catégories que vous utilisez';

  @override
  String get setupCategoriesHint =>
      'Nous organiserons l\'écran selon votre choix. Vous pourrez ajouter des catégories personnalisées plus tard.';

  @override
  String get setupFinish => 'Commencer à utiliser Falousna';

  @override
  String get setupSkipAll => 'Tout passer et commencer';

  @override
  String setupStepOf(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get homeGreeting => 'Bienvenue 👋';

  @override
  String get homeEmptyTitle => 'Aucune opération pour l\'instant';

  @override
  String get homeEmptyBody =>
      'Ajoutez votre première dépense ou revenu et commencez à voir où va votre argent.';

  @override
  String get homeEmptyAction => 'Ajouter une opération';

  @override
  String get homeBalance => 'Solde actuel';

  @override
  String get homeIncome => 'Revenus';

  @override
  String get homeExpenses => 'Dépenses';

  @override
  String get homeThisPeriod => 'Cette période';

  @override
  String get homeRecentTransactions => 'Dernières opérations';

  @override
  String homeTrialBanner(String days) {
    return 'Il reste $days d\'essai gratuit';
  }

  @override
  String homeOfflineBanner(int count) {
    return 'Hors ligne — $count opérations en attente de synchronisation';
  }

  @override
  String get placeholderTitle => 'Cet écran est en construction';

  @override
  String placeholderBody(String phase) {
    return 'Cet écran sera construit à la Phase $phase. L\'application est actuellement en phase de fondations : design, traductions, navigation et consentements.';
  }

  @override
  String placeholderPhaseLabel(int phase) {
    return 'Phase $phase';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionAppearance => 'Apparence et langue';

  @override
  String get settingsSectionMoney => 'Argent et périodes';

  @override
  String get settingsSectionData => 'Données et synchronisation';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionLegal => 'Légal et confidentialité';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsTheme => 'Apparence';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Automatique (selon l\'appareil)';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue de l\'appareil';

  @override
  String get settingsCurrency => 'Devise principale';

  @override
  String get settingsExchangeRates => 'Taux de change';

  @override
  String get settingsFiscalAnchor => 'Jour de début du mois budgétaire';

  @override
  String get settingsBudgetMode => 'Cycle budgétaire';

  @override
  String get settingsBudgetModeMonthly => 'Mensuel';

  @override
  String get settingsBudgetModeWeekly => 'Hebdomadaire';

  @override
  String get settingsBudgetModeBoth => 'Les deux';

  @override
  String get settingsSync => 'Synchronisation cloud';

  @override
  String get settingsSyncOff =>
      'Désactivée — vos données restent sur votre appareil';

  @override
  String get settingsSyncOn => 'Activée';

  @override
  String get settingsSyncRequiresConsent =>
      'Nécessite un consentement explicite distinct (transfert de données hors du pays)';

  @override
  String get settingsBackup => 'Sauvegarde locale';

  @override
  String get settingsNotificationsDaily => 'Rappel quotidien d\'enregistrement';

  @override
  String get settingsNotificationsBudget => 'Alertes de dépassement de budget';

  @override
  String get settingsNotificationsDebts => 'Alertes d\'échéance des dettes';

  @override
  String get legalTitle => 'Légal et confidentialité';

  @override
  String get legalPrivacy => 'Politique de confidentialité';

  @override
  String get legalTerms => 'Conditions d\'utilisation';

  @override
  String get legalSubscription =>
      'Conditions d\'abonnement et de remboursement';

  @override
  String get legalDisclaimer => 'Avertissement';

  @override
  String get legalExportData => 'Exporter toutes mes données';

  @override
  String get legalExportDataNote =>
      'Droit d\'accès et droit à la portabilité — nous générons un fichier de tout ce que nous détenons sur vous.';

  @override
  String get legalRectifyData => 'Demander la rectification de mes données';

  @override
  String get legalObjectData => 'S\'opposer au traitement';

  @override
  String get legalDeleteAccount =>
      'Supprimer définitivement mon compte et mes données';

  @override
  String get legalDeleteAccountNote =>
      'Droit à l\'effacement — irréversible une fois exécuté.';

  @override
  String get legalDpoContact => 'E-mail du délégué à la protection des données';

  @override
  String get legalComplaintAnpdp => 'Déposer une plainte auprès de l\'ANPDP';

  @override
  String get legalMyConsents => 'Historique de mes consentements';

  @override
  String get legalComingSoon => 'Ce droit sera activé à la Phase 4';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuild => 'Numéro de build';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutCheckUpdate => 'Vérifier les mises à jour';

  @override
  String get aboutRateApp => 'Noter l\'application';

  @override
  String get errorGenericTitle => 'Une erreur est survenue';

  @override
  String get errorGenericBody =>
      'Nous n\'avons pas pu terminer l\'opération. Vos données sont conservées et rien n\'a été perdu.';

  @override
  String get errorNetworkTitle => 'Aucune connexion';

  @override
  String get errorNetworkBody =>
      'Vérifiez votre connexion Internet puis réessayez. Vous pouvez continuer à utiliser l\'application hors ligne.';

  @override
  String get errorUnknownTitle => 'Erreur inattendue';

  @override
  String get errorUnknownBody =>
      'Quelque chose d\'imprévu s\'est produit. Réessayez, et si cela se répète, contactez le support.';

  @override
  String get errorValidationTitle => 'Vérifiez vos saisies';

  @override
  String get errorPermissionTitle => 'Vous n\'avez pas l\'autorisation';

  @override
  String get errorPermissionBody =>
      'Cet écran est réservé à un rôle précis. Contactez le support si vous pensez qu\'il s\'agit d\'une erreur.';

  @override
  String get errorFeatureLockedTitle => 'Cette fonction est verrouillée';

  @override
  String get errorFeatureLockedBody =>
      'La période d\'essai gratuite est terminée. Choisissez votre formule pour continuer — vos données sont conservées et restent consultables et exportables.';

  @override
  String get errorContactSupport => 'Contacter le support';

  @override
  String get validateEmailRequired => 'L\'adresse e-mail est requise';

  @override
  String get validateEmailInvalid =>
      'Format d\'e-mail incorrect. Exemple : nom@mail.com';

  @override
  String get validateEmailTooLong =>
      'L\'e-mail est trop long (254 caractères maximum)';

  @override
  String get validatePasswordRequired => 'Le mot de passe est requis';

  @override
  String get validatePasswordTooShort =>
      'Mot de passe trop court — 8 caractères minimum';

  @override
  String get validatePasswordNoDigit =>
      'Ajoutez au moins un chiffre au mot de passe';

  @override
  String get validatePasswordTooLong =>
      'Le mot de passe est trop long (128 caractères maximum)';

  @override
  String get validateConfirmMismatch =>
      'Les deux mots de passe ne correspondent pas';

  @override
  String get validateNameTooLong =>
      'Le nom est trop long (40 caractères maximum)';

  @override
  String get validateAmountRequired => 'Saisissez un montant';

  @override
  String get validateAmountZero => 'Le montant doit être supérieur à zéro';

  @override
  String get validateAmountTooLarge =>
      'Montant trop élevé (999 999 999,99 maximum)';

  @override
  String get validateAmountDecimals => 'Deux décimales maximum';

  @override
  String get validatePhoneAlgerian =>
      'Numéro algérien invalide. Il doit commencer par 05, 06 ou 07 (exemple : 0555123456)';

  @override
  String get validateNoteTooLong =>
      'La note est trop longue (500 caractères maximum)';

  @override
  String get stateLoading => 'Chargement…';

  @override
  String get stateSaving => 'Enregistrement…';

  @override
  String get stateEmpty => 'Il n\'y a rien ici pour l\'instant';

  @override
  String get stateOffline =>
      'Vous êtes hors ligne — l\'application fonctionne normalement';

  @override
  String get stateSyncing => 'Synchronisation…';

  @override
  String get stateSyncDone => 'Synchronisation terminée';

  @override
  String get stateNoInternet => 'Pas d\'Internet';

  @override
  String get confirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get confirmDeleteBody =>
      'Cet élément sera supprimé définitivement. Action irréversible.';

  @override
  String get confirmExitTitle => 'Quitter l\'application';

  @override
  String get confirmExitBody => 'Voulez-vous fermer Falousna ?';

  @override
  String countdownNote(int seconds) {
    return 'Le bouton s\'active dans $seconds secondes — pour vérifier votre intention.';
  }

  @override
  String get fieldShowPassword => 'Afficher le mot de passe';

  @override
  String get fieldHidePassword => 'Masquer le mot de passe';

  @override
  String get validateRequired => 'Ce champ est requis';

  @override
  String validateTooLong(int max) {
    return 'Texte trop long ($max caractères maximum)';
  }

  @override
  String get incomeKind => 'Revenu';

  @override
  String get expenseKind => 'Dépense';

  @override
  String get categoryFood => 'Alimentation et courses';

  @override
  String get categoryTransport => 'Transport et déplacements';

  @override
  String get categoryHousing => 'Logement et loyer';

  @override
  String get categoryUtilities => 'Électricité et gaz';

  @override
  String get categoryWater => 'Eau';

  @override
  String get categoryInternet => 'Internet et téléphone';

  @override
  String get categoryHealth => 'Santé et médicaments';

  @override
  String get categoryEducation => 'Éducation et école';

  @override
  String get categoryClothing => 'Vêtements';

  @override
  String get categoryCharity => 'Zakat et aumônes';

  @override
  String get categoryCafe => 'Cafés et boissons';

  @override
  String get categoryGifts => 'Cadeaux et occasions';

  @override
  String get categoryMaintenance => 'Entretien et réparations';

  @override
  String get categorySubscriptions => 'Abonnements';

  @override
  String get categoryDebtRepay => 'Remboursement de dette';

  @override
  String get categoryDebtCollect => 'Récupération de créance';

  @override
  String get categoryLeisure => 'Loisirs et voyages';

  @override
  String get categorySalary => 'Salaire mensuel';

  @override
  String get categoryDailyWage => 'Salaire journalier';

  @override
  String get categoryBonus => 'Prime ou bonus';

  @override
  String get categoryFreelance => 'Travail indépendant';

  @override
  String get categoryTrade => 'Commerce et ventes';

  @override
  String get categoryPension => 'Retraite ou pension';

  @override
  String get categoryFamilyAid => 'Aide familiale';

  @override
  String get categoryOtherIncome => 'Autre revenu';

  @override
  String get categoryOtherExpense => 'Autre dépense';

  @override
  String get txEmptyTitle => 'Aucun mouvement sur cette période';

  @override
  String get txEmptyBody =>
      'Enregistrez votre premier mouvement avec le bouton d\'ajout en bas ; il apparaîtra ici immédiatement.';

  @override
  String get txSearchHint => 'Rechercher un mouvement…';

  @override
  String get txFilterAll => 'Tout';

  @override
  String get txSortLabel => 'Plus récents d\'abord';

  @override
  String get txTotalIncome => 'Total des revenus';

  @override
  String get txTotalExpense => 'Total des dépenses';

  @override
  String get budgetEmptyTitle => 'Aucun budget défini pour l\'instant';

  @override
  String get budgetEmptyBody =>
      'Définissez un plafond de dépenses ; nous vous alertons avant de le dépasser, pas après.';

  @override
  String get budgetEmptyAction => 'Définir mon budget';

  @override
  String get budgetSpent => 'Dépensé';

  @override
  String get budgetRemaining => 'Restant';

  @override
  String get budgetLimitLabel => 'Plafond du budget';

  @override
  String get budgetWeeklySection => 'Budget hebdomadaire';

  @override
  String get budgetMonthlySection => 'Budget mensuel';

  @override
  String get addTitle => 'Nouveau mouvement';

  @override
  String get addKindLabel => 'Type de mouvement';

  @override
  String get addAmountLabel => 'Montant';

  @override
  String get addAmountHint => 'Ex. : 1500';

  @override
  String get addCategoryLabel => 'Catégorie';

  @override
  String get addNoteLabel => 'Note (facultatif)';

  @override
  String get addNoteHint => 'Ex. : courses au marché';

  @override
  String get addDateLabel => 'Date';

  @override
  String get addPhase2Title => 'L\'enregistrement réel démarre à la Phase 2';

  @override
  String get addPhase2Body =>
      'Cet écran est complet : champs, validation et catégories fonctionnent. L\'enregistrement des mouvements dans la base locale arrive à la Phase 2. Rien n\'est sauvegardé pour l\'instant — pour que vous ne croyiez pas à tort que vos données le sont.';

  @override
  String get addFormValid => 'Champs valides — prêts à enregistrer';

  @override
  String get moreSectionTools => 'Outils';

  @override
  String get moreSectionInfo => 'Informations';

  @override
  String get moreSectionAccount => 'Compte';

  @override
  String get moreGoals => 'Objectifs d\'épargne';

  @override
  String get moreDebts => 'Dettes (dues et à récupérer)';

  @override
  String get moreRecurring => 'Mouvements récurrents';

  @override
  String get moreReports => 'Rapports et exports';

  @override
  String get moreSubscription => 'Abonnement et formule';

  @override
  String get settingsBudgetModeHint =>
      'Le cycle suit votre type de revenu : journalier → hebdomadaire, salaire → mensuel.';

  @override
  String get settingsFiscalAnchorHint =>
      'Le jour où commence votre mois budgétaire (de 1 à 28). Utile si votre salaire tombe le 25 par exemple.';

  @override
  String get settingsCurrencyHint =>
      'La devise dans laquelle tous les rapports sont totalisés. Les autres devises sont saisies avec un taux manuel.';

  @override
  String get settingsEraseAll => 'Supprimer toutes les données de cet appareil';

  @override
  String get settingsEraseAllNote =>
      'Efface les consentements, les paramètres et tout le contenu local. Irréversible.';

  @override
  String get settingsEraseConfirmTitle => 'Supprimer toutes les données ?';

  @override
  String get settingsEraseConfirmBody =>
      'Tout sera définitivement effacé de cet appareil et vous reviendrez à l\'écran d\'accueil, comme sur une application neuve.';

  @override
  String get settingsErased => 'Toutes les données ont été supprimées';

  @override
  String get settingsNotificationsNote =>
      'Les notifications fonctionnent localement sans Internet et seront activées à la Phase 5.';

  @override
  String get settingsSyncNote =>
      'La synchronisation est optionnelle, démarre à la Phase 3 et exige un consentement explicite distinct.';

  @override
  String get settingsSaved => 'Paramètre enregistré';

  @override
  String get legalConsentRecorded => 'Consentement enregistré';

  @override
  String get legalConsentVersion => 'Version de la politique';

  @override
  String get legalConsentHash => 'Empreinte du consentement (SHA-256)';

  @override
  String get legalConsentDate => 'Date du consentement';

  @override
  String get legalNoConsentYet =>
      'Aucun consentement enregistré pour l\'instant';

  @override
  String get legalRightsTitle => 'Vos cinq droits';

  @override
  String get legalRightsBody =>
      'Accès · rectification · opposition · effacement · portabilité. Exercez-les depuis l\'application ou en écrivant au délégué à la protection des données ; réponse sous 72 heures maximum.';

  @override
  String get legalCantOpenLink =>
      'Impossible d\'ouvrir le lien. Copiez-le et ouvrez-le dans votre navigateur.';

  @override
  String get legalCopied => 'Copié dans le presse-papiers';

  @override
  String get legalCopyAction => 'Copier';

  @override
  String get legalDataOnDevice => 'Vos données ne sont que sur cet appareil';

  @override
  String get aboutTitle => 'À propos de l\'application';

  @override
  String get aboutAppDescription =>
      'Falousna est un outil de saisie manuelle des revenus, dépenses et budgets. Aucune liaison à un compte bancaire ou postal, aucun paiement ni virement exécuté.';

  @override
  String get aboutNoBrandsNote =>
      'L\'application ne cite aucun établissement bancaire ou institution et ne demande aucun numéro de compte ou de carte.';

  @override
  String get aboutPhaseLabel => 'Phase actuelle : fondations (1 sur 6)';

  @override
  String get aboutDataLocalNote =>
      'Tout ce que vous saisissez reste sur votre appareil';

  @override
  String dayCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get legalDisclaimerBody =>
      'Falousna est un outil de suivi manuel. L\'application :\n• n\'est pas un établissement de paiement et ne dispose d\'aucun agrément bancaire ;\n• n\'exécute aucun paiement, virement ou retrait ;\n• ne se connecte à aucun compte bancaire, postal ou de paiement ;\n• ne fournit aucun conseil en investissement, fiscal ou juridique ;\n• affiche des montants saisis par l\'utilisateur, sans vérification auprès d\'un tiers.\n\nLes chiffres affichés reflètent uniquement ce que vous avez saisi. Vous restez responsable de la gestion de vos fonds et de vos déclarations fiscales.';

  @override
  String get legalSubscriptionBody =>
      'Essai gratuit : sept jours avec toutes les fonctionnalités, sans paiement.\n\nAprès l\'essai, un abonnement est nécessaire pour continuer à saisir des données. La consultation, les rapports, l\'export et la suppression de vos données restent gratuits et accessibles à tout moment (verrouillage souple qui ne retient jamais vos données).\n\nFormules : Individu · Couple · Famille, avec des prix mensuels et annuels affichés dans l\'écran d\'abonnement et modifiables sans mise à jour de l\'application.\n\nActivation : vous choisissez une formule dans l\'application, une demande est envoyée à l\'équipe, puis un code d\'activation vous est remis après paiement. Les modalités de paiement sont communiquées dans la conversation, jamais dans l\'application.\n\nRemboursement : un code non activé est remboursable. Un code activé ne l\'est pas, sauf manquement de notre part.';

  @override
  String get categorySeasonalBadge =>
      'Catégorie saisonnière — usage accru pendant certaines saisons';

  @override
  String get creditDeveloper => 'Développé par Shawqi Builds';

  @override
  String get socialSectionTitle => 'Suivez-nous';

  @override
  String get socialHint =>
      'Nos canaux officiels : nouveautés, conseils pratiques et annonces.';

  @override
  String get channelFacebook => 'Facebook';

  @override
  String get channelInstagram => 'Instagram';

  @override
  String get channelTiktok => 'TikTok';

  @override
  String get channelX => 'X';

  @override
  String get channelYoutube => 'YouTube';

  @override
  String get channelTelegram => 'Telegram';

  @override
  String get channelWhatsapp => 'WhatsApp';

  @override
  String get catMgrTitle => 'Gestion des catégories';

  @override
  String get catMgrAdd => 'Ajouter une catégorie';

  @override
  String get catMgrNameAr => 'Nom en arabe';

  @override
  String get catMgrNameFr => 'Nom en français';

  @override
  String get catMgrIconLabel => 'Icône';

  @override
  String get catMgrSeasonal => 'Catégorie saisonnière (ramadan, rentrée…)';

  @override
  String get catMgrEmpty => 'Aucune catégorie personnalisée';

  @override
  String get catMgrEmptyBody =>
      'Ajoutez votre première catégorie selon vos habitudes';

  @override
  String get catMgrSaved => 'Catégorie enregistrée ✅';

  @override
  String get catMgrArchived => 'Archivée';

  @override
  String get catMgrArchive => 'Archiver';

  @override
  String get catMgrRestore => 'Restaurer';

  @override
  String get catMgrDuplicate => 'Une catégorie porte déjà ce nom';

  @override
  String get txSavedSnack => 'Mouvement enregistré ✅';

  @override
  String get txNoResults => 'Aucun résultat pour votre recherche';

  @override
  String get settingsCatMgr => 'Gérer les catégories personnalisées';

  @override
  String get settingsCatMgrNote =>
      'Ajouter, modifier ou archiver des catégories personnalisées';

  @override
  String get budgetOverallLabel => 'Toutes les dépenses (plafond global)';

  @override
  String get budgetOverallShort => 'Plafond global';

  @override
  String get budgetAddLimit => 'Ajouter un plafond';

  @override
  String get budgetEditLimit => 'Modifier le plafond';

  @override
  String get budgetNewLimit => 'Nouveau plafond';

  @override
  String get budgetPickCategory => 'Catégorie';

  @override
  String get budgetAmountLabel => 'Montant du plafond';

  @override
  String get budgetAmountHint => 'Ex. : 20000';

  @override
  String get budgetAlertPercentLabel => 'M\'avertir à';

  @override
  String get budgetAlertRange =>
      'Le seuil d\'alerte doit être entre 50 % et 100 %';

  @override
  String budgetAlertPercentValue(int percent) {
    return '$percent % du plafond';
  }

  @override
  String get budgetStatusSafe => 'Dans le plafond';

  @override
  String get budgetStatusNear => 'Proche du plafond';

  @override
  String get budgetStatusOver => 'Plafond dépassé';

  @override
  String budgetUsedPercent(int percent) {
    return '$percent %';
  }

  @override
  String get budgetSpentOfLimit => 'Dépensé sur le plafond';

  @override
  String get budgetRemainingLabel => 'Il vous reste';

  @override
  String get budgetOverByLabel => 'Dépassement de';

  @override
  String get budgetExhausted => 'Plafond entièrement consommé — plus de marge';

  @override
  String get budgetFormulaNote =>
      'Calcul : pourcentage = dépensé ÷ plafond × 100. État : « dans le plafond » en dessous du seuil, « proche » au seuil, « dépassé » au-delà de 100 %.';

  @override
  String get budgetSavedSnack => 'Plafond enregistré';

  @override
  String get budgetDeletedSnack => 'Plafond supprimé';

  @override
  String get budgetDeleteTitle => 'Supprimer ce plafond ?';

  @override
  String get budgetDeleteBody =>
      'Seul le plafond est supprimé — vos transactions restent intactes.';

  @override
  String get budgetDeleteAction => 'Supprimer le plafond';

  @override
  String get budgetNotFound => 'Ce plafond n\'existe plus';

  @override
  String get budgetPeriodNote =>
      'Les plafonds sont calculés sur la période affichée ci-dessus.';

  @override
  String get budgetAlertsSection => 'Alertes de plafond';

  @override
  String budgetAlertOverTitle(String category) {
    return 'Plafond « $category » dépassé';
  }

  @override
  String budgetAlertNearTitle(String category) {
    return 'Vous approchez du plafond « $category »';
  }

  @override
  String budgetAlertOverBody(String spent, String limit) {
    return 'Vous avez dépensé $spent sur $limit';
  }

  @override
  String budgetAlertNearBody(String spent, String limit, String remaining) {
    return 'Vous avez dépensé $spent sur $limit — reste $remaining';
  }

  @override
  String budgetAlertMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'et $count autres alertes',
      one: 'et une autre alerte',
      zero: 'et aucune autre alerte',
    );
    return '$_temp0';
  }

  @override
  String get budgetAlertAction => 'Voir les plafonds';

  @override
  String get budgetCategoryMissing => 'Catégorie inconnue';
}
