extern crate core;
extern crate merkleized_metadata;

use codec::{Decode, Encode};
use frame_metadata::{RuntimeMetadataPrefixed, OpaqueMetadata, RuntimeMetadata};
use merkleized_metadata::{generate_metadata_digest, generate_proof_for_extrinsic_parts, ExtraInfo, SignedExtrinsicData, FrameMetadataPrepared, Proof, ExtrinsicMetadata};
use base64::{engine::general_purpose::STANDARD, Engine};

#[swift_bridge::bridge]
mod ffi {    
    extern "Rust" {
        #[swift_bridge(swift_name = "generateExtrinsicProof")]
        fn ext_generate_extrinsic_proof(
            call: String,
            signed_extras: String,
            additional_signed: String,
            metadata: String,
            spec_version: u32,
            spec_name: String,
            base58_prefix: u16,
            decimals: u8,
            token_symbol: String 
        ) -> String;

        #[swift_bridge(swift_name = "generateMetadataDigest")]
        fn ext_generate_metadata_digest(
            metadata: String,
            spec_version: u32,
            spec_name: String,
            base58_prefix: u16,
            decimals: u8,
            token_symbol: String
        ) -> String;
    }
}

#[derive(Encode)]
pub struct MetadataProof {
    proof: Proof,
    extrinsic: ExtrinsicMetadata,
    extra_info: ExtraInfo,
}

fn error() -> String {
    "-1".to_string()
}

#[no_mangle]
pub fn ext_generate_extrinsic_proof(
    call: String,
    signed_extras: String,
    additional_signed: String,
    metadata: String,
    spec_version: u32,
    spec_name: String,
    base58_prefix: u16,
    decimals: u8,
    token_symbol: String 
) -> String {
    let Some(metadata) = decode_metadata(metadata) else {
        return error();
    };

    let included_in_extrinsic = decode_slice(&signed_extras);

    if included_in_extrinsic.is_err() {
        return error();
    }

    let included_in_signed_data = decode_slice(&additional_signed);

    if included_in_extrinsic.is_err() {
        return error();
    }

    let call_vec = decode_slice(&call);

    if call_vec.is_err() {
        return error();
    }

    let included_in_extrinsic = included_in_extrinsic.unwrap();
    let included_in_signed_data = included_in_signed_data.unwrap();
    let call_vec = call_vec.unwrap();

    let signed_ext_data = SignedExtrinsicData {
        included_in_extrinsic: included_in_extrinsic.as_slice(),
        included_in_signed_data: included_in_signed_data.as_slice(),
    };

    let extra_info = ExtraInfo {
        spec_version: spec_version,
        spec_name: spec_name.into(),
        base58_prefix: base58_prefix,
        decimals: decimals,
        token_symbol: token_symbol.into(),
    };

    let extrinsic_metadata = FrameMetadataPrepared::prepare(&metadata)
        .unwrap()
        .as_type_information()
        .unwrap()
        .extrinsic_metadata;

    let Ok(registry_proof) =
        generate_proof_for_extrinsic_parts(call_vec.as_slice(), Some(signed_ext_data), &metadata) else {
        return error();
    };

    let meta_proof = MetadataProof {
        proof: registry_proof,
        extrinsic: extrinsic_metadata,
        extra_info: extra_info,
    };

    let proof_encoded = meta_proof.encode();

    return STANDARD.encode(proof_encoded.as_slice().as_ref());
}

#[no_mangle]
pub fn ext_generate_metadata_digest(
    metadata: String,
    spec_version: u32,
    spec_name: String,
    base58_prefix: u16,
    decimals: u8,
    token_symbol: String
) -> String {
    let Some(metadata) = decode_metadata(metadata) else {
        return error();
    };

    let extra_info = ExtraInfo {
        spec_version: spec_version,
        spec_name: spec_name.into(),
        base58_prefix: base58_prefix,
        decimals: decimals,
        token_symbol: token_symbol.into(),
    };

    let Ok(digest) = generate_metadata_digest(&metadata, extra_info) else {
        return error();
    };

    let digest_hash = digest.hash();

    return STANDARD.encode(digest_hash.as_slice().as_ref());
}

fn decode_metadata(metadata: String) -> Option<RuntimeMetadata> {
    let metadata = decode_slice(&metadata);

    if metadata.is_err() {
        return None;
    }

    let metadata = metadata.unwrap();

    let Some(metadata) = Option::<OpaqueMetadata>::decode(&mut &metadata[..])
        .ok()
        .flatten() else {
            return None;
        };
    let metadata = metadata.0;

    let Ok(metadata) = RuntimeMetadataPrefixed::decode(&mut &metadata[..]) else {
        return None;
    };

    return Some(metadata.1);
}

fn decode_slice(base64_string: &str) -> Result<Vec<u8>, String> {
    return STANDARD.decode(base64_string).map_err(|_| error());
}