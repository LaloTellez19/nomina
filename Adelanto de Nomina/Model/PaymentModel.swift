//
//  PaymentModel.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 23/06/21.
//
struct ResponseData: Decodable {
    var payment: [Payment]
}
struct Payment: Decodable {
    var concepto: String
    var monto: Double
    var fecha: String
    var metodo: String
    var imageConcept: String
}

// MARK: - Estados
struct Estados: Codable {
    let error: Bool
    let code_error: Int
    let error_message: JSONNull?
    let response: Response

    enum CodingKeys: String, CodingKey {
        case error
        case code_error
        case error_message
        case response
    }
}

// MARK: - Municipios
struct Municipios: Codable {
    let error: Bool
    let code_error: Int
    let error_message: JSONNull?
    let response: ResponseMuni

    enum CodingKeys: String, CodingKey {
        case error
        case code_error
        case error_message
        case response
    }
}

// MARK: - Colonia
struct Colonias: Codable {
    let error: Bool
    let code_error: Int
    let error_message: JSONNull?
    let response: ResponseColo

    enum CodingKeys: String, CodingKey {
        case error
        case code_error
        case error_message
        case response
    }
}

// MARK: - Response
struct Response: Codable {
    let estado: [String]
}

struct ResponseMuni: Codable {
    let municipios: [String]
}

struct ResponseColo: Codable {
    let colonia: [String]
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {

    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath,
                                                                                  debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
