/*=========================================================================

  Program:   Lesion Sizing Toolkit
  Module:    itkFastMarchingSegmentationModuleTest1.cxx

  Copyright (c) Kitware Inc. 
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/

#include "itkFastMarchingSegmentationModule.h"
#include "itkImage.h"
#include "itkSpatialObject.h"
#include "itkImageSpatialObject.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkLandmarksReader.h"

int main( int argc, char * argv [] )
{

  if( argc < 3 )
    {
    std::cerr << "Missing Arguments" << std::endl;
    std::cerr << argv[0] << "\n\tlandmarksFile\n\tfeatureImage\n\toutputImage ";
    std::cerr << "\n\tstopping time for fast marching";
    std::cerr << "\n\tdistance from seeds for fast marching" << std::endl;
    return EXIT_FAILURE;
    }

  const unsigned int Dimension = 3;
  typedef itk::FastMarchingSegmentationModule< Dimension >   SegmentationModuleType;

  typedef SegmentationModuleType::FeatureImageType     FeatureImageType;
  typedef SegmentationModuleType::OutputImageType      OutputImageType;

  typedef itk::ImageFileReader< FeatureImageType >     FeatureReaderType;
  typedef itk::ImageFileWriter< OutputImageType >      OutputWriterType;

  typedef itk::LandmarksReader< Dimension >    LandmarksReaderType;
  
  LandmarksReaderType::Pointer landmarksReader = LandmarksReaderType::New();

  landmarksReader->SetFileName( argv[1] );
  landmarksReader->Update();


  FeatureReaderType::Pointer featureReader = FeatureReaderType::New();
  featureReader->SetFileName( argv[2] );
  try 
    {
    featureReader->Update();
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }


  SegmentationModuleType::Pointer  segmentationModule = SegmentationModuleType::New();
  
  typedef SegmentationModuleType::InputSpatialObjectType          InputSpatialObjectType;
  typedef SegmentationModuleType::FeatureSpatialObjectType        FeatureSpatialObjectType;
  typedef SegmentationModuleType::OutputSpatialObjectType         OutputSpatialObjectType;

  InputSpatialObjectType::Pointer inputObject = InputSpatialObjectType::New();
  FeatureSpatialObjectType::Pointer featureObject = FeatureSpatialObjectType::New();

  FeatureImageType::Pointer featureImage = featureReader->GetOutput();
  featureImage->DisconnectPipeline();
  featureImage->Print( std::cout );
  featureObject->SetImage( featureImage );

  segmentationModule->SetFeature( featureObject );
  segmentationModule->SetInput( landmarksReader->GetOutput() );

  const double stoppingTime = (argc > 4) ? atof( argv[4] ) : 10.0;
  const double distanceFromSeeds = (argc > 5) ? atof( argv[5] ) : 5.0;

  segmentationModule->SetStoppingValue( stoppingTime );
  segmentationModule->SetDistanceFromSeeds( distanceFromSeeds );
  segmentationModule->Update();

  typedef SegmentationModuleType::SpatialObjectType    SpatialObjectType;
  SpatialObjectType::ConstPointer segmentation = segmentationModule->GetOutput();

  OutputSpatialObjectType::ConstPointer outputObject = 
    dynamic_cast< const OutputSpatialObjectType * >( segmentation.GetPointer() );
  OutputImageType::ConstPointer outputImage = outputObject->GetImage();
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

  segmentationModule->Print( std::cout );
  

  //
  // Exercise Set/Get methods
  //
  segmentationModule->SetStoppingValue( 0.0 );
  segmentationModule->SetDistanceFromSeeds( 0.0 );

  if( segmentationModule->GetStoppingValue() != 0.0 )
    {
    std::cerr << "Error in Set/GetStoppingValue() " << std::endl;
    return EXIT_FAILURE;
    }
  
  if( segmentationModule->GetDistanceFromSeeds() != 0.0 )
    {
    std::cerr << "Error in Set/GetDistanceFromSeeds() " << std::endl;
    return EXIT_FAILURE;
    }
  
  segmentationModule->SetStoppingValue( stoppingTime );
  segmentationModule->SetDistanceFromSeeds( distanceFromSeeds );

  if( segmentationModule->GetStoppingValue() != stoppingTime )
    {
    std::cerr << "Error in Set/GetStoppingValue() " << std::endl;
    return EXIT_FAILURE;
    }
  
  if( segmentationModule->GetDistanceFromSeeds() != distanceFromSeeds )
    {
    std::cerr << "Error in Set/GetDistanceFromSeeds() " << std::endl;
    return EXIT_FAILURE;
    }
 
  return EXIT_SUCCESS;
}
