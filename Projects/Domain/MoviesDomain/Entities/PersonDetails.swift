import Foundation

public struct PersonDetails: Codable {
    public var adult: Bool
    public var alsoKnownAs: [String]
    public var biography: String
    public var birthday: Date?
    public var deathday: Date?
    public var gender: Int
    public var id: PersonID
    public var imdbID: String?
    public var knownForDepartment, name: String
    public var placeOfBirth: String?
    public var popularity: Double
    public var profilePath: String?
    public var images: Images

    public struct Images: Codable {
        public var profiles: [Image]
    }

    public struct Image: Codable {
        public var filePath: String
    }
}

#if DEBUG
public extension PersonDetails {
    static var example: Self {
        PersonDetails(
            adult: false,
            alsoKnownAs: [
                "Edward Thomas Hardy",
                "توم هاردي",
                "톰 하디",
                "トム・ハーディ",
                "ทอม ฮาร์ดี",
                "汤姆·哈迪",
                "ტომ ჰარდი",
                "Edward Thomas \"Tom\" Hardy",
                "Έντουαρντ Τόμας \"Τομ\" Χάρντι",
                "Έντουαρντ Τόμας Χάρντι",
                "טום הארדי",
                "Том Харді"
            ],
            biography:
            """
            "Edward Thomas Hardy CBE (born 15 September 1977) is an English actor, producer, writer and former model. After studying acting at the Drama Centre London, he made his film debut in Ridley Scott's Black Hawk Down (2001). He has since been nominated for the Academy Award for Best Supporting Actor, two Critics' Choice Movie Awards and two British Academy Film Awards, receiving the 2011 BAFTA Rising Star Award.\n\nHardy has also appeared in films such as Star Trek: Nemesis (2002), RocknRolla (2008), Bronson (2008), Warrior (2011), Tinker Tailor Soldier Spy (2011), Lawless (2012), This Means War (2012), Locke (2013), The Drop (2014), and The Revenant (2015), for which he received a nomination for an Academy Award. In 2015, he portrayed \"Mad\" Max Rockatansky in Mad Max: Fury Road and both Kray twins in Legend. He has appeared in three Christopher Nolan films: Inception (2010) as Eames, The Dark Knight Rises (2012) as Bane, and Dunkirk (2017) as an RAF fighter-pilot. He starred as both Eddie Brock and Venom in the 2018 anti-hero film Venom and its sequel Venom: Let There Be Carnage (2021).\n\nHardy's television roles include the HBO war drama mini-series Band of Brothers (2001), the BBC historical drama mini-series The Virgin Queen (2005), Bill Sikes in the BBC's mini-series Oliver Twist (2007), Heathcliff in ITV's Wuthering Heights (2009), the Sky 1 drama series The Take (2009), and as Alfie Solomons in the BBC historical crime drama series Peaky Blinders (2014–present). He created, co-produced, and took the lead in the eight-part historical fiction series Taboo (2017) on BBC One and FX. In 2020, he also contributed narration work to the Amazon docuseries All or Nothing: Tottenham Hotspur.\n\nHardy has performed on both British and American stages. He was nominated for the Laurence Olivier Award for Most Promising Newcomer for his role as Skank in the production of In Arabia We'd All Be Kings (2003), and was awarded the 2003 Evening Standard Theatre Award for Outstanding Newcomer for his performances in both In Arabia We'd All Be Kings and Blood, in which he played Luca. He starred in the production of The Man of Mode (2007) and received positive reviews for his role in the play The Long Red Road (2010). Hardy is active in charity work and is an ambassador for the Prince's Trust. He was appointed a CBE in the 2018 Birthday Honours for services to drama.\n\nDescription above from the Wikipedia article Tom Hardy, licensed under CC-BY-SA, full list of contributors on Wikipedia."
            """,
            birthday: Date(timeIntervalSince1970: 0),
            gender: 1,
            id: 2524,
            imdbID: "nm0362766",
            knownForDepartment: "Acting",
            name: "Tom Hardy",
            placeOfBirth: "Hammersmith, London, England, UK",
            popularity: 112.617,
            profilePath: "/d81K0RH8UX7tZj49tZaQhZ9ewH.jpg",
            images: Images(
                profiles: [
                    Image(filePath: "/d81K0RH8UX7tZj49tZaQhZ9ewH.jpg"),
                    Image(filePath: "/scbbuyWX3yuMjDlm1etAljrbCr0.jpg"),
                    Image(filePath: "/mHSmt9qu2JzEPqnVWCGViv9Stnn.jpg"),
                    Image(filePath: "/yVGF9FvDxTDPhGimTbZNfghpllA.jpg"),
                    Image(filePath: "/sGMA6pA2D6X0gun49igJT3piHs3.jpg")
                ]
            )
        )
    }
}

#endif
