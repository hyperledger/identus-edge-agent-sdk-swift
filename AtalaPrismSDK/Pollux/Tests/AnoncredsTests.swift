@testable import Pollux
import XCTest

final class AnoncredsTests: XCTestCase {

    let anoncredJson = """
{
"schema_id": "test schema id",
"cred_def_id": "test cred definition id",
"rev_reg_id": null,
"values": {
    "first_name": {
        "raw": "Alice",
        "encoded": "113...335"
    },
    "last_name": {
        "raw": "Garcia",
        "encoded": "532...452"
    },
    "birthdate_dateint": {
        "raw": "19981119",
        "encoded": "19981119"
    }
},
"signature": {
    "p_credential": {
        "m_2": "992...312",
        "a": "548...252",
        "e": "259...199",
        "v": "977...597"
    },
    "r_credential": null
},
"signature_correctness_proof": {
    "se": "898...935",
    "c": "935...598"
},
"rev_reg": null,
"witness": null
}
""".data(using: .utf8)!
    
    let anoncredWithRevocationJson = """
{
"schema_id": "test schema id",
"cred_def_id": "test cred definition id",
"rev_reg_id": "revocation registry id",
"values": {
    "first_name": {
        "raw": "Alice",
        "encoded": "113...335"
    },
    "last_name": {
        "raw": "Garcia",
        "encoded": "532...452"
    },
    "birthdate_dateint": {
        "raw": "19981119",
        "encoded": "19981119"
    }
},
"signature": {
    "p_credential": {
        "m_2": "992...312",
        "a": "548...252",
        "e": "259...199",
        "v": "977...597"
    },
    "r_credential": {
        "sigma": "1 14C...8A8",
        "c": "12A...BB6",
        "vr_prime_prime": "0F3...FC4",
        "witness_signature": {
            "sigma_i": "1 1D72...000",
            "u_i": "1 0B3...000",
            "g_i": "1 10D...8A8"
        },
        "g_i": "1 10D7...8A8",
        "i": 1,
        "m2": "FDC...283"
    }
},
"signature_correctness_proof": {
    "se": "898...935",
    "c": "935...598"
},
"rev_reg": {
    "accum": "21 118...1FB"
},
"witness": {
    "omega": "21 124...AC8"
}
}
""".data(using: .utf8)!
    
    func testDecodeAnoncred() throws {
        let decoder = JSONDecoder()
        XCTAssertNoThrow(try decoder.decode(AnonCredential.self, from: anoncredJson))
    }
    
    func testDecodeAnoncredWithRevocation() throws {
        XCTAssertNoThrow(try JSONDecoder().decode(AnonCredential.self, from: anoncredWithRevocationJson))
    }
}
