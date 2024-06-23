import Foundation

public struct ExtrinsicProofParams {
    public let encodedCall: Data
    public let encodedSignedExtra: Data
    public let encodedAdditionalSigned: Data
    public let encodedMetadata: Data
    public let specVersion: UInt32
    public let specName: String
    public let decimals: UInt8
    public let base58Prefix: UInt16
    public let tokenSymbol: String
}

public struct MetadataHashParams {
    public let metadata: Data
    public let specVersion: UInt32
    public let specName: String
    public let decimals: UInt8
    public let base58Prefix: UInt16
    public let tokenSymbol: String
}

public protocol MetadataShortenerApiProtocol {
    func generateExtrinsicProof(for params: ExtrinsicProofParams) throws -> Data
    func generateMetadataHash(for params: MetadataHashParams) throws -> Data
}

public enum MetadataShortenerApiError: Error {
    case internalError
    case badResult
}

public final class MetadataShortenerApi {
    private func isError(_ result: String) -> Bool {
        result == "-1"
    }
}

public extension MetadataShortenerApi {
    func generateExtrinsicProof(for params: ExtrinsicProofParams) throws -> Data {
        let result = internalGenerateExtrinsicProof(
            params.encodedCall.base64EncodedString().intoRustString(),
            params.encodedSignedExtra.base64EncodedString().intoRustString(),
            params.encodedAdditionalSigned.base64EncodedString().intoRustString(),
            params.encodedMetadata.base64EncodedString().intoRustString(),
            params.specVersion,
            params.specName.intoRustString(),
            params.base58Prefix,
            params.decimals,
            params.tokenSymbol.intoRustString()
        )
        
        guard !isError(result.toString()) else {
            throw MetadataShortenerApiError.internalError
        }
        
        guard let proof = Data(base64Encoded: result.toString()) else {
            throw MetadataShortenerApiError.badResult
        }
        
        return proof
    }
    
    func generateMetadataHash(for params: MetadataHashParams) throws -> Data {
        let result = internalGenerateMetadataDigest(
            params.metadata.base64EncodedString().intoRustString(),
            params.specVersion,
            params.specName.intoRustString(),
            params.base58Prefix,
            params.decimals,
            params.tokenSymbol.intoRustString()
        )
        
        guard !isError(result.toString()) else {
            throw MetadataShortenerApiError.internalError
        }
        
        guard let hash = Data(base64Encoded: result.toString()) else {
            throw MetadataShortenerApiError.badResult
        }
        
        return hash
    }
}
