import XCTest
import MetadataShortenerApi

final class MetadataShortenerApiTests: XCTestCase {
    func testProofGeneration() throws {
        let metadata = try loadMetadata()
        
        let encodedCall = Data(base64Encoded: "BAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")!
        let encodedSignedExtra = Data(base64Encoded: "AAAAAQ==")!
        let encodedAdditionalSigned = Data(base64Encoded: "FUoPABoAAACwqNSTKFwt9zKQ37fmH4cPF7QYARl6FJypNlRJnqPa/rCo1JMoXC33MpDft+Yfhw8XtBgBGXoUnKk2VEmeo9r+AZ2LQlbybnmEscZASFiHguZv1c1FH+w03BSjRr6HJYEt")!
        
        let params = ExtrinsicProofParams(
            encodedCall: encodedCall,
            encodedSignedExtra: encodedSignedExtra,
            encodedAdditionalSigned: encodedAdditionalSigned,
            encodedMetadata: metadata,
            specVersion: 1002005,
            specName: "kusama",
            decimals: 12,
            base58Prefix: 2,
            tokenSymbol: "KSM"
        )
        
        do {
            let proof = try MetadataShortenerApi().generateExtrinsicProof(for: params)
            print("Proof: \(proof.base64EncodedString())")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testMetadataHashCreation() throws {
        let metadata = try loadMetadata()
        
        let params = MetadataHashParams(
            metadata: metadata,
            specVersion: 1002005,
            specName: "kusama",
            decimals: 12,
            base58Prefix: 2,
            tokenSymbol: "KSM"
        )
        
        do {
            let metadataHash = try MetadataShortenerApi().generateMetadataHash(for: params)
            print("Hash: \(metadataHash.base64EncodedString())")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    private func loadMetadata() throws -> Data {
        guard let metadataUrl = Bundle(for: Self.self).url(forResource: "kusama-v15-metadata", withExtension: "") else {
            fatalError("Can't read metadata")
        }
        
        let base64Metadata = try String(contentsOf: metadataUrl)
        
        guard let metadata = Data(base64Encoded: base64Metadata) else {
            fatalError("Can't decode metadata")
        }
        
        return metadata
    }
}
