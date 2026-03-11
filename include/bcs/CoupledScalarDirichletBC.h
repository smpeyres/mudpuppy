//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADNodalBC.h"

/**
 * Dirichlet boundary condition that sets a field variable equal to
 * a coupled scalar variable value on a specified boundary.
 *
 * Intended for coupling a spatially-resolved field variable to a
 * well-mixed bulk scalar variable, e.g. C(x=delta, t) = C_bulk(t).
 */
class CoupledScalarDirichletBC : public ADNodalBC
{
public:
  static InputParameters validParams();

  CoupledScalarDirichletBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Value of the coupled scalar variable
  const ADVariableValue & _scalar_val;
};
