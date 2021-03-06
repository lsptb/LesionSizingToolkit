/*=========================================================================

  Program:   Lesion Sizing Toolkit
  Module:    itkLesionSegmentationMethodTest10.cxx

  Copyright (c) Kitware Inc. 
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/

// The test runs a shape detection level set from user supplied seed points
// and then runs the shape detection level set with the results from the 
// fast marching to get the final segmentation.

#include "itkLesionSegmentationMethod.h"
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkLandmarksReader.h"
#include "itkImageMaskSpatialObject.h"
#include "itkIsotropicResampler.h"
#include "itkLungWallFeatureGenerator.h"
#include "itkSatoVesselnessSigmoidFeatureGenerator.h"
#include "itkCannyEdgesFeatureGenerator.h"
#include "itkSigmoidFeatureGenerator.h"
#include "itkFastMarchingAndGeodesicActiveContourLevelSetSegmentationModule.h"
#include "itkMinimumFeatureAggregator.h"

int main( int argc, char * argv [] )
{

  if( argc < 3 )
    {
    std::cerr << "Applies fast marhching followed by segmentation using geodesic active contours. Arguments" << std::endl;
    std::cerr << argv[0] << "\n\tlandmarksFile\n\tinputImage\n\toutputImage ";
    std::cerr << "\n\t[CannySigma]"
              << "\n\t[CannyUpperThreshold]"
              << "\n\t[CannyLowerThreshold]"
              << "\n\t[RMSErrorForGeodesicActiveContour]"
              << "\n\t[IterationsForGeodesicActiveContour]"
              << "\n\t[CurvatureScalingForGeodesicActiveContour]"
              << "\n\t[PropagationScalingForGeodesicActiveContour]"
              << "\n\t[AdvectionScalingForGeodesicActiveContour]";
    std::cerr << "\n\t[stopping time for fast marching]";
    std::cerr << "\n\t[distance from seeds for fast marching]" << std::endl;
    return EXIT_FAILURE;
    }


  const unsigned int Dimension = 3;
  typedef signed short   InputPixelType;

  typedef itk::Image< InputPixelType, Dimension > InputImageType;

  typedef itk::ImageFileReader< InputImageType > InputImageReaderType;
  InputImageReaderType::Pointer inputImageReader = InputImageReaderType::New();

  inputImageReader->SetFileName( argv[2] );

  try 
    {
    inputImageReader->Update();
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }


  typedef itk::LesionSegmentationMethod< Dimension >   MethodType;

  MethodType::Pointer  lesionSegmentationMethod = MethodType::New();
  
  typedef itk::ImageMaskSpatialObject< Dimension > ImageMaskSpatialObjectType;

  ImageMaskSpatialObjectType::Pointer regionOfInterest = ImageMaskSpatialObjectType::New();

  lesionSegmentationMethod->SetRegionOfInterest( regionOfInterest );

  typedef itk::SatoVesselnessSigmoidFeatureGenerator< Dimension > VesselnessGeneratorType;
  VesselnessGeneratorType::Pointer vesselnessGenerator = VesselnessGeneratorType::New();

  typedef itk::LungWallFeatureGenerator< Dimension > LungWallGeneratorType;
  LungWallGeneratorType::Pointer lungWallGenerator = LungWallGeneratorType::New();

  typedef itk::SigmoidFeatureGenerator< Dimension >   SigmoidFeatureGeneratorType;
  SigmoidFeatureGeneratorType::Pointer  sigmoidGenerator = SigmoidFeatureGeneratorType::New();
 
  typedef itk::CannyEdgesFeatureGenerator< Dimension >   CannyEdgesFeatureGeneratorType;
  CannyEdgesFeatureGeneratorType::Pointer  cannyEdgesGenerator = CannyEdgesFeatureGeneratorType::New();
 
  typedef itk::MinimumFeatureAggregator< Dimension >   FeatureAggregatorType;
  FeatureAggregatorType::Pointer featureAggregator = FeatureAggregatorType::New();

  featureAggregator->AddFeatureGenerator( lungWallGenerator );
  featureAggregator->AddFeatureGenerator( vesselnessGenerator );
  featureAggregator->AddFeatureGenerator( cannyEdgesGenerator );
  featureAggregator->AddFeatureGenerator( sigmoidGenerator );

  lesionSegmentationMethod->AddFeatureGenerator( featureAggregator );

  typedef MethodType::SpatialObjectType    SpatialObjectType;
  typedef itk::ImageSpatialObject< Dimension, InputPixelType  > InputImageSpatialObjectType;
  InputImageSpatialObjectType::Pointer inputObject = InputImageSpatialObjectType::New();

  InputImageType::Pointer inputImage = inputImageReader->GetOutput();

  inputImage->DisconnectPipeline();

  typedef itk::IsotropicResampler< Dimension >   ResampleFilterType;
  typedef ResampleFilterType::SpatialObjectType    SpatialObjectType;

  ResampleFilterType::Pointer  resampler = ResampleFilterType::New();
 
  inputObject->SetImage( inputImage );

  resampler->SetInput( inputObject );

  try 
    {
    resampler->Update();
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

  SpatialObjectType::ConstPointer resampledObject = resampler->GetOutput();

  lungWallGenerator->SetInput( resampledObject );
  vesselnessGenerator->SetInput( resampledObject );
  sigmoidGenerator->SetInput( resampledObject );
  cannyEdgesGenerator->SetInput( resampledObject );

  lungWallGenerator->SetLungThreshold( -400 );

  vesselnessGenerator->SetSigma( 1.0 );
  vesselnessGenerator->SetAlpha1( 0.1 );
  vesselnessGenerator->SetAlpha2( 2.0 );
  vesselnessGenerator->SetSigmoidAlpha( -10.0 );
  vesselnessGenerator->SetSigmoidBeta( 80.0 );

  sigmoidGenerator->SetAlpha(  100.0 );
  sigmoidGenerator->SetBeta(  -500.0 );

  double spacing[3] = { inputImage->GetSpacing()[0],
                        inputImage->GetSpacing()[1],
                        inputImage->GetSpacing()[2] };
  double maxSpacing = (spacing[0] > spacing[1] ? spacing[0] : spacing[1]);
  maxSpacing = (maxSpacing > spacing[2] ? maxSpacing : spacing[2]);
  
  cannyEdgesGenerator->SetSigma( argc > 4 ? atof(argv[4]) : maxSpacing );
  cannyEdgesGenerator->SetUpperThreshold( argc > 5 ? atof(argv[5]) : 150.0 );
  cannyEdgesGenerator->SetLowerThreshold( argc > 6 ? atof(argv[6]) :  75.0 );

  typedef itk::FastMarchingAndGeodesicActiveContourLevelSetSegmentationModule< Dimension > SegmentationModuleType;
  SegmentationModuleType::Pointer  segmentationModule = SegmentationModuleType::New();
  segmentationModule->SetMaximumRMSError( argc > 7 ? atof(argv[7]) : 0.0002 );
  segmentationModule->SetMaximumNumberOfIterations( argc > 8 ? atoi(argv[8]) : 300 );
  segmentationModule->SetCurvatureScaling( argc > 9 ? atof(argv[9]) : 1.0 );
  segmentationModule->SetPropagationScaling( argc > 10 ? atof(argv[10]) : 500.0 );
  segmentationModule->SetAdvectionScaling( argc > 11 ? atof(argv[11]) : 0.0 );
  segmentationModule->SetStoppingValue( argc > 12 ? atof(argv[12]) : 5.0 );
  segmentationModule->SetDistanceFromSeeds( argc > 13 ? atof(argv[13]) : 0.5 );
  lesionSegmentationMethod->SetSegmentationModule( segmentationModule );

  typedef itk::LandmarksReader< Dimension >    LandmarksReaderType;
  
  LandmarksReaderType::Pointer landmarksReader = LandmarksReaderType::New();

  landmarksReader->SetFileName( argv[1] );
  landmarksReader->Update();

  lesionSegmentationMethod->SetInitialSegmentation( landmarksReader->GetOutput() );

  lesionSegmentationMethod->Update();

  
  typedef SegmentationModuleType::SpatialObjectType           SpatialObjectType;
  typedef SegmentationModuleType::OutputSpatialObjectType     OutputSpatialObjectType;
  typedef SegmentationModuleType::OutputImageType             OutputImageType;

  SpatialObjectType::ConstPointer segmentation = segmentationModule->GetOutput();

  OutputSpatialObjectType::ConstPointer outputObject = 
    dynamic_cast< const OutputSpatialObjectType * >( segmentation.GetPointer() );

  OutputImageType::ConstPointer outputImage = outputObject->GetImage();

  typedef itk::ImageFileWriter< OutputImageType >      OutputWriterType;
  OutputWriterType::Pointer writer = OutputWriterType::New();

  writer->SetFileName( argv[3] );
  writer->SetInput( outputImage );
  writer->UseCompressionOn();


  try 
    {
    writer->Update();
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }


  // 
  // Exercise the exception on the number of feature generators
  //
  lesionSegmentationMethod->AddFeatureGenerator( lungWallGenerator );

  try 
    {
    lesionSegmentationMethod->Update();
    std::cerr << "Failure to throw expected exception" << std::endl;
    return EXIT_FAILURE;
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cout << "Caught expected exception " << std::endl;
    std::cout << excp << std::endl;
    }


  return EXIT_SUCCESS;
}
