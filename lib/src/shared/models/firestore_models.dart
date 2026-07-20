import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? firestoreDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

GeoPoint? firestoreGeoPoint(Object? value) {
  if (value is GeoPoint) return value;
  if (value is Map<String, dynamic>) {
    final point = value['geopoint'];
    if (point is GeoPoint) return point;
    final latitude = value['lat'] as num?;
    final longitude = value['lng'] as num?;
    if (latitude != null && longitude != null) {
      return GeoPoint(latitude.toDouble(), longitude.toDouble());
    }
  }
  if (value is Map) {
    final point = value['geopoint'];
    if (point is GeoPoint) return point;
    final latitude = value['lat'];
    final longitude = value['lng'];
    if (latitude is num && longitude is num) {
      return GeoPoint(latitude.toDouble(), longitude.toDouble());
    }
  }
  return null;
}

String firestoreGeohash(Object? value) {
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    return value['geohash'] as String? ?? '';
  }
  if (value is Map) {
    return value['geohash'] as String? ?? '';
  }
  return '';
}

Map<String, Object> firestoreGeo(GeoPoint point, String geohash) => {
      'geopoint': point,
      'geohash': geohash,
    };

double geoDistanceMeters(GeoPoint first, GeoPoint second) {
  const earthRadiusMeters = 6371000.0;
  final latitudeDelta = _degreesToRadians(second.latitude - first.latitude);
  final longitudeDelta = _degreesToRadians(second.longitude - first.longitude);
  final firstLatitude = _degreesToRadians(first.latitude);
  final secondLatitude = _degreesToRadians(second.latitude);
  final haversine = math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
      math.cos(firstLatitude) *
          math.cos(secondLatitude) *
          math.sin(longitudeDelta / 2) *
          math.sin(longitudeDelta / 2);
  return earthRadiusMeters *
      2 *
      math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
}

double _degreesToRadians(double degrees) => degrees * math.pi / 180;

class PublicProfile {
  const PublicProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.usernameLower,
    this.avatarUrl,
    this.lastSeenAt,
  });

  factory PublicProfile.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      PublicProfile.fromMap(document.id, document.data());

  factory PublicProfile.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return PublicProfile(
      uid: data['uid'] as String? ?? id,
      displayName: data['displayName'] as String? ??
          data['preferredName'] as String? ??
          data['username'] as String? ??
          'Fluentish user',
      username: data['username'] as String? ?? '',
      usernameLower: data['usernameLower'] as String? ??
          (data['username'] as String? ?? '').toLowerCase(),
      avatarUrl: data['avatarUrl'] as String?,
      lastSeenAt: firestoreDateTime(data['lastSeenAt']),
    );
  }

  final String uid;
  final String displayName;
  final String username;
  final String usernameLower;
  final String? avatarUrl;
  final DateTime? lastSeenAt;

  bool get isOnline {
    final lastSeen = lastSeenAt;
    return lastSeen != null &&
        DateTime.now().difference(lastSeen) < const Duration(minutes: 2);
  }

  Map<String, Object?> toFirestore() => {
        'uid': uid,
        'displayName': displayName,
        'username': username,
        'usernameLower': usernameLower,
        'avatarUrl': avatarUrl,
        'lastSeenAt':
            lastSeenAt == null ? null : Timestamp.fromDate(lastSeenAt!),
      };
}

class FriendRequestRecord {
  const FriendRequestRecord({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.createdAt,
    this.respondedAt,
  });

  factory FriendRequestRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      FriendRequestRecord.fromMap(document.id, document.data());

  factory FriendRequestRecord.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return FriendRequestRecord(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: firestoreDateTime(data['createdAt']),
      respondedAt: firestoreDateTime(data['respondedAt']),
    );
  }

  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  Map<String, Object?> toFirestore() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'status': status,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'respondedAt':
            respondedAt == null ? null : Timestamp.fromDate(respondedAt!),
      };
}

class SharedLocation {
  const SharedLocation({
    required this.ownerId,
    required this.point,
    required this.geohash,
    required this.accuracyM,
    required this.updatedAt,
    required this.expiresAt,
  });

  factory SharedLocation.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      SharedLocation.fromMap(document.id, document.data());

  factory SharedLocation.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    final point = firestoreGeoPoint(data['geo']);
    return SharedLocation(
      ownerId: data['ownerId'] as String? ?? id,
      point: point ?? const GeoPoint(0, 0),
      geohash: firestoreGeohash(data['geo']),
      accuracyM: (data['accuracyM'] as num?)?.toDouble() ?? 0,
      updatedAt: firestoreDateTime(data['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: firestoreDateTime(data['expiresAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String ownerId;
  final GeoPoint point;
  final String geohash;
  final double accuracyM;
  final DateTime updatedAt;
  final DateTime expiresAt;

  bool get isExpired => isExpiredAt(DateTime.now());

  bool isExpiredAt(DateTime now) => !expiresAt.isAfter(now);

  Map<String, Object> toFirestore() => {
        'ownerId': ownerId,
        'geo': firestoreGeo(point, geohash),
        'accuracyM': accuracyM,
        'updatedAt': Timestamp.fromDate(updatedAt),
        'expiresAt': Timestamp.fromDate(expiresAt),
      };
}

class FriendMapEntry {
  const FriendMapEntry({required this.profile, required this.location});

  final PublicProfile profile;
  final SharedLocation location;
}

class MapLocationRecord {
  const MapLocationRecord({
    required this.id,
    required this.placeId,
    required this.name,
    required this.point,
    required this.geohash,
    required this.group,
    required this.category,
    required this.categoryLabel,
    required this.iconKey,
    required this.sourceCategory,
    this.shortDescription = '',
    required this.sourceCategories,
    required this.address,
    required this.neighborhood,
    required this.region,
    required this.city,
    required this.countryCode,
    required this.phone,
    required this.website,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.openingHours,
    required this.status,
    required this.isActive,
    required this.googleMapsUrl,
    required this.scrapedAt,
  });

  factory MapLocationRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      MapLocationRecord.fromMap(document.id, document.data());

  factory MapLocationRecord.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    final address = _stringKeyedMap(data['address']);
    final contact = _stringKeyedMap(data['contact']);
    final rating = _stringKeyedMap(data['rating']);
    final hours = _stringKeyedMap(data['openingHours']);
    return MapLocationRecord(
      id: id,
      placeId: data['placeId'] as String? ?? id,
      name: data['name'] as String? ?? 'Unknown place',
      point: firestoreGeoPoint(data['location']) ?? const GeoPoint(0, 0),
      geohash: firestoreGeohash(data['geohash']),
      group: data['group'] as String? ?? '',
      category: data['category'] as String? ?? 'place',
      categoryLabel: data['categoryLabel'] as String? ?? 'Place',
      iconKey: (data['iconKey'] as String?) ??
          (data['category'] as String?) ??
          'place',
      sourceCategory: data['sourceCategory'] as String? ?? '',
      shortDescription: data['shortDescription'] as String? ??
          data['description'] as String? ??
          '',
      sourceCategories: _stringList(data['sourceCategories']),
      address: address['formatted'] as String? ?? '',
      neighborhood: address['neighborhood'] as String? ?? '',
      region: address['region'] as String? ?? '',
      city: address['city'] as String? ?? '',
      countryCode: address['countryCode'] as String? ?? '',
      phone: contact['phone'] as String?,
      website: contact['website'] as String?,
      rating: (rating['score'] as num?)?.toDouble(),
      reviewCount: (rating['reviewCount'] as num?)?.toInt() ?? 0,
      price: data['price'] as String?,
      openingHours: Map<String, String>.unmodifiable({
        for (final entry in hours.entries)
          if (entry.value is String) entry.key: entry.value as String,
      }),
      status: data['status'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      googleMapsUrl: data['googleMapsUrl'] as String?,
      scrapedAt: firestoreDateTime(data['scrapedAt']),
    );
  }

  final String id;
  final String placeId;
  final String name;
  final GeoPoint point;
  final String geohash;
  final String group;
  final String category;
  final String categoryLabel;
  final String iconKey;
  final String sourceCategory;
  final String shortDescription;
  final List<String> sourceCategories;
  final String address;
  final String neighborhood;
  final String region;
  final String city;
  final String countryCode;
  final String? phone;
  final String? website;
  final double? rating;
  final int reviewCount;
  final String? price;
  final Map<String, String> openingHours;
  final String status;
  final bool isActive;
  final String? googleMapsUrl;
  final DateTime? scrapedAt;

  bool get hasValidPoint =>
      point.latitude >= -90 &&
      point.latitude <= 90 &&
      point.longitude >= -180 &&
      point.longitude <= 180 &&
      (point.latitude != 0 || point.longitude != 0);
}

Map<String, dynamic> _stringKeyedMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return {
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
  }
  return const {};
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) return const [];
  return List<String>.unmodifiable(value.whereType<String>());
}

enum GuideType { place, route, collection }

extension GuideTypeFirestore on GuideType {
  String get firestoreValue => name;
}

GuideType guideTypeFromString(String? value) {
  return switch (value) {
    'route' => GuideType.route,
    'collection' => GuideType.collection,
    _ => GuideType.place,
  };
}

class PlaceRecord {
  const PlaceRecord({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.point,
    required this.geohash,
    required this.guideCount,
    required this.primaryGuideId,
    required this.isPublished,
    this.osmType,
    this.osmId,
    this.imageUrl,
  });

  factory PlaceRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      PlaceRecord.fromMap(document.id, document.data());

  factory PlaceRecord.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return PlaceRecord(
      id: id,
      name: data['name'] as String? ?? 'Unknown place',
      address: data['address'] as String? ?? '',
      category: data['category'] as String? ?? 'culture',
      point: firestoreGeoPoint(data['geo']) ?? const GeoPoint(0, 0),
      geohash: firestoreGeohash(data['geo']),
      guideCount: (data['guideCount'] as num?)?.toInt() ?? 0,
      primaryGuideId: data['primaryGuideId'] as String? ?? '',
      isPublished: data['isPublished'] as bool? ?? false,
      osmType: data['osmType'] as String?,
      osmId: data['osmId']?.toString(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  final String id;
  final String name;
  final String address;
  final String category;
  final GeoPoint point;
  final String geohash;
  final int guideCount;
  final String primaryGuideId;
  final bool isPublished;
  final String? osmType;
  final String? osmId;
  final String? imageUrl;

  Map<String, Object?> toFirestore() => {
        'name': name,
        'address': address,
        'category': category,
        'geo': firestoreGeo(point, geohash),
        'osmType': osmType,
        'osmId': osmId,
        'guideCount': guideCount,
        'primaryGuideId': primaryGuideId,
        'isPublished': isPublished,
        'imageUrl': imageUrl,
      };
}

class GuideRecord {
  const GuideRecord({
    required this.id,
    required this.type,
    required this.placeId,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.authorId,
    required this.ratingAverage,
    required this.reviewCount,
    required this.isPublished,
    required this.isMapVisible,
    this.stopCount = 0,
  });

  factory GuideRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      GuideRecord.fromMap(document.id, document.data());

  factory GuideRecord.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return GuideRecord(
      id: id,
      type: guideTypeFromString(data['type'] as String?),
      placeId: data['placeId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled guide',
      category: data['category'] as String? ?? 'culture',
      summary: data['summary'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble(),
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      isPublished: data['isPublished'] as bool? ?? false,
      isMapVisible: data['isMapVisible'] as bool? ?? false,
      stopCount: (data['stopCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final GuideType type;
  final String placeId;
  final String title;
  final String category;
  final String summary;
  final String content;
  final String authorId;
  final double? ratingAverage;
  final int reviewCount;
  final bool isPublished;
  final bool isMapVisible;
  final int stopCount;

  Map<String, Object?> toFirestore() => {
        'type': type.firestoreValue,
        'placeId': placeId,
        'title': title,
        'category': category,
        'summary': summary,
        'content': content,
        'authorId': authorId,
        'ratingAverage': ratingAverage,
        'reviewCount': reviewCount,
        'isPublished': isPublished,
        'isMapVisible': isMapVisible,
        'stopCount': stopCount,
      };
}

class GuideStop {
  const GuideStop({
    required this.id,
    required this.order,
    required this.name,
    required this.address,
    required this.point,
    required this.geohash,
    required this.instruction,
    this.osmType,
    this.osmId,
  });

  factory GuideStop.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      GuideStop.fromMap(document.id, document.data());

  factory GuideStop.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return GuideStop(
      id: id,
      order: (data['order'] as num?)?.toInt() ?? 0,
      name: data['name'] as String? ?? 'Stop',
      address: data['address'] as String? ?? '',
      point: firestoreGeoPoint(data['geo']) ?? const GeoPoint(0, 0),
      geohash: firestoreGeohash(data['geo']),
      instruction: data['instruction'] as String? ?? '',
      osmType: data['osmType'] as String?,
      osmId: data['osmId']?.toString(),
    );
  }

  final String id;
  final int order;
  final String name;
  final String address;
  final GeoPoint point;
  final String geohash;
  final String instruction;
  final String? osmType;
  final String? osmId;

  Map<String, Object?> toFirestore() => {
        'order': order,
        'name': name,
        'address': address,
        'geo': firestoreGeo(point, geohash),
        'osmType': osmType,
        'osmId': osmId,
        'instruction': instruction,
      };
}
