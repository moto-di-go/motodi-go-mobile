import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/auth/data/models/auth_models.dart';
import 'package:motodi_go_mobile/features/profiles/data/models/profile_model.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

void main() {
  group('ApiErrorModel', () {
    test('parses structured API errors', () {
      final error = ApiErrorModel.fromJson({
        'errorCode': 'OTP_INVALID',
        'message': 'Invalid code',
        'correlationId': 'corr-1',
        'timestamp': '2026-07-21T10:00:00.000Z',
      });

      expect(error.errorCode, 'OTP_INVALID');
      expect(error.message, 'Invalid code');
      expect(error.correlationId, 'corr-1');
      expect(error.timestamp, DateTime.parse('2026-07-21T10:00:00.000Z'));
    });

    test('uses safe defaults for partial API errors', () {
      final error = ApiErrorModel.fromJson({});

      expect(error.errorCode, 'UNKNOWN');
      expect(error.message, isNotEmpty);
      expect(error.timestamp, isNull);
    });
  });

  group('AuthSessionModel', () {
    test('parses token response and nested profile summaries', () {
      final model = AuthSessionModel.fromJson({
        'tokenType': 'Bearer',
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'accessTokenExpiresAt': '2026-07-21T11:00:00.000Z',
        'refreshTokenExpiresAt': '2026-08-21T11:00:00.000Z',
        'sessionId': 'session-1',
        'userId': 'user-1',
        'phoneNumber': '+237678901234',
        'roles': ['PASSENGER', 'AGENCY', 'UNKNOWN_ROLE'],
        'profiles': [
          {'id': 'profile-1', 'type': 'PASSENGER', 'validationStatus': 'VALIDATED', 'active': true},
        ],
        'activeProfileId': 'profile-1',
        'activeProfileType': 'PASSENGER',
        'permissions': ['rides:create'],
      });

      final entity = model.toEntity();

      expect(entity.accessToken, 'access');
      expect(entity.roles, [ProfileType.passenger, ProfileType.agency]);
      expect(entity.profiles.single.type, ProfileType.passenger);
      expect(entity.activeProfileType, ProfileType.passenger);
      expect(entity.permissions, ['rides:create']);
    });
  });

  group('ProfileModel and ProfilePayload', () {
    test('parses mobile and agency profile types while marking agency as hidden for mobile', () {
      final profile = ProfileModel.fromJson({
        'id': 'agency-1',
        'userId': 'user-1',
        'type': 'AGENCY',
        'validationStatus': 'PENDING',
        'displayName': 'Agence',
        'active': false,
        'allowedActions': <String>[],
        'agency': {'legalName': 'Agence Centrale'},
      }).toEntity();

      expect(profile.type, ProfileType.agency);
      expect(profile.validationStatus, ValidationStatus.pending);
      expect(profile.canBeShownInMobile, isFalse);
    });

    test('builds passenger, mototaxi and transporter payloads aligned with the API', () {
      final passenger = ProfilePayload.fromInput(
        const ProfileInput(
          type: ProfileType.passenger,
          displayName: 'Passager',
          preferredLanguage: 'fr',
          emergencyContact: '+237699001122',
        ),
      ).toCreateJson();
      final mototaxi = ProfilePayload.fromInput(
        const ProfileInput(
          type: ProfileType.mototaxi,
          displayName: 'Ibrahim M.',
          operatingZone: 'Bastos, Yaounde',
          licenseNumber: 'CM-YDE-000001',
        ),
      ).toCreateJson();
      final transporter = ProfilePayload.fromInput(
        const ProfileInput(
          type: ProfileType.transporter,
          displayName: 'Express Voyages SARL',
          companyName: 'Express Voyages SARL',
          permitNumber: 'AGR-2024-01234',
        ),
      ).toCreateJson();

      expect(passenger['passenger'], {
        'preferredLanguage': 'fr',
        'emergencyContact': '+237699001122',
      });
      expect(mototaxi['motoTaxi'], {
        'licenseNumber': 'CM-YDE-000001',
        'operatingZone': 'Bastos, Yaounde',
      });
      expect(transporter['transporter'], {
        'permitNumber': 'AGR-2024-01234',
        'companyName': 'Express Voyages SARL',
      });
    });
  });
}
