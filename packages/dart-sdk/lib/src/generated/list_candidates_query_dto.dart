// AUTO-GENERATED
import 'candidate_level.dart';
class ListCandidatesQueryDto {
  final String? page;
  final String? page_size;
  final String? search;
  final CandidateLevel? level;

  const ListCandidatesQueryDto({
    this.page,
    this.page_size,
    this.search,
    this.level,
  });

  factory ListCandidatesQueryDto.fromJson(Map<String, dynamic> json) =>
    ListCandidatesQueryDto(
      page: json['page']?.toString() ?? '',
      page_size: json['page_size']?.toString() ?? '',
      search: json['search']?.toString() ?? '',
      level: CandidateLevel.fromJson(json['level']?.toString()),
    );

  Map<String, dynamic> toJson() => {
    if (page != null) 'page': page,
    if (page_size != null) 'page_size': page_size,
    if (search != null) 'search': search,
    if (level != null) 'level': level?.toJson(),
  };

  ListCandidatesQueryDto copyWith({
    String? page,
    String? page_size,
    String? search,
    CandidateLevel? level,
  }) => ListCandidatesQueryDto(
    page: page ?? this.page,
    page_size: page_size ?? this.page_size,
    search: search ?? this.search,
    level: level ?? this.level,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is ListCandidatesQueryDto && other.page == page && other.page_size == page_size);
  @override
  int get hashCode => page.hashCode ^ page_size.hashCode;
}
