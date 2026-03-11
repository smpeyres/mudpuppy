//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SideDiffusiveFluxIntegralLin.h"

registerMooseObject("mudpuppyApp", SideDiffusiveFluxIntegralLin);

InputParameters
SideDiffusiveFluxIntegralLin::validParams()
{
  InputParameters params = SideIntegralVariablePostprocessor::validParams();
  params.addClassDescription(
      "Computes the boundary integral of the diffusive flux: -D * grad(u) . n. "
      "The diffusivity is obtained from an AD material property on the adjacent element. "
      "By default, the property name is 'diff' + variable_name (Zapdos convention).");
  params.addParam<MaterialPropertyName>("diffusivity",
                                        "",
                                        "Name of the AD diffusivity material property. "
                                        "If not provided, defaults to 'diff' + variable_name.");
  return params;
}

SideDiffusiveFluxIntegralLin::SideDiffusiveFluxIntegralLin(const InputParameters & parameters)
  : SideIntegralVariablePostprocessor(parameters),
    _diffusivity(getADMaterialProperty<Real>(
        isParamValid("diffusivity") && !getParam<MaterialPropertyName>("diffusivity").empty()
            ? std::string(getParam<MaterialPropertyName>("diffusivity"))
            : "diff" + _var->name()))
{
}

Real
SideDiffusiveFluxIntegralLin::computeQpIntegral()
{
  return -MetaPhysicL::raw_value(_diffusivity[_qp]) * _grad_u[_qp] * _normals[_qp];
}
