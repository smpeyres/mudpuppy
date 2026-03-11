//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PostprocessorBulkScalarKernel.h"

registerMooseObject("mudpuppyApp", PostprocessorBulkScalarKernel);

InputParameters
PostprocessorBulkScalarKernel::validParams()
{
  InputParameters params = ScalarKernel::validParams();
  params.addClassDescription(
      "Adds a postprocessor value as a source/sink to a scalar variable ODE. "
      "The residual contribution is simply the postprocessor value. "
      "Use ScalePostprocessor to apply any needed prefactors before passing to this kernel.");
  params.addRequiredParam<PostprocessorName>("postprocessor",
                                             "The postprocessor whose value is added "
                                             "to the scalar variable residual.");
  return params;
}

PostprocessorBulkScalarKernel::PostprocessorBulkScalarKernel(const InputParameters & parameters)
  : ScalarKernel(parameters), _pp_value(getPostprocessorValue("postprocessor"))
{
}

void
PostprocessorBulkScalarKernel::reinit()
{
}

Real
PostprocessorBulkScalarKernel::computeQpResidual()
{
  return _pp_value;
}

Real
PostprocessorBulkScalarKernel::computeQpJacobian()
{
  return 0;
}
