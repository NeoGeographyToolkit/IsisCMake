/**
 * @file
 * $Revision: 7311 $ 
 * $Date: 2016-12-26 22:19:31 -0700 (Mon, 26 Dec 2016) $ 
 *
 *   Unless noted otherwise, the portions of Isis written by the USGS are public
 *   domain. See individual third-party library and package descriptions for
 *   intellectual property information,user agreements, and related information.
 *
 *   Although Isis has been used by the USGS, no warranty, expressed or implied,
 *   is made by the USGS as to the accuracy and functioning of such software
 *   and related material nor shall the fact of distribution constitute any such
 *   warranty, and no responsibility is assumed by the USGS in connection
 *   therewith.
 *
 *   For additional information, launch
 *   $ISISROOT/doc//documents/Disclaimers/Disclaimers.html in a browser or see
 *   the Privacy &amp; Disclaimers page on the Isis website,
 *   http://isis.astrogeology.usgs.gov, and the USGS privacy and disclaimers on
 *   http://www.usgs.gov/privacy.html.
 */

#include <boost/foreach.hpp>
#include "opencv2/opencv.hpp"
#include "opencv2/xfeatures2d.hpp"

#include "SIFTAlgorithm.h"
#include <QVariant>

namespace Isis {

  /**
   * Constructs an empty SiftAlgorithm with default variables. 
   */
  SIFTAlgorithm::SIFTAlgorithm() : 
                 Feature2DAlgorithm( "SIFT", "Feature2D",
                                      SIFTType::create() ) {  
    setupParameters();
  }


  /**
   * Constructs a SIFTAlgorithm with input variables. 
   *  
   * @param cvars Variables that are not included will be set to their default.
   * @param config The config string used to construct cvars.
   */
  SIFTAlgorithm::SIFTAlgorithm(const PvlFlatMap &cvars, const QString &config) : 
                 Feature2DAlgorithm("SIFT", "Feature2D", 
                                     SIFTType::create(), cvars) {
    setConfig(config);
    PvlFlatMap variables = setupParameters();
    variables.merge(cvars);
    const int nfeatures = toInt(variables.get("nfeatures"));
    const int nOctaveLayers = toInt(variables.get("nOctaveLayers"));
    const double contrastThreshold = toDouble(variables.get("constrastThreshold"));
    const double edgeThreshold = toDouble(variables.get("edgeThreshold"));
    const double sigma = toDouble(variables.get("sigma"));

    m_algorithm = SIFTType::create(nfeatures, nOctaveLayers, contrastThreshold, 
                                   edgeThreshold, sigma);

    m_variables.merge(variables);
  }


  /**
   * Destroys the algorithm
   */
  SIFTAlgorithm::~SIFTAlgorithm() { }


  /**
   * Sets up the algorithm parameters with default values. 
   * 
   * @return PvlFlatMap Algorithm parameters and their default values. 
   */
  PvlFlatMap SIFTAlgorithm::setupParameters() {
    PvlFlatMap variables;
    variables.add("nfeatures",          "0");
    variables.add("nOctaveLayers",      "3");
    variables.add("constrastThreshold", "0.04");
    variables.add("edgeThreshold",      "10");
    variables.add("sigma",              "1.6");
    m_variables = variables;
    return (m_variables);
  }


  /**
   * Returns a description of the algorithm.
   * 
   * @return @b QString A description of the algorithm.
   */
  QString SIFTAlgorithm::description() const {
    QString desc = "The OpenCV SIFT Feature2D detector/extractor algorithm."
                   " See the documentation at "
     "http://docs.opencv.org/3.1.0/d5/d3c/classcv_1_1xfeatures2d_1_1SIFT.html";
    return (desc);
  }


  /**
   * Creates and returns an intance of SIFTAlgorithm.
   *  
   * @param vars PvlFlatMap containing algorithm parameters and their values
   * @param config A configuration string input by the user
   * 
   * @return @b Feature2DAlgorithm An instance of SIFTAlgorithm
   */
  Feature2DAlgorithm *SIFTAlgorithm::create(const PvlFlatMap &vars, const QString &config) {
    return ( new SIFTAlgorithm(vars, config) );
  }



  /**
   * Returns true if the algorithm has a detector. 
   *  
   * @return @b true if the algorithm has a detector. 
   */
  bool SIFTAlgorithm::hasDetector() const { 
    return true; 
  }


  /**
   * Returns true if the algorithm has an extractor. 
   *  
   * @return @b true if the algorithm has an extractor. 
   */
  bool SIFTAlgorithm::hasExtractor() const { 
    return true; 
  }


  /**
   * Returns true if the algorithm has a matcher. 
   *  
   * @return @b true if the algorithm has a matcher. 
   */
  bool SIFTAlgorithm::hasMatcher() const { 
    return false; 
  }


/**
 * Get and return SIFT's parameters and what they're set to as a PvlFlatMap.
 *  
 * @return @b PvlFlatMap A PvlFlatMap of SIFT's currently set variables and their values. 
 */
  PvlFlatMap SIFTAlgorithm::getAlgorithmVariables( ) const {
    return ( variables() );
  }


/**
 * @brief Set parameters as provided by the variables, does not work for the 
 * SIFT algorithm in OpenCV3, so calling this will throw an exception. 
 * Always returns -1. 
 * 
 * @param variables Container of parameters to set
 *  
 * @throws IException::Programmer "SIFT does not have the ability to set algorithm parameters.";
 *  
 * @return @b int -1 Cannot set the Algorithm Variables
 */
  int SIFTAlgorithm::setAlgorithmVariables(const PvlFlatMap &variables) {
    QString message = "SIFT does not have the ability to set algorithm parameters.";
    throw IException(IException::Programmer, message, _FILEINFO_);   

    return (-1);
  }

};  // namespace Isis

