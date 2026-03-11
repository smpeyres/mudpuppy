//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoupledScalarDirichletBC.h"

registerMooseObject("mudpuppyApp", CoupledScalarDirichletBC);

InputParameters
CoupledScalarDirichletBC::validParams()
{
  InputParameters params = ADNodalBC::validParams();
  params.addRequiredCoupledVar("coupled_scalar", "The scalar variable whose value is imposed.");
  params.addClassDescription(
      "Sets a field variable equal to a coupled scalar variable on a boundary. "
      "Useful for coupling a spatially-resolved species to a well-mixed bulk concentration.");
  return params;
}

CoupledScalarDirichletBC::CoupledScalarDirichletBC(const InputParameters & parameters)
  : ADNodalBC(parameters), _scalar_val(adCoupledScalarValue("coupled_scalar"))
{
}

ADReal
CoupledScalarDirichletBC::computeQpResidual()
{
  return _u - _scalar_val[0];
}
