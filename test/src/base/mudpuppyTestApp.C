//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "mudpuppyTestApp.h"
#include "mudpuppyApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
mudpuppyTestApp::validParams()
{
  InputParameters params = mudpuppyApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

mudpuppyTestApp::mudpuppyTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  mudpuppyTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

mudpuppyTestApp::~mudpuppyTestApp() {}

void
mudpuppyTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  mudpuppyApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"mudpuppyTestApp"});
    Registry::registerActionsTo(af, {"mudpuppyTestApp"});
  }
}

void
mudpuppyTestApp::registerApps()
{
  registerApp(mudpuppyApp);
  registerApp(mudpuppyTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
mudpuppyTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  mudpuppyTestApp::registerAll(f, af, s);
}
extern "C" void
mudpuppyTestApp__registerApps()
{
  mudpuppyTestApp::registerApps();
}
