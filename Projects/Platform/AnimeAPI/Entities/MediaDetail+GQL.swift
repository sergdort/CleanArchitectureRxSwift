import AnimeDomain
import Foundation

extension MediaDetail {
    static func make(with media: MediaByIdQuery.Data.Media) -> Self {
        let recommendations = media.recommendations?.nodes?
            .compactMap { $0?.mediaRecommendation?.fragments.gQLDiscoverMedia }
            .map {
                DiscoverMedia(media: $0)
            }

        let trailerURL: URL?

        if media.trailer?.site == "youtube", let id = media.trailer?.id {
            trailerURL = URL(string: "https://www.youtube.com/embed/\(id)")
        } else {
            trailerURL = nil
        }

        return MediaDetail(
            id: media.id,
            coverImage: media.coverImage?.large,
            trailerURL: trailerURL,
            genres: media.genres?.compactMap { $0 } ?? [],
            duration: media.duration ?? 0,
            startDate: media.startDate?.fragments.fuzzyDateFragmet.date,
            type: media.type?.rawValue ?? "",
            popularity: media.popularity ?? 0,
            averageScore: media.averageScore ?? 0,
            description: media.description ?? "",
            bannerImage: media.bannerImage,
            characters: media.characters?.nodes?.compactMap { $0 }
                .map(MediaDetail.Character.make(with:)) ?? [],
            title: media.title?.english ?? "",
            recommendations: recommendations ?? []
        )
    }
}

extension MediaDetail.Character {
    static func make(with character: MediaByIdQuery.Data.Media.Characters.Node) -> Self {
        MediaDetail.Character(
            id: character.id,
            name: character.name?.full,
            image: character.image?.medium
        )
    }
}
