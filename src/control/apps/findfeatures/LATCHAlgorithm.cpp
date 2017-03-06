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

#include "LATCHAlgorithm.h"
#include <QVariant>

namespace Isis {


  /**
   * Constructs the algorithm with default variables.
   */
  LATCHAlgorithm::LATCHAlgorithm() : 
                 Feature2DAlgorithm("LATCH", "Feature2D",
                                    LATCHType::create()) {  

    setupParameters();
  }


  /**
   * Constructs the algorithm with the input variables
   * 
   * @param cvars  The variables and values the algorithm will use.
   *               Variables that are not included will be set to their default.
   * @param config The config string used to construct cvars.
   */
  LATCHAlgorithm::LATCHAlgorithm(const PvlFlatMap &cvars, const QString &config) : 
                  Feature2DAlgorithm("LATCH", "Feature2D", 
                                     LATCHType::create(), cvars) {
    setConfig(config);    
    PvlFlatMap variables = setupParameters();
    variables.merge(cvars);
    const int bytes = toInt(variables.get("Bytes"));
    const bool rotationInvariance = toBool(variables.get("RotationInvariance"));
    const int halfSSDSize = toInt(variables.get("HalfSSDSize"));

    m_algorithm = LATCHType::create(bytes, rotationInvariance, halfSSDSize);

    m_variables.merge(variables);
  }


  /**
   * Destroys the algorithm
   */
  LATCHAlgorithm::~LATCHAlgorithm() { }


  /**
   * Sets up the algorithm parameters with default values. 
   * 
   * @return PvlFlatMap Algorithm parameters and their default values. 
   */
  PvlFlatMap LATCHAlgorithm::setupParameters() {
    PvlFlatMap variables;
    variables.add("Bytes",              "32");
    variables.add("RotationInvariance", "true");
    variables.add("HalfSSDSize",        "3");
    m_variables.merge(variables);
    return (m_variables);
  }


  /**
   * Returns a description of the algorithm.
   * 
   * @return @b QString A description of the algorithm.
   */
  QString LATCHAlgorithm::description() const {
    QString desc = "The OpenCV LATCH Feature2D detector/extractor algorithm."
                   " See the documentation at "
     "http://docs.opencv.org/3.1.0/d6/d36/classcv_1_1xfeatures2d_1_1LATCH.html";
    return (desc);
  }


  /**
   * Creates an instance of the algorithm.
   * 
   * @param cvars  The variables and values the algorithm will use.
   *               Variables that are not included will be set to their default.
   * @param config The config string used to construct cvars.
   */
  Feature2DAlgorithm *LATCHAlgorithm::create(const PvlFlatMap &vars, const QString &config) {
    return ( new LATCHAlgorithm(vars, config) );
  }


  /**
   * Returns true if the algorithm has a detector. 
   *  
   * @return @b true if the algorithm has a detector. 
   */
  bool LATCHAlgorithm::hasDetector() const { 
    return false; 
  }


  /**
   * Returns true if the algorithm has an extractor. 
   *  
   * @return @b true if the algorithm has an extractor. 
   */
  bool LATCHAlgorithm::hasExtractor() const { 
    return true; 
  }


  /**
   * Returns true if the algorithm has a matcher. 
   *  
   * @return @b true if the algorithm has a matcher. 
   */
  bool LATCHAlgorithm::hasMatcher() const { 
    return false; 
  }


  /**
   * Returns the variables and their values used by the algorithm.
   * 
   * @return @b PvlFlatMap The variables and their values as keyword, value pairs.
   */
  PvlFlatMap LATCHAlgorithm::getAlgorithmVariables( ) const {
    return (variables());
  }


/**
 * @brief Set parameters as provided by the variables
 * 
 * @param variables Container of parameters to set
 * 
 * @return @b int Always -1, variables cannot be set after initialization.
 * 
 * @throws IException::Programmer "LATCHAlgorithm does not have the ability
 *                                 to set algorithm parameters."
 */
  int LATCHAlgorithm::setAlgorithmVariables(const PvlFlatMap &variables) {
    QString msg = "LATCHAlgorithm does not have the ability to set algorithm parameters.";
    throw IException(IException::Programmer, msg, _FILEINFO_);

    return (-1);
  }

};  // namespace Isis
