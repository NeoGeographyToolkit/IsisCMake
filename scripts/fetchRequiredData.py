
import sys, os

def main():
    
    # Hardcoded list of downloadable files needed to run tests
    fileList = '''
messenger/kernels/ck/msgr20111020.bc
cassini/calibration/vims/RC19/solar-spectrum/
base/templates/labels/
galileo/calibration/conversionFactors_v001.sav
galileo/calibration/conversionFactors_v002.sav
galileo/calibration/weightTables_v001.sav
messenger/kernels/ck/msgr20111019.bc
lro/kernels/ck/lrolc_2009181_2009213_v02.bc
clementine1/calibration/nir/nirmodeflats/strip015_set4_061_065_33_a_n.cub
clementine1/calibration/uvvis/lub_comp_flat_long.cub
clementine1/calibration/uvvis/uvvisTemperature.tbl
newhorizons/calibration/target-wavelengths-expanded.csv
odyssey/testData/I50695002EDR.proj.reduced.cub
galileo/calibration/shutter/calibration.so02F.cub
messenger/testData/EW0089570936I.IMG
lro/apps/mrf2pds/tsts/CH_Lev2/input/FSR_CDR_LV2_01921_0R_Lev2.cub
mer/calibration/REFPIXVAR_105.cub
mer/calibration/REFPIXVAR_110.cub
lro/apps/mrf2pds/tsts/CH_Lev2/input/FSR_CDR_LV2_01921_0R_Lev2.cub
messenger/kernels/ck/msgr20111018.bc
lro/kernels/ck/lrolc_2009181_2009213_v02.bc
base/dems/ulcn2005_lpo_0004.cub
clementine1/calibration/nir/clemnircal.def
calibration/uvvis/uvvisTemperature.tbl
odyssey/testData/I56969027EDR.proj.reduced.cub
galileo/calibration/gain/redf.cal04.cub
galileo/calibration/gain/clrf.cal04.cub
mro/testData/ctx_pmoi_i_00003.bottom.cub
messenger/testData/EW0031592574E.IMG
lro/apps/mrf2pds/tsts/CH_Lev2/input/FSR_CDR_LV2_01921_0R_Lev2.cub
cassini/calibration/darkcurrent/
apollo15/templates/apolloPanFiducialFinder.pvl
base/dems/ulcn2005_lpo_0004.cub
clementine1/translations/
lro/translations/
viking1/translations/
mgs/translations/
mariner10/translations/
mariner10/calibration/mariner_10_CLE_A_coef.cub
mariner10/calibration/mariner_10_ORA_A_coef.cub
mariner10/calibration/mariner_10_CLE_B_coef.cub
mariner10/calibration/mariner_10_ORA_B_coef.cub
mariner10/calibration/mariner_10_UV_B_coef.cub
clementine1/calibration/hires/lhd_flat.cub
clementine1/calibration/nir/nir.addflats.dat
clementine1/calibration/uvvis/lua_comp_flat_long.cub
clementine1/calibration/uvvis/lue_uncomp_flat_long.cub
messenger/translations/
messenger/templates/
lo/templates/
chandrayaan1/bandBin/
chandrayaan1/translations/
chandrayaan1/kernels/
mer/translations/
mro/templates/
mro/calibration/
mgs/calibration/
mer/calibration/
newhorizons/translations/
rolo/translations/
mex/translations/
kaguya/translations/
hayabusa/translations/
galileo/translations/
dawn/translations/
rosetta/translations/
clementine1/kernels/
viking1/kernels/
viking2/kernels/
apollo15/kernels/
cassini/calibration/darkcurrent/
hayabusa/kernels/
mariner10/kernels/
odyssey/calibration/
odyssey/testData/I51718010EDR.crop.proj.reduced.cub
cassini/testData/vims2.cub
galileo/calibration/gll_gain.sav
lro/apps/mrf2pds/tsts/CH_Lev2/input/FSR_CDR_LV2_01921_0R_Lev2.cub
base/dems/ulcn2005_lpo_0004.cub
lro/kernels/ck/lrolc_2009181_2009213_v02.bc
messenger/kernels/ck/msgr20080110.bc
mro/kernels/spk/mro_psp7.bsp
messenger/kernels/ck/msgr20111017.bc
mer/translations/merInstrument.trn
mer/translations/merInstrument.trn
odyssey/testData/I25685003EDR.crop.proj.reduced.cub
odyssey/testData/I25685003EDR.crop.proj.reduced.cub
odyssey/testData/I25685003EDR.crop.proj.reduced.cub
cassini/testData/vims2.cub+100
base/translations/
mro/testData/ctx_pmoi_i_00003.bottom.cub
mrg_Global_512ppd_radius-demprep.cub
cassini/translations/
chandrayaan1/translations/m3Instrument.trn
Clementine1/calibration/hires/lhd_flat.cub
clementine1/calibration/nir/nirorbitflats/nir_orbflat_284_a.cub
clementine1/calibration/uvvis/dark_5_15_96.cub
dawn/translations/dawnfcArchive.trn
dawn/translations/dawnvirArchive.trn
galileo/translations/galileoNIMSInstrument.trn
galileo/calibration/darkcurrent/2f8.dc04.cub
galileo/calibration/darkcurrent/4f8.dc04.cub
hayabusa/translations/amicaArchive.trn
hayabusa/translations/nirsArchive.trn
kaguya/translations/kaguyamiInstrument.trn
kaguya/translations/tcmapInstrument.trn
kaguya/translations/mimapBandBin.trn
base/translations/pdsExportImageImage.typ
lro/translations/lronacArchive.trn
lro/translations/lronacPdsLabelExport.trn
lro/translations/lrowacArchive.trn
lro/translations/lrowacPdsLabelExport.trn
lro/translations/mrflev1Archive.trn
lro/translations/mrflev2Archive.trn
base/translations/pdsExportImageImage.typ
mariner10/calibration/mariner_10_blem_A.cub
mariner10/calibration/mariner_10_blem_B.cub
mer/translations/merInstrument.trn
messenger/translations/mdisBandBin.trn
base/translations/pdsExportImageImage.typ
messenger/translations/mdisBandBin.trn
mex/translations/hrscBandBin.trn
mex/translations/hrscBandBin.trn
base/translations/pdsExportImageImage.typ
mro/calibration/psf/PSF_IR.cub
newhorizons/translations/leisaArchive_fit.trn
newhorizons/translations/lorriBandBin_fit.trn
rolo/translations/roloInstrument.trn
rosetta/translations/osirisBandBin.trn
viking2/reseaus/nominal.pvl
apollo15/kernels/pck/moon_assoc_me.tf
base/dems/ulcn2005_lpo_0004.cub
cassini/kernels/pck/cpck21Apr2005.tpc
lro/kernels/ck/lrolc_2009181_2009213_v02.bc
odyssey/kernels/sclk/ORB1_SCLKSCET.00200.tsc
odyssey/kernels/sclk/ORB1_SCLKSCET.00203.tsc
apollo/DEM/LRO_LOLA-KaguyaLPF3-mrg_Global_512ppd_radius-demprep.cub
hayabusa/dawn/DEM/vesta512.bds
messenger/kernels/ck/msgr20080109.bc
messenger/kernels/ck/msgr20111016.bc
apollo15/templates/apolloPanFiducialFinder.pvl
base/dems/ulcn2005_lpo_0004.cub
mer/translations/merInstrument.trn
mer/translations/merInstrument.trn
odyssey/testData/I25685003EDR.crop.proj.reduced.cub
cassini/testData/vims2.cub+100
base/translations/pdsExportImageImage.typ
mro/testData/ctx_pmoi_i_00003.bottom.cub
cassini/translations/narrowAngle.def
cassini/translations/wideAngle.def
chandrayaan1/translations/m3Instrument.trn
Clementine1/calibration/hires/lhd_flat.cub
clementine1/calibration/nir/nirorbitflats/nir_orbflat_284_a.cub
clementine1/calibration/uvvis/dark_5_15_96.cub
hayabusa/dawn/DEM/vesta512.bds
dawn/translations/dawnfcArchive.trn
dawn/translations/dawnvirArchive.trn
galileo/translations/galileoNIMSInstrument.trn
galileo/calibration/darkcurrent/2f8.dc04.cub
galileo/calibration/darkcurrent/4f8.dc04.cub
hayabusa/translations/amicaArchive.trn
hayabusa/translations/nirsArchive.trn
kaguya/translations/kaguyamiInstrument.trn
kaguya/translations/tcmapInstrument.trn
kaguya/translations/mimapBandBin.trn
base/translations/pdsExportImageImage.typ
cassini/translations/narrowAngle.def
lro/translations/lronacArchive.trn
lro/translations/lronacPdsLabelExport.trn
lro/translations/lrowacArchive.trn
lro/translations/lrowacPdsLabelExport.trn
lro/translations/mrflev1Archive.trn
lro/translations/mrflev2Archive.trn
base/translations/pdsExportImageImage.typ
mariner10/calibration/mariner_10_blem_A.cub
mariner10/calibration/mariner_10_blem_B.cub
mer/translations/merInstrument.trn
messenger/translations/mdisBandBin.trn
base/translations/pdsExportImageImage.typ
messenger/translations/mdisBandBin.trn
mex/translations/hrscBandBin.trn
base/translations/pdsExportImageImage.typ
mro/calibration/psf/PSF_IR.cub
newhorizons/translations/leisaArchive_fit.trn
newhorizons/translations/lorriBandBin_fit.trn
rolo/translations/roloInstrument.trn
rosetta/translations/osirisBandBin.trn
rosetta/translations/osirisBandBin.trn
viking2/reseaus/nominal.pvl
apollo15/calibration/METRIC_flatfield.cub
apollo15/calibration/ApolloPanFiducialMark.cub
base/dems/ulcn2005_lpo_0004.cub
mer/translations/merStructure.trn
newhorizons/calibration/target-wavelengths-expanded.csv.
odyssey/testData/I10047011EDR.proj.reduced.cub
viking1/reseaus/vo1.visb.template.cub
cassini/testData/vims1.cub
base/translations/pdsExportRootGen.typ
mro/testData/ctx_pmoi_i_00003.bottom.cub
Apollo/DEM/LRO_LOLA-KaguyaLPF3-mrg_Global_512ppd_radius-demprep.cub
base/templates/maps/polarstereographic.map
base/templates/maps/simplecylindrical.map
cassini/translations/cassiniIss.trn
cassini/translations/vimsPds.trn
chandrayaan1/translations/m3Archive.trn
clementine1/translations/clementine.trn
Clementine1/calibration/hires/lhd_flat.cub
clementine1/calibration/nir/newnir_flat_a.cub
clementine1/calibration/uvvis/uvvis.def
base/templates/cnet_validmeasure/validmeasure.def
base/templates/cnetref/cnetref_nooperator.def
base/templates/cnetref/cnetref_operator.def
base/templates/cnetref/cnetref_nooperator.def
base/templates/cnetstats/cnetstats.def
hayabusa/dawn/DEM/vesta512.bds
dawn/translations/dawnfcBandBin.trn
dawn/translations/dawnvirBandBin.trn
dawn/translations/dawnvirBandBin.trn
galileo/translations/galileoNIMSArchive.trn
galileo/translations/galileoSsi.trn
galileo/calibration/gll_dc.sav
hayabusa/translations/amicaBandBin.trn
hayabusa/translations/nirsInstrument.trn
kaguya/translations/kaguyamiArchive.trn
kaguya/translations/tcmapBandBin.trn
base/translations/pdsExportRootGen.typ
cassini/translations/cissua2isis.trn
lro/translations/lronacInstrument.trn
lro/translations/pdsExportRootGen.typ
lro/translations/lrowacInstrument.trn
lro/translations/pdsExportRootGen.typ
lro/translations/mrflev1BandBin.trn
lro/translations/mrflev2BandBin.trn
lro/translations/mrfExportRoot.typ
mariner10/reseaus/mar10VenusNominal.pvl
mariner10/translations/mariner10isis2.trn
mariner10/calibration/mariner_10_A_dc.cub
mariner10/calibration/mariner_10_B_dc.cub
mariner10/reseaus/mar10b.template.cub
mer/translations/merStructure.trn
messenger/translations/mdisInstrument.trn
messenger/translations/mdisInstrument.trn
base/translations/pdsExportRootGen.typ
messenger/testData/EW0031509051D.cub
messenger/testData/EN0089576657M.IMG
messenger/translations/mdisInstrument.trn
mex/translations/hrscInstrument.trn
mro/calibration/ctxFlat_0001.cub
mro/calibration/HiRISE_Gain_Drift_Correction_Bin2.0001.csv
mro/calibration/HiRISE_Gain_Drift_Correction_Bin4.0001.csv
mro/calibration/HiccdstitchOffsets.def
base/translations/pdsExportRootGen.typ
mro/calibration/hijitreg.p1745.s3070.def
output/PSP_007556_2010_RED4.balance.cropped.cub
mro/calibration/psf/PSF_BG.cub
near/translations/nearImportPdsLabel.trn
newhorizons/translations/leisaInstrument_fit.trn
newhorizons/translations/lorriInstrument_fit.trn
newhorizons/translations/mvicInstrument_fit.trn
rolo/translations/roloMapping.trn
rosetta/translations/osirisArchive.trn
viking1/reseaus/nominal.pvl
iking2/reseaus/nominal.pvl
voyager1/calibration/voylin.pvl
apollo15/kernels/pck/moon_080317.tf
viking1/kernels/sclk/vo1_fsc.tsc
base/dems/ulcn2005_lpo_0004.cub
cassini/kernels/fk/cas_v40.tf
lro/kernels/ck/lrolc_2009181_2009213_v02.bc
lro/kernels/spk/fdf29r_2009182_2009213_v01.bsp
odyssey/kernels/fk/m01_v29.tf
cassini/kernels/sclk/cas00110.tsc
hayabusa/dawn/DEM/vesta512.bds
odyssey/kernels/sclk/ORB1_SCLKSCET.00174.tsc
galileo/kernels/sclk/mk00062b.tsc
messenger/kernels/ck/msgr20111015.bc
lro/kernels/spk/fdf29r_2012275_2012306_v01.bsp
apollo15/kernels/tspk/de421.bsp
viking1/kernels/sclk/vo1_fict.tsc
base/dems/ulcn2005_lpo_0004.cub
viking1/kernels/ck/vo1_sedr_ck2.bc
cassini/kernels/ck/05047_05052ra.bc
mro/kernels/ck/mro_sc_psp_061114_061120.bc
lro/kernels/tspk/de421.bsp
odyssey/kernels/ck/m01_sc_map7.bc
odyssey/kernels/ck/m01_sc_map5_rec_nadir.bc
odyssey/kernels/sclk/ORB1_SCLKSCET.00160.tsc
cassini/kernels/iak/vimsAddendum02.ti
viking1/kernels/sclk/vo1_fict.tsc
Apollo/DEM/LRO_LOLA-KaguyaLPF3-mrg_Global_512ppd_radius-demprep.cub
cassini/kernels/sclk/cas00106.tsc
clementine1/kernels/fk/clem_v10.tf
clementine1/kernels/iak/nirAddendum002.ti
hayabusa/dawn/DEM/vesta512.bds
odyssey/kernels/sclk/ORB1_SCLKSCET.00174.tsc
galileo/kernels/sclk/mk00062b.tsc
messenger/kernels/ck/msgr20111014.bc
apollo15/kernels/tspk/moon_pa_de421_1900-2050.bpc
viking1/kernels/iak/vikingAddendum003.ti
base/dems/ulcn2005_lpo_0004.cub
viking1/kernels/spk/vik1_ext.bsp
cassini/kernels/spk/050414RB_SCPSE_05034_05060.bsp
mro/kernels/spk/mro_psp1.bsp
lro/kernels/tspk/moon_pa_de421_1900-2050.bpc
odyssey/kernels/spk/m01_map7.bsp
odyssey/kernels/spk/m01_map5.bsp
odyssey/kernels/iak/themisAddendum003.ti
cassini/kernels/pck/cpck19Sep2007.tpc
mgs/kernels/iak/mocAddendum003.ti
viking1/kernels/fk/vo1_v10.tf
Apollo/DEM/LRO_LOLA-KaguyaLPF3-mrg_Global_512ppd_radius-demprep.cub
cassini/kernels/pck/cpck01Dec2006.tpc
base/dems/Ceres_Dawn_FC_HAMO_DTM_DLR_Global_60ppd_Oct2016_prep.cub
cassini/kernels/pck/cpck01Dec2006.tpc
mgs/kernels/sclk/MGS_SCLKSCET.00060.tsc
hayabusa/dawn/DEM/vesta512.bds
odyssey/kernels/iak/themisAddendum003.ti
galileo/kernels/iak/ssiAddendum004.ti
mro/kernels/spk/mro_psp22.bsp
messenger/kernels/ck/msgr20111013.bc
mro/kernels/spk/mro_psp22.bsp
base/templates/autoreg/findrx.def
viking2/reseaus/vo2.visb.template.cub
viking2/calibration/vik2evenMask.cub
voyager1/kernels/
voyager1/calibration/NA1CLR.CAL.cub
voyager1/calibration/NA1OFF.CAL.cub
voyager1/calibration/voycal.pvl
voyager1/reseaus/vg1naMasterReseaus.pvl
voyager2/translations/
voyager2/kernels/
voyager2/reseaus/nominal.pvl
base/templates/maps/sinusoidal.map
base/applications/noprojInstruments001.pvl
base/applications/noprojInstruments002.pvl
base/applications/noprojInstruments003.pvl
messenger/kernels/ck/1018221575_197834_mdis_pivot_pvtres.bc
messenger/kernels/ck/1018290560_1175_mdis_atthist.bc
messenger/kernels/ck/msgr20120630.bc
messenger/kernels/ck/msgr20120629.bc
messenger/kernels/ck/msgr20120628.bc
messenger/kernels/ck/msgr20120627.bc
messenger/kernels/ck/msgr20120626.bc
messenger/kernels/ck/msgr20120625.bc
messenger/kernels/ck/msgr20120624.bc
messenger/kernels/ck/msgr20120623.bc
messenger/kernels/ck/msgr20120622.bc
messenger/kernels/ck/msgr20120621.bc
messenger/kernels/pck/kernels.0001.db
messenger/kernels/pck/kernels.0002.db
messenger/kernels/pck/kernels.0003.db
messenger/kernels/pck/kernels.0004.db
messenger/kernels/tspk/
messenger/testData/EW0131770376G.equi.cub
mgs/calibration
mro/kernels/fk/
mro/kernels/ik/
mro/kernels/sclk/
base/kernels/lsk/
base/kernels/pck/
base/kernels/spk/de118.bsp
base/kernels/spk/de245.bsp
base/kernels/spk/de405.bsp
base/testData/kernels/de405.bsp
base/kernels/spk/kernels.0001.db
base/kernels/spk/kernels.0002.db
base/testData/kernels/moc.bsp
base/testData/kernels/naif0007.tls
base/testData/kernels/moc.bc
base/testData/kernels/pck00006.tpc
base/testData/kernels/mocSpiceUnitTest.ti
base/testData/kernels/mocAddendum.ti
base/testData/kernels/MGS_SCLKSCET.00045.tsc
base/testData/kernels/moc13.ti
base/kernels/pck/pck00009.tpc
base/kernels/lsk/naif0009.tls
base/kernels/spk/de405.bsp
base/kernels/lsk/naif0009.tls
base/kernels/pck/pck00009.tpc
base/dems/kernels.0003.db
base/dems/kernels.0004.db
base/dems/kernels.0005.db
mgs/testData/ab102401.cub
base/templates/labels/CubeFormatTemplate.pft
mariner10/testData/0027399_clean_equi.cub
mgs/testData/ab102401.lev2.cub
odyssey/testData/I00824006RDR.lev2.cub
base/testData/blobTruth.cub
base/testData/isisTruth.cub
base/testData/isisTruth2.cub
base/testData/xmlTestLabel.xml
base/testData/f319b18_ideal.cub
base/translations/MissionName2DataDir.trn
base/translations/MissionName2DataDir.trn
messenger/testData/EW0211286081G.lev1.cub
messenger/testData/EW0131770376G.equi.cub
base/translations/NaifErrors.trn
mariner10/testData/0027399_clean_equi.cub
dawn/testData/FC21B0001010_09049002212F5D.cub
base/testData/LRONAC_M139722912RE_cropped.cub
base/dems/molaMarsPlanetaryRadius0004.cub
base/dems/molaMarsPlanetaryRadius0005.cub
viking2/testData/f348b26.cub
viking2/kernels/sclk/vo2_fict.tsc
viking2/kernels/iak/vikingAddendum003.ti
clementine1/testData/lna1391h.cub
base/testData/ab102401_ideal.cub
lo/testData/3133_h1.cub
mgs/kernels/ik/moc20.ti
mgs/kernels/iak/mocAddendum004.ti
mgs/kernels/sclk/MGS_SCLKSCET.00061.tsc
viking2/kernels/sclk/vo2_fsc.tsc
hayabusa/kernels/dsk/hay_a_amica_5_itokawashape_v1_0_512q.bds
hayabusa/kernels/pck/itokawa_gaskell_n3.tpc
hayabusa/kernels/tspk/de403s.bsp
hayabusa/kernels/tspk/sb_25143_140.bsp
hayabusa/kernels/spk/hay_jaxa_050916_051119_v1n.bsp
hayabusa/kernels/spk/hay_osbj_050911_051118_v1n.bsp
hayabusa/kernels/ck/hayabusa_itokawarendezvous_v02n.bc
hayabusa/kernels/fk/hayabusa_hp.tf
hayabusa/kernels/fk/itokawa_fixed.tf
hayabusa/kernels/ik/amica31.ti
hayabusa/kernels/iak/amicaAddendum001.ti
hayabusa/kernels/sclk/hayabusa.tsc
base/kernels/spk/de405.bsp
mgs/kernels/spk/mgs_ab1.bsp
mgs/testData/ab102402.lev2.cub
odyssey/testData/I02609002RDR.lev2.cub
mgs/kernels/ck/mgs_sc_ab1.bc
viking2/kernels/spk/vo2_rcon.bsp
apollo15/testData/AS15-M-0533.cropped.cub
apollo15/testData/TL.cub
cassini/testData/W1294561261_1.c2i.nospice.cub
cassini/testData/N1525100863_2.cub
cassini/testData/W1525116136_1.cub
odyssey/testData/I01523019RDR.lev2.cub
odyssey/testData/I01523019RDR.lev2.cub
messenger/testData/EW0131770381F.equi.cub
mariner10/testData/0166613_clean_equi.cub
lo/testData/3133_h1.cropped.cub
lo/testData/3083_med_tohi.cub
mgs/testData/fha00491.lev1.cub
mro/testData/frt0001cfd8_07_if124s_trr3_b24.cub
mro/testData/ctx_pmoi_i_00003.bottom.cub
mro/testData/PSP_001446_1790_BG12_0.cub
mro/testData/P12_005911_3396_MA_00N009W.cropped.cub
mro/kernels/ck/mro_crm_psp_080101_080131.bc
mro/kernels/ck/mro_sc_psp_080108_080114.bc
mro/kernels/spk/mro_psp6.bsp
mro/kernels/ck/mro_sc_psp_080304_080310.bc
mro/kernels/iak/hiriseAddendum006.ti
cassini/testData/N1355543510_1.c2i.nospice.cub
base/dems/ldem_128ppd_Mar2011_clon180_radius_pad.cub
cassini/testData/CM_1515951157_1.ir.cub
clementine1/testData/lub5992r.292.lev1.phot.cub
messenger/testData/EW0213634118G.lev1.cub
galileo/testData/1213r.cub
lo/testData/3083_med_raw.cub
base/dems/ldem_128ppd_Mar2011_clon180_radius_pad.cub
lo/testData/4008_med_res.cropped.cub
mro/testData/ctx_pmoi_i_00003.top.cub
base/dems/ldem_128ppd_Mar2011_clon180_radius_pad.cub
lro/kernels/pck/moon_080317.tf
viking2/kernels/ck/vo2_sedr_ck2.bc
base/dems/ldem_128ppd_Mar2011_clon180_radius_pad.cub
mariner10/kernels/iak/mariner10Addendum002.ti
base/kernels/fk/lunarMeanEarth001.tf
viking2/kernels/fk/vo2_v10.tf
lro/kernels/pck/moon_assoc_me.tf
mro/kernels/iak/mroctxAddendum004.ti
cassini/testData/N1536363784_1.c2i.spice.cub
apollo16/testData/AS16-M-0533.reduced.cub
lo/testData/4164H_Full_mirror.cub
lo/testData/5072_med_res.cropped.cub
cassini/testData/N1313633704_1.c2i.nospice.cub
clementine1/kernels/iak/uvvisAddendum003.ti
clementine1/kernels/ck/clem_5sc.bck
apollo15/kernels/iak/apolloPanAddendum001.ti
mariner10/kernels/sclk/mariner10.0001.tsc
hayabusa/testData/st_2530292409_v.cub
lo/testData/5006_high_res_1.cropped.cub
cassini/testData/CM_1514390782_1.ir.cub
clementine1/kernels/sclk/dspse002.tsc
cassini/kernels/pck/cpck14Feb2006.tpc
apollo15/testData/BL.cub
mro/testData/G02_019106_1390_XN_41S257W.cub
apollo17/testData/AS17-M-0543.reduced.cub
cassini/kernels/iak/vimsAddendum03.ti
base/dems/ulcn2005_lpo_0004.cub
base/dems/molaMarsPlanetaryRadius0001.cub
apollo15/testData/M.cub
mro/apps/hiequal/tsts/default/input/RED0.cub
cassini/kernels/sclk/cas00130.tsc
cassini/kernels/sclk/cas00112.tsc
cassini/testData/CM_1514390782_1.vis.cub
cassini/testData/CM_1515945709_1.ir.cub
cassini/kernels/pck/cpck21Mar2006.tpc
cassini/testData/CM_1515945709_1.vis.cub
cassini/testData/C1465336166_1.ir.cub
apollo15/testData/TR.cub
apollo15/testData/BR.cub
mgs/testData/ab102401.cub
base/templates/labels/MappingGroupKeywords.pft
odyssey/testData/I00824006RDR.lev2.cub
odyssey/testData/I56632006EDR.lev2.cub
odyssey/testData/I02609002RDR.lev2.cub
odyssey/testData/I01523019RDR.lev2.cub
viking2/reseaus/vik2bMasterReseaus.pvl
mgs/testData/m0402852.cub
mariner10/reseaus/mar10aMasterReseaus.pvl
lo/testData/3133_h1.cub
base/translations/NaifErrors.trn
base/testData/blobTruth.cub
base/testData/isisTruthNoSpacecraftName.cub
base/testData/isisTruthNoInstrumentId.cub
lo/testData/5106_h1.cropped.cub
lo/testData/5106_h2.cropped.cub
mgs/calibration/MGSC_1246_wago.tab
mgs/calibration/MGSC_1290_wago.tab
mgs/calibration/MGSC_1428_wago.tab
mgs/calibration/MGSC_1546_wago.tab
mgs/calibration/MGSC_1578_wago.tab
clementine1/kernels/ck/clem_ulcn2005_type2_1sc.bc
clementine1/kernels/fk/clem_v11.tf
clementine1/kernels/sclk/dspse002.tsc
clementine1/kernels/spk/SPKMERGE_940219_940504_CLEMV001b.bsp
clementine1/kernels/iak/uvvisAddendum003.ti
base/templates/maps/equirectangular.map
newhorizons/calibration/NHSmileDefinitionNew.cub
messenger/kernels/tspk/de423s.bsp
messenger/kernels/tspk/kernels.0001.db
messenger/kernels/tspk/kernels.0002.db
messenger/kernels/tspk/kernels.0003.db
messenger/kernels/spk/msgr_20040803_20150328_od332sc_0.bsp
messenger/kernels/spk/msgr_20040803_20150430_od431sc_2.bsp
messenger/kernels/sclk/messenger_1930.tsc
base/translations/pdsProjectionLineSampToXY.def
'''

    dbList = '''
mro/kernels/
messenger/kernels/
messenger/kernels/spk/
apollo15/kernels/
base/translations/
lo/translations/
mgs/translations/
odyssey/translations/
odyssey/kernels/ck/
odyssey/kernels/ik/
odyssey/kernels/iak/
odyssey/kernels/sclk/
odyssey/kernels/fk/
odyssey/kernels/spk/
mro/translations/
voyager1/kernels/
mgs/kernels/
cassini/kernels/
cassini/calibration/
lro/calibration/
lro/kernels/
messenger/calibration/
newhorizons/kernels/
base/dems/
'''

    fileList = fileList.split()
    dbList   = dbList.split()

    # TODO: Input argument
    installDir = '/home/smcmich1/release_isis/isis3data/'
    #installDir = '/Users/smcmich1/release_isis/isis3data/'

    cmd    = 'rsync -azv --delete --partial '
    remote = 'isisdist.astrogeology.usgs.gov::isis3data/data/'

    for f in fileList:

        # Set up commands
        target = installDir + f
        
        print target
        
        # Don't refetch existing files
        if os.path.exists(target) and (not os.path.isdir(target)):
            continue
        
        # Fetch the file
        fullCmd = cmd + remote + f +' '+ target
        print fullCmd
        os.system('mkdir -p ' + os.path.dirname(target))
        os.system(fullCmd)

    # This is for folders where we want just the small files
    for f in dbList:
        fullCmd = (cmd + remote + f+' --max-size=5m ' + installDir+f)
        print fullCmd
        os.system('mkdir -p '+ installDir +f)
        os.system(fullCmd)



if __name__ == '__main__':
    sys.exit( main() )
