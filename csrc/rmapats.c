// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  hsG_0__0 (struct dummyq_struct * I1353, EBLK  * I1348, U  I707);
void  hsG_0__0 (struct dummyq_struct * I1353, EBLK  * I1348, U  I707)
{
    U  I1613;
    U  I1614;
    U  I1615;
    struct futq * I1616;
    struct dummyq_struct * pQ = I1353;
    I1613 = ((U )vcs_clocks) + I707;
    I1615 = I1613 & ((1 << fHashTableSize) - 1);
    I1348->I752 = (EBLK  *)(-1);
    I1348->I753 = I1613;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1348);
    }
    if (I1613 < (U )vcs_clocks) {
        I1614 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1348, I1614 + 1, I1613);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I707 == 1)) {
        I1348->I755 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I752 = I1348;
        peblkFutQ1Tail = I1348;
    }
    else if ((I1616 = pQ->I1256[I1615].I775)) {
        I1348->I755 = (struct eblk *)I1616->I773;
        I1616->I773->I752 = (RP )I1348;
        I1616->I773 = (RmaEblk  *)I1348;
    }
    else {
        sched_hsopt(pQ, I1348, I1613);
    }
}
void  hs_0_M_23_21__salida_daidir (UB  * pcode, scalar  val)
{
    if (*(pcode + 2) == val) {
        if (fRTFrcRelCbk) {
            U  I1435 = 0;
            if (fScalarIsForced) {
                I1435 = 29;
            }
            else if (fScalarIsReleased) {
                I1435 = 30;
            }
            if ((fScalarIsForced || fScalarIsReleased) && fRTFrcRelCbk && *(RP  *)((pcode + 136))) {
                RP  I1480 = (RP )(pcode + 136);
                void * I1481 = hsimGetCbkMemOptCallback(I1480);
                if (I1481) {
                    SDaicbForHsimCbkMemOptNoFlagFrcRel(I1481, I1435, -1, -1, -1);
                }
                fScalarIsForced = 0;
                fScalarIsReleased = 0;
            }
        }
        return  ;
    }
    *(pcode + 2) = val;
    if (fRTFrcRelCbk) {
        U  I1435 = 0;
        if (fScalarIsForced) {
            I1435 = 29;
        }
        else if (fScalarIsReleased) {
            I1435 = 30;
        }
        if ((fScalarIsForced || fScalarIsReleased) && fRTFrcRelCbk && *(RP  *)((pcode + 136))) {
            RP  I1480 = (RP )(pcode + 136);
            void * I1481 = hsimGetCbkMemOptCallback(I1480);
            if (I1481) {
                SDaicbForHsimCbkMemOptNoFlagFrcRel(I1481, I1435, -1, -1, -1);
            }
            fScalarIsForced = 0;
            fScalarIsReleased = 0;
        }
    }
    RmaRtlXEdgesHdr  * I977 = (RmaRtlXEdgesHdr  *)(pcode + 8);
    RmaRtlEdgeBlock  * I811;
    U  I5 = I977->I5;
    scalar  I843 = (((I5) >> (16)) & ((1 << (8)) - 1));
    US  I1495 = (1 << (((I843) << 2) + (X4val[val])));
    if (I1495 & 31692) {
        rmaSchedRtlXEdges(I977, I1495, X4val[val]);
    }
    (I5) = (((I5) & ~(((U )((1 << (8)) - 1)) << (16))) | ((X4val[val]) << (16)));
    I977->I5 = I5;
    {
        unsigned long long * I1737 = derivedClk + (4U * X4val[val]);
        memcpy(pcode + 104 + 4, I1737, 25U);
    }
    {
        {
            RP  I1540;
            RP  * I743 = (RP  *)(pcode + 136);
            {
                I1540 = *I743;
                if (I1540) {
                    hsimDispatchCbkMemOptNoDynElabS(I743, val, 0U);
                }
            }
        }
    }
    {
        scalar  I1571;
        scalar  I1483;
        U  I1528;
        U  I1579;
        U  I1580;
        EBLK  * I1348;
        struct dummyq_struct * pQ;
        U  I1351;
        I1351 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        I1483 = X4val[val];
        I1571 = *(pcode + 144);
        *(pcode + 144) = I1483;
        I1528 = (I1571 << 2) + I1483;
        I1528 = 1 << I1528;
        if (I1528 & 2) {
            if (getCurSchedRegion()) {
                SchedSemiLerTBReactiveRegion_th((struct eblk *)(pcode + 152), I1351);
            }
            else {
                sched0_th(pQ, (EBLK  *)(pcode + 152));
            }
        }
    }
    {
        scalar  I1739 = X4val[val];
        scalar  I1740 = *(scalar  *)(pcode + 192 + 2U);
        *(scalar  *)(pcode + 192 + 2U) = I1739;
        UB  * I977 = *(UB  **)(pcode + 192 + 8U);
        if (I977) {
            U  I1741 = I1739 * 2;
            U  I1742 = 1 << ((I1740 << 2) + I1739);
            *(pcode + 192 + 0U) = 1;
            while (I977){
                UB  * I1744 = *(UB  **)(I977 + 16U);
                if ((*(US  *)(I977 + 0U)) & I1742) {
                    *(*(UB  **)(I977 + 48U)) = 1;
                    (*(FP  *)(I977 + 32U))((void *)(*(RP  *)(I977 + 40U)), (((*(scalar  *)(I977 + 2U)) >> I1741) & 3));
                }
                I977 = I1744;
            };
            *(pcode + 192 + 0U) = 0;
            rmaRemoveNonEdgeLoads(pcode + 192);
        }
    }
    {
        scalar  I1361;
        I1361 = val;
        pcode += 232;
        (*(FP  *)(pcode + 0))(*(UB  **)(pcode + 8), I1361);
    }
}
void  hs_0_M_23_0__salida_daidir (UB  * pcode, scalar  val)
{
    UB  * I1680;
    *(pcode + 0) = val;
    if (*(pcode + 1)) {
        return  ;
    }
    hs_0_M_23_21__salida_daidir(pcode, val);
    fScalarIsReleased = 0;
}
void  hs_0_M_23_1__salida_daidir (UB  * pcode, scalar  val, U  I699, scalar  * I1368, U  did)
{
    U  I1347 = 0;
    *(pcode + 1) = 1;
    fScalarIsForced = 1;
    hs_0_M_23_21__salida_daidir(pcode, val);
    fScalarIsForced = 0;
}
void  hs_0_M_23_2__salida_daidir (UB  * pcode)
{
    scalar  val;
    fScalarIsReleased = 1;
    val = *(pcode + 0);
    *(pcode + 1) = 0;
    hs_0_M_23_21__salida_daidir(pcode, val);
    fScalarIsReleased = 0;
}
void  hs_0_M_23_5__salida_daidir (UB  * pcode, UB  val)
{
    val = *(pcode + 0);
    *(pcode + 0) = 0xff;
    hs_0_M_23_0__salida_daidir(pcode, val);
    fScalarIsReleased = 0;
}
void  hs_0_M_25_21__salida_daidir (UB  * pcode, scalar  val)
{
    if (*(pcode + 2) == val) {
        if (fRTFrcRelCbk) {
            U  I1435 = 0;
            if (fScalarIsForced) {
                I1435 = 29;
            }
            else if (fScalarIsReleased) {
                I1435 = 30;
            }
            if ((fScalarIsForced || fScalarIsReleased) && fRTFrcRelCbk && *(RP  *)((pcode + 136))) {
                RP  I1480 = (RP )(pcode + 136);
                void * I1481 = hsimGetCbkMemOptCallback(I1480);
                if (I1481) {
                    SDaicbForHsimCbkMemOptNoFlagFrcRel(I1481, I1435, -1, -1, -1);
                }
                fScalarIsForced = 0;
                fScalarIsReleased = 0;
            }
        }
        return  ;
    }
    *(pcode + 2) = val;
    if (fRTFrcRelCbk) {
        U  I1435 = 0;
        if (fScalarIsForced) {
            I1435 = 29;
        }
        else if (fScalarIsReleased) {
            I1435 = 30;
        }
        if ((fScalarIsForced || fScalarIsReleased) && fRTFrcRelCbk && *(RP  *)((pcode + 136))) {
            RP  I1480 = (RP )(pcode + 136);
            void * I1481 = hsimGetCbkMemOptCallback(I1480);
            if (I1481) {
                SDaicbForHsimCbkMemOptNoFlagFrcRel(I1481, I1435, -1, -1, -1);
            }
            fScalarIsForced = 0;
            fScalarIsReleased = 0;
        }
    }
    *(pcode + 3) = X4val[val];
    RmaRtlXEdgesHdr  * I977 = (RmaRtlXEdgesHdr  *)(pcode + 8);
    RmaRtlEdgeBlock  * I811;
    U  I5 = I977->I5;
    scalar  I843 = (((I5) >> (16)) & ((1 << (8)) - 1));
    US  I1495 = (1 << (((I843) << 2) + (X4val[val])));
    if (I1495 & 31692) {
        rmaSchedRtlXEdges(I977, I1495, X4val[val]);
    }
    (I5) = (((I5) & ~(((U )((1 << (8)) - 1)) << (16))) | ((X4val[val]) << (16)));
    I977->I5 = I5;
    {
        unsigned long long * I1737 = derivedClk + (4U * X4val[val]);
        memcpy(pcode + 104 + 4, I1737, 25U);
    }
    {
        {
            RP  I1540;
            RP  * I743 = (RP  *)(pcode + 136);
            {
                I1540 = *I743;
                if (I1540) {
                    hsimDispatchCbkMemOptNoDynElabS(I743, val, 0U);
                }
            }
        }
    }
    RP  * I1527;
    I1527 = (RP  *)(pcode + 144);
    if (*I1527) {
        scalar  I1538;
        I1538 = X4val[val];
        Wsvvar_sched_virt_intf_eval(I1527, I1538);
        Wsvvar_callback_virt_intf(I1527);
    }
    {
        scalar  I1571;
        scalar  I1483;
        U  I1528;
        U  I1579;
        U  I1580;
        EBLK  * I1348;
        struct dummyq_struct * pQ;
        U  I1351;
        I1351 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        I1483 = X4val[val];
        I1571 = *(pcode + 152);
        *(pcode + 152) = I1483;
        I1528 = (I1571 << 2) + I1483;
        I1528 = 1 << I1528;
        if (I1528 & 2) {
            if (getCurSchedRegion()) {
                SchedSemiLerTBReactiveRegion_th((struct eblk *)(pcode + 160), I1351);
            }
            else {
                sched0_th(pQ, (EBLK  *)(pcode + 160));
            }
        }
    }
    {
        scalar  I1739 = X4val[val];
        scalar  I1740 = *(scalar  *)(pcode + 200 + 2U);
        *(scalar  *)(pcode + 200 + 2U) = I1739;
        UB  * I977 = *(UB  **)(pcode + 200 + 8U);
        if (I977) {
            U  I1741 = I1739 * 2;
            U  I1742 = 1 << ((I1740 << 2) + I1739);
            *(pcode + 200 + 0U) = 1;
            while (I977){
                UB  * I1744 = *(UB  **)(I977 + 16U);
                if ((*(US  *)(I977 + 0U)) & I1742) {
                    *(*(UB  **)(I977 + 48U)) = 1;
                    (*(FP  *)(I977 + 32U))((void *)(*(RP  *)(I977 + 40U)), (((*(scalar  *)(I977 + 2U)) >> I1741) & 3));
                }
                I977 = I1744;
            };
            *(pcode + 200 + 0U) = 0;
            rmaRemoveNonEdgeLoads(pcode + 200);
        }
    }
}
void  hs_0_M_25_0__salida_daidir (UB  * pcode, scalar  val)
{
    UB  * I1680;
    *(pcode + 0) = val;
    if (*(pcode + 1)) {
        return  ;
    }
    hs_0_M_25_21__salida_daidir(pcode, val);
    fScalarIsReleased = 0;
}
void  hs_0_M_25_1__salida_daidir (UB  * pcode, scalar  val, U  I699, scalar  * I1368, U  did)
{
    U  I1347 = 0;
    *(pcode + 1) = 1;
    fScalarIsForced = 1;
    hs_0_M_25_21__salida_daidir(pcode, val);
    fScalarIsForced = 0;
}
void  hs_0_M_25_2__salida_daidir (UB  * pcode)
{
    scalar  val;
    fScalarIsReleased = 1;
    val = *(pcode + 0);
    *(pcode + 1) = 0;
    hs_0_M_25_21__salida_daidir(pcode, val);
    fScalarIsReleased = 0;
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
