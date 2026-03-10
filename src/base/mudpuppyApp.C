#include "mudpuppyApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
mudpuppyApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

mudpuppyApp::mudpuppyApp(const InputParameters & parameters) : MooseApp(parameters)
{
  mudpuppyApp::registerAll(_factory, _action_factory, _syntax);
}

mudpuppyApp::~mudpuppyApp() {}

void
mudpuppyApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<mudpuppyApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"mudpuppyApp"});
  Registry::registerActionsTo(af, {"mudpuppyApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
mudpuppyApp::registerApps()
{
  registerApp(mudpuppyApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
mudpuppyApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  mudpuppyApp::registerAll(f, af, s);
}
extern "C" void
mudpuppyApp__registerApps()
{
  mudpuppyApp::registerApps();
}
