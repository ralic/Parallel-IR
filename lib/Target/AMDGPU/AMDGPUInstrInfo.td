//===-- AMDGPUInstrInfo.td - AMDGPU DAG nodes --------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains DAG node defintions for the AMDGPU target.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AMDGPU DAG Profiles
//===----------------------------------------------------------------------===//

def AMDGPUDTIntTernaryOp : SDTypeProfile<1, 3, [
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisInt<0>, SDTCisInt<3>
]>;

def AMDGPUTrigPreOp : SDTypeProfile<1, 2,
  [SDTCisSameAs<0, 1>, SDTCisFP<0>, SDTCisInt<2>]
>;

def AMDGPULdExpOp : SDTypeProfile<1, 2,
  [SDTCisSameAs<0, 1>, SDTCisFP<0>, SDTCisInt<2>]
>;

def AMDGPUFPClassOp : SDTypeProfile<1, 2,
  [SDTCisInt<0>, SDTCisFP<1>, SDTCisInt<2>]
>;

def AMDGPUDivScaleOp : SDTypeProfile<2, 3,
  [SDTCisFP<0>, SDTCisInt<1>, SDTCisSameAs<0, 2>, SDTCisSameAs<0, 3>, SDTCisSameAs<0, 4>]
>;

// float, float, float, vcc
def AMDGPUFmasOp : SDTypeProfile<1, 4,
  [SDTCisFP<0>, SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisSameAs<0, 3>, SDTCisInt<4>]
>;

def AMDGPUKillSDT : SDTypeProfile<0, 1, [SDTCisInt<0>]>;

//===----------------------------------------------------------------------===//
// AMDGPU DAG Nodes
//

def AMDGPUconstdata_ptr : SDNode<
  "AMDGPUISD::CONST_DATA_PTR", SDTypeProfile <1, 1, [SDTCisVT<0, iPTR>,
                                                     SDTCisVT<0, iPTR>]>
>;

// This argument to this node is a dword address.
def AMDGPUdwordaddr : SDNode<"AMDGPUISD::DWORDADDR", SDTIntUnaryOp>;

// Force dependencies for vector trunc stores
def R600dummy_chain : SDNode<"AMDGPUISD::DUMMY_CHAIN", SDTNone, [SDNPHasChain]>;

def AMDGPUcos : SDNode<"AMDGPUISD::COS_HW", SDTFPUnaryOp>;
def AMDGPUsin : SDNode<"AMDGPUISD::SIN_HW", SDTFPUnaryOp>;

// out = a - floor(a)
def AMDGPUfract : SDNode<"AMDGPUISD::FRACT", SDTFPUnaryOp>;

// out = 1.0 / a
def AMDGPUrcp : SDNode<"AMDGPUISD::RCP", SDTFPUnaryOp>;

// out = 1.0 / sqrt(a)
def AMDGPUrsq : SDNode<"AMDGPUISD::RSQ", SDTFPUnaryOp>;

// out = 1.0 / sqrt(a)
def AMDGPUrcp_legacy : SDNode<"AMDGPUISD::RCP_LEGACY", SDTFPUnaryOp>;
def AMDGPUrsq_legacy : SDNode<"AMDGPUISD::RSQ_LEGACY", SDTFPUnaryOp>;

// out = 1.0 / sqrt(a) result clamped to +/- max_float.
def AMDGPUrsq_clamp : SDNode<"AMDGPUISD::RSQ_CLAMP", SDTFPUnaryOp>;

def AMDGPUldexp : SDNode<"AMDGPUISD::LDEXP", AMDGPULdExpOp>;

def AMDGPUfp_class : SDNode<"AMDGPUISD::FP_CLASS", AMDGPUFPClassOp>;

// out = max(a, b) a and b are floats, where a nan comparison fails.
// This is not commutative because this gives the second operand:
//   x < nan ? x : nan -> nan
//   nan < x ? nan : x -> x
def AMDGPUfmax_legacy : SDNode<"AMDGPUISD::FMAX_LEGACY", SDTFPBinOp,
  []
>;

def AMDGPUfmul_legacy : SDNode<"AMDGPUISD::FMUL_LEGACY", SDTFPBinOp,
  [SDNPCommutative, SDNPAssociative]
>;

def AMDGPUclamp : SDNode<"AMDGPUISD::CLAMP", SDTFPTernaryOp, []>;

// out = min(a, b) a and b are floats, where a nan comparison fails.
def AMDGPUfmin_legacy : SDNode<"AMDGPUISD::FMIN_LEGACY", SDTFPBinOp,
  []
>;

// FIXME: TableGen doesn't like commutative instructions with more
// than 2 operands.
// out = max(a, b, c) a, b and c are floats
def AMDGPUfmax3 : SDNode<"AMDGPUISD::FMAX3", SDTFPTernaryOp,
  [/*SDNPCommutative, SDNPAssociative*/]
>;

// out = max(a, b, c) a, b, and c are signed ints
def AMDGPUsmax3 : SDNode<"AMDGPUISD::SMAX3", AMDGPUDTIntTernaryOp,
  [/*SDNPCommutative, SDNPAssociative*/]
>;

// out = max(a, b, c) a, b and c are unsigned ints
def AMDGPUumax3 : SDNode<"AMDGPUISD::UMAX3", AMDGPUDTIntTernaryOp,
  [/*SDNPCommutative, SDNPAssociative*/]
>;

// out = min(a, b, c) a, b and c are floats
def AMDGPUfmin3 : SDNode<"AMDGPUISD::FMIN3", SDTFPTernaryOp,
  [/*SDNPCommutative, SDNPAssociative*/]
>;

// out = min(a, b, c) a, b and c are signed ints
def AMDGPUsmin3 : SDNode<"AMDGPUISD::SMIN3", AMDGPUDTIntTernaryOp,
  [/*SDNPCommutative, SDNPAssociative*/]
>;

// out = min(a, b) a and b are unsigned ints
def AMDGPUumin3 : SDNode<"AMDGPUISD::UMIN3", AMDGPUDTIntTernaryOp,
  [/*SDNPCommutative, SDNPAssociative*/]
>;

// out = (src0 + src1 > 0xFFFFFFFF) ? 1 : 0
def AMDGPUcarry : SDNode<"AMDGPUISD::CARRY", SDTIntBinOp, []>;

// out = (src1 > src0) ? 1 : 0
def AMDGPUborrow : SDNode<"AMDGPUISD::BORROW", SDTIntBinOp, []>;

def AMDGPUSetCCOp : SDTypeProfile<1, 3, [        // setcc
  SDTCisVT<0, i64>, SDTCisSameAs<1, 2>, SDTCisVT<3, OtherVT>
]>;

def AMDGPUsetcc : SDNode<"AMDGPUISD::SETCC", AMDGPUSetCCOp>;

def AMDGPUSetRegOp :  SDTypeProfile<0, 2, [
  SDTCisInt<0>, SDTCisInt<1>
]>;

def AMDGPUsetreg : SDNode<"AMDGPUISD::SETREG", AMDGPUSetRegOp, [
  SDNPHasChain, SDNPSideEffect, SDNPOptInGlue, SDNPOutGlue]>;

def AMDGPUfma : SDNode<"AMDGPUISD::FMA_W_CHAIN", SDTFPTernaryOp, [
   SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def AMDGPUmul : SDNode<"AMDGPUISD::FMUL_W_CHAIN", SDTFPBinOp, [
  SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def AMDGPUcvt_f32_ubyte0 : SDNode<"AMDGPUISD::CVT_F32_UBYTE0",
  SDTIntToFPOp, []>;
def AMDGPUcvt_f32_ubyte1 : SDNode<"AMDGPUISD::CVT_F32_UBYTE1",
  SDTIntToFPOp, []>;
def AMDGPUcvt_f32_ubyte2 : SDNode<"AMDGPUISD::CVT_F32_UBYTE2",
  SDTIntToFPOp, []>;
def AMDGPUcvt_f32_ubyte3 : SDNode<"AMDGPUISD::CVT_F32_UBYTE3",
  SDTIntToFPOp, []>;


// urecip - This operation is a helper for integer division, it returns the
// result of 1 / a as a fractional unsigned integer.
// out = (2^32 / a) + e
// e is rounding error
def AMDGPUurecip : SDNode<"AMDGPUISD::URECIP", SDTIntUnaryOp>;

// Special case divide preop and flags.
def AMDGPUdiv_scale : SDNode<"AMDGPUISD::DIV_SCALE", AMDGPUDivScaleOp>;

//  Special case divide FMA with scale and flags (src0 = Quotient,
//  src1 = Denominator, src2 = Numerator).
def AMDGPUdiv_fmas : SDNode<"AMDGPUISD::DIV_FMAS", AMDGPUFmasOp>;

// Single or double precision division fixup.
// Special case divide fixup and flags(src0 = Quotient, src1 =
// Denominator, src2 = Numerator).
def AMDGPUdiv_fixup : SDNode<"AMDGPUISD::DIV_FIXUP", SDTFPTernaryOp>;

// Look Up 2.0 / pi src0 with segment select src1[4:0]
def AMDGPUtrig_preop : SDNode<"AMDGPUISD::TRIG_PREOP", AMDGPUTrigPreOp>;

def AMDGPUregister_load : SDNode<"AMDGPUISD::REGISTER_LOAD",
                          SDTypeProfile<1, 2, [SDTCisPtrTy<1>, SDTCisInt<2>]>,
                          [SDNPHasChain, SDNPMayLoad]>;

def AMDGPUregister_store : SDNode<"AMDGPUISD::REGISTER_STORE",
                           SDTypeProfile<0, 3, [SDTCisPtrTy<1>, SDTCisInt<2>]>,
                           [SDNPHasChain, SDNPMayStore]>;

// MSKOR instructions are atomic memory instructions used mainly for storing
// 8-bit and 16-bit values.  The definition is:
//
// MSKOR(dst, mask, src) MEM[dst] = ((MEM[dst] & ~mask) | src)
//
// src0: vec4(src, 0, 0, mask)
// src1: dst - rat offset (aka pointer) in dwords
def AMDGPUstore_mskor : SDNode<"AMDGPUISD::STORE_MSKOR",
                        SDTypeProfile<0, 2, []>,
                        [SDNPHasChain, SDNPMayStore, SDNPMemOperand]>;

def AMDGPUatomic_cmp_swap : SDNode<"AMDGPUISD::ATOMIC_CMP_SWAP",
                            SDTypeProfile<1, 2, [SDTCisPtrTy<1>, SDTCisVec<2>]>,
                            [SDNPHasChain, SDNPMayStore, SDNPMayLoad,
                             SDNPMemOperand]>;

def AMDGPUround : SDNode<"ISD::FROUND",
                         SDTypeProfile<1, 1, [SDTCisFP<0>, SDTCisSameAs<0,1>]>>;

def AMDGPUbfe_u32 : SDNode<"AMDGPUISD::BFE_U32", AMDGPUDTIntTernaryOp>;
def AMDGPUbfe_i32 : SDNode<"AMDGPUISD::BFE_I32", AMDGPUDTIntTernaryOp>;
def AMDGPUbfi : SDNode<"AMDGPUISD::BFI", AMDGPUDTIntTernaryOp>;
def AMDGPUbfm : SDNode<"AMDGPUISD::BFM", SDTIntBinOp>;

def AMDGPUffbh_u32 : SDNode<"AMDGPUISD::FFBH_U32", SDTIntUnaryOp>;
def AMDGPUffbh_i32 : SDNode<"AMDGPUISD::FFBH_I32", SDTIntUnaryOp>;

// Signed and unsigned 24-bit multiply. The highest 8-bits are ignore
// when performing the mulitply. The result is a 32-bit value.
def AMDGPUmul_u24 : SDNode<"AMDGPUISD::MUL_U24", SDTIntBinOp,
  [SDNPCommutative, SDNPAssociative]
>;
def AMDGPUmul_i24 : SDNode<"AMDGPUISD::MUL_I24", SDTIntBinOp,
  [SDNPCommutative, SDNPAssociative]
>;

def AMDGPUmulhi_u24 : SDNode<"AMDGPUISD::MULHI_U24", SDTIntBinOp,
  [SDNPCommutative, SDNPAssociative]
>;
def AMDGPUmulhi_i24 : SDNode<"AMDGPUISD::MULHI_I24", SDTIntBinOp,
  [SDNPCommutative, SDNPAssociative]
>;

def AMDGPUmad_u24 : SDNode<"AMDGPUISD::MAD_U24", AMDGPUDTIntTernaryOp,
  []
>;
def AMDGPUmad_i24 : SDNode<"AMDGPUISD::MAD_I24", AMDGPUDTIntTernaryOp,
  []
>;

def AMDGPUsmed3 : SDNode<"AMDGPUISD::SMED3", AMDGPUDTIntTernaryOp,
  []
>;

def AMDGPUumed3 : SDNode<"AMDGPUISD::UMED3", AMDGPUDTIntTernaryOp,
  []
>;

def AMDGPUfmed3 : SDNode<"AMDGPUISD::FMED3", SDTFPTernaryOp, []>;

def AMDGPUsendmsg : SDNode<"AMDGPUISD::SENDMSG",
                    SDTypeProfile<0, 1, [SDTCisInt<0>]>,
                    [SDNPHasChain, SDNPInGlue]>;

def AMDGPUsendmsghalt : SDNode<"AMDGPUISD::SENDMSGHALT",
                    SDTypeProfile<0, 1, [SDTCisInt<0>]>,
                    [SDNPHasChain, SDNPInGlue]>;

def AMDGPUinterp_mov : SDNode<"AMDGPUISD::INTERP_MOV",
                        SDTypeProfile<1, 3, [SDTCisFP<0>]>,
                        [SDNPInGlue]>;

def AMDGPUinterp_p1 : SDNode<"AMDGPUISD::INTERP_P1",
                      SDTypeProfile<1, 3, [SDTCisFP<0>]>,
                      [SDNPInGlue, SDNPOutGlue]>;

def AMDGPUinterp_p2 : SDNode<"AMDGPUISD::INTERP_P2",
                      SDTypeProfile<1, 4, [SDTCisFP<0>]>,
                      [SDNPInGlue]>;


def AMDGPUkill : SDNode<"AMDGPUISD::KILL", AMDGPUKillSDT,
  [SDNPHasChain, SDNPSideEffect]>;

// SI+ export
def AMDGPUExportOp : SDTypeProfile<0, 8, [
  SDTCisInt<0>,       // i8 tgt
  SDTCisInt<1>,       // i8 en
                      // i32 or f32 src0
  SDTCisSameAs<3, 2>, // f32 src1
  SDTCisSameAs<4, 2>, // f32 src2
  SDTCisSameAs<5, 2>, // f32 src3
  SDTCisInt<6>,       // i1 compr
  // skip done
  SDTCisInt<1>        // i1 vm

]>;

def AMDGPUexport: SDNode<"AMDGPUISD::EXPORT", AMDGPUExportOp,
  [SDNPHasChain, SDNPMayStore]>;

def AMDGPUexport_done: SDNode<"AMDGPUISD::EXPORT_DONE", AMDGPUExportOp,
  [SDNPHasChain, SDNPMayLoad, SDNPMayStore]>;


def R600ExportOp : SDTypeProfile<0, 7, [SDTCisFP<0>, SDTCisInt<1>]>;

def R600_EXPORT: SDNode<"AMDGPUISD::R600_EXPORT", R600ExportOp,
  [SDNPHasChain, SDNPSideEffect]>;

//===----------------------------------------------------------------------===//
// Flow Control Profile Types
//===----------------------------------------------------------------------===//
// Branch instruction where second and third are basic blocks
def SDTIL_BRCond : SDTypeProfile<0, 2, [
    SDTCisVT<0, OtherVT>
    ]>;

//===----------------------------------------------------------------------===//
// Flow Control DAG Nodes
//===----------------------------------------------------------------------===//
def IL_brcond      : SDNode<"AMDGPUISD::BRANCH_COND", SDTIL_BRCond, [SDNPHasChain]>;

//===----------------------------------------------------------------------===//
// Call/Return DAG Nodes
//===----------------------------------------------------------------------===//
def AMDGPUendpgm : SDNode<"AMDGPUISD::ENDPGM", SDTNone,
    [SDNPHasChain, SDNPOptInGlue]>;

def AMDGPUreturn : SDNode<"AMDGPUISD::RETURN", SDTNone,
    [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
