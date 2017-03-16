
import sys, os

def main():
    
    # Hardcoded list of downloadable files needed to run tests
    fileList = '''
mgs/calibration
mro/kernels/fk/
mro/kernels/ik/
mro/kernels/sclk/
base/kernels/lsk/
base/kernels/pck/
base/kernels/spk/de118.bsp
base/kernels/spk/de245.bsp
base/kernels/spk/de405.bsp
base/kernels/spk/kernels.0001.db
base/kernels/spk/kernels.0002.db
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
base/kernels/lsk/naif0009.tls
base/kernels/pck/pck00009.tpc
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
base/translations/MissionName2DataDir.trn
base/translations/Instruments.trn
base/translations/SerialNumber0001.trn
base/translations/SerialNumber0002.trn
lo/testData/3133_h1.cub
lo/translations/loSerialNumber0001.trn
lo/translations/loSerialNumber0002.trn
lo/translations/loSerialNumber0003.trn
lo/translations/loSerialNumber0004.trn
mgs/translations/mocSerialNumber0001.trn
mgs/translations/mocSerialNumber0002.trn
mgs/translations/mocSerialNumber0003.trn
mgs/translations/mocSerialNumber0004.trn
odyssey/translations/themisSerialNumber0001.trn
odyssey/translations/themisSerialNumber0002.trn
odyssey/translations/themisSerialNumber0003.trn
odyssey/translations/themisSerialNumber0004.trn
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
base/kernels/lsk/naif0009.tls
base/kernels/spk/de405.bsp
clementine1/kernels/ck/clem_ulcn2005_type2_1sc.bc
clementine1/kernels/fk/clem_v11.tf
clementine1/kernels/sclk/dspse002.tsc
clementine1/kernels/spk/SPKMERGE_940219_940504_CLEMV001b.bsp
clementine1/kernels/iak/uvvisAddendum003.ti
base/templates/maps/equirectangular.map
'''

    dbList = '''
mro/kernels/ck/
mro/kernels/spk/
mro/kernels/iak/
'''

    fileList = fileList.split()
    dbList   = dbList.split()

    # TODO: Input argument
    #installDir = '/home/smcmich1/release_isis/isis3data/'
    installDir = '/Users/smcmich1/isis3data/'

    cmd    = 'rsync -azv --delete --partial '
    remote = 'isisdist.astrogeology.usgs.gov::isis3data/data/'

    for f in fileList:

        # Set up commands
        target = installDir + f
        
        print target
        
        # Don't refetch existing files
        if os.path.exists(target):
            continue
        
        # Fetch the file
        fullCmd = cmd + remote + f +' '+ target
        print fullCmd
        os.system('mkdir -p ' + os.path.dirname(target))
        os.system(fullCmd)

    # This is for folders where we want just the small .db files
    for f in dbList:
        fullCmd = (cmd + remote + f+' --include="*.db" --exclude="*" ' + installDir+f)
        print fullCmd
        os.system('mkdir -p '+ installDir +f)
        os.system(fullCmd)



if __name__ == '__main__':
    sys.exit( main() )
