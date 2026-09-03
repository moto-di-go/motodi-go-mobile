import re

f = r'D:\Projects\moto-di-go\motodi-go-mobile\lib\features\intercity\presentation\pages\booking_pages.dart'
with open(f, 'r', encoding='utf-8') as fh:
    c = fh.read()

replacements = [
    # Detail page dialog
    ("'Validez votre pi\u00e8ce d\u2019identit\u00e9 (CNI) pour souscrire \u00e0 un trajet interurbain.',", "'Validez votre pi\u00e8ce d\u2019identit\u00e9 (CNI) pour souscrire \u00e0 un trajet interurbain.'.tr(context),"),
    ("'Plus tard',\n                    style: _detailText(", "'Plus tard'.tr(context),\n                    style: _detailText("),
    ("'Valider mon profil',\n                    style: _detailText(\n                      fontSize: 15,\n                      fontWeight: FontWeight.w700,\n                      color: const Color(0xFF16A34A),", "'Valider mon profil'.tr(context),\n                    style: _detailText(\n                      fontSize: 15,\n                      fontWeight: FontWeight.w700,\n                      color: const Color(0xFF16A34A),"),
    # agency transporteur
    ("? 'Transporteur v\u00e9rifi\u00e9'\n                                : 'Transporteur',", "? 'Transporteur v\u00e9rifi\u00e9'.tr(context)\n                                : 'Transporteur'.tr(context),"),
    # Detail du trajet
    ("'D\u00e9tail du trajet',", "'D\u00e9tail du trajet'.tr(context),"),
    # Places label in detail
    ("'Places',\n                              textAlign: TextAlign.center,\n                              style: _detailText(\n                                fontSize: 14,\n                                fontWeight: FontWeight.w500,\n                                color: const Color(0xFF15803D),", "'Places'.tr(context),\n                              textAlign: TextAlign.center,\n                              style: _detailText(\n                                fontSize: 14,\n                                fontWeight: FontWeight.w500,\n                                color: const Color(0xFF15803D),"),
    # CONSIGNES
    ("'CONSIGNES',", "'CONSIGNES'.tr(context),"),
    ("_kDefaultInstructionsFr,", "_kDefaultInstructionsFr.tr(context),"),
    # ITINERAIRE
    ("'ITIN\u00c9RAIRE',", "'ITIN\u00c9RAIRE'.tr(context),"),
    # POLITIQUE D'ANNULATION
    ("\"POLITIQUE D'ANNULATION\",", "\"POLITIQUE D'ANNULATION\".tr(context),"),
    ("_kDefaultCancellationPolicyFr,", "_kDefaultCancellationPolicyFr.tr(context),"),
    # CTA labels
    ("? '\u00c9mis par vous'\n        : hasSeats\n        ? (_checkingKyc ? 'V\u00e9rification\u2026' : 'Souscrire')\n        : 'Complet';", "? '\u00c9mis par vous'.tr(context)\n        : hasSeats\n        ? (_checkingKyc ? 'V\u00e9rification\u2026'.tr(context) : 'Souscrire'.tr(context))\n        : 'Complet'.tr(context);"),
    # Subscribe page
    ("'Souscrire',\n                          style: _detailText(fontSize: 28,", "'Souscrire'.tr(context),\n                          style: _detailText(fontSize: 28,"),
    ("'Nombre de places',", "'Nombre de places'.tr(context),"),
    ("'Num\u00e9ro de contact',", "'Num\u00e9ro de contact'.tr(context),"),
    ("'Confirmer la demande',", "'Confirmer la demande'.tr(context),"),
    ("'Num\u00e9ro invalide. Format attendu : +237 6/7/8/9XXXXXXXX'", "'Num\u00e9ro invalide. Format attendu : +237 6/7/8/9XXXXXXXX'.tr(context)"),
    # Booking status page
    ("'Ma r\u00e9servation',", "'Ma r\u00e9servation'.tr(context),"),
    ("'R\u00e9servation introuvable.',", "'R\u00e9servation introuvable.'.tr(context),"),
    ("'Place verrouill\u00e9e',", "'Place verrouill\u00e9e'.tr(context),"),
    # Expire dans / Délai expiré
    ("remaining == Duration.zero ? 'D\u00e9lai de paiement expir\u00e9' : 'Expire dans $label',", "remaining == Duration.zero ? 'D\u00e9lai de paiement expir\u00e9'.tr(context) : '${Localizations.localeOf(context).languageCode == \"en\" ? \"Expires in\" : \"Expire dans\"} $label',"),
    # APERCU DU TRAJET
    ("'APER\u00c7U DU TRAJET',", "'APER\u00c7U DU TRAJET'.tr(context),"),
    # Pay now
    ("'Payer maintenant',", "'Payer maintenant'.tr(context),"),
    # Suivre le trajet
    ("'Suivre le trajet',", "'Suivre le trajet'.tr(context),"),
    # Voir le reçu
    ("'Voir le re\u00e7u',", "'Voir le re\u00e7u'.tr(context),"),
    # Annuler button
    ("child: Text('Annuler', style: _detailText(fontSize: 16,", "child: Text('Annuler'.tr(context), style: _detailText(fontSize: 16,"),
    # Retour à l'accueil
    ("\"Retour \u00e0 l'accueil\",", "\"Retour \u00e0 l'accueil\".tr(context),"),
    # Cancel bottom sheet
    ("'Annuler cette r\u00e9servation ?',", "'Annuler cette r\u00e9servation ?'.tr(context),"),
    ("hintText: \"Motif de l'annulation\",", "hintText: \"Motif de l'annulation\".tr(context),"),
    ("'Annulation demand\u00e9e'", "'Annulation demand\u00e9e'.tr(context)"),
    # Fermer in dialog
    ("'Fermer',\n                              style: _detailText(", "'Fermer'.tr(context),\n                              style: _detailText("),
    # Itinerary messages
    ("'Itin\u00e9raire routier indisponible pour le moment.',\n        )", "'Itin\u00e9raire routier indisponible pour le moment.'.tr(context),\n        )"),
    ("'Itin\u00e9raire routier indisponible pour le moment.')", "'Itin\u00e9raire routier indisponible pour le moment.'.tr(context))"),
    # Validation requise in subscribe dialog
    ("'Validation requise',\n                          style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),\n                        ),\n                        content: Text(\n                          state.subscribeErrorMessage!,", "'Validation requise'.tr(context),\n                          style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),\n                        ),\n                        content: Text(\n                          state.subscribeErrorMessage!,"),
    # Valider mon profil in subscribe dialog
    ("'Valider mon profil',\n                              style: _detailText(\n                                fontSize: 15,\n                                fontWeight: FontWeight.w700,\n                                color: const Color(0xFF16A34A),", "'Valider mon profil'.tr(context),\n                              style: _detailText(\n                                fontSize: 15,\n                                fontWeight: FontWeight.w700,\n                                color: const Color(0xFF16A34A),"),
    # Confirmer / Retour in bottom sheet
    ("label: 'Confirmer',", "label: 'Confirmer'.tr(context),"),
    ("label: 'Retour',\n                onPressed: () => Navigator.of(sheetContext).pop(false),", "label: 'Retour'.tr(context),\n                onPressed: () => Navigator.of(sheetContext).pop(false),"),
    # Demande créée
    ("label: 'Demande cr\u00e9\u00e9e',", "label: 'Demande cr\u00e9\u00e9e'.tr(context),"),
    # Place verrouillée timeline
    ("label: 'Place verrouill\u00e9e',", "label: 'Place verrouill\u00e9e'.tr(context),"),
    ("'Place r\u00e9serv\u00e9e'", "'Place r\u00e9serv\u00e9e'.tr(context)"),
    ("'En attente du transporteur'", "'En attente du transporteur'.tr(context)"),
    # Annulée / Expirée in timeline
    ("label: cancelled ? 'Annul\u00e9e' : 'Expir\u00e9e',", "label: cancelled ? 'Annul\u00e9e'.tr(context) : 'Expir\u00e9e'.tr(context),"),
    # Paiement demandé
    ("label: 'Paiement demand\u00e9',", "label: 'Paiement demand\u00e9'.tr(context),"),
    ("'\u00c0 r\u00e9gler via Wallet avant le d\u00e9part'", "'\u00c0 r\u00e9gler via Wallet avant le d\u00e9part'.tr(context)"),
    ("'Apr\u00e8s confirmation du transporteur'", "'Apr\u00e8s confirmation du transporteur'.tr(context)"),
    # Paiement confirmé
    ("label: 'Paiement confirm\u00e9',", "label: 'Paiement confirm\u00e9'.tr(context),"),
    ("'Wallet \u00b7 pay\u00e9'", "'Wallet \u00b7 pay\u00e9'.tr(context)"),
    # Départ prévu
    ("label: 'D\u00e9part pr\u00e9vu',", "label: 'D\u00e9part pr\u00e9vu'.tr(context),"),
    # Trajet terminé
    ("label: 'Trajet termin\u00e9',", "label: 'Trajet termin\u00e9'.tr(context),"),
    ("'Suivi disponible'", "'Suivi disponible'.tr(context)"),
    # Booking status badge labels (same as search_pages but in _BookingStatusBadge)
]

for old, new in replacements:
    if old in c:
        c = c.replace(old, new, 1)
    else:
        print(f"NOT FOUND: {old[:60]}...")

# Handle remaining seats interpolation in detail page
c = c.replace(
    "'${announcement.remainingSeats} restante${announcement.remainingSeats > 1 ? 's' : ''}',",
    "Localizations.localeOf(context).languageCode == 'en'\n                              ? '${announcement.remainingSeats} remaining'\n                              : '${announcement.remainingSeats} restante${announcement.remainingSeats > 1 ? 's' : ''}',")

# Handle places interpolation in subscribe
c = c.replace(
    "final placesLabel = '$_seats place${_seats > 1 ? 's' : ''}';",
    "final _isEn = Localizations.localeOf(context).languageCode == 'en';\n    final placesLabel = _isEn ? '$_seats seat${_seats > 1 ? 's' : ''}' : '$_seats place${_seats > 1 ? 's' : ''}';")

# Total label
c = c.replace("'Total',\n                                      style: _detailText(fontSize: 18,", "'Total'.tr(context),\n                                      style: _detailText(fontSize: 18,")

# Capacity places in vehicle photo
c = c.replace("'$capacity places',", "Localizations.localeOf(context).languageCode == 'en' ? '$capacity seats' : '$capacity places',")

# Expiry snackbar
c = c.replace("'Votre place expire dans moins d\u2019une minute.'", "'Votre place expire dans moins d\u2019une minute.'.tr(context)")
c = c.replace("'Votre place expire dans ${remaining.inMinutes} min.',", "Localizations.localeOf(context).languageCode == 'en' ? 'Your seat expires in ${remaining.inMinutes} min.' : 'Votre place expire dans ${remaining.inMinutes} min.',")

# BookingStatusBadge in booking_pages
# 'En attente' appears in _BookingStatusBadge
old_badge = """    final (label, fg, bg) = switch (status) {
      IntercityBookingStatus.pending => (
        'En attente',
        const Color(0xFFB45309),
        const Color(0xFFFFF7ED),
      ),
      IntercityBookingStatus.confirmed || IntercityBookingStatus.pendingPayment => (
        'Confirm\u00e9e',
        const Color(0xFF16A34A),
        const Color(0xFFEFFAF3),
      ),
      IntercityBookingStatus.paid => ('Pay\u00e9e', const Color(0xFF16A34A), const Color(0xFFEFFAF3)),
      IntercityBookingStatus.cancelled => (
        'Annul\u00e9e',
        const Color(0xFFDC2626),
        const Color(0xFFFEF2F2),
      ),
      IntercityBookingStatus.expired => (
        'Expir\u00e9e',
        const Color(0xFF6B7280),
        const Color(0xFFF3F4F6),
      ),
      IntercityBookingStatus.unknown => (
        status.label,
        const Color(0xFF6B7280),
        const Color(0xFFF3F4F6),
      ),
    };"""

new_badge = """    final (label, fg, bg) = switch (status) {
      IntercityBookingStatus.pending => (
        'En attente'.tr(context),
        const Color(0xFFB45309),
        const Color(0xFFFFF7ED),
      ),
      IntercityBookingStatus.confirmed || IntercityBookingStatus.pendingPayment => (
        'Confirm\u00e9e'.tr(context),
        const Color(0xFF16A34A),
        const Color(0xFFEFFAF3),
      ),
      IntercityBookingStatus.paid => ('Pay\u00e9e'.tr(context), const Color(0xFF16A34A), const Color(0xFFEFFAF3)),
      IntercityBookingStatus.cancelled => (
        'Annul\u00e9e'.tr(context),
        const Color(0xFFDC2626),
        const Color(0xFFFEF2F2),
      ),
      IntercityBookingStatus.expired => (
        'Expir\u00e9e'.tr(context),
        const Color(0xFF6B7280),
        const Color(0xFFF3F4F6),
      ),
      IntercityBookingStatus.unknown => (
        status.label,
        const Color(0xFF6B7280),
        const Color(0xFFF3F4F6),
      ),
    };"""

c = c.replace(old_badge, new_badge)

# seatsRequested place(s) in BookingTripSummaryCard
c = c.replace(
    "'${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''}',",
    "Localizations.localeOf(context).languageCode == 'en' ? '${booking.seatsRequested} seat${booking.seatsRequested > 1 ? 's' : ''}' : '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''}',")

# seatsRequested in incoming booking card
c = c.replace(
    "'${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''} demand\u00e9e${booking.seatsRequested > 1 ? 's' : ''}';",
    "Localizations.localeOf(context).languageCode == 'en'\n        ? '${booking.seatsRequested} seat${booking.seatsRequested > 1 ? 's' : ''} requested'\n        : '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''} demand\u00e9e${booking.seatsRequested > 1 ? 's' : ''}';")

# Pt. Ramassage label
c = c.replace("'Pt. Ramassage $ptRamassage',", "'Pt. Ramassage $ptRamassage',")  # keep as is since it's a label

with open(f, 'w', encoding='utf-8') as fh:
    fh.write(c)
print("Done booking_pages.dart")
