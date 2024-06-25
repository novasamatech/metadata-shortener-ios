import metadata_shortener

enum InternalError: Error {
    case extrinsicProof(String)
    case metadata(String)
}

public func internalGenerateExtrinsicProof<GenericIntoRustString: IntoRustString>(_ call: GenericIntoRustString, _ signed_extras: GenericIntoRustString, _ additional_signed: GenericIntoRustString, _ metadata: GenericIntoRustString, _ spec_version: UInt32, _ spec_name: GenericIntoRustString, _ base58_prefix: UInt16, _ decimals: UInt8, _ token_symbol: GenericIntoRustString) throws -> RustString {
    try { let val = __swift_bridge__$ext_generate_extrinsic_proof({ let rustString = call.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), { let rustString = signed_extras.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), { let rustString = additional_signed.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), { let rustString = metadata.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), spec_version, { let rustString = spec_name.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), base58_prefix, decimals, { let rustString = token_symbol.intoRustString(); rustString.isOwned = false; return rustString.ptr }()); if val.is_ok { return RustString(ptr: val.ok_or_err!) } else { throw InternalError.extrinsicProof(RustString(ptr: val.ok_or_err!).toString()) } }()
}
public func internalGenerateMetadataDigest<GenericIntoRustString: IntoRustString>(_ metadata: GenericIntoRustString, _ spec_version: UInt32, _ spec_name: GenericIntoRustString, _ base58_prefix: UInt16, _ decimals: UInt8, _ token_symbol: GenericIntoRustString) throws -> RustString {
    try { let val = __swift_bridge__$ext_generate_metadata_digest({ let rustString = metadata.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), spec_version, { let rustString = spec_name.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), base58_prefix, decimals, { let rustString = token_symbol.intoRustString(); rustString.isOwned = false; return rustString.ptr }()); if val.is_ok { return RustString(ptr: val.ok_or_err!) } else { throw InternalError.metadata(RustString(ptr: val.ok_or_err!).toString()) } }()
}


