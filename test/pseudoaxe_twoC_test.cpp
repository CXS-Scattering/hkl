#include "pseudoaxe_twoC_test.h"
#include <fstream>

CPPUNIT_TEST_SUITE_REGISTRATION( PseudoAxe_TwoC_Vertical_Test );

void
PseudoAxe_TwoC_Vertical_Test::setUp(void)
{ 
    m_geometry_TwoC.get_source().setWaveLength(1.54);

    m_geometry_TwoC.get_axe("omega").set_value(45. * constant::math::degToRad);
    m_geometry_TwoC.get_axe("2theta").set_value(34. * constant::math::degToRad);  
}

void 
PseudoAxe_TwoC_Vertical_Test::tearDown(void)
{}

void 
PseudoAxe_TwoC_Vertical_Test::Th2th(void)
{
    hkl::pseudoAxe::twoC::vertical::Th2th pseudoAxe;

    // exception if now initialize
    CPPUNIT_ASSERT_THROW(pseudoAxe.get_value(m_geometry_TwoC), HKLException);
    CPPUNIT_ASSERT_THROW(pseudoAxe.set_value(m_geometry_TwoC, 1), HKLException);

    pseudoAxe.initialize(m_geometry_TwoC);

    // no more exception after initialization
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.get_value(m_geometry_TwoC));
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.set_value(m_geometry_TwoC, 1. * constant::math::degToRad));

    //set_value
    pseudoAxe.set_value(m_geometry_TwoC, 34. * constant::math::degToRad);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(45 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("omega").get_value(),
                                 constant::math::epsilon_0);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(34 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("2theta").get_value(),
                                 constant::math::epsilon_0);
    //get_value
    CPPUNIT_ASSERT_DOUBLES_EQUAL(34. * constant::math::degToRad, pseudoAxe.get_value(m_geometry_TwoC), constant::math::epsilon_0);


    //set_value
    pseudoAxe.set_value(m_geometry_TwoC, 36. * constant::math::degToRad);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(46 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("omega").get_value(),
                                 constant::math::epsilon_0);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(36 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("2theta").get_value(),
                                 constant::math::epsilon_0);
}

void 
PseudoAxe_TwoC_Vertical_Test::Q2th(void)
{
    hkl::pseudoAxe::twoC::vertical::Q2th pseudoAxe;

    // exception if now initialize
    CPPUNIT_ASSERT_THROW(pseudoAxe.get_value(m_geometry_TwoC), HKLException);
    CPPUNIT_ASSERT_THROW(pseudoAxe.set_value(m_geometry_TwoC, 1), HKLException);

    pseudoAxe.initialize(m_geometry_TwoC);

    // no more exception after initialization
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.get_value(m_geometry_TwoC));
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.set_value(m_geometry_TwoC, 1. * constant::math::degToRad));

    //set_value
    double lambda = m_geometry_TwoC.get_source().get_waveLength();
    double theta = 34 / 2;
    double value = 2 * constant::physic::tau * sin(theta * constant::math::degToRad) / lambda;
    pseudoAxe.set_value(m_geometry_TwoC, value);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(45 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("omega").get_value(),
                                 constant::math::epsilon_0);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(34 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("2theta").get_value(),
                                 constant::math::epsilon_0);
    //get_value
    CPPUNIT_ASSERT_DOUBLES_EQUAL(value, pseudoAxe.get_value(m_geometry_TwoC), constant::math::epsilon_0);


    //set_value
    theta = 36 / 2;
    value = 2 * constant::physic::tau * sin(theta* constant::math::degToRad) / lambda;
    pseudoAxe.set_value(m_geometry_TwoC, value);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(46 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("omega").get_value(),
                                 constant::math::epsilon_0);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(36 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("2theta").get_value(),
                                 constant::math::epsilon_0);
}

void 
PseudoAxe_TwoC_Vertical_Test::Q(void)
{
    hkl::pseudoAxe::twoC::vertical::Q pseudoAxe;

    // no exception if now initialize this pseudoAxe is always valid.
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.get_value(m_geometry_TwoC));
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.set_value(m_geometry_TwoC, 1));

    pseudoAxe.initialize(m_geometry_TwoC);

    // no more exception after initialization
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.get_value(m_geometry_TwoC));
    CPPUNIT_ASSERT_NO_THROW(pseudoAxe.set_value(m_geometry_TwoC, 1. * constant::math::degToRad));

    m_geometry_TwoC.setAngles(45 * constant::math::degToRad, 34 * constant::math::degToRad);
    //set_value
    double lambda = m_geometry_TwoC.get_source().get_waveLength();
    double theta = 34 / 2 * constant::math::degToRad;
    double value = 2 * constant::physic::tau * sin(theta) / lambda;
    pseudoAxe.set_value(m_geometry_TwoC, value);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(45 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("omega").get_value(),
                                 constant::math::epsilon_0);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(34 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("2theta").get_value(),
                                 constant::math::epsilon_0);
    //get_value
    CPPUNIT_ASSERT_DOUBLES_EQUAL(value, pseudoAxe.get_value(m_geometry_TwoC), constant::math::epsilon_0);


    //set_value
    theta = 36 / 2;
    value = 2 * constant::physic::tau * sin(theta* constant::math::degToRad) / lambda;
    pseudoAxe.set_value(m_geometry_TwoC, value);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(45 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("omega").get_value(),
                                 constant::math::epsilon_0);
    CPPUNIT_ASSERT_DOUBLES_EQUAL(36 * constant::math::degToRad,
                                 m_geometry_TwoC.get_axe("2theta").get_value(),
                                 constant::math::epsilon_0);
}

void
PseudoAxe_TwoC_Vertical_Test::persistanceIO(void)
{
    hkl::pseudoAxe::twoC::vertical::Th2th th2th_ref, th2th;
    stringstream flux;

    th2th_ref.toStream(flux);

    th2th.fromStream(flux);

    CPPUNIT_ASSERT_EQUAL(th2th_ref, th2th);
}