f = r'D:\Projects\moto-di-go\motodi-go-mobile\lib\features\intercity\presentation\pages\publish_pages.dart'
with open(f, 'r', encoding='utf-8') as fh:
    c = fh.read()

# Add import
c = c.replace(
    "import 'package:share_plus/share_plus.dart';",
    "import 'package:share_plus/share_plus.dart';\nimport 'package:motodi_go_mobile/core/utils/extensions.dart';")

repls = [
    # PublishGuardPage
    ("'Publier une annonce',\n            style: TextStyle(", "'Publier une annonce'.tr(context),\n            style: TextStyle("),
    ("'Vous pouvez publier une annonce'", "'Vous pouvez publier une annonce'.tr(context)"),
    ("'Publication non disponible'", "'Publication non disponible'.tr(context)"),
    ("'Renseignez votre trajet, votre v\u00e9hicule et vos disponibilit\u00e9s.'", "'Renseignez votre trajet, votre v\u00e9hicule et vos disponibilit\u00e9s.'.tr(context)"),
    ("'Votre profil ne remplit pas encore les conditions requises.'", "'Votre profil ne remplit pas encore les conditions requises.'.tr(context)"),
    ("'MES V\u00c9HICULES',", "'MES V\u00c9HICULES'.tr(context),"),
    ("label: state.isEligible ? 'Continuer' : 'Retour à l\\'accueil',", "label: state.isEligible ? 'Continuer'.tr(context) : 'Retour à l\\'accueil'.tr(context),"),
    # VehicleTile - places · Validé
    ("'${vehicle.capacity ?? '\u2014'} places \u00b7 ${vehicle.isUsable ? 'Valid\u00e9' : vehicle.validationStatus}',", "Localizations.localeOf(context).languageCode == 'en'\n                    ? '${vehicle.capacity ?? '\u2014'} seats \u00b7 ${vehicle.isUsable ? 'Validated' : vehicle.validationStatus}'\n                    : '${vehicle.capacity ?? '\u2014'} places \u00b7 ${vehicle.isUsable ? 'Valid\u00e9' : vehicle.validationStatus}',"),
    # CreateAnnouncementPage
    ("'Cr\u00e9er une annonce',", "'Cr\u00e9er une annonce'.tr(context),"),
    ("label: 'D\u00e9part',", "label: 'D\u00e9part'.tr(context),"),
    ("label: 'Destination',\n                    child: CityAutocompleteField(", "label: 'Destination'.tr(context),\n                    child: CityAutocompleteField("),
    ("label: 'Pt. Ramassage',", "label: 'Pt. Ramassage'.tr(context),"),
    ("? 'Choisir d\\'abord la ville de d\u00e9part'\n                          : 'Ex : quartier, carrefour\u2026',", "? 'Choisir d\\'abord la ville de d\u00e9part'.tr(context)\n                          : 'Ex : quartier, carrefour\u2026'.tr(context),"),
    ("missingBiasMessage: 'Choisissez d\\'abord une ville de d\u00e9part',", "missingBiasMessage: 'Choisissez d\\'abord une ville de d\u00e9part'.tr(context),"),
    ("label: 'Date',\n                          child: _CreateTapBox(", "label: 'Date'.tr(context),\n                          child: _CreateTapBox(",),
    ("placeholder: 'Choisir',\n                          ),\n                        ),\n                      ),\n                      const SizedBox(width: 12),\n                      Expanded(\n                        child: _CreateLabeledField(\n                          label: 'Heure',", "placeholder: 'Choisir'.tr(context),\n                          ),\n                        ),\n                      ),\n                      const SizedBox(width: 12),\n                      Expanded(\n                        child: _CreateLabeledField(\n                          label: 'Heure'.tr(context),"),
    ("placeholder: 'Choisir',\n                          ),\n                        ),\n                      ),\n                    ],\n                  ),", "placeholder: 'Choisir'.tr(context),\n                          ),\n                        ),\n                      ),\n                    ],\n                  ),"),
    ("label: 'V\u00e9hicule',", "label: 'V\u00e9hicule'.tr(context),"),
    ("'Aucun v\u00e9hicule valid\u00e9 disponible',", "'Aucun v\u00e9hicule valid\u00e9 disponible'.tr(context),"),
    ("label: 'Places totales',", "label: 'Places totales'.tr(context),"),
    ("label: 'Prix / place',", "label: 'Prix / place'.tr(context),"),
    ("label: 'Consignes',", "label: 'Consignes'.tr(context),"),
    ("hint: 'Pr\u00e9sentez-vous 15 min avant le d\u00e9part...',", "hint: 'Pr\u00e9sentez-vous 15 min avant le d\u00e9part...'.tr(context),"),
    ("'Pr\u00e9visualiser',", "'Pr\u00e9visualiser'.tr(context),"),
    # Form errors
    ("_formError = 'Renseignez le d\u00e9part et la destination.'", "_formError = 'Renseignez le d\u00e9part et la destination.'.tr(context)"),
    ("_formError = 'Choisissez une date et une heure de d\u00e9part.'", "_formError = 'Choisissez une date et une heure de d\u00e9part.'.tr(context)"),
    ("_formError = 'Le prix par place est invalide.'", "_formError = 'Le prix par place est invalide.'.tr(context)"),
    ("_formError = 'Le nombre de places est invalide.'", "_formError = 'Le nombre de places est invalide.'.tr(context)"),
    ("_formError = 'S\u00e9lectionnez un v\u00e9hicule.'", "_formError = 'S\u00e9lectionnez un v\u00e9hicule.'.tr(context)"),
    # PreviewPage
    ("\"Aper\u00e7u de l'annonce\",", "\"Aper\u00e7u de l'annonce\".tr(context),"),
    ("label: 'Si\u00e8ges',", "label: 'Si\u00e8ges'.tr(context),"),
    ("label: 'Instructions',", "label: 'Instructions'.tr(context),"),
    ("label: \"Publier l'annonce\",", "label: \"Publier l'annonce\".tr(context),"),
    ("label: 'Modifier',", "label: 'Modifier'.tr(context),"),
    # SuccessPage
    ("'Annonce publi\u00e9e',", "'Annonce publi\u00e9e'.tr(context),"),
    ("'Voir mes annonces',", "'Voir mes annonces'.tr(context),"),
    ("'Partager',", "'Partager'.tr(context),"),
    ("'Cr\u00e9er une autre annonce',", "'Cr\u00e9er une autre annonce'.tr(context),"),
    # MyAnnouncementsPage
    ("'Mes annonces',", "'Mes annonces'.tr(context),"),
    ("label: 'Actives',", "label: 'Actives'.tr(context),"),
    ("label: 'Compl\u00e8tes',", "label: 'Compl\u00e8tes'.tr(context),"),
    ("label: 'Cl\u00f4tur\u00e9es',", "label: 'Cl\u00f4tur\u00e9es'.tr(context),"),
    ("\"Vous n'avez publi\u00e9 aucune annonce\"", "\"Vous n'avez publi\u00e9 aucune annonce\".tr(context)"),
    ("'Aucune annonce dans ce filtre',", "'Aucune annonce dans ce filtre'.tr(context),"),
    # places réservées
    ("'$reserved/${announcement.totalSeats} places r\u00e9serv\u00e9es',", "Localizations.localeOf(context).languageCode == 'en' ? '$reserved/${announcement.totalSeats} seats booked' : '$reserved/${announcement.totalSeats} places r\u00e9serv\u00e9es',"),
    # AnnouncementStatusBadge
    ("('Active', const Color(0xFF16A34A), const Color(0xFFE8F8EE)),", "('Active'.tr(context), const Color(0xFF16A34A), const Color(0xFFE8F8EE)),"),
    ("('Compl\u00e8te', const Color(0xFFB45309), const Color(0xFFFFF7ED)),", "('Compl\u00e8te'.tr(context), const Color(0xFFB45309), const Color(0xFFFFF7ED)),"),
    ("('Cl\u00f4tur\u00e9e', const Color(0xFF6B756E), const Color(0xFFEEEEE6)),", "('Cl\u00f4tur\u00e9e'.tr(context), const Color(0xFF6B756E), const Color(0xFFEEEEE6)),"),
    ("('Annul\u00e9e', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),", "('Annul\u00e9e'.tr(context), const Color(0xFFDC2626), const Color(0xFFFEF2F2)),"),
    ("('Brouillon', const Color(0xFF6B756E), const Color(0xFFEEEEE6)),", "('Brouillon'.tr(context), const Color(0xFF6B756E), const Color(0xFFEEEEE6)),"),
    # IncomingBookingsPage
    ("'R\u00e9servations\\nre\u00e7ues',", "'R\u00e9servations\\nre\u00e7ues'.tr(context),"),
    ("'Impossible de charger les r\u00e9servations.',", "'Impossible de charger les r\u00e9servations.'.tr(context),"),
    ("'Aucune r\u00e9servation',\n                                textAlign: TextAlign.center,\n                                style: _publishText(", "'Aucune r\u00e9servation'.tr(context),\n                                textAlign: TextAlign.center,\n                                style: _publishText(",),
    ("'Les demandes de places pour cette annonce appara\u00eetront ici.',", "'Les demandes de places pour cette annonce appara\u00eetront ici.'.tr(context),"),
    ("'Refus\u00e9e par le transporteur',", "'Refus\u00e9e par le transporteur'.tr(context),"),
    # IncomingBookingCard 'En attente' badge
    ("'En attente',\n                      style: _publishText(\n                        fontSize: 12,\n                        fontWeight: FontWeight.w700,\n                        color: const Color(0xFFB45309),", "'En attente'.tr(context),\n                      style: _publishText(\n                        fontSize: 12,\n                        fontWeight: FontWeight.w700,\n                        color: const Color(0xFFB45309),"),
    # IncomingCompactBadge
    ("'Refus\u00e9e',\n        const Color(0xFFDC2626),", "'Refus\u00e9e'.tr(context),\n        const Color(0xFFDC2626),"),
    ("'Expir\u00e9e',\n        const Color(0xFF6B756E),", "'Expir\u00e9e'.tr(context),\n        const Color(0xFF6B756E),"),
    # places in dropdown
    ("'${vehicle.type} \u00b7 ${vehicle.capacity ?? '\u2014'} places',", "Localizations.localeOf(context).languageCode == 'en' ? '${vehicle.type} \u00b7 ${vehicle.capacity ?? '\u2014'} seats' : '${vehicle.type} \u00b7 ${vehicle.capacity ?? '\u2014'} places',"),
    # subtitle in success page
    ("'Votre trajet ${announcement.route} du ${formatDayMonthLong(announcement.departureDate)} '\n        'est visible par les voyageurs.';", "Localizations.localeOf(context).languageCode == 'en'\n        ? 'Your trip ${announcement.route} on ${formatDayMonthLong(announcement.departureDate)} '\n        'is now visible to travelers.'\n        : 'Votre trajet ${announcement.route} du ${formatDayMonthLong(announcement.departureDate)} '\n        'est visible par les voyageurs.';"),
    # Preview rows labels
    ("label: 'Date',\n                              ),\n                              _PreviewRow(\n                                label: 'Heure',", "label: 'Date'.tr(context),\n                              ),\n                              _PreviewRow(\n                                label: 'Heure'.tr(context),"),
    ("label: 'Pt. Ramassage',", "label: 'Pt. Ramassage'.tr(context),"),
    ("label: 'V\u00e9hicule',\n                                value:", "label: 'V\u00e9hicule'.tr(context),\n                                value:"),
    # seatsRequested in incoming
    ("'${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''} demand\u00e9e${booking.seatsRequested > 1 ? 's' : ''}';", "Localizations.localeOf(context).languageCode == 'en'\n        ? '${booking.seatsRequested} seat${booking.seatsRequested > 1 ? 's' : ''} requested'\n        : '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''} demand\u00e9e${booking.seatsRequested > 1 ? 's' : ''}';"),
]

for old, new in repls:
    if old in c:
        c = c.replace(old, new, 1)
    else:
        print(f"NOT FOUND: {repr(old[:80])}...")

with open(f, 'w', encoding='utf-8') as fh:
    fh.write(c)
print("Done publish_pages.dart")
