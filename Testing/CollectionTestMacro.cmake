INCLUDE( ParseArgumentsMacro.cmake )

#  Helper macro that will run the set of operations in a given dataset.
#
MACRO(FEATURE_SCREEN_SHOT DATASET_ID OBJECT_ID ISO_VALUE CONTOUR_ID)

SET(DATASET_OBJECT_ID ${DATASET_ID}_${OBJECT_ID})
SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha)

SET(SEEDS_FILE ${TEST_DATA_ROOT}/Input/${DATASET_OBJECT_ID}_Seeds.txt)

ADD_TEST(SCRN_${CONTOUR_ID}_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ViewImageSlicesAndSegmentationContours
  ${DATASET_ROI}
  ${SEEDS_FILE}
  ${ISO_VALUE}
  1
  ${TEMP}/${CONTOUR_ID}_Test${DATASET_OBJECT_ID}.png
  ${TEMP}/${CONTOUR_ID}_Test${DATASET_ID}.mha
  )

ENDMACRO(FEATURE_SCREEN_SHOT)


MACRO(VOLUME_ESTIMATION_A DATASET_ID OBJECT_ID SEGMENTATION_METHOD_ID EXPECTED_VOLUME)
SET(DATASET_OBJECT_ID ${DATASET_ID}_${OBJECT_ID})
ADD_TEST(LSMTVEA${SEGMENTATION_METHOD_ID}_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkGrayscaleImageSegmentationVolumeEstimatorTest2
  ${TEMP}/LSMT${SEGMENTATION_METHOD_ID}_Test${DATASET_OBJECT_ID}.mha
  LSMT${SEGMENTATION_METHOD_ID}
  ${DATASET_ID}
  ${EXPECTED_VOLUME}
  ${TEMP}/VolumeEstimationA_${DATASET_OBJECT_ID}.txt
  )
ENDMACRO(VOLUME_ESTIMATION_A)


MACRO(VOLUME_ESTIMATION_B DATASET_ID OBJECT_ID SEGMENTATION_METHOD_ID EXPECTED_VOLUME)
SET(DATASET_OBJECT_ID ${DATASET_ID}_${OBJECT_ID})
SET(ISO_VALUE -0.5) # Compensate for half-pixel shift in Canny-Edges
IF(LSTK_SANDBOX_USE_VTK)
  ADD_TEST(LSMTVEB${SEGMENTATION_METHOD_ID}_${DATASET_OBJECT_ID}
    ${CXX_TEST_PATH}/IsoSurfaceVolumeEstimation
    ${TEMP}/LSMT${SEGMENTATION_METHOD_ID}_Test${DATASET_OBJECT_ID}.mha
    ${ISO_VALUE}
    LSMT${SEGMENTATION_METHOD_ID}
    ${DATASET_ID}
    ${EXPECTED_VOLUME}
    ${TEMP}/VolumeEstimationB_${DATASET_OBJECT_ID}.txt
    )
ENDIF(LSTK_SANDBOX_USE_VTK)
ENDMACRO(VOLUME_ESTIMATION_B)


MACRO(SEGMENTATION_SCREEN_SHOT DATASET_ID OBJECT_ID ISO_VALUE CONTOUR_ID)

SET(DATASET_OBJECT_ID ${DATASET_ID}_${OBJECT_ID})
SET(SEEDS_FILE ${TEST_DATA_ROOT}/Input/${DATASET_OBJECT_ID}_Seeds.txt)
SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha)

ADD_TEST(SCRN_${CONTOUR_ID}_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ViewImageSlicesAndSegmentationContours
  ${DATASET_ROI}
  ${SEEDS_FILE}
  ${ISO_VALUE}
  1
  ${TEMP}/${CONTOUR_ID}_Test${DATASET_OBJECT_ID}.png
  ${TEMP}/${CONTOUR_ID}_Test${DATASET_OBJECT_ID}.mha
  )

ENDMACRO(SEGMENTATION_SCREEN_SHOT)




MACRO(CONVERT_DICOM_TO_META COLLECTION_PATH DATASET_ID DATASET_DIRECTORY)

# Dicom to Meta
ADD_TEST(DTM_${DATASET_ID}
  ${CXX_TEST_PATH}/DicomSeriesReadImageWrite
  ${COLLECTION_PATH}/${DATASET_DIRECTORY}
  ${TEMP}/${DATASET_ID}.mha
  )

ENDMACRO(CONVERT_DICOM_TO_META)


MACRO(EXTRACT_REGION_OF_INTEREST MASTER_DATASET_ID DATASET_ID ROI_X ROI_Y ROI_Z ROI_DX ROI_DY ROI_DZ)

SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha)

# Extract Region of Interest
ADD_TEST(ROI_${DATASET_ID}
  ${CXX_TEST_PATH}/ImageReadRegionOfInterestWrite
  ${TEMP}/${MASTER_DATASET_ID}.mha
  ${DATASET_ROI}
  ${ROI_X} ${ROI_Y} ${ROI_Z} 
  ${ROI_DX} ${ROI_DY} ${ROI_DZ} 
  )

ENDMACRO(EXTRACT_REGION_OF_INTEREST)


MACRO(GENERATE_FEATURES DATASET_ID)

SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha)

# Gradient Magnitude Sigmoid Feature Generator
ADD_TEST(GMSFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkGradientMagnitudeSigmoidFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/GMSFG_Test${DATASET_ID}.mha
  0.7    # Sigma
  -0.1   # Alpha
  150.0  # Beta
  )

# Sigmoid Feature Generator
ADD_TEST(SFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkSigmoidFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/SFG_Test${DATASET_ID}.mha
   100.0 # Alpha
  -500.0 # Beta: Lung Threshold
  )

# Binary Threshold Feature Generator
ADD_TEST(BTFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkBinaryThresholdFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/BTFG_Test${DATASET_ID}.mha
  -200.0 # Beta: Lung Threshold
  )

# Lung Wall Feature Generator
ADD_TEST(LWFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkLungWallFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/LWFG_Test${DATASET_ID}.mha
  -400.0 # Lung Threshold
  )

# Morphological Openning Feature Generator
ADD_TEST(MOFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkMorphologicalOpenningFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/MOFG_Test${DATASET_ID}.mha
  -400.0 # Lung Threshold
  )

# Canny Edges Feature Generator
ADD_TEST(CEFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkCannyEdgesFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/CEFG_Test${DATASET_ID}.mha
    1.0 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )

# Canny Edges Feature Generator
ADD_TEST(CEDFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkCannyEdgesDistanceFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/CEDFG_Test${DATASET_ID}.mha
    1.0 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )

# Sato Vesselness Feature Generator
ADD_TEST(SVFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkSatoVesselnessSigmoidFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/SVFG_Test${DATASET_ID}.mha
  1.0   # Sigma
  0.5   # Vesselness Alpha1
  2.0   # Vesselness Alpha2
  )

# Sato Vesselness Sigmoid Feature Generator
ADD_TEST(SVSFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkSatoVesselnessSigmoidFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/SVSFG_Test${DATASET_ID}.mha
  1.0   # Sigma
  0.1   # Vesselness Alpha1
  2.0   # Vesselness Alpha2
  -10.0 # Sigmoid Alpha
  80.0  # Sigmoid Beta
  )

# Vessel enhancing diffusion test
ADD_TEST(VED_${DATASET_ID}
  ${CXX_TEST_PATH}/itkVEDTest
  ${DATASET_ROI}
  ${TEMP}/VED_Test${DATASET_ID}.mha  )

ADD_TEST(SLSFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkSatoLocalStructureFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/SLSFG_Test${DATASET_ID}.mha
  1.0  # Sigma
  0.5  # Alpha
  2.0  # Gamma
  )

ADD_TEST(DSFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkDescoteauxSheetnessFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/DSFG_Test${DATASET_ID}.mha
  1      # Search for Bright sheets
  1.0    # Sigma
  100.0  # Sheetness
  100.0  # Bloobiness
  100.0  # Noise
  )

ADD_TEST(FTFG_${DATASET_ID}
  ${CXX_TEST_PATH}/itkFrangiTubularnessFeatureGeneratorTest1
  ${DATASET_ROI}
  ${TEMP}/FTFG_Test${DATASET_ID}.mha
  1.0    # Sigma
  100.0  # Sheetness
  100.0  # Bloobiness
  100.0  # Noise
  )
ENDMACRO(GENERATE_FEATURES)


MACRO(SCREEN_SHOT_FEATURES DATASET_ID OBJECT_ID)

IF( LSTK_SANDBOX_USE_VTK )

SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha)
SET(DATASET_OBJECT_ID ${DATASET_ID}_${OBJECT_ID})

# Screen shots of feature generators
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 GMSFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 SFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 LWFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 MOFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 SVFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 SVSFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 SLSFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 DSFG )
FEATURE_SCREEN_SHOT( ${DATASET_ID} ${OBJECT_ID} 0.5 FTFG )

ADD_TEST(SCRN_AFG_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ViewImageSlicesAndSegmentationContours
  ${DATASET_ROI}
  ${SEEDS_FILE}
  0.0
  1
  ${TEMP}/SCRN_AFG_${DATASET_OBJECT_ID}.png
  ${TEMP}/GMSFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/SFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/LWFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/MOFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/SVFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/SVSFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/SLSFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/DSFG_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/FTFG_Test${DATASET_OBJECT_ID}.mha
  )
ENDIF( LSTK_SANDBOX_USE_VTK )

ENDMACRO(SCREEN_SHOT_FEATURES) 


MACRO(COMPUTE_SEGMENTATIONS DATASET_ID OBJECT_ID EXPECTED_VOLUME)

PARSE_ARGUMENTS( COMPUTE_SEGMENTATIONS_OPTIONS "" "AROUND_SEED" ${ARGN} )

SET(DATASET_OBJECT_ID ${DATASET_ID}_${OBJECT_ID})
SET(SEEDS_FILE ${TEST_DATA_ROOT}/Input/${DATASET_OBJECT_ID}_Seeds.txt)

SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha )
SET(DATASET_ROI_SEED ${TEMP}/${DATASET_OBJECT_ID}_ROI.mha)
SET(REGION_RADIUS 10)  # in millimeters

ADD_TEST(ROIS_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ImageReadRegionOfInterestAroundSeedWrite
  ${TEMP}/${DATASET_ID}_ROI.mha
  ${DATASET_ROI_SEED}
  ${SEEDS_FILE}
  ${REGION_RADIUS}
  )

IF ( COMPUTE_SEGMENTATIONS_OPTIONS_AROUND_SEED )
  SET(DATASET_ROI ${DATASET_ROI_SEED} )  
ENDIF( COMPUTE_SEGMENTATIONS_OPTIONS_AROUND_SEED )

# Resample to isotropic with different interpolation kernels
ADD_TEST(RVTI_BSpline_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ResampleVolumeToBeIsotropic
  ${DATASET_ROI}
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_BSpline_Isotropic.mha
  0.2 # 0.2mm
  0   # BSpline interpolation  
  )
ADD_TEST(RVTI_HWSinc_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ResampleVolumeToBeIsotropic
  ${DATASET_ROI}
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_HWSinc_Isotropic.mha
  0.2 # 0.2mm
  1   # HammingWindowedSinc
  )
ADD_TEST(RVTI_Linear_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ResampleVolumeToBeIsotropic
  ${DATASET_ROI}
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_Linear_Isotropic.mha
  0.2 # 0.2mm
  2   # Linear interpolation  
  )

ADD_TEST(CEFG_BSpline_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkCannyEdgesFeatureGeneratorTest1
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_BSpline_Isotropic.mha
  ${TEMP}/CEFG_Test${DATASET_OBJECT_ID}_BSpline_Isotropic_Sigma0.47.mha
    .47 # Sigma
  150.0 # Upper threshold
   25.0 # Lower threshold
  )
ADD_TEST(CEFG_HWSinc_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkCannyEdgesFeatureGeneratorTest1
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_HWSinc_Isotropic.mha
  ${TEMP}/CEFG_Test${DATASET_OBJECT_ID}_HWSinc_Isotropic_Sigma0.47.mha
    .47 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )
ADD_TEST(CEFG_Linear_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkCannyEdgesFeatureGeneratorTest1
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_Linear_Isotropic.mha
  ${TEMP}/CEFG_Test${DATASET_OBJECT_ID}_Linear_Isotropic_Sigma0.47.mha
    .47 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )

ADD_TEST(LFG_BSpline_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/LaplacianRecursiveGaussianImageFilter
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_BSpline_Isotropic.mha
  ${TEMP}/LFG_Test${DATASET_OBJECT_ID}_BSpline_Isotropic_Sigma0.47.mha
    .47 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )
ADD_TEST(LFG_HWSinc_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/LaplacianRecursiveGaussianImageFilter
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_HWSinc_Isotropic.mha
  ${TEMP}/LFG_Test${DATASET_OBJECT_ID}_HWSinc_Isotropic_Sigma0.47.mha
    .47 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )
ADD_TEST(LFG_Linear_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/LaplacianRecursiveGaussianImageFilter
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_Linear_Isotropic.mha
  ${TEMP}/LFG_Test${DATASET_OBJECT_ID}_Linear_Isotropic_Sigma0.47.mha
    0.47 # Sigma
  150.0 # Upper threshold
   75.0 # Lower threshold
  )

# Sigmoid Feature Generator
ADD_TEST(SFG_BSpline_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkSigmoidFeatureGeneratorTest1
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_BSpline_Isotropic.mha
  ${TEMP}/SFG_BSpline_Test${DATASET_OBJECT_ID}.mha
   100.0 # Alpha
  -500.0 # Beta: Lung Threshold
  )

# Sato Vesselness Sigmoid Feature Generator
ADD_TEST(SVSFG_BSpline_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkSatoVesselnessSigmoidFeatureGeneratorTest1
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_BSpline_Isotropic.mha
  ${TEMP}/SVSFG_BSpline_Test${DATASET_OBJECT_ID}.mha
  1.0   # Sigma
  0.1   # Vesselness Alpha1
  2.0   # Vesselness Alpha2
  -10.0 # Sigmoid Alpha
  40.0  # Sigmoid Beta
  )

ADD_TEST(LWFG_BSpline_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLungWallFeatureGeneratorTest1
  ${TEMP}/RVTI_Test${DATASET_OBJECT_ID}_BSpline_Isotropic.mha
  ${TEMP}/LWFG_BSpline_Test${DATASET_OBJECT_ID}.mha
  -400.0 # Lung Threshold
  )


ADD_TEST(CTRG_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkConnectedThresholdSegmentationModuleTest1
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/CTRG_Test${DATASET_OBJECT_ID}.mha
  -700  # Lower Threshold
  500   # Upper Threshold
  )

ADD_TEST(LSMT3_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest3
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT3_Test${DATASET_OBJECT_ID}.mha
  0.5  # Lower Threshold
  1.0  # Upper Threshold
  )

ADD_TEST(LSMT4_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest4
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT4_Test${DATASET_OBJECT_ID}.mha
  500   # Stopping time for Fast Marching termination
    5   # Distance from seeds for Fast Marching initialization
  )

ADD_TEST(LSMT5_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest5
  ${TEMP}/LSMT4_Test${DATASET_OBJECT_ID}.mha
  ${DATASET_ROI}
  ${TEMP}/LSMT5_Test${DATASET_OBJECT_ID}.mha
  0.0002  # RMS maximum error
  300     # Maximum number of iterations
   1.0    # Curvature scaling
  10.0    # Propagation scaling
  )

ADD_TEST(LSMT6_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest6
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT6_Test${DATASET_OBJECT_ID}.mha
  0.0002  # RMS maximum error
  300     # Maximum number of iterations
   1.0    # Curvature scaling
  10.0    # Propagation scaling
  500     # Stopping time for Fast Marching termination
    5     # Distance from seeds for Fast Marching initialization
  )

ADD_TEST(LSMT7_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest7
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT7_Test${DATASET_OBJECT_ID}.mha
  )

ADD_TEST(LSMT8_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8_Test${DATASET_OBJECT_ID}.mha
  )

ADD_TEST(LSMT8b_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8b
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8b_Test${DATASET_OBJECT_ID}.mha
  -200  # Threshold used for solid lesions
  )

ADD_TEST(LSMT8c_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8b
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8c_Test${DATASET_OBJECT_ID}.mha
  -500  # Threshold used for part-solid lesions
  )

ADD_TEST(LSMT8d_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8b
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8d_Test${DATASET_OBJECT_ID}.mha
  -200  # Threshold used for solid lesions
  -ResampleThickSliceData     # Supersample
  )

ADD_TEST(LSMT8e_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8b
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8e_Test${DATASET_OBJECT_ID}.mha
  -500  # Threshold used for part-solid lesions
  -ResampleThickSliceData     # Supersample
  )

ADD_TEST(LSMT8dVED_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8b
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8dVED_Test${DATASET_OBJECT_ID}.mha
  -200  # Threshold used for solid lesions
  -ResampleThickSliceData     # Supersample
  -UseVesselEnhancingDiffusion
  )

ADD_TEST(LSMT8eVED_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest8b
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT8eVED_Test${DATASET_OBJECT_ID}.mha
  -500  # Threshold used for part-solid lesions
  -ResampleThickSliceData     # Supersample
  -UseVesselEnhancingDiffusion
  )


ADD_TEST(LSMT9_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest9
  ${SEEDS_FILE}
  ${DATASET_ROI}
  ${TEMP}/LSMT9_Test${DATASET_OBJECT_ID}.mha
  )

# Supersampled version
ADD_TEST(LSMT10_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/itkLesionSegmentationMethodTest10
  ${SEEDS_FILE}
  ${DATASET_ROI_SEED}
  ${TEMP}/LSMTS8_Test${DATASET_OBJECT_ID}.mha
  )


VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 3 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 4 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 5 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 6 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 7 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 8 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_A( ${DATASET_ID} ${OBJECT_ID} 9 ${EXPECTED_VOLUME} )

VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 3 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 4 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 5 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 6 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 7 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 9 ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8b ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8c ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8d ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8e ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8dVED ${EXPECTED_VOLUME} )
VOLUME_ESTIMATION_B( ${DATASET_ID} ${OBJECT_ID} 8eVED ${EXPECTED_VOLUME} )


IF( LSTK_SANDBOX_USE_VTK )

# Screen shots of segmentations
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT3 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT4 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT5 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT6 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT7 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT8 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT9 )
SEGMENTATION_SCREEN_SHOT( ${DATASET_ID}  ${OBJECT_ID}  0.0   LSMT8b )

ADD_TEST(SCRN_ALSM_${DATASET_OBJECT_ID}
  ${CXX_TEST_PATH}/ViewImageSlicesAndSegmentationContours
  ${DATASET_ROI}
  ${SEEDS_FILE}
  0.0
  1
  ${TEMP}/SCRN_ALSM_${DATASET_OBJECT_ID}.png
  ${TEMP}/LSMT3_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/LSMT4_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/LSMT5_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/LSMT6_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/LSMT7_Test${DATASET_OBJECT_ID}.mha
  ${TEMP}/LSMT8_Test${DATASET_OBJECT_ID}.mha
  )
ENDIF( LSTK_SANDBOX_USE_VTK )

ENDMACRO(COMPUTE_SEGMENTATIONS)



MACRO(TEST_DATASET_FROM_COLLECTION COLLECTION_PATH DATASET_ID DATASET_DIRECTORY ROI_X ROI_Y ROI_Z ROI_DX ROI_DY ROI_DZ)

SET(DATASET_ROI ${TEMP}/${DATASET_ID}_ROI.mha)

CONVERT_DICOM_TO_META( ${COLLECTION_PATH} ${DATASET_ID} ${DATASET_DIRECTORY} )
EXTRACT_REGION_OF_INTEREST( ${DATASET_ID} ${ROI_X} ${ROI_Y} ${ROI_Z} ${ROI_DX} ${ROI_DY} ${ROI_DZ} )
GENERATE_FEATURES( ${DATASET_ID} )
COMPUTE_SEGMENTATIONS( ${DATASET_ID} 001 400.0)

ENDMACRO(TEST_DATASET_FROM_COLLECTION)

