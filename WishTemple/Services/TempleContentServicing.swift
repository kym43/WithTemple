import Foundation

protocol TempleContentServicing: Sendable {
    func fetchTemple() async throws -> Temple
    func fetchDeities() async throws -> [Deity]
    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature]
}

struct MockTempleContentService: TempleContentServicing {
    func fetchTemple() async throws -> Temple {
        Temple(
            id: UUID(),
            name: "心願廟",
            summary: "一座從簡樸小廟開始，隨大家心意慢慢擴建的線上廟宇。",
            history: "",
            highlights: [],
            imageName: "temple_placeholder"
        )
    }

    func fetchDeities() async throws -> [Deity] {
        [
            Deity(
                id: UUID(uuidString: "0E9750A8-C7D0-48B3-9495-29EAE72B6D6B")!,
                name: String(localized: "deity_mazu_name"),
                alias: String(localized: "deity_mazu_alias"),
                origin: String(localized: "deity_mazu_origin"),
                domain: String(localized: "deity_mazu_domain"),
                howToWorship: String(localized: "deity_mazu_worship"),
                imageName: "deity_mazu_art",
                sourceName: String(localized: "source_executive_yuan"),
                sourceURL: URL(string: "https://www.ey.gov.tw/state/D00B53C98CD4F08F/ebdc93b1-e9df-4bf4-8bfe-c6374a0f811f")
            ),
            Deity(
                id: UUID(uuidString: "AF73B4E7-893B-4DB5-8D23-D7F5D59B15D8")!,
                name: String(localized: "deity_yuelao_name"),
                alias: String(localized: "deity_yuelao_alias"),
                origin: String(localized: "deity_yuelao_origin"),
                domain: String(localized: "deity_yuelao_domain"),
                howToWorship: String(localized: "deity_yuelao_worship"),
                imageName: "deity_yuelao_art",
                sourceName: String(localized: "source_ntpc_civil_affairs"),
                sourceURL: URL(string: "https://www.ca.ntpc.gov.tw/home.jsp?id=140")
            ),
            Deity(
                id: UUID(uuidString: "E302886F-BF17-46C9-9C1A-EFA58D0F2D8F")!,
                name: String(localized: "deity_guandi_name"),
                alias: String(localized: "deity_guandi_alias"),
                origin: String(localized: "deity_guandi_origin"),
                domain: String(localized: "deity_guandi_domain"),
                howToWorship: String(localized: "deity_guandi_worship"),
                imageName: "deity_guandi_art",
                sourceName: String(localized: "source_moi_religion_map"),
                sourceURL: URL(string: "https://taiwangods.moi.gov.tw/html/cultural/3_0011.aspx?i=28")
            ),
            Deity(
                id: UUID(uuidString: "93D4E9ED-9E59-40DA-B346-1E6FFDDC167D")!,
                name: String(localized: "deity_wenchang_name"),
                alias: String(localized: "deity_wenchang_alias"),
                origin: String(localized: "deity_wenchang_origin"),
                domain: String(localized: "deity_wenchang_domain"),
                howToWorship: String(localized: "deity_wenchang_worship"),
                imageName: "deity_wenchang_art",
                sourceName: String(localized: "source_moi_religion_map"),
                sourceURL: URL(string: "https://taiwangods.moi.gov.tw/html/cultural/3_0011.aspx?i=66")
            ),
            Deity(
                id: UUID(uuidString: "0EEE42FA-DB12-4B3B-9635-B728AB5F1B80")!,
                name: String(localized: "deity_fude_name"),
                alias: String(localized: "deity_fude_alias"),
                origin: String(localized: "deity_fude_origin"),
                domain: String(localized: "deity_fude_domain"),
                howToWorship: String(localized: "deity_fude_worship"),
                imageName: "deity_fude_art",
                sourceName: String(localized: "source_moi_religion_map"),
                sourceURL: URL(string: "https://taiwangods.moi.gov.tw/html/cultural/3_0011.aspx?i=300")
            ),
            Deity(
                id: UUID(uuidString: "1D46899A-FA68-402C-898D-F8F5B6E69030")!,
                name: String(localized: "deity_xuantian_name"),
                alias: String(localized: "deity_xuantian_alias"),
                origin: String(localized: "deity_xuantian_origin"),
                domain: String(localized: "deity_xuantian_domain"),
                howToWorship: String(localized: "deity_xuantian_worship"),
                imageName: "deity_xuantian_art",
                sourceName: String(localized: "source_moi_religion_map"),
                sourceURL: URL(string: "https://taiwangods.moi.gov.tw/html/cultural/3_0011.aspx?i=11")
            ),
            Deity(
                id: UUID(uuidString: "1D5953B7-8DD6-4EBD-8285-1A6724C6D7BD")!,
                name: String(localized: "deity_zhusheng_name"),
                alias: String(localized: "deity_zhusheng_alias"),
                origin: String(localized: "deity_zhusheng_origin"),
                domain: String(localized: "deity_zhusheng_domain"),
                howToWorship: String(localized: "deity_zhusheng_worship"),
                imageName: "deity_zhusheng_art",
                sourceName: String(localized: "source_taiwan_historica_dictionary"),
                sourceURL: URL(string: "https://dict.th.gov.tw/detailPage.aspx?Ca=281&ID=1198")
            ),
            Deity(
                id: UUID(uuidString: "F216C5D9-8795-49AA-BAF7-68007013569D")!,
                name: String(localized: "deity_baosheng_name"),
                alias: String(localized: "deity_baosheng_alias"),
                origin: String(localized: "deity_baosheng_origin"),
                domain: String(localized: "deity_baosheng_domain"),
                howToWorship: String(localized: "deity_baosheng_worship"),
                imageName: "deity_baosheng_art",
                sourceName: String(localized: "source_moi_religion_map"),
                sourceURL: URL(string: "https://taiwangods.moi.gov.tw/Religious_Culture/html/Cultural/3_0011.aspx?i=310")
            )
        ]
    }

    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature] {
        []
    }
}
